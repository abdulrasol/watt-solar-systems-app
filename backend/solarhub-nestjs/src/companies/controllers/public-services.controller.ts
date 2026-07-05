import { Controller, Get, Post, Put, Delete, Body, Param, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { CompaniesService } from '../companies.service';
import { PublicServiceCreateDto, PublicServiceUpdateDto } from '../dto/works-contacts.dto';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';

@ApiTags('Company Public Services')
@Controller('companies/:company_id/public-services')
export class CompanyPublicServicesController {
  constructor(private readonly companiesService: CompaniesService) {}

  @Get()
  async listPublicServices(@Param('company_id') companyId: string) {
    return this.companiesService.listPublicServices(Number(companyId));
  }

  @Post()
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  async createPublicService(
    @Param('company_id') companyId: string,
    @Body() data: PublicServiceCreateDto
  ) {
    return this.companiesService.createPublicService(Number(companyId), data);
  }

  @Put(':id')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  async updatePublicService(
    @Param('company_id') companyId: string,
    @Param('id') id: string,
    @Body() data: PublicServiceUpdateDto
  ) {
    return this.companiesService.updatePublicService(Number(companyId), Number(id), data);
  }

  @Delete(':id')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  async deletePublicService(
    @Param('company_id') companyId: string,
    @Param('id') id: string
  ) {
    return this.companiesService.deletePublicService(Number(companyId), Number(id));
  }
}
