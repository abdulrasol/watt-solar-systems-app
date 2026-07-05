import { Controller, Get, Post, Put, Delete, Body, Param, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { CompaniesService } from '../companies.service';
import { CompanyTypeCreateDto, CompanyTypeUpdateDto } from '../dto/types.dto';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { SuperuserGuard } from '../../auth/guards/superuser.guard';

@ApiTags('Company Types')
@Controller('company-types')
export class CompanyTypesController {
  constructor(private readonly companiesService: CompaniesService) {}

  @Get()
  async listCompanyTypes() {
    return this.companiesService.listCompanyTypes();
  }

  @Post()
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, SuperuserGuard)
  async createCompanyType(@Body() data: CompanyTypeCreateDto) {
    return this.companiesService.createCompanyType(data);
  }

  @Put(':id')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, SuperuserGuard)
  async updateCompanyType(@Param('id') id: string, @Body() data: CompanyTypeUpdateDto) {
    return this.companiesService.updateCompanyType(Number(id), data);
  }

  @Delete(':id')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, SuperuserGuard)
  async deleteCompanyType(@Param('id') id: string) {
    return this.companiesService.deleteCompanyType(Number(id));
  }
}
