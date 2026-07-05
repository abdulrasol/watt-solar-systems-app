import { Controller, Get, UseGuards, Query } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { ProductsService } from '../services/products.service';
import { ShopFiltersDto } from '../dto/filters.dto';
import { AuthGuard } from '@nestjs/passport';
import { AdminGuard } from '../../auth/guards/admin.guard';

@ApiTags('Admin Products')
@ApiBearerAuth()
@Controller('shop/admin/products')
@UseGuards(AuthGuard('jwt'), AdminGuard)
export class AdminProductsController {
  constructor(private readonly productsService: ProductsService) {}

  @Get()
  async getAllProducts(@Query() query: ShopFiltersDto) {
    return this.productsService.findAllAdmin(query);
  }
}
