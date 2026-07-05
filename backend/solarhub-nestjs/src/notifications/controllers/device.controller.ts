import { Controller, Get, Post, Body, Param, UseGuards, Request, UnauthorizedException, NotFoundException } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { NotificationsService } from '../notifications.service';
import { SubscribeDto } from '../dto/notification.dto';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';

@ApiTags('Notifications - Devices')
@Controller('notification')
export class DeviceController {
  constructor(private readonly notificationsService: NotificationsService) {}

  @Post('subscribe')
  async subscribe(@Request() req, @Body() data: SubscribeDto) {
    // Determine userId if authenticated, else null
    // Assuming you have a way to inject user info or we can get from req.user
    const userId = req.user?.id ?? null;
    const device = await this.notificationsService.subscribeDevice(userId, data);
    return { device_id: device.id };
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @Post('unsubscribe')
  async unsubscribe(@Request() req) {
    await this.notificationsService.unsubscribeUserDevices(req.user.id);
    return { message: 'Successfully unsubscribed from notifications' };
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @Get('devices')
  async getDevices(@Request() req) {
    const devices = await this.notificationsService.listUserDevices(req.user.id);
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
    await this.notificationsService.deactivateDevice(req.user.id, Number(token_id));
    return { message: `Device ${token_id} deactivated successfully` };
  }
}
