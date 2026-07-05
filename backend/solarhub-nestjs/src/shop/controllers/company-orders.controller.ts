import {
  Controller,
  Get,
  Put,
  Param,
  Body,
  Headers,
  UseGuards,
  Request,
  ParseIntPipe,
} from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiHeader } from '@nestjs/swagger';
import { OrdersService } from '../services/orders.service';
import { AuthGuard } from '@nestjs/passport';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../auth/decorators/roles.decorator';

@ApiTags('Company Orders (Sales)')
@ApiBearerAuth()
@ApiHeader({ name: 'company-id', required: true })
@Controller('shop/company-orders')
@UseGuards(AuthGuard('jwt'), RolesGuard)
@Roles('admin', 'manager', 'sales')
export class CompanyOrdersController {
  constructor(private readonly ordersService: OrdersService) {}

  @Get()
  async findIncomingOrders(
    @Request() req,
    @Headers('company-id') companyId: string,
  ) {
    return this.ordersService.findCompanyIncomingOrders(
      req.user.id,
      parseInt(companyId),
    );
  }

  @Put(':id/status')
  async updateOrderStatus(
    @Request() req,
    @Headers('company-id') companyId: string,
    @Param('id', ParseIntPipe) id: number,
    @Body('status') status: string,
  ) {
    return this.ordersService.updateCompanyOrder(
      req.user.id,
      parseInt(companyId),
      id,
      status,
    );
  }
}
