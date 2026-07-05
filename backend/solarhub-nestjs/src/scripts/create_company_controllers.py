import os

controller_dir = "src/companies/controllers"
os.makedirs(controller_dir, exist_ok=True)

controllers = {
    "companies.controller.ts": """import { Controller, Get, Post, Put, Body, Param, UseGuards, Request, UseInterceptors, UploadedFile, Query } from '@nestjs/common';
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
    return this.companiesService.registerCompany(req.user.sub, data);
  }

  @Get()
  async listUserCompanies(@Request() req) {
    return this.companiesService.listUserCompanies(req.user.sub);
  }

  @Get(':id')
  async getCompany(@Request() req, @Param('id') id: string) {
    return this.companiesService.getCompany(req.user.sub, Number(id));
  }

  @Put(':id')
  async updateCompany(@Request() req, @Param('id') id: string, @Body() data: CompanyUpdateDto) {
    return this.companiesService.updateCompany(req.user.sub, Number(id), data);
  }

  @Post(':id/logo')
  @ApiConsumes('multipart/form-data')
  @UseInterceptors(FileInterceptor('logo'))
  async updateLogo(@Request() req, @Param('id') id: string, @UploadedFile() logo: Express.Multer.File) {
    return this.companiesService.updateLogo(req.user.sub, Number(id), logo);
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
}
""",

    "members.controller.ts": """import { Controller, Get, Post, Put, Delete, Body, Param, UseGuards, Request } from '@nestjs/common';
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
    return this.companiesService.listMembers(req.user.sub, Number(companyId));
  }

  @Post('invite')
  async inviteMember(@Request() req, @Param('company_id') companyId: string, @Body() data: InviteMemberDto) {
    return this.companiesService.inviteMember(req.user.sub, Number(companyId), data);
  }

  @Post('create')
  async createMember(@Request() req, @Param('company_id') companyId: string, @Body() data: CreateMemberDto) {
    return this.companiesService.createMember(req.user.sub, Number(companyId), data);
  }

  @Delete(':member_id')
  async removeMember(@Request() req, @Param('company_id') companyId: string, @Param('member_id') memberId: string) {
    return this.companiesService.removeMember(req.user.sub, Number(companyId), Number(memberId));
  }
}
""",

    "services.controller.ts": """import { Controller, Get, Post, Put, Delete, Body, Param, UseGuards, Request } from '@nestjs/common';
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
    return this.companiesService.listServices(req.user.sub, Number(companyId));
  }

  @Post()
  async createService(@Request() req, @Param('company_id') companyId: string, @Body() data: CompanyServiceCreateDto) {
    return this.companiesService.createService(req.user.sub, Number(companyId), data);
  }

  @Put(':service_id')
  async updateService(@Request() req, @Param('company_id') companyId: string, @Param('service_id') serviceId: string, @Body() data: CompanyServiceUpdateDto) {
    return this.companiesService.updateService(req.user.sub, Number(companyId), Number(serviceId), data);
  }

  @Delete(':service_id')
  async deleteService(@Request() req, @Param('company_id') companyId: string, @Param('service_id') serviceId: string) {
    return this.companiesService.deleteService(req.user.sub, Number(companyId), Number(serviceId));
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
""",
    
    "posters.controller.ts": """import { Controller, Get, Post, Put, Body, Param, UseGuards, Request, UseInterceptors, UploadedFile } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiConsumes } from '@nestjs/swagger';
import { FileInterceptor } from '@nestjs/platform-express';
import { CompaniesService } from '../companies.service';
import { PosterCreateDto, PosterUpdateDto, PosterReviewDto, PosterExtendDto } from '../dto/company.dto';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { SuperuserGuard } from '../../auth/guards/superuser.guard';

@ApiTags('Company Posters')
@Controller()
export class CompanyPostersController {
  constructor(private readonly companiesService: CompaniesService) {}

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @Get('companies/:company_id/posters')
  async listCompanyPosters(@Request() req, @Param('company_id') companyId: string) {
    return this.companiesService.listCompanyPosters(req.user.sub, Number(companyId));
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @Post('companies/:company_id/posters')
  @ApiConsumes('multipart/form-data')
  @UseInterceptors(FileInterceptor('image'))
  async createPoster(@Request() req, @Param('company_id') companyId: string, @Body() data: PosterCreateDto, @UploadedFile() image: Express.Multer.File) {
    return this.companiesService.createPoster(req.user.sub, Number(companyId), data, image);
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, SuperuserGuard)
  @Get('admin/posters')
  async listAllPosters() {
    return this.companiesService.listAllPosters();
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, SuperuserGuard)
  @Put('admin/posters/:poster_id/review')
  async reviewPoster(@Param('poster_id') posterId: string, @Body() data: PosterReviewDto) {
    return this.companiesService.reviewPoster(Number(posterId), data);
  }
}
""",

    "subscriptions.controller.ts": """import { Controller, Get, Post, Put, Body, Param, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { CompaniesService } from '../companies.service';
import { CompanySubscriptionRequestCreateDto, CompanySubscriptionRequestReviewDto } from '../dto/company.dto';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { SuperuserGuard } from '../../auth/guards/superuser.guard';

@ApiTags('Company Subscription Requests')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller()
export class CompanySubscriptionsController {
  constructor(private readonly companiesService: CompaniesService) {}

  @Post('companies/:company_id/subscription-requests')
  async requestSubscription(@Request() req, @Param('company_id') companyId: string, @Body() data: CompanySubscriptionRequestCreateDto) {
    return this.companiesService.requestSubscription(req.user.sub, Number(companyId), data);
  }

  @Get('companies/:company_id/subscription-requests')
  async listCompanySubscriptions(@Request() req, @Param('company_id') companyId: string) {
    return this.companiesService.listCompanySubscriptions(req.user.sub, Number(companyId));
  }

  @UseGuards(SuperuserGuard)
  @Get('admin/subscription-requests')
  async listAllSubscriptions() {
    return this.companiesService.listAllSubscriptions();
  }

  @UseGuards(SuperuserGuard)
  @Put('admin/subscription-requests/:request_id/review')
  async reviewSubscription(@Param('request_id') requestId: string, @Body() data: CompanySubscriptionRequestReviewDto) {
    return this.companiesService.reviewSubscription(Number(requestId), data);
  }
}
"""
}

for filename, content in controllers.items():
    with open(os.path.join(controller_dir, filename), "w") as f:
        f.write(content)

print("Company controllers generated successfully.")
