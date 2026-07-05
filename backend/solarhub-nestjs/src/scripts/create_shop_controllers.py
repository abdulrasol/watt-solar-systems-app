import os

CONTROLLERS_DIR = "src/shop/controllers"
os.makedirs(CONTROLLERS_DIR, exist_ok=True)

# 1. store-catalog.controller.ts
store_catalog = """import { Controller, Get, Param, Query } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { ProductsService } from '../services/products.service';
import { ShopFiltersDto } from '../dto/filters.dto';

@ApiTags('Store Catalog (B2C)')
@Controller('shop/store')
export class StoreCatalogController {
  constructor(private readonly productsService: ProductsService) {}

  @Get('products')
  async getProducts(@Query() query: ShopFiltersDto) {
    return this.productsService.findStoreProducts(query);
  }
}
"""

with open(f"{CONTROLLERS_DIR}/store-catalog.controller.ts", "w") as f:
    f.write(store_catalog)

# 2. b2b-catalog.controller.ts
b2b_catalog = """import { Controller, Get, Param, Query } from '@nestjs/common';
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
}
"""

with open(f"{CONTROLLERS_DIR}/b2b-catalog.controller.ts", "w") as f:
    f.write(b2b_catalog)


# 3. company-products.controller.ts
company_products = """import { Controller, Get, Post, Put, Delete, Param, Body, Headers, UseGuards, Request, ParseIntPipe, Query } from '@nestjs/common';
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
  async findAll(@Request() req, @Headers('company-id') companyId: string, @Query() query: ShopFiltersDto) {
    return this.productsService.findAllForCompany(req.user.id, parseInt(companyId), query);
  }

  @Get(':id')
  @Roles('admin', 'manager', 'sales', 'staff')
  async findOne(@Request() req, @Headers('company-id') companyId: string, @Param('id', ParseIntPipe) id: number) {
    return this.productsService.findOneForCompany(req.user.id, parseInt(companyId), id);
  }

  @Post()
  @Roles('admin', 'manager', 'inventory')
  async create(@Request() req, @Headers('company-id') companyId: string, @Body() data: ProductFormDto) {
    return this.productsService.createForCompany(req.user.id, parseInt(companyId), data);
  }

  @Put(':id')
  @Roles('admin', 'manager', 'inventory')
  async update(@Request() req, @Headers('company-id') companyId: string, @Param('id', ParseIntPipe) id: number, @Body() data: ProductFormDto) {
    return this.productsService.updateForCompany(req.user.id, parseInt(companyId), id, data);
  }

  @Delete(':id')
  @Roles('admin', 'manager')
  async remove(@Request() req, @Headers('company-id') companyId: string, @Param('id', ParseIntPipe) id: number) {
    return this.productsService.deleteForCompany(req.user.id, parseInt(companyId), id);
  }
}
"""

with open(f"{CONTROLLERS_DIR}/company-products.controller.ts", "w") as f:
    f.write(company_products)


# 4. company-customers.controller.ts
company_customers = """import { Controller, Get, Post, Put, Delete, Param, Body, Headers, UseGuards, Request, ParseIntPipe } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiHeader } from '@nestjs/swagger';
import { CrmService } from '../services/crm.service';
import { CustomerFormDto } from '../dto/crm.dto';
import { AuthGuard } from '@nestjs/passport';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../auth/decorators/roles.decorator';

@ApiTags('Company Customers (CRM)')
@ApiBearerAuth()
@ApiHeader({ name: 'company-id', required: true })
@Controller('shop/company-customers')
@UseGuards(AuthGuard('jwt'), RolesGuard)
@Roles('admin', 'manager', 'sales', 'staff')
export class CompanyCustomersController {
  constructor(private readonly crmService: CrmService) {}

  @Get()
  async findAll(@Request() req, @Headers('company-id') companyId: string) {
    return this.crmService.findAllCustomers(req.user.id, parseInt(companyId));
  }

  @Get(':id')
  async findOne(@Request() req, @Headers('company-id') companyId: string, @Param('id', ParseIntPipe) id: number) {
    return this.crmService.findOneCustomer(req.user.id, parseInt(companyId), id);
  }

  @Post()
  async create(@Request() req, @Headers('company-id') companyId: string, @Body() data: CustomerFormDto) {
    return this.crmService.createCustomer(req.user.id, parseInt(companyId), data);
  }

  @Put(':id')
  async update(@Request() req, @Headers('company-id') companyId: string, @Param('id', ParseIntPipe) id: number, @Body() data: CustomerFormDto) {
    return this.crmService.updateCustomer(req.user.id, parseInt(companyId), id, data);
  }

  @Delete(':id')
  @Roles('admin', 'manager')
  async remove(@Request() req, @Headers('company-id') companyId: string, @Param('id', ParseIntPipe) id: number) {
    return this.crmService.deleteCustomer(req.user.id, parseInt(companyId), id);
  }
}
"""

with open(f"{CONTROLLERS_DIR}/company-customers.controller.ts", "w") as f:
    f.write(company_customers)


# 5. company-suppliers.controller.ts
company_suppliers = """import { Controller, Get, Post, Put, Delete, Param, Body, Headers, UseGuards, Request, ParseIntPipe } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiHeader } from '@nestjs/swagger';
import { CrmService } from '../services/crm.service';
import { SupplierFormDto } from '../dto/crm.dto';
import { AuthGuard } from '@nestjs/passport';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../auth/decorators/roles.decorator';

@ApiTags('Company Suppliers (CRM)')
@ApiBearerAuth()
@ApiHeader({ name: 'company-id', required: true })
@Controller('shop/company-suppliers')
@UseGuards(AuthGuard('jwt'), RolesGuard)
@Roles('admin', 'manager', 'sales', 'staff')
export class CompanySuppliersController {
  constructor(private readonly crmService: CrmService) {}

  @Get()
  async findAll(@Request() req, @Headers('company-id') companyId: string) {
    return this.crmService.findAllSuppliers(req.user.id, parseInt(companyId));
  }

  @Get(':id')
  async findOne(@Request() req, @Headers('company-id') companyId: string, @Param('id', ParseIntPipe) id: number) {
    return this.crmService.findOneSupplier(req.user.id, parseInt(companyId), id);
  }

  @Post()
  async create(@Request() req, @Headers('company-id') companyId: string, @Body() data: SupplierFormDto) {
    return this.crmService.createSupplier(req.user.id, parseInt(companyId), data);
  }

  @Put(':id')
  async update(@Request() req, @Headers('company-id') companyId: string, @Param('id', ParseIntPipe) id: number, @Body() data: SupplierFormDto) {
    return this.crmService.updateSupplier(req.user.id, parseInt(companyId), id, data);
  }

  @Delete(':id')
  @Roles('admin', 'manager')
  async remove(@Request() req, @Headers('company-id') companyId: string, @Param('id', ParseIntPipe) id: number) {
    return this.crmService.deleteSupplier(req.user.id, parseInt(companyId), id);
  }
}
"""

with open(f"{CONTROLLERS_DIR}/company-suppliers.controller.ts", "w") as f:
    f.write(company_suppliers)


# 6. company-orders.controller.ts
company_orders = """import { Controller, Get, Put, Param, Body, Headers, UseGuards, Request, ParseIntPipe } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiHeader } from '@nestjs/swagger';
import { OrdersService } from '../services/orders.service';
import { AuthGuard } from '@nestjs/passport';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../auth/decorators/roles.decorator';

@ApiTags('Company Orders (Sales)')
@ApiBearerAuth()
@ApiHeader({ name: 'company-id', required: true })
@Controller('shop/company-orders')
@UseGuards(AuthGuard('jwt'), RolesGuard)
@Roles('admin', 'manager', 'sales')
export class CompanyOrdersController {
  constructor(private readonly ordersService: OrdersService) {}

  @Get()
  async findIncomingOrders(@Request() req, @Headers('company-id') companyId: string) {
    return this.ordersService.findCompanyIncomingOrders(req.user.id, parseInt(companyId));
  }

  @Put(':id/status')
  async updateOrderStatus(@Request() req, @Headers('company-id') companyId: string, @Param('id', ParseIntPipe) id: number, @Body('status') status: string) {
    return this.ordersService.updateCompanyOrder(req.user.id, parseInt(companyId), id, status);
  }
}
"""

with open(f"{CONTROLLERS_DIR}/company-orders.controller.ts", "w") as f:
    f.write(company_orders)


# 7. user-orders.controller.ts
user_orders = """import { Controller, Get, Post, Param, Body, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { OrdersService } from '../services/orders.service';
import { OrderFormDto } from '../dto/orders.dto';
import { AuthGuard } from '@nestjs/passport';

@ApiTags('User Purchases (B2C & B2B)')
@ApiBearerAuth()
@Controller('shop/my-orders')
@UseGuards(AuthGuard('jwt'))
export class UserOrdersController {
  constructor(private readonly ordersService: OrdersService) {}

  @Get('b2c')
  async getB2cOrders(@Request() req) {
    return this.ordersService.findMyOrders(req.user.id, 'b2c');
  }

  @Post('b2c/checkout')
  async checkoutB2c(@Request() req, @Body() data: OrderFormDto) {
    return this.ordersService.checkout(req.user.id, 'b2c', data);
  }

  @Get('b2b')
  async getB2bOrders(@Request() req) {
    return this.ordersService.findMyOrders(req.user.id, 'b2b');
  }

  @Post('b2b/checkout')
  async checkoutB2b(@Request() req, @Body() data: OrderFormDto) {
    return this.ordersService.checkout(req.user.id, 'b2b', data);
  }
}
"""

with open(f"{CONTROLLERS_DIR}/user-orders.controller.ts", "w") as f:
    f.write(user_orders)


# 8. admin-products.controller.ts
admin_products = """import { Controller, Get, UseGuards, Query } from '@nestjs/common';
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
"""

with open(f"{CONTROLLERS_DIR}/admin-products.controller.ts", "w") as f:
    f.write(admin_products)


print("Shop Controllers generated successfully!")
