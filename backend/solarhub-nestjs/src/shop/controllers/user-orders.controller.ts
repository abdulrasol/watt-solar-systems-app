import {
  Controller,
  Get,
  Post,
  Put,
  Param,
  Body,
  UseGuards,
  Request,
} from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { OrdersService } from '../services/orders.service';
import { OrderFormDto } from '../dto/orders.dto';
import { AuthGuard } from '@nestjs/passport';

@ApiTags('User Purchases (B2C & B2B)')
@ApiBearerAuth()
@Controller('shop/my-orders')
@UseGuards(AuthGuard('jwt'))
export class UserOrdersController {
  constructor(private readonly ordersService: OrdersService) {}

  @Get('b2c')
  async getB2cOrders(@Request() req) {
    return this.ordersService.findMyOrders(req.user.id, 'b2c');
  }

  @Post('b2c/checkout')
  async checkoutB2c(@Request() req, @Body() data: OrderFormDto) {
    return this.ordersService.checkout(req.user.id, 'b2c', data);
  }

  @Get('b2b')
  async getB2bOrders(@Request() req) {
    return this.ordersService.findMyOrders(req.user.id, 'b2b');
  }

  @Post('b2b/checkout')
  async checkoutB2b(@Request() req, @Body() data: OrderFormDto) {
    return this.ordersService.checkout(req.user.id, 'b2b', data);
  }

  @Get('b2c/:id')
  async getB2cOrderById(@Request() req, @Param('id') id: string) {
    return this.ordersService.findMyOrderById(req.user.id, Number(id), 'b2c');
  }

  @Put('b2c/:id/cancel')
  async cancelB2cOrder(@Request() req, @Param('id') id: string) {
    return this.ordersService.cancelOrder(req.user.id, Number(id), 'b2c');
  }

  @Get('b2b/:id')
  async getB2bOrderById(@Request() req, @Param('id') id: string) {
    return this.ordersService.findMyOrderById(req.user.id, Number(id), 'b2b');
  }

  @Put('b2b/:id/cancel')
  async cancelB2bOrder(@Request() req, @Param('id') id: string) {
    return this.ordersService.cancelOrder(req.user.id, Number(id), 'b2b');
  }

  @Put('b2b/:id/confirm-receipt')
  async confirmB2bReceipt(@Request() req, @Param('id') id: string) {
    return this.ordersService.confirmReceipt(req.user.id, Number(id));
  }
}
