import { Controller, Get, Post, Put, Body, Param, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { CompaniesService } from '../companies.service';
import { CompanySubscriptionRequestCreateDto, CompanySubscriptionRequestReviewDto } from '../dto/company.dto';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { SuperuserGuard } from '../../auth/guards/superuser.guard';

@ApiTags('Company Subscription Requests')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller()
export class CompanySubscriptionsController {
  constructor(private readonly companiesService: CompaniesService) {}

  @Post('companies/:company_id/subscription-requests')
  async requestSubscription(@Request() req, @Param('company_id') companyId: string, @Body() data: CompanySubscriptionRequestCreateDto) {
    return this.companiesService.requestSubscription(req.user.id, Number(companyId), data);
  }

  @Get('companies/:company_id/subscription-requests')
  async listCompanySubscriptions(@Request() req, @Param('company_id') companyId: string) {
    return this.companiesService.listCompanySubscriptions(req.user.id, Number(companyId));
  }

  @UseGuards(SuperuserGuard)
  @Get('admin/subscription-requests')
  async listAllSubscriptions() {
    return this.companiesService.listAllSubscriptions();
  }

  @UseGuards(SuperuserGuard)
  @Put('admin/subscription-requests/:request_id/review')
  async reviewSubscription(@Param('request_id') requestId: string, @Body() data: CompanySubscriptionRequestReviewDto) {
    return this.companiesService.reviewSubscription(Number(requestId), data);
  }
}
