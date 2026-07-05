import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
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
        { description: { contains: query.q, mode: 'insensitive' } },
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
        where,
        skip,
        take,
        include: {
          company: true,
          globalCategory: true,
          productImages: true,
          productOption: true,
          productPricingTier: true,
        },
      }),
      this.prisma.product.count({ where }),
    ]);
    return { items: data, pagination: { count: total, page: query.page || 1, page_size: take } };
  }

  // B2B & Store Catalogs
  async findStoreProducts(query: ShopFiltersDto = {}) {
    const where = this.buildProductWhereClause(query, { status: 'active' });
    const skip = ((query.page || 1) - 1) * (query.page_size || 20);
    const take = query.page_size || 20;

    const [data, total] = await Promise.all([
      this.prisma.product.findMany({
        where,
        skip,
        take,
        include: {
          company: true,
          globalCategory: true,
          productImages: true,
          productOption: true,
          productPricingTier: true,
        },
      }),
      this.prisma.product.count({ where }),
    ]);
    return { items: data, pagination: { count: total, page: query.page || 1, page_size: take } };
  }

  async getStoreCatalogMeta() {
    const categories = await this.prisma.globalCategory.findMany();
    return { categories };
  }

  async getStorefrontCompanies() {
    // Find all companies that have at least one active product
    const companies = await this.prisma.company.findMany({
      where: {
        product: {
          some: { status: 'active' }
        }
      },
      select: {
        id: true,
        name: true,
        logo: true,
        description: true,
        address: true,
        phone: true,
        city: { select: { name: true } },
        companyType: { select: { name: true } }
      }
    });
    return { items: companies, pagination: { count: companies.length, page: 1, page_size: companies.length } };
  }

  // Company managing its own products
  async findAllForCompany(
    userId: number,
    companyId: number,
    query: ShopFiltersDto = {},
  ) {
    await this.checkCompanyAccess(userId, companyId);
    const where = this.buildProductWhereClause(query, {
      company_id: companyId,
    });
    const skip = ((query.page || 1) - 1) * (query.page_size || 20);
    const take = query.page_size || 20;

    const [data, total] = await Promise.all([
      this.prisma.product.findMany({
        where,
        skip,
        take,
        include: {
          globalCategory: true,
          productImages: true,
          productOption: true,
          productPricingTier: true,
        },
      }),
      this.prisma.product.count({ where }),
    ]);
    return { items: data, pagination: { count: total, page: query.page || 1, page_size: take } };
  }

  async findOneForCompany(
    userId: number,
    companyId: number,
    productId: number,
  ) {
    await this.checkCompanyAccess(userId, companyId);
    const product = await this.prisma.product.findFirst({
      where: { id: productId, company_id: companyId },
      include: {
        globalCategory: true,
        productImages: true,
        productOption: true,
        productPricingTier: true,
      },
    });
    if (!product) throw new NotFoundException('Product not found');
    return product;
  }

  async createForCompany(
    userId: number,
    companyId: number,
    data: ProductFormDto,
  ) {
    await this.checkCompanyAccess(userId, companyId);

    // Extract nested relations
    const {
      options,
      pricing_tiers,
      company_category_ids,
      specs,
      ...productData
    } = data;

    return this.prisma.product.create({
      data: {
        ...productData,
        specs: specs ? JSON.stringify(specs) : '{}',
        created_at: new Date(),
        updated_at: new Date(),
        company_id: companyId,
        // @ts-ignore
        productOption: options
          ? { create: options.map((o) => ({ ...o, created_at: new Date() })) }
          : undefined,
        // @ts-ignore
        productPricingTier: pricing_tiers
          ? {
              create: pricing_tiers.map((pt) => ({
                ...pt,
                created_at: new Date(),
              })),
            }
          : undefined,
      },
      include: { productOption: true, productPricingTier: true },
    });
  }

  async updateForCompany(
    userId: number,
    companyId: number,
    productId: number,
    data: ProductFormDto,
  ) {
    await this.findOneForCompany(userId, companyId, productId); // Verify existence & access

    const {
      options,
      pricing_tiers,
      company_category_ids,
      specs,
      ...productData
    } = data;

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
      where: { id: productId },
    });
  }
}
