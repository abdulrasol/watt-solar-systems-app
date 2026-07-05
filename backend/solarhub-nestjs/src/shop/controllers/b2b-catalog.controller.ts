import { Controller, Get, Param, Query } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { ProductsService } from '../services/products.service';
import { ShopFiltersDto } from '../dto/filters.dto';

@ApiTags('B2B Catalog')
@Controller('shop/b2b')
export class B2bCatalogController {
  constructor(private readonly productsService: ProductsService) {}

  @Get('products')
  async getB2bProducts(@Query() query: ShopFiltersDto) {
    return this.productsService.findStoreProducts(query);
  }

  @Get('search')
  async searchB2bProducts(@Query() query: ShopFiltersDto) {
    return this.productsService.findStoreProducts(query);
  }

  @Get('companies/:id/products')
  async getCompanyProducts(@Param('id') id: string, @Query() query: ShopFiltersDto) {
    query.company_id = Number(id);
    return this.productsService.findStoreProducts(query);
  }

  @Get('categories/:type/:id/products')
  async getCategoryProducts(
    @Param('type') type: string,
    @Param('id') id: string,
    @Query() query: ShopFiltersDto
  ) {
    query.category_id = Number(id);
    return this.productsService.findStoreProducts(query);
  }
}
