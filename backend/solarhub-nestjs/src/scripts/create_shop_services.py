import os

SERVICES_DIR = "src/shop/services"
os.makedirs(SERVICES_DIR, exist_ok=True)

# 1. products.service.ts
products_service = """import { Injectable, NotFoundException, ForbiddenException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { ProductFormDto } from '../dto/products.dto';
import { ShopFiltersDto } from '../dto/filters.dto';

@Injectable()
export class ProductsService {
  constructor(private prisma: PrismaService) {}

  private async checkCompanyAccess(userId: number, companyId: number) {
    const member = await this.prisma.companyMember.findFirst({
      where: { user_id: userId, company_id: companyId },
      include: { company: true },
    });
    if (!member) {
      throw new ForbiddenException('Not a company member');
    }
    return { member, company: member.company };
  }

  // Helper to build where clause from filters
  private buildProductWhereClause(query: ShopFiltersDto, baseWhere: any = {}) {
    const where: any = { ...baseWhere };
    if (query.q) {
      where.OR = [
        { name: { contains: query.q, mode: 'insensitive' } },
        { description: { contains: query.q, mode: 'insensitive' } }
      ];
    }
    if (query.category_id) {
      where.category_id = query.category_id;
    }
    if (query.company_id) {
      where.company_id = query.company_id;
    }
    if (query.min_price || query.max_price) {
      where.retail_price = {};
      if (query.min_price) where.retail_price.gte = query.min_price;
      if (query.max_price) where.retail_price.lte = query.max_price;
    }
    return where;
  }

  // Admin access
  async findAllAdmin(query: ShopFiltersDto = {}) {
    const where = this.buildProductWhereClause(query);
    const skip = ((query.page || 1) - 1) * (query.page_size || 20);
    const take = query.page_size || 20;

    const [data, total] = await Promise.all([
      this.prisma.product.findMany({
        where, skip, take,
        include: { company: true, globalCategory: true, productImages: true, productOption: true, productPricingTier: true },
      }),
      this.prisma.product.count({ where })
    ]);
    return { data, total, page: query.page || 1, page_size: take };
  }

  // B2B & Store Catalogs
  async findStoreProducts(query: ShopFiltersDto = {}) {
    const where = this.buildProductWhereClause(query, { status: 'active' });
    const skip = ((query.page || 1) - 1) * (query.page_size || 20);
    const take = query.page_size || 20;

    const [data, total] = await Promise.all([
      this.prisma.product.findMany({
        where, skip, take,
        include: { company: true, globalCategory: true, productImages: true, productOption: true, productPricingTier: true },
      }),
      this.prisma.product.count({ where })
    ]);
    return { data, total, page: query.page || 1, page_size: take };
  }

  // Company managing its own products
  async findAllForCompany(userId: number, companyId: number, query: ShopFiltersDto = {}) {
    await this.checkCompanyAccess(userId, companyId);
    const where = this.buildProductWhereClause(query, { company_id: companyId });
    const skip = ((query.page || 1) - 1) * (query.page_size || 20);
    const take = query.page_size || 20;

    const [data, total] = await Promise.all([
      this.prisma.product.findMany({
        where, skip, take,
        include: { globalCategory: true, productImages: true, productOption: true, productPricingTier: true },
      }),
      this.prisma.product.count({ where })
    ]);
    return { data, total, page: query.page || 1, page_size: take };
  }

  async findOneForCompany(userId: number, companyId: number, productId: number) {
    await this.checkCompanyAccess(userId, companyId);
    const product = await this.prisma.product.findFirst({
      where: { id: productId, company_id: companyId },
      include: { 
        globalCategory: true,
        productImages: true, 
        productOption: true, 
        productPricingTier: true 
      },
    });
    if (!product) throw new NotFoundException('Product not found');
    return product;
  }

  async createForCompany(userId: number, companyId: number, data: ProductFormDto) {
    await this.checkCompanyAccess(userId, companyId);
    
    // Extract nested relations
    const { options, pricing_tiers, company_category_ids, specs, ...productData } = data;
    
    return this.prisma.product.create({
      data: {
        ...productData,
        specs: specs ? JSON.stringify(specs) : '{}',
        created_at: new Date(),
        updated_at: new Date(),
        company_id: companyId,
        // @ts-ignore
        productOption: options ? { create: options.map(o => ({ ...o, created_at: new Date() })) } : undefined,
        // @ts-ignore
        productPricingTier: pricing_tiers ? { create: pricing_tiers.map(pt => ({ ...pt, created_at: new Date() })) } : undefined,
      },
      include: { productOption: true, productPricingTier: true }
    });
  }

  async updateForCompany(userId: number, companyId: number, productId: number, data: ProductFormDto) {
    await this.findOneForCompany(userId, companyId, productId); // Verify existence & access
    
    const { options, pricing_tiers, company_category_ids, specs, ...productData } = data;

    return this.prisma.product.update({
      where: { id: productId },
      data: {
        ...productData,
        specs: specs ? JSON.stringify(specs) : undefined,
        updated_at: new Date(),
      },
    });
  }

  async deleteForCompany(userId: number, companyId: number, productId: number) {
    await this.findOneForCompany(userId, companyId, productId);
    return this.prisma.product.delete({
      where: { id: productId }
    });
  }
}
"""

with open(f"{SERVICES_DIR}/products.service.ts", "w") as f:
    f.write(products_service)


# 2. crm.service.ts
crm_service = """import { Injectable, NotFoundException, ForbiddenException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CustomerFormDto, SupplierFormDto } from '../dto/crm.dto';

@Injectable()
export class CrmService {
  constructor(private prisma: PrismaService) {}

  private async checkCompanyAccess(userId: number, companyId: number) {
    const member = await this.prisma.companyMember.findFirst({
      where: { user_id: userId, company_id: companyId },
      include: { company: true },
    });
    if (!member) {
      throw new ForbiddenException('Not a company member');
    }
    return { member, company: member.company };
  }

  // Customers
  async findAllCustomers(userId: number, companyId: number) {
    await this.checkCompanyAccess(userId, companyId);
    return this.prisma.customer.findMany({
      where: { company_id: companyId },
      include: { company_shop_customer_buyer_company_idTocompany_company: true, user: true },
    });
  }

  async findOneCustomer(userId: number, companyId: number, customerId: number) {
    await this.checkCompanyAccess(userId, companyId);
    const customer = await this.prisma.customer.findFirst({
      where: { id: customerId, company_id: companyId },
      include: { company_shop_customer_buyer_company_idTocompany_company: true, user: true },
    });
    if (!customer) throw new NotFoundException('Customer not found');
    return customer;
  }

  async createCustomer(userId: number, companyId: number, data: CustomerFormDto) {
    await this.checkCompanyAccess(userId, companyId);
    return this.prisma.customer.create({
      // @ts-ignore
      data: {
        ...data,
        customer_type: data.customer_type || 'b2c',
        company_id: companyId,
        user_id: data.buyer_profile_id,
        created_at: new Date(),
        updated_at: new Date(),
      }
    });
  }

  async updateCustomer(userId: number, companyId: number, customerId: number, data: CustomerFormDto) {
    await this.findOneCustomer(userId, companyId, customerId);
    return this.prisma.customer.update({
      where: { id: customerId },
      // @ts-ignore
      data: {
        ...data,
        customer_type: data.customer_type || 'b2c',
        user_id: data.buyer_profile_id,
        updated_at: new Date(),
      }
    });
  }

  async deleteCustomer(userId: number, companyId: number, customerId: number) {
    await this.findOneCustomer(userId, companyId, customerId);
    return this.prisma.customer.delete({
      where: { id: customerId }
    });
  }

  // Suppliers
  async findAllSuppliers(userId: number, companyId: number) {
    await this.checkCompanyAccess(userId, companyId);
    return this.prisma.supplier.findMany({
      where: { company_id: companyId },
      include: { company_shop_supplier_seller_company_idTocompany_company: true },
    });
  }

  async findOneSupplier(userId: number, companyId: number, supplierId: number) {
    await this.checkCompanyAccess(userId, companyId);
    const supplier = await this.prisma.supplier.findFirst({
      where: { id: supplierId, company_id: companyId },
      include: { company_shop_supplier_seller_company_idTocompany_company: true },
    });
    if (!supplier) throw new NotFoundException('Supplier not found');
    return supplier;
  }

  async createSupplier(userId: number, companyId: number, data: SupplierFormDto) {
    await this.checkCompanyAccess(userId, companyId);
    return this.prisma.supplier.create({
      // @ts-ignore
      data: {
        ...data,
        supplier_type: data.supplier_type || 'external',
        company_id: companyId,
        created_at: new Date(),
        updated_at: new Date(),
      }
    });
  }

  async updateSupplier(userId: number, companyId: number, supplierId: number, data: SupplierFormDto) {
    await this.findOneSupplier(userId, companyId, supplierId);
    return this.prisma.supplier.update({
      where: { id: supplierId },
      // @ts-ignore
      data: {
        ...data,
        supplier_type: data.supplier_type || 'external',
        updated_at: new Date(),
      }
    });
  }

  async deleteSupplier(userId: number, companyId: number, supplierId: number) {
    await this.findOneSupplier(userId, companyId, supplierId);
    return this.prisma.supplier.delete({
      where: { id: supplierId }
    });
  }
}
"""

with open(f"{SERVICES_DIR}/crm.service.ts", "w") as f:
    f.write(crm_service)


# 3. orders.service.ts
orders_service = """import { Injectable, NotFoundException, ForbiddenException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { OrderFormDto } from '../dto/orders.dto';

@Injectable()
export class OrdersService {
  constructor(private prisma: PrismaService) {}

  private async checkCompanyAccess(userId: number, companyId: number) {
    const member = await this.prisma.companyMember.findFirst({
      where: { user_id: userId, company_id: companyId },
      include: { company: true },
    });
    if (!member) {
      throw new ForbiddenException('Not a company member');
    }
    return { member, company: member.company };
  }

  // User B2C / B2B purchases
  async findMyOrders(userId: number, type: string) {
    const whereClause: any = { order_type: type };
    if (type === 'b2c') {
      whereClause.buyer_user_id = userId;
    } else {
      // B2B
      const member = await this.prisma.companyMember.findFirst({ where: { user_id: userId } });
      if (!member) throw new ForbiddenException('Not a company member');
      whereClause.buyer_company_id = member.company_id;
    }

    return this.prisma.order.findMany({
      where: whereClause,
      include: { orderItem: { include: { product: true } }, company_shop_order_seller_company_idTocompany_company: true }
    });
  }

  async checkout(userId: number, type: string, data: OrderFormDto) {
    const orderNumber = Math.floor(Math.random() * 1000000000); 

    const { items, shipping_address, ...orderData } = data;

    let buyer_company_id: number | null = null;
    if (type === 'b2b') {
      const member = await this.prisma.companyMember.findFirst({ where: { user_id: userId } });
      if (!member) throw new ForbiddenException('Not a company member');
      buyer_company_id = member.company_id;
    }

    return this.prisma.order.create({
      // @ts-ignore
      data: {
        ...orderData,
        shipping_address: shipping_address ? JSON.stringify(shipping_address) : undefined,
        created_at: new Date(),
        updated_at: new Date(),
        created_offline: false,
        buyer_receipt_confirmed: false,
        order_number: orderNumber,
        order_type: type,
        buyer_user_id: type === 'b2c' ? userId : null,
        buyer_company_id: type === 'b2b' ? buyer_company_id : null,
        orderItem: items ? { create: items.map(i => {
          const { selected_options, ...rest } = i;
          return {
            ...rest,
            selected_options: selected_options ? JSON.stringify(selected_options) : '[]',
          };
        }) } : undefined,
      },
      include: { orderItem: true }
    });
  }

  // Company managing incoming orders
  async findCompanyIncomingOrders(userId: number, companyId: number) {
    await this.checkCompanyAccess(userId, companyId);
    return this.prisma.order.findMany({
      where: { seller_company_id: companyId },
      include: { 
        orderItem: { include: { product: true } }, 
        user: true, 
        company_shop_order_buyer_company_idTocompany_company: true 
      }
    });
  }

  async updateCompanyOrder(userId: number, companyId: number, orderId: number, status: string) {
    await this.checkCompanyAccess(userId, companyId);
    
    const order = await this.prisma.order.findFirst({
      where: { id: orderId, seller_company_id: companyId }
    });
    
    if (!order) throw new NotFoundException('Order not found');

    return this.prisma.order.update({
      where: { id: orderId },
      data: { 
        status,
        updated_at: new Date(),
      }
    });
  }
}
"""

with open(f"{SERVICES_DIR}/orders.service.ts", "w") as f:
    f.write(orders_service)

print("Shop Services updated successfully!")
