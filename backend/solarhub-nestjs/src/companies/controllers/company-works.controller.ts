import { Controller, Get, Post, Put, Delete, Body, Param, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { CompaniesService } from '../companies.service';
import { CompanyWorkCreateDto, CompanyWorkUpdateDto } from '../dto/works-contacts.dto';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';

@ApiTags('Company Works')
@Controller('companies/:company_id/works')
export class CompanyWorksController {
  constructor(private readonly companiesService: CompaniesService) {}

  @Get()
  async listWorks(@Param('company_id') companyId: string) {
    return this.companiesService.listWorks(Number(companyId));
  }

  @Get(':id')
  async getWork(@Param('company_id') companyId: string, @Param('id') id: string) {
    return this.companiesService.getWork(Number(companyId), Number(id));
  }

  @Post()
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  async createWork(
    @Param('company_id') companyId: string,
    @Body() data: CompanyWorkCreateDto
  ) {
    return this.companiesService.createWork(Number(companyId), data);
  }

  @Put(':id')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  async updateWork(
    @Param('company_id') companyId: string,
    @Param('id') id: string,
    @Body() data: CompanyWorkUpdateDto
  ) {
    return this.companiesService.updateWork(Number(companyId), Number(id), data);
  }

  @Delete(':id')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  async deleteWork(
    @Param('company_id') companyId: string,
    @Param('id') id: string
  ) {
    return this.companiesService.deleteWork(Number(companyId), Number(id));
  }
}
