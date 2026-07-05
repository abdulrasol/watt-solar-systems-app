import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
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
      const member = await this.prisma.companyMember.findFirst({
        where: { user_id: userId },
      });
      if (!member) throw new ForbiddenException('Not a company member');
      whereClause.buyer_company_id = member.company_id;
    }

    return this.prisma.order.findMany({
      where: whereClause,
      include: {
        orderItem: { include: { product: true } },
        company_shop_order_seller_company_idTocompany_company: true,
      },
    });
  }

  async findMyOrderById(userId: number, orderId: number, type: string) {
    const whereClause: any = { id: orderId, order_type: type };
    if (type === 'b2c') {
      whereClause.buyer_user_id = userId;
    } else {
      const member = await this.prisma.companyMember.findFirst({
        where: { user_id: userId },
      });
      if (!member) throw new ForbiddenException('Not a company member');
      whereClause.buyer_company_id = member.company_id;
    }

    const order = await this.prisma.order.findFirst({
      where: whereClause,
      include: {
        orderItem: { include: { product: true } },
        company_shop_order_seller_company_idTocompany_company: true,
      },
    });
    if (!order) throw new NotFoundException('Order not found');
    return order;
  }

  async cancelOrder(userId: number, orderId: number, type: string) {
    const order = await this.findMyOrderById(userId, orderId, type);
    if (order.status !== 'pending' && order.status !== 'accepted') {
      throw new BadRequestException('Cannot cancel order at this stage');
    }
    return this.prisma.order.update({
      where: { id: orderId },
      data: { status: 'cancelled', updated_at: new Date() }
    });
  }

  async confirmReceipt(userId: number, orderId: number) {
    const order = await this.findMyOrderById(userId, orderId, 'b2b');
    return this.prisma.order.update({
      where: { id: orderId },
      data: { buyer_receipt_confirmed: true, updated_at: new Date() }
    });
  }

  async checkout(userId: number, type: string, data: OrderFormDto) {
    const orderNumber = Math.floor(Math.random() * 1000000000);

    const { items, shipping_address, ...orderData } = data;

    let buyer_company_id: number | null = null;
    if (type === 'b2b') {
      const member = await this.prisma.companyMember.findFirst({
        where: { user_id: userId },
      });
      if (!member) throw new ForbiddenException('Not a company member');
      buyer_company_id = member.company_id;
    }

    return this.prisma.order.create({
      // @ts-ignore
      data: {
        ...orderData,
        shipping_address: shipping_address
          ? JSON.stringify(shipping_address)
          : undefined,
        created_at: new Date(),
        updated_at: new Date(),
        created_offline: false,
        buyer_receipt_confirmed: false,
        order_number: orderNumber,
        order_type: type,
        buyer_user_id: type === 'b2c' ? userId : null,
        buyer_company_id: type === 'b2b' ? buyer_company_id : null,
        orderItem: items
          ? {
              create: items.map((i) => {
                const { selected_options, ...rest } = i;
                return {
                  ...rest,
                  selected_options: selected_options
                    ? JSON.stringify(selected_options)
                    : '[]',
                };
              }),
            }
          : undefined,
      },
      include: { orderItem: true },
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
        company_shop_order_buyer_company_idTocompany_company: true,
      },
    });
  }

  async updateCompanyOrder(
    userId: number,
    companyId: number,
    orderId: number,
    status: string,
  ) {
    await this.checkCompanyAccess(userId, companyId);

    const order = await this.prisma.order.findFirst({
      where: { id: orderId, seller_company_id: companyId },
    });

    if (!order) throw new NotFoundException('Order not found');

    return this.prisma.order.update({
      where: { id: orderId },
      data: {
        status,
        updated_at: new Date(),
      },
    });
  }
}
