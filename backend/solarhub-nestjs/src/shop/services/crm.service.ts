import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
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
      include: {
        company_shop_customer_buyer_company_idTocompany_company: true,
        user: true,
      },
    });
  }

  async findOneCustomer(userId: number, companyId: number, customerId: number) {
    await this.checkCompanyAccess(userId, companyId);
    const customer = await this.prisma.customer.findFirst({
      where: { id: customerId, company_id: companyId },
      include: {
        company_shop_customer_buyer_company_idTocompany_company: true,
        user: true,
      },
    });
    if (!customer) throw new NotFoundException('Customer not found');
    return customer;
  }

  async createCustomer(
    userId: number,
    companyId: number,
    data: CustomerFormDto,
  ) {
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
      },
    });
  }

  async updateCustomer(
    userId: number,
    companyId: number,
    customerId: number,
    data: CustomerFormDto,
  ) {
    await this.findOneCustomer(userId, companyId, customerId);
    return this.prisma.customer.update({
      where: { id: customerId },
      // @ts-ignore
      data: {
        ...data,
        customer_type: data.customer_type || 'b2c',
        user_id: data.buyer_profile_id,
        updated_at: new Date(),
      },
    });
  }

  async deleteCustomer(userId: number, companyId: number, customerId: number) {
    await this.findOneCustomer(userId, companyId, customerId);
    return this.prisma.customer.delete({
      where: { id: customerId },
    });
  }

  // Suppliers
  async findAllSuppliers(userId: number, companyId: number) {
    await this.checkCompanyAccess(userId, companyId);
    return this.prisma.supplier.findMany({
      where: { company_id: companyId },
      include: {
        company_shop_supplier_seller_company_idTocompany_company: true,
      },
    });
  }

  async findOneSupplier(userId: number, companyId: number, supplierId: number) {
    await this.checkCompanyAccess(userId, companyId);
    const supplier = await this.prisma.supplier.findFirst({
      where: { id: supplierId, company_id: companyId },
      include: {
        company_shop_supplier_seller_company_idTocompany_company: true,
      },
    });
    if (!supplier) throw new NotFoundException('Supplier not found');
    return supplier;
  }

  async createSupplier(
    userId: number,
    companyId: number,
    data: SupplierFormDto,
  ) {
    await this.checkCompanyAccess(userId, companyId);
    return this.prisma.supplier.create({
      // @ts-ignore
      data: {
        ...data,
        supplier_type: data.supplier_type || 'external',
        company_id: companyId,
        created_at: new Date(),
        updated_at: new Date(),
      },
    });
  }

  async updateSupplier(
    userId: number,
    companyId: number,
    supplierId: number,
    data: SupplierFormDto,
  ) {
    await this.findOneSupplier(userId, companyId, supplierId);
    return this.prisma.supplier.update({
      where: { id: supplierId },
      // @ts-ignore
      data: {
        ...data,
        supplier_type: data.supplier_type || 'external',
        updated_at: new Date(),
      },
    });
  }

  async deleteSupplier(userId: number, companyId: number, supplierId: number) {
    await this.findOneSupplier(userId, companyId, supplierId);
    return this.prisma.supplier.delete({
      where: { id: supplierId },
    });
  }
}
