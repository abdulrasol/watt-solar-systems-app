import { Controller, Get, Post, Put, Delete, Body, Param, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { CompaniesService } from '../companies.service';
import { ServiceTypeCreateDto, ServiceTypeUpdateDto } from '../dto/types.dto';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { SuperuserGuard } from '../../auth/guards/superuser.guard';
import { RawResponse } from '../../common/decorators/raw-response.decorator';

@ApiTags('Service Types')
@Controller('service-types')
export class ServiceTypesController {
  constructor(private readonly companiesService: CompaniesService) {}

  @Get()
  async listServiceTypes() {
    return this.companiesService.listServiceTypes();
  }

  @Get('public')
  @RawResponse()
  async listPublicServiceTypes() {
    // Return all active or public service types if any filter needed, currently returns all
    return this.companiesService.listServiceTypes();
  }

  @Post()
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, SuperuserGuard)
  async createServiceType(@Body() data: ServiceTypeCreateDto) {
    return this.companiesService.createServiceType(data);
  }

  @Put(':id')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, SuperuserGuard)
  async updateServiceType(@Param('id') id: string, @Body() data: ServiceTypeUpdateDto) {
    return this.companiesService.updateServiceType(Number(id), data);
  }

  @Delete(':id')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, SuperuserGuard)
  async deleteServiceType(@Param('id') id: string) {
    return this.companiesService.deleteServiceType(Number(id));
  }
}
