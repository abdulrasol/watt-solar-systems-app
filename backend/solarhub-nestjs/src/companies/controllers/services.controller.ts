import { Controller, Get, Post, Put, Delete, Body, Param, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { CompaniesService } from '../companies.service';
import { CompanyServiceCreateDto, CompanyServiceUpdateDto } from '../dto/company.dto';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { SuperuserGuard } from '../../auth/guards/superuser.guard';

@ApiTags('Company Services')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('companies/:company_id/services')
export class CompanyServicesController {
  constructor(private readonly companiesService: CompaniesService) {}

  @Get()
  async listServices(@Request() req, @Param('company_id') companyId: string) {
    return this.companiesService.listServices(req.user.id, Number(companyId));
  }

  @Post()
  async createService(@Request() req, @Param('company_id') companyId: string, @Body() data: CompanyServiceCreateDto) {
    return this.companiesService.createService(req.user.id, Number(companyId), data);
  }

  @Put(':service_id')
  async updateService(@Request() req, @Param('company_id') companyId: string, @Param('service_id') serviceId: string, @Body() data: CompanyServiceUpdateDto) {
    return this.companiesService.updateService(req.user.id, Number(companyId), Number(serviceId), data);
  }

  @Delete(':service_id')
  async deleteService(@Request() req, @Param('company_id') companyId: string, @Param('service_id') serviceId: string) {
    return this.companiesService.deleteService(req.user.id, Number(companyId), Number(serviceId));
  }
}

@ApiTags('Company Service Catalogs')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, SuperuserGuard)
@Controller('service-catalogs')
export class CompanyServiceCatalogsController {
  constructor(private readonly companiesService: CompaniesService) {}

  @Get()
  async listCatalogs() {
    return this.companiesService.listCatalogs();
  }
}
