import { Global, Module } from '@nestjs/common';
import { FirebaseService } from './firebase.service';
import { NotifierService } from './notifier.service';
import { NotificationsService } from './notifications.service';
import { PrismaModule } from '../prisma/prisma.module';
import { AdminNotificationController } from './controllers/admin-notification.controller';
import { DeviceController } from './controllers/device.controller';
import { HistoryController } from './controllers/history.controller';

/**
 * Global Notifications Module
 * Provides:
 * - NotificationsService: Legacy service for device management, FCM, and history
 * - FirebaseService: Firebase Admin SDK wrapper (new)
 * - NotifierService: Centralized notification dispatcher with i18n (new)
 */
@Global()
@Module({
  imports: [PrismaModule],
  providers: [FirebaseService, NotifierService, NotificationsService],
  controllers: [AdminNotificationController, DeviceController, HistoryController],
  exports: [FirebaseService, NotifierService, NotificationsService],
})
export class NotificationsModule {}
