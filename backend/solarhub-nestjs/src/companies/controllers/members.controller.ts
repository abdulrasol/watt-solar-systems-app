import { Controller, Get, Post, Put, Delete, Body, Param, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { CompaniesService } from '../companies.service';
import { InviteMemberDto, CreateMemberDto } from '../dto/company.dto';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';

@ApiTags('Company Members')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('companies/:company_id/members')
export class CompanyMembersController {
  constructor(private readonly companiesService: CompaniesService) {}

  @Get()
  async listMembers(@Request() req, @Param('company_id') companyId: string) {
    return this.companiesService.listMembers(req.user.id, Number(companyId));
  }

  @Post('invite')
  async inviteMember(@Request() req, @Param('company_id') companyId: string, @Body() data: InviteMemberDto) {
    return this.companiesService.inviteMember(req.user.id, Number(companyId), data);
  }

  @Post('create')
  async createMember(@Request() req, @Param('company_id') companyId: string, @Body() data: CreateMemberDto) {
    return this.companiesService.createMember(req.user.id, Number(companyId), data);
  }

  @Delete(':member_id')
  async removeMember(@Request() req, @Param('company_id') companyId: string, @Param('member_id') memberId: string) {
    return this.companiesService.removeMember(req.user.id, Number(companyId), Number(memberId));
  }
}
