import { Controller, Get, Post, Put, Delete, Body, Param, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { CompaniesService } from '../companies.service';
import { DeliveryOptionCreateDto, DeliveryOptionUpdateDto } from '../dto/works-contacts.dto';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';

@ApiTags('Company Delivery Options')
@Controller('companies/:company_id/delivery')
export class CompanyDeliveryOptionsController {
  constructor(private readonly companiesService: CompaniesService) {}

  @Get()
  async listDeliveryOptions(@Param('company_id') companyId: string) {
    return this.companiesService.listDeliveryOptions(Number(companyId));
  }

  @Post()
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  async createDeliveryOption(
    @Param('company_id') companyId: string,
    @Body() data: DeliveryOptionCreateDto
  ) {
    return this.companiesService.createDeliveryOption(Number(companyId), data);
  }

  @Put(':id')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  async updateDeliveryOption(
    @Param('company_id') companyId: string,
    @Param('id') id: string,
    @Body() data: DeliveryOptionUpdateDto
  ) {
    return this.companiesService.updateDeliveryOption(Number(companyId), Number(id), data);
  }

  @Delete(':id')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  async deleteDeliveryOption(
    @Param('company_id') companyId: string,
    @Param('id') id: string
  ) {
    return this.companiesService.deleteDeliveryOption(Number(companyId), Number(id));
  }
}
