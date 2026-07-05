import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { ProductsService } from './services/products.service';
import { OrdersService } from './services/orders.service';
import { CrmService } from './services/crm.service';

import { StoreCatalogController } from './controllers/store-catalog.controller';
import { B2bCatalogController } from './controllers/b2b-catalog.controller';
import { CompanyProductsController } from './controllers/company-products.controller';
import { CompanyCustomersController } from './controllers/company-customers.controller';
import { CompanySuppliersController } from './controllers/company-suppliers.controller';
import { CompanyOrdersController } from './controllers/company-orders.controller';
import { UserOrdersController } from './controllers/user-orders.controller';
import { AdminProductsController } from './controllers/admin-products.controller';

@Module({
  imports: [PrismaModule],
  controllers: [
    StoreCatalogController,
    B2bCatalogController,
    CompanyProductsController,
    CompanyCustomersController,
    CompanySuppliersController,
    CompanyOrdersController,
    UserOrdersController,
    AdminProductsController,
  ],
  providers: [ProductsService, OrdersService, CrmService],
  exports: [ProductsService, OrdersService, CrmService],
})
export class ShopModule {}
