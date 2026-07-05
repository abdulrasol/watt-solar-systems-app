import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Param,
  Body,
  Headers,
  UseGuards,
  Request,
  ParseIntPipe,
  Query,
} from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiHeader } from '@nestjs/swagger';
import { ProductsService } from '../services/products.service';
import { ProductFormDto } from '../dto/products.dto';
import { ShopFiltersDto } from '../dto/filters.dto';
import { AuthGuard } from '@nestjs/passport';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../auth/decorators/roles.decorator';

@ApiTags('Company Products')
@ApiBearerAuth()
@ApiHeader({ name: 'company-id', required: true })
@Controller('shop/company-products')
@UseGuards(AuthGuard('jwt'), RolesGuard)
export class CompanyProductsController {
  constructor(private readonly productsService: ProductsService) {}

  @Get()
  @Roles('admin', 'manager', 'sales', 'staff')
  async findAll(
    @Request() req,
    @Headers('company-id') companyId: string,
    @Query() query: ShopFiltersDto,
  ) {
    return this.productsService.findAllForCompany(
      req.user.id,
      parseInt(companyId),
      query,
    );
  }

  @Get(':id')
  @Roles('admin', 'manager', 'sales', 'staff')
  async findOne(
    @Request() req,
    @Headers('company-id') companyId: string,
    @Param('id', ParseIntPipe) id: number,
  ) {
    return this.productsService.findOneForCompany(
      req.user.id,
      parseInt(companyId),
      id,
    );
  }

  @Post()
  @Roles('admin', 'manager', 'inventory')
  async create(
    @Request() req,
    @Headers('company-id') companyId: string,
    @Body() data: ProductFormDto,
  ) {
    return this.productsService.createForCompany(
      req.user.id,
      parseInt(companyId),
      data,
    );
  }

  @Put(':id')
  @Roles('admin', 'manager', 'inventory')
  async update(
    @Request() req,
    @Headers('company-id') companyId: string,
    @Param('id', ParseIntPipe) id: number,
    @Body() data: ProductFormDto,
  ) {
    return this.productsService.updateForCompany(
      req.user.id,
      parseInt(companyId),
      id,
      data,
    );
  }

  @Delete(':id')
  @Roles('admin', 'manager')
  async remove(
    @Request() req,
    @Headers('company-id') companyId: string,
    @Param('id', ParseIntPipe) id: number,
  ) {
    return this.productsService.deleteForCompany(
      req.user.id,
      parseInt(companyId),
      id,
    );
  }
}
