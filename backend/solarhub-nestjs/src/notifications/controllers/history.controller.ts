import { Controller, Get, Query, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { NotificationsService } from '../notifications.service';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';

@ApiTags('Notifications - History')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('notification/history')
export class HistoryController {
  constructor(private readonly notificationsService: NotificationsService) {}

  @ApiQuery({ name: 'page', required: false })
  @ApiQuery({ name: 'page_size', required: false })
  @Get()
  async getHistory(@Request() req, @Query('page') page: string = '1', @Query('page_size') page_size: string = '20') {
    const p = Math.max(Number(page) || 1, 1);
    const size = Math.min(Math.max(Number(page_size) || 20, 1), 100);
    const skip = (p - 1) * size;

    const { notifications, total } = await this.notificationsService.listUserNotifications(req.user.id, skip, size);
    
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
