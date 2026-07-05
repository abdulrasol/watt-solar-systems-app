import { Injectable, OnModuleInit, Logger } from '@nestjs/common';
import { initializeApp, cert, getApps, applicationDefault } from 'firebase-admin/app';
import { getMessaging, MulticastMessage, Message, SendResponse } from 'firebase-admin/messaging';
import { PrismaService } from '../prisma/prisma.service';
import { SubscribeDto } from './dto/notification.dto';
import * as fs from 'fs';
import * as path from 'path';

@Injectable()
export class NotificationsService implements OnModuleInit {
  private readonly logger = new Logger(NotificationsService.name);

  constructor(private prisma: PrismaService) {}

  onModuleInit() {
    try {
      const serviceAccountPath = path.resolve(process.cwd(), 'firebase-service-account.json');
      let cred = applicationDefault();
      
      if (fs.existsSync(serviceAccountPath)) {
        const serviceAccount = JSON.parse(fs.readFileSync(serviceAccountPath, 'utf8'));
        cred = cert(serviceAccount);
      }

      if (!getApps().length) {
        initializeApp({
          credential: cred,
        });
        this.logger.log('Firebase Admin initialized successfully');
      }
    } catch (error) {
      this.logger.error('Failed to initialize Firebase Admin', error);
    }
  }

  async subscribeDevice(userId: number | null, data: SubscribeDto) {
    const existing = await this.prisma.fCMDevice.findUnique({
      where: { registration_id: data.token }
    });

    if (existing) {
      return this.prisma.fCMDevice.update({
        where: { id: existing.id },
        data: {
          type: data.platform,
          active: true,
          user_id: userId,
          device_id: data.device_id ?? existing.device_id,
          name: data.app_version ? `App v${data.app_version}` : existing.name,
        }
      });
    }

    return this.prisma.fCMDevice.create({
      data: {
        registration_id: data.token,
        type: data.platform,
        user_id: userId,
        device_id: data.device_id,
        name: data.app_version ? `App v${data.app_version}` : null,
        active: true,
      }
    });
  }

  async unsubscribeUserDevices(userId: number) {
    return this.prisma.fCMDevice.updateMany({
      where: { user_id: userId },
      data: { active: false }
    });
  }

  async deactivateDevice(userId: number, tokenId: number) {
    return this.prisma.fCMDevice.updateMany({
      where: { id: tokenId, user_id: userId },
      data: { active: false }
    });
  }

  async listUserDevices(userId: number) {
    return this.prisma.fCMDevice.findMany({
      where: { user_id: userId }
    });
  }

  async listUserNotifications(userId: number, skip: number, take: number) {
    const [notifications, total] = await Promise.all([
      this.prisma.notificationMsg.findMany({
        where: { target_user_id: userId, status: 'sent' },
        orderBy: { created_at: 'desc' },
        skip,
        take,
      }),
      this.prisma.notificationMsg.count({
        where: { target_user_id: userId, status: 'sent' }
      })
    ]);
    return { notifications, total };
  }

  // --- Push Notification Methods (Old Notifier Logic) ---

  async sendBroadcastNotification(title: string, body: string, data: Record<string, any> = {}) {
    const devices = await this.prisma.fCMDevice.findMany({
      where: { active: true },
      select: { registration_id: true }
    });
    
    if (devices.length === 0) return { success: 0, failure: 0 };
    
    const tokens = devices.map(d => d.registration_id);
    const message: MulticastMessage = {
      notification: { title, body },
      data: this.stringifyData(data),
      tokens,
    };
    
    const response = await getMessaging().sendEachForMulticast(message);
    this.handleFailedTokens(tokens, response.responses);
    
    return { success: response.successCount, failure: response.failureCount };
  }

  async sendUserNotification(userId: number, title: string, body: string, data: Record<string, any> = {}) {
    const devices = await this.prisma.fCMDevice.findMany({
      where: { user_id: userId, active: true },
      select: { registration_id: true }
    });

    const notification = await this.prisma.notificationMsg.create({
      data: {
        title,
        body,
        data: JSON.stringify(data),
        data_extra: '',
        type: data.type || 'system',
        status: 'pending',
        target_user_id: userId,
        devices_count: devices.length,
        success_count: 0,
        failure_count: 0,
        created_at: new Date(),
      }
    });
    
    if (devices.length === 0) return { success: 0, failure: 0 };

    const tokens = devices.map(d => d.registration_id);
    const message: MulticastMessage = {
      notification: { title, body },
      data: this.stringifyData(data),
      tokens,
    };
    
    const response = await getMessaging().sendEachForMulticast(message);
    this.handleFailedTokens(tokens, response.responses);
    
    await this.prisma.notificationMsg.update({
      where: { id: notification.id },
      data: { 
        status: 'sent', 
        sent_at: new Date(),
        success_count: response.successCount,
        failure_count: response.failureCount
      }
    });
    
    return { success: response.successCount, failure: response.failureCount };
  }

  async sendGroupNotification(groupType: string, groupId: any, title: string, body: string, data: Record<string, any> = {}) {
    let userIds: number[] = [];

    if (groupType === 'company') {
      const members = await this.prisma.companyMember.findMany({
        where: { company_id: Number(groupId) },
        select: { user_id: true }
      });
      userIds = members.map(m => m.user_id);
    } else if (groupType === 'followers') {
      userIds = []; 
    } else if (groupType === 'custom' && Array.isArray(groupId)) {
      userIds = groupId.map(Number);
    }

    if (userIds.length === 0) return { success: 0, failure: 0 };

    const devices = await this.prisma.fCMDevice.findMany({
      where: { user_id: { in: userIds }, active: true },
      select: { registration_id: true }
    });
    
    const now = new Date();
    await this.prisma.notificationMsg.createMany({
      data: userIds.map(uid => ({
        title,
        body,
        data: JSON.stringify(data),
        data_extra: '',
        type: data.type || 'group',
        status: 'sent',
        target_user_id: uid,
        devices_count: 1, // Just a rough estimate per user
        success_count: 0,
        failure_count: 0,
        created_at: now,
        sent_at: now,
      }))
    });

    if (devices.length === 0) return { success: 0, failure: 0 };

    const tokens = devices.map(d => d.registration_id);
    const message: MulticastMessage = {
      notification: { title, body },
      data: this.stringifyData(data),
      tokens,
    };
    
    const response = await getMessaging().sendEachForMulticast(message);
    this.handleFailedTokens(tokens, response.responses);
    
    return { success: response.successCount, failure: response.failureCount };
  }

  async sendTopicNotification(topic: string, title: string, body: string, data: Record<string, any> = {}) {
    const message: Message = {
      notification: { title, body },
      data: this.stringifyData(data),
      topic,
    };
    
    try {
      await getMessaging().send(message);
      return { success: 1 };
    } catch (error) {
      this.logger.error(`Error sending to topic ${topic}`, error);
      return { success: 0, error: String(error) };
    }
  }

  async getStatistics() {
    const [devicesCount, notificationsCount] = await Promise.all([
      this.prisma.fCMDevice.count(),
      this.prisma.notificationMsg.count()
    ]);
    return { devices: devicesCount, notifications: notificationsCount };
  }

  // --- Helpers ---
  
  private stringifyData(data: Record<string, any>): Record<string, string> {
    const stringified: Record<string, string> = {};
    for (const [key, value] of Object.entries(data)) {
      stringified[key] = typeof value === 'object' ? JSON.stringify(value) : String(value);
    }
    return stringified;
  }

  private handleFailedTokens(tokens: string[], responses: SendResponse[]) {
    const failedTokens: string[] = [];
    responses.forEach((resp, idx) => {
      if (!resp.success) {
        const error = resp.error;
        if (error?.code === 'messaging/invalid-registration-token' ||
            error?.code === 'messaging/registration-token-not-registered') {
          failedTokens.push(tokens[idx]);
        }
      }
    });

    if (failedTokens.length > 0) {
      this.prisma.fCMDevice.updateMany({
        where: { registration_id: { in: failedTokens } },
        data: { active: false }
      }).catch(err => this.logger.error('Failed to cleanup inactive FCM tokens', err));
    }
  }
}
