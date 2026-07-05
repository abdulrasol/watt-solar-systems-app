import os

controller_dir = "src/notifications/controllers"
os.makedirs(controller_dir, exist_ok=True)

controllers = {
    "device.controller.ts": """import { Controller, Get, Post, Body, Param, UseGuards, Request, UnauthorizedException, NotFoundException } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { NotificationsService } from '../notifications.service';
import { SubscribeDto } from '../dto/notification.dto';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { OptionalJwtAuthGuard } from '../../auth/guards/optional-jwt-auth.guard'; // I'll assume we might need this or just extract from req

@ApiTags('Notifications - Devices')
@Controller()
export class DeviceController {
  constructor(private readonly notificationsService: NotificationsService) {}

  @Post('subscribe')
  async subscribe(@Request() req, @Body() data: SubscribeDto) {
    // Determine userId if authenticated, else null
    // Assuming you have a way to inject user info or we can get from req.user
    const userId = req.user?.sub ?? null;
    const device = await this.notificationsService.subscribeDevice(userId, data);
    return { device_id: device.id };
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @Post('unsubscribe')
  async unsubscribe(@Request() req) {
    await this.notificationsService.unsubscribeUserDevices(req.user.sub);
    return { message: 'Successfully unsubscribed from notifications' };
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @Get('devices')
  async getDevices(@Request() req) {
    const devices = await this.notificationsService.listUserDevices(req.user.sub);
    return {
      devices: devices.map(d => ({
        id: d.id,
        user_id: d.user_id,
        platform: d.type,
        device_id: d.device_id,
        name: d.name,
        is_active: d.active,
        created_at: d.date_created,
      })),
      count: devices.length
    };
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @Post('tokens/:token_id/deactivate')
  async deactivateDevice(@Request() req, @Param('token_id') token_id: number) {
    await this.notificationsService.deactivateDevice(req.user.sub, Number(token_id));
    return { message: `Device ${token_id} deactivated successfully` };
  }
}
""",

    "history.controller.ts": """import { Controller, Get, Query, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { NotificationsService } from '../notifications.service';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';

@ApiTags('Notifications - History')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('history')
export class HistoryController {
  constructor(private readonly notificationsService: NotificationsService) {}

  @ApiQuery({ name: 'page', required: false })
  @ApiQuery({ name: 'page_size', required: false })
  @Get()
  async getHistory(@Request() req, @Query('page') page: string = '1', @Query('page_size') page_size: string = '20') {
    const p = Math.max(Number(page) || 1, 1);
    const size = Math.min(Math.max(Number(page_size) || 20, 1), 100);
    const skip = (p - 1) * size;

    const { notifications, total } = await this.notificationsService.listUserNotifications(req.user.sub, skip, size);
    
    return {
      notifications: notifications.map(n => ({
        id: n.id,
        title: n.title,
        body: n.body,
        data: n.data ? JSON.parse(n.data) : {},
        type: n.type,
        status: n.status,
        created_at: n.created_at,
        sent_at: n.sent_at,
      })),
      count: total,
      pagination: {
        page: p,
        page_size: size,
        total_items: total,
        total_pages: Math.max(Math.ceil(total / size), 1),
        has_next: skip + size < total,
        has_previous: p > 1,
      }
    };
  }
}
""",

    "admin-notification.controller.ts": """import { Controller, Get, Post, Body, Param, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { NotificationsService } from '../notifications.service';
import { BroadcastDto, GroupNotificationDto, UserNotificationDto } from '../dto/notification.dto';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { SuperuserGuard } from '../../auth/guards/superuser.guard';

@ApiTags('Notifications - Admin')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, SuperuserGuard)
@Controller()
export class AdminNotificationController {
  constructor(private readonly notificationsService: NotificationsService) {}

  @Post('send-broadcast')
  async sendBroadcast(@Body() data: BroadcastDto) {
    const result = await this.notificationsService.sendBroadcastNotification(data.title, data.body, data.data);
    return {
      success_count: result.success,
      failure_count: result.failure
    };
  }

  @Post('send-group')
  async sendGroup(@Body() data: GroupNotificationDto) {
    const result = await this.notificationsService.sendGroupNotification(data.group_type, data.group_id, data.title, data.body, data.data);
    return {
      success_count: result.success,
      failure_count: result.failure,
      group_type: data.group_type,
      group_id: data.group_id
    };
  }

  @Post('send-user')
  async sendUser(@Body() data: UserNotificationDto) {
    const result = await this.notificationsService.sendUserNotification(data.user_id, data.title, data.body, data.data);
    return {
      success_count: result.success,
      failure_count: result.failure,
      user_id: data.user_id
    };
  }

  @Post('send-topic/:topic')
  async sendTopic(@Param('topic') topic: string, @Body() data: BroadcastDto) {
    const result = await this.notificationsService.sendTopicNotification(topic, data.title, data.body, data.data);
    return {
      success_count: result.success,
      topic: topic
    };
  }

  @Get('statistics')
  async getStatistics() {
    return this.notificationsService.getStatistics();
  }
}
"""
}

for filename, content in controllers.items():
    with open(os.path.join(controller_dir, filename), "w") as f:
        f.write(content)

print("Notification controllers generated successfully.")
