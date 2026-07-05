import { Controller, Get, Post, Put, Delete, Body, Param, Query, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { OffersService } from '../offers.service';
import { OfferRequestInDto } from '../dto/offer-request.dto';
import { OfferResponseInDto } from '../dto/offer.dto';
import { AuthGuard } from '@nestjs/passport';

@ApiTags('User Offer Requests')
@ApiBearerAuth()
@Controller('offers/requests')
@UseGuards(AuthGuard('jwt'))
export class UserOfferRequestsController {
  constructor(private readonly offersService: OffersService) {}

  @Post()
  async createRequest(@Request() req, @Body() data: OfferRequestInDto) {
    const userId = req.user.userId;
    const request = await this.offersService.createOfferRequest(userId, data);
    return {
      status: 200,
      message: 'Request created successfully',
      body: request,
      error: false,
      message_user: null,
    };
  }

  @Get()
  async listMyRequests(@Request() req, @Query('status') status?: string, @Query('page') page = 1, @Query('page_size') pageSize = 10) {
    const userId = req.user.userId;
    const result = await this.offersService.listUserRequests(userId, status, Number(page), Number(pageSize));
    return {
      status: 200,
      message: 'Requests retrieved successfully',
      body: {
        items: result.items,
        count: result.total,
        pagination: {
          page: result.page,
          page_size: result.pageSize,
          total_items: result.total,
          total_pages: Math.max(Math.ceil(result.total / result.pageSize), 1),
          has_next: result.page < Math.ceil(result.total / result.pageSize),
          has_previous: result.page > 1,
        }
      },
      error: false,
      message_user: null,
    };
  }

  @Get(':id')
  async getRequestDetail(@Request() req, @Param('id') id: string) {
    const userId = req.user.userId;
    const request = await this.offersService.getRequestDetail(userId, Number(id));
    return {
      status: 200,
      message: 'Request detail retrieved',
      body: request,
      error: false,
      message_user: null,
    };
  }

  @Put(':id')
  async updateRequest(@Request() req, @Param('id') id: string, @Body() data: OfferRequestInDto) {
    const userId = req.user.userId;
    const request = await this.offersService.updateRequest(userId, Number(id), data);
    return {
      status: 200,
      message: 'Request updated',
      body: request,
      error: false,
      message_user: null,
    };
  }

  @Delete(':id')
  async deleteRequest(@Request() req, @Param('id') id: string) {
    const userId = req.user.userId;
    await this.offersService.deleteRequest(userId, Number(id));
    return {
      status: 200,
      message: 'Request deleted',
      body: {},
      error: false,
      message_user: null,
    };
  }

  @Get(':id/offers')
  async listRequestOffers(@Request() req, @Param('id') id: string, @Query('page') page = 1, @Query('page_size') pageSize = 10) {
    const userId = req.user.userId;
    const result = await this.offersService.listRequestOffers(userId, Number(id), Number(page), Number(pageSize));
    return {
      status: 200,
      message: 'Request offers retrieved successfully',
      body: {
        items: result.items,
        count: result.total,
        pagination: {
          page: result.page,
          page_size: result.pageSize,
          total_items: result.total,
          total_pages: Math.max(Math.ceil(result.total / result.pageSize), 1),
          has_next: result.page < Math.ceil(result.total / result.pageSize),
          has_previous: result.page > 1,
        }
      },
      error: false,
      message_user: null,
    };
  }

  @Post(':id/response')
  async respondToOffer(@Request() req, @Param('id') id: string, @Body() data: OfferResponseInDto) {
    const userId = req.user.userId;
    await this.offersService.respondToOffer(userId, Number(id), data);
    return {
      status: 200,
      message: `Offer marked as ${data.state}`,
      body: {},
      error: false,
      message_user: null,
    };
  }
}
