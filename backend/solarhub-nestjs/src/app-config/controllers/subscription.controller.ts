import { Controller, Get, Post, Put, Delete, Body, Param, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { AppConfigService } from '../app-config.service';
import { SubscriptionPlanDto } from '../dto/subscription.dto';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { SuperuserGuard } from '../../auth/guards/superuser.guard';

@ApiTags('Subscriptions')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, SuperuserGuard)
@Controller('subscriptions')
export class SubscriptionController {
  constructor(private readonly configService: AppConfigService) {}

  @Get()
  async listSubscriptions() {
    return this.configService.listSubscriptions();
  }

  @Post()
  async createSubscription(@Body() data: SubscriptionPlanDto) {
    return this.configService.createSubscription(data);
  }

  @Put(':sub_id')
  async updateSubscription(@Param('sub_id') sub_id: number, @Body() data: SubscriptionPlanDto) {
    return this.configService.updateSubscription(Number(sub_id), data);
  }

  @Delete(':sub_id')
  async deleteSubscription(@Param('sub_id') sub_id: number) {
    return this.configService.deleteSubscription(Number(sub_id));
  }
}
