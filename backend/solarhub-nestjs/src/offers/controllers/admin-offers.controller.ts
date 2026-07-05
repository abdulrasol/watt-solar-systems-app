import { Controller, Get, Query, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { PrismaService } from '../../prisma/prisma.service';
import { AuthGuard } from '@nestjs/passport';

@ApiTags('Admin Offers')
@ApiBearerAuth()
@Controller('offers/admin')
@UseGuards(AuthGuard('jwt'))
export class AdminOffersController {
  constructor(private readonly prisma: PrismaService) {}

  @Get('offers')
  async adminListOffers(@Request() req, @Query('status') status?: string, @Query('page') page = 1, @Query('page_size') pageSize = 10) {
    // Only superuser
    if (!req.user.isSuperuser) {
      return { status: 403, message: 'Forbidden', body: {}, error: true, message_user: 'Not a superuser' };
    }

    const where: any = {};
    if (status) where.status = status;

    const [items, total] = await Promise.all([
      this.prisma.offer.findMany({
        where,
        orderBy: { created_at: 'desc' },
        skip: (Number(page) - 1) * Number(pageSize),
        take: Number(pageSize),
        include: { user: true, company: true },
      }),
      this.prisma.offer.count({ where }),
    ]);

    return {
      status: 200,
      message: 'Admin offers retrieved successfully',
      body: {
        items,
        count: total,
        pagination: {
          page: Number(page),
          page_size: Number(pageSize),
          total_items: total,
          total_pages: Math.max(Math.ceil(total / Number(pageSize)), 1),
          has_next: Number(page) < Math.ceil(total / Number(pageSize)),
          has_previous: Number(page) > 1,
        }
      },
      error: false,
      message_user: null,
    };
  }

  @Get('requests')
  async adminListRequests(@Request() req, @Query('status') status?: string, @Query('page') page = 1, @Query('page_size') pageSize = 10) {
    if (!req.user.isSuperuser) {
      return { status: 403, message: 'Forbidden', body: {}, error: true, message_user: 'Not a superuser' };
    }

    const where: any = {};
    if (status) where.status = status;

    const [items, total] = await Promise.all([
      this.prisma.offerRequest.findMany({
        where,
        orderBy: { created_at: 'desc' },
        skip: (Number(page) - 1) * Number(pageSize),
        take: Number(pageSize),
        include: { user: true },
      }),
      this.prisma.offerRequest.count({ where }),
    ]);

    return {
      status: 200,
      message: 'Admin requests retrieved successfully',
      body: {
        items,
        count: total,
        pagination: {
          page: Number(page),
          page_size: Number(pageSize),
          total_items: total,
          total_pages: Math.max(Math.ceil(total / Number(pageSize)), 1),
          has_next: Number(page) < Math.ceil(total / Number(pageSize)),
          has_previous: Number(page) > 1,
        }
      },
      error: false,
      message_user: null,
    };
  }
}
