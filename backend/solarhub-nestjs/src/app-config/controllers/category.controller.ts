import { Controller, Get, Post, Put, Delete, Body, Param, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { AppConfigService } from '../app-config.service';
import { GlobalCategoryDto } from '../dto/category.dto';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { SuperuserGuard } from '../../auth/guards/superuser.guard';

@ApiTags('Categories')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, SuperuserGuard)
@Controller('categories')
export class CategoryController {
  constructor(private readonly configService: AppConfigService) {}

  @Get()
  async listCategories() {
    return this.configService.listCategories();
  }

  @Post()
  async createCategory(@Body() data: GlobalCategoryDto) {
    return this.configService.createCategory(data);
  }

  @Put(':id')
  async updateCategory(@Param('id') id: number, @Body() data: GlobalCategoryDto) {
    return this.configService.updateCategory(Number(id), data);
  }

  @Delete(':id')
  async deleteCategory(@Param('id') id: number) {
    return this.configService.deleteCategory(Number(id));
  }
}
