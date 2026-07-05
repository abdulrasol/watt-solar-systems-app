import { Controller, Get, Post, Put, Body, Param, UseGuards, Request, UseInterceptors, UploadedFile, Query } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiConsumes } from '@nestjs/swagger';
import { FileInterceptor } from '@nestjs/platform-express';
import { CompaniesService } from '../companies.service';
import { CompanyRegisterDto, CompanyUpdateDto } from '../dto/company.dto';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { SuperuserGuard } from '../../auth/guards/superuser.guard';

@ApiTags('Companies')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('companies')
export class CompaniesController {
  constructor(private readonly companiesService: CompaniesService) {}

  @Post()
  async registerCompany(@Request() req, @Body() data: CompanyRegisterDto) {
    const fs = require('fs');
    try {
      fs.writeFileSync('./debug_user.json', JSON.stringify(req.user));
    } catch(e) {}
    return this.companiesService.registerCompany(req.user.id, data);
  }

  @Get()
  async listUserCompanies(@Request() req) {
    return this.companiesService.listUserCompanies(req.user.id);
  }

  @Get(':id')
  async getCompany(@Request() req, @Param('id') id: string) {
    return this.companiesService.getCompany(req.user.id, Number(id));
  }

  @Put(':id')
  async updateCompany(@Request() req, @Param('id') id: string, @Body() data: CompanyUpdateDto) {
    return this.companiesService.updateCompany(req.user.id, Number(id), data);
  }

  @Post(':id/logo')
  @ApiConsumes('multipart/form-data')
  @UseInterceptors(FileInterceptor('logo'))
  async updateLogo(@Request() req, @Param('id') id: string, @UploadedFile() logo: Express.Multer.File) {
    return this.companiesService.updateLogo(req.user.id, Number(id), logo);
  }
}

@ApiTags('Public Companies')
@Controller('public-companies')
export class PublicCompaniesController {
  constructor(private readonly companiesService: CompaniesService) {}

  @Get()
  async listPublicCompanies(
    @Query('type') type?: string,
    @Query('search') search?: string,
    @Query('city') city?: number,
    @Query('page') page?: number,
    @Query('page_size') page_size?: number
  ) {
    return this.companiesService.listPublicCompanies({ type, search, city, page, page_size });
  }

  @Get(':id')
  async getPublicCompany(@Param('id') id: string) {
    return this.companiesService.getPublicCompany(Number(id));
  }

  @Get(':id/works')
  async getPublicCompanyWorks(@Param('id') id: string) {
    return this.companiesService.listWorks(Number(id));
  }
}
