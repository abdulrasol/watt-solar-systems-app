import { Controller, Get, Post, Put, Body, Param, UseGuards, Request, UseInterceptors, UploadedFile } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiConsumes } from '@nestjs/swagger';
import { FileInterceptor } from '@nestjs/platform-express';
import { CompaniesService } from '../companies.service';
import { PosterCreateDto, PosterUpdateDto, PosterReviewDto, PosterExtendDto } from '../dto/company.dto';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { SuperuserGuard } from '../../auth/guards/superuser.guard';
import { RawResponse } from '../../common/decorators/raw-response.decorator';

@ApiTags('Company Posters')
@Controller()
export class CompanyPostersController {
  constructor(private readonly companiesService: CompaniesService) {}

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @Get('companies/:company_id/posters')
  async listCompanyPosters(@Request() req, @Param('company_id') companyId: string) {
    return this.companiesService.listCompanyPosters(req.user.id, Number(companyId));
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @Post('companies/:company_id/posters')
  @ApiConsumes('multipart/form-data')
  @UseInterceptors(FileInterceptor('image'))
  async createPoster(@Request() req, @Param('company_id') companyId: string, @Body() data: PosterCreateDto, @UploadedFile() image: Express.Multer.File) {
    return this.companiesService.createPoster(req.user.id, Number(companyId), data, image);
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

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, SuperuserGuard)
  @Put('admin/posters/:poster_id/extend')
  async extendPoster(@Param('poster_id') posterId: string, @Body() data: PosterExtendDto) {
    return this.companiesService.extendPoster(Number(posterId), data);
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @Put('companies/:company_id/posters/:poster_id/toggle-active')
  async togglePosterActive(@Request() req, @Param('company_id') companyId: string, @Param('poster_id') posterId: string) {
    return this.companiesService.togglePosterActive(req.user.id, Number(companyId), Number(posterId));
  }

  @Get('public-companies/posters')
  @RawResponse()
  async listActivePosters() {
    return this.companiesService.listActivePosters();
  }
}
