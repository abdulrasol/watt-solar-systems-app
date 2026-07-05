import { Controller, Get, Post, Body, Param, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { AppConfigService } from '../app-config.service';
import { CompanyApproveDto } from '../dto/company.dto';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { SuperuserGuard } from '../../auth/guards/superuser.guard';

@ApiTags('Admin Companies')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, SuperuserGuard)
@Controller('companies')
export class AdminCompanyController {
  constructor(private readonly configService: AppConfigService) {}

  @Get()
  async listCompanies() {
    return this.configService.listCompanies();
  }

  @Post(':company_id/status')
  async updateCompanyStatus(@Param('company_id') company_id: number, @Body() data: CompanyApproveDto) {
    return this.configService.updateCompanyStatus(Number(company_id), data);
  }
}
