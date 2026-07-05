import { Controller, Get, Param, Query } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { ProductsService } from '../services/products.service';
import { ShopFiltersDto } from '../dto/filters.dto';

@ApiTags('Store Catalog (B2C)')
@Controller('shop')
export class StoreCatalogController {
  constructor(private readonly productsService: ProductsService) {}

  @Get('store/products')
  async getProducts(@Query() query: ShopFiltersDto) {
    return this.productsService.findStoreProducts(query);
  }

  @Get('store/search')
  async searchProducts(@Query() query: ShopFiltersDto) {
    return this.productsService.findStoreProducts(query);
  }

  @Get('catalog/meta')
  async getStoreCatalogMeta() {
    return this.productsService.getStoreCatalogMeta();
  }

  @Get('store/companies')
  async getStorefrontCompanies() {
    return this.productsService.getStorefrontCompanies();
  }

  @Get('store/companies/:id/products')
  async getCompanyProducts(@Param('id') id: string, @Query() query: ShopFiltersDto) {
    query.company_id = Number(id);
    return this.productsService.findStoreProducts(query);
  }

  @Get('store/categories/:type/:id/products')
  async getCategoryProducts(
    @Param('type') type: string,
    @Param('id') id: string,
    @Query() query: ShopFiltersDto
  ) {
    // For simplicity, just use global category id for now.
    query.category_id = Number(id);
    return this.productsService.findStoreProducts(query);
  }
}
