import { Controller, Get, Post, Body, Param, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { NotificationsService } from '../notifications.service';
import { BroadcastDto, GroupNotificationDto, UserNotificationDto } from '../dto/notification.dto';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { SuperuserGuard } from '../../auth/guards/superuser.guard';

@ApiTags('Notifications - Admin')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, SuperuserGuard)
@Controller('notification')
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
