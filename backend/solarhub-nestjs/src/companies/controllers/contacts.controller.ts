import { Controller, Get, Post, Put, Delete, Body, Param, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { CompaniesService } from '../companies.service';
import { ContactCreateDto, ContactUpdateDto } from '../dto/works-contacts.dto';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';

@ApiTags('Company Contacts')
@Controller('companies/:company_id/contacts')
export class CompanyContactsController {
  constructor(private readonly companiesService: CompaniesService) {}

  @Get()
  async listContacts(@Param('company_id') companyId: string) {
    return this.companiesService.listContacts(Number(companyId));
  }

  @Post()
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  async createContact(
    @Param('company_id') companyId: string,
    @Body() data: ContactCreateDto
  ) {
    return this.companiesService.createContact(Number(companyId), data);
  }

  @Put(':id')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  async updateContact(
    @Param('company_id') companyId: string,
    @Param('id') id: string,
    @Body() data: ContactUpdateDto
  ) {
    return this.companiesService.updateContact(Number(companyId), Number(id), data);
  }

  @Delete(':id')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  async deleteContact(
    @Param('company_id') companyId: string,
    @Param('id') id: string
  ) {
    return this.companiesService.deleteContact(Number(companyId), Number(id));
  }
}
