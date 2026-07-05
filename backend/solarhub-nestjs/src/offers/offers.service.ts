import { Injectable, NotFoundException, ForbiddenException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { NotificationsService } from '../notifications/notifications.service';
import { OfferRequestInDto } from './dto/offer-request.dto';
import { OfferInDto, OfferResponseInDto } from './dto/offer.dto';
import { InvolvementTemplateInDto } from './dto/involvement-template.dto';

@Injectable()
export class OffersService {
  constructor(
    private prisma: PrismaService,
    private notificationsService: NotificationsService,
  ) {}

  private async checkCompanyAccess(userId: number, companyId: number) {
    const member = await this.prisma.companyMember.findFirst({
      where: { user_id: userId, company_id: companyId },
      include: { company: true },
    });
    if (!member) {
      throw new ForbiddenException('Not a company member');
    }
    // TODO: Verify if company has "offers" service active, depending on subscription.
    // For now we just return member and company.
    return { member, company: member.company };
  }

  // --- User OfferRequests ---

  async createOfferRequest(userId: number, data: OfferRequestInDto) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: { city: true },
    });

    const cityId = data.city_id || user?.cityId || null;

    const request = await this.prisma.offerRequest.create({
      data: {
        user_id: userId,
        status: 'open',
        created_at: new Date(),
        all_cities: data.all_cities || false,
        city_id: cityId,
        total_panel_power: data.total_panel_power ?? 0,
        panel_power: data.panel_power ?? 0,
        panel_count: data.panel_count ?? 0,
        panel_note: data.panel_note,
        total_battery_power: data.total_battery_power ?? 0,
        battery_size: data.battery_size ?? 0,
        battery_count: data.battery_count ?? 0,
        battery_note: data.battery_note,
        battery_type: data.battery_type ?? 'gel',
        total_inverters_power: data.total_inverters_power ?? 0,
        inverter_size: data.inverter_size ?? 0,
        inverter_count: data.inverter_count ?? 0,
        inverter_note: data.inverter_note,
        inverter_type: data.inverter_type ?? 'hybrid',
        note: data.note,
      },
    });

    // Notify companies
    // For simplicity, we broadcast to a topic or specific companies
    await this.notificationsService.sendTopicNotification(
      'companies',
      'طلب عرض جديد',
      'تم إنشاء طلب عرض جديد في النظام',
      { type: 'new_offer_request', id: request.id.toString() }
    );

    return request;
  }

  async listUserRequests(userId: number, status?: string, page = 1, pageSize = 10) {
    const where: any = { user_id: userId };
    if (status) where.status = status;

    const [items, total] = await Promise.all([
      this.prisma.offerRequest.findMany({
        where,
        orderBy: { created_at: 'desc' },
        skip: (page - 1) * pageSize,
        take: pageSize,
      }),
      this.prisma.offerRequest.count({ where }),
    ]);

    return { items, total, page, pageSize };
  }

  async getRequestDetail(userId: number, id: number) {
    const request = await this.prisma.offerRequest.findFirst({
      where: { id, user_id: userId },
      include: { offer: true }, // Include offers
    });
    if (!request) throw new NotFoundException('Request not found');
    return request;
  }

  async updateRequest(userId: number, id: number, data: OfferRequestInDto) {
    const request = await this.getRequestDetail(userId, id);
    if (request.status === 'fulfilled') {
      throw new ForbiddenException('Cannot update a fulfilled request');
    }

    const updateData: any = { ...data };
    if (data.all_cities !== undefined) updateData.all_cities = data.all_cities;

    const updated = await this.prisma.offerRequest.update({
      where: { id },
      data: updateData,
    });

    return updated;
  }

  async deleteRequest(userId: number, id: number) {
    const request = await this.getRequestDetail(userId, id);
    if (request.status === 'fulfilled') {
      throw new ForbiddenException('Cannot delete a fulfilled request');
    }
    await this.prisma.offerRequest.delete({ where: { id } });
    return true;
  }

  async listRequestOffers(userId: number, id: number, page = 1, pageSize = 10) {
    await this.getRequestDetail(userId, id); // Ensure ownership

    const [items, total] = await Promise.all([
      this.prisma.offer.findMany({
        where: { offer_request_id: id },
        orderBy: { created_at: 'desc' },
        skip: (page - 1) * pageSize,
        take: pageSize,
        include: { company: true },
      }),
      this.prisma.offer.count({ where: { offer_request_id: id } }),
    ]);

    return { items, total, page, pageSize };
  }

  async respondToOffer(userId: number, id: number, data: OfferResponseInDto) {
    const offer = await this.prisma.offer.findFirst({
      where: { id, offerRequest: { user_id: userId } },
      include: { offerRequest: true, company: true },
    });
    if (!offer) throw new NotFoundException('Offer not found');

    await this.prisma.offer.update({
      where: { id },
      data: { status: data.state },
    });

    if (data.state === 'accepted') {
      await this.prisma.offerRequest.update({
        where: { id: offer.offer_request_id },
        data: { status: 'accepted' },
      });
      // Reject others
      await this.prisma.offer.updateMany({
        where: { offer_request_id: offer.offer_request_id, id: { not: id } },
        data: { status: 'rejected' },
      });
    }

    // Notify company
    await this.notificationsService.sendGroupNotification(
      'custom',
      [offer.company_id], // Assuming group mapping handles company_id to members
      'تحديث العرض',
      `تم ${data.state === 'accepted' ? 'قبول' : 'رفض'} العرض الخاص بك للطلب رقم ${offer.offer_request_id}`,
      { type: 'offer_response', offer_id: id.toString(), state: data.state }
    );

    return true;
  }

  // --- Company Endpoints ---

  async listAvailableRequests(userId: number, companyId: number, status?: string, page = 1, pageSize = 10) {
    const { company } = await this.checkCompanyAccess(userId, companyId);
    
    const where: any = {
      OR: [
        { all_cities: true },
        { city_id: company.city_id },
      ],
    };
    if (status) where.status = status;

    const [items, total] = await Promise.all([
      this.prisma.offerRequest.findMany({
        where,
        orderBy: { created_at: 'desc' },
        skip: (page - 1) * pageSize,
        take: pageSize,
      }),
      this.prisma.offerRequest.count({ where }),
    ]);

    return { items, total, page, pageSize };
  }

  async replyToRequest(userId: number, companyId: number, requestId: number, data: OfferInDto) {
    const { company } = await this.checkCompanyAccess(userId, companyId);
    
    const request = await this.prisma.offerRequest.findUnique({
      where: { id: requestId },
      include: { user: true },
    });
    if (!request) throw new NotFoundException('Request not found');

    const existingOffer = await this.prisma.offer.findFirst({
      where: { offer_request_id: requestId, company_id: companyId },
    });
    if (existingOffer) throw new BadRequestException('You already sent an offer for this request');

    // Create Offer
    const offer = await this.prisma.offer.create({
      data: {
        offer_request_id: requestId,
        company_id: companyId,
        user_id: request.user_id,
        price: data.price,
        status: 'pending',
        created_at: new Date(),
        total_panel_power: data.total_panel_power ?? 0,
        panel_power: data.panel_power ?? 0,
        panel_count: data.panel_count ?? 0,
        panel_note: data.panel_note,
        battery_size: data.battery_size ?? 0,
        battery_count: data.battery_count ?? 0,
        battery_note: data.battery_note,
        battery_type: data.battery_type ?? 'gel',
        inverter_size: data.inverter_size ?? 0,
        inverter_count: data.inverter_count ?? 0,
        inverter_note: data.inverter_note,
        inverter_type: data.inverter_type ?? 'hybrid',
        note: data.note,
      },
    });

    // Create Lead (Customer)
    const existingLead = await this.prisma.customer.findFirst({
      where: { company_id: companyId, buyer_profile_id: request.user_id },
    });
    if (!existingLead) {
      await this.prisma.customer.create({
        data: {
          company_id: companyId,
          customer_type: 'lead',
          buyer_profile_id: request.user_id,
          full_name: request.user.first_name + ' ' + request.user.last_name,
          phone_number: request.user.phone,
          email: request.user.email,
          address: '',
          created_at: new Date(),
          updated_at: new Date(),
        },
      });
    }

    // Snapshots
    if (data.template_involves && data.template_involves.length > 0) {
      for (const item of data.template_involves) {
        const template = await this.prisma.involvementTemplate.findUnique({
          where: { id: item.template_id },
        });
        if (template && template.company_id === companyId) {
          const inv = await this.prisma.offerInvolvement.create({
            data: {
              name: template.name,
              quantity: item.quantity ?? 1,
              cost: template.cost,
              company_id: companyId,
            },
          });
          await this.prisma.offerInvolves.create({
            data: {
              offer_id: offer.id,
              offerinvolvement_id: inv.id,
            }
          });
        }
      }
    }

    if (request.status === 'open') {
      await this.prisma.offerRequest.update({
        where: { id: requestId },
        data: { status: 'offered' },
      });
    }

    await this.notificationsService.sendUserNotification(
      request.user_id,
      'عرض جديد',
      `الشركة ${company.name} قدمت عرضاً لطلبك`,
      { type: 'new_offer', offer_id: offer.id.toString() }
    );

    return offer;
  }

  async listCompanyOffers(userId: number, companyId: number, status?: string, page = 1, pageSize = 10) {
    await this.checkCompanyAccess(userId, companyId);
    
    const where: any = { company_id: companyId };
    if (status) where.status = status;

    const [items, total] = await Promise.all([
      this.prisma.offer.findMany({
        where,
        orderBy: { created_at: 'desc' },
        skip: (page - 1) * pageSize,
        take: pageSize,
      }),
      this.prisma.offer.count({ where }),
    ]);

    return { items, total, page, pageSize };
  }

  async getCompanyOffer(userId: number, companyId: number, id: number) {
    await this.checkCompanyAccess(userId, companyId);
    
    const offer = await this.prisma.offer.findFirst({
      where: { id, company_id: companyId },
      include: { offerInvolves: { include: { offerInvolvement: true } }, offerRequest: true },
    });
    if (!offer) throw new NotFoundException('Offer not found');
    return offer;
  }

  async updateCompanyOffer(userId: number, companyId: number, id: number, data: OfferInDto) {
    const offer = await this.getCompanyOffer(userId, companyId, id);
    if (offer.status === 'accepted') throw new ForbiddenException('Cannot edit an accepted offer');

    const updated = await this.prisma.offer.update({
      where: { id },
      data: {
        price: data.price,
        total_panel_power: data.total_panel_power ?? 0,
        panel_power: data.panel_power ?? 0,
        panel_count: data.panel_count ?? 0,
        panel_note: data.panel_note,
        battery_size: data.battery_size ?? 0,
        battery_count: data.battery_count ?? 0,
        battery_note: data.battery_note,
        battery_type: data.battery_type ?? 'gel',
        inverter_size: data.inverter_size ?? 0,
        inverter_count: data.inverter_count ?? 0,
        inverter_note: data.inverter_note,
        inverter_type: data.inverter_type ?? 'hybrid',
        note: data.note,
      },
    });

    if (data.template_involves) {
      await this.prisma.offerInvolves.deleteMany({ where: { offer_id: id } });
      for (const item of data.template_involves) {
        const template = await this.prisma.involvementTemplate.findUnique({
          where: { id: item.template_id },
        });
        if (template && template.company_id === companyId) {
          const inv = await this.prisma.offerInvolvement.create({
            data: {
              name: template.name,
              quantity: item.quantity ?? 1,
              cost: template.cost,
              company_id: companyId,
            },
          });
          await this.prisma.offerInvolves.create({
            data: {
              offer_id: id,
              offerinvolvement_id: inv.id,
            }
          });
        }
      }
    }

    return updated;
  }

  async deleteCompanyOffer(userId: number, companyId: number, id: number) {
    const offer = await this.getCompanyOffer(userId, companyId, id);
    if (offer.status === 'accepted') throw new ForbiddenException('Cannot delete an accepted offer');
    await this.prisma.offer.delete({ where: { id } });
    return true;
  }

  async completeCompanyOffer(userId: number, companyId: number, id: number) {
    const offer = await this.getCompanyOffer(userId, companyId, id);
    if (offer.status !== 'accepted') throw new BadRequestException('Only accepted offers can be completed');

    await this.prisma.offer.update({
      where: { id },
      data: { status: 'completed' },
    });

    await this.prisma.offerRequest.update({
      where: { id: offer.offer_request_id },
      data: { status: 'closed' },
    });

    return true;
  }

  // --- Involvement Templates ---

  async listTemplates(userId: number, companyId: number) {
    await this.checkCompanyAccess(userId, companyId);
    return this.prisma.involvementTemplate.findMany({
      where: { company_id: companyId, is_active: true },
    });
  }

  async createTemplate(userId: number, companyId: number, data: InvolvementTemplateInDto) {
    await this.checkCompanyAccess(userId, companyId);
    return this.prisma.involvementTemplate.create({
      data: {
        company_id: companyId,
        name: data.name,
        cost: data.cost,
        is_active: true,
        created_at: new Date(),
      },
    });
  }

  async updateTemplate(userId: number, companyId: number, id: number, data: InvolvementTemplateInDto) {
    await this.checkCompanyAccess(userId, companyId);
    const template = await this.prisma.involvementTemplate.findFirst({
      where: { id, company_id: companyId },
    });
    if (!template) throw new NotFoundException('Template not found');

    return this.prisma.involvementTemplate.update({
      where: { id },
      data: { name: data.name, cost: data.cost },
    });
  }

  async deleteTemplate(userId: number, companyId: number, id: number) {
    await this.checkCompanyAccess(userId, companyId);
    const template = await this.prisma.involvementTemplate.findFirst({
      where: { id, company_id: companyId },
    });
    if (!template) throw new NotFoundException('Template not found');

    return this.prisma.involvementTemplate.update({
      where: { id },
      data: { is_active: false },
    });
  }
}
