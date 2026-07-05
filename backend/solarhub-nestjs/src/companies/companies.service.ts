import { Injectable, BadRequestException, NotFoundException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { NotifierService } from '../notifications/notifier.service';
import { 
  CompanyRegisterDto, 
  CompanyUpdateDto, 
  InviteMemberDto, 
  CreateMemberDto,
  CompanyServiceCreateDto,
  CompanyServiceUpdateDto,
  CompanySubscriptionRequestCreateDto,
  CompanySubscriptionRequestReviewDto,
  PosterCreateDto,
  PosterReviewDto
} from './dto/company.dto';
import {
  CompanyTypeCreateDto,
  CompanyTypeUpdateDto,
  ServiceTypeCreateDto,
  ServiceTypeUpdateDto
} from './dto/types.dto';
import {
  CompanyWorkCreateDto,
  CompanyWorkUpdateDto,
  ContactCreateDto,
  ContactUpdateDto,
  PublicServiceCreateDto,
  PublicServiceUpdateDto,
  DeliveryOptionCreateDto,
  DeliveryOptionUpdateDto
} from './dto/works-contacts.dto';

@Injectable()
export class CompaniesService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly notificationsService: NotifierService
  ) {}

  // ==============================
  // Company CRUD
  // ==============================
  
  async registerCompany(userId: number, data: CompanyRegisterDto) {
    const existing = await this.prisma.company.findFirst({
      where: { name: data.name }
    });
    if (existing) {
      throw new BadRequestException('Company with this name already exists');
    }

    const company = await this.prisma.company.create({
      data: {
        name: data.name,
        company_type_id: data.company_type,
        description: data.description || '',
        address: data.address || '',
        phone: data.phone || '',
        allows_b2b: data.allows_b2b ?? true,
        allows_b2c: data.allows_b2c ?? true,
        city_id: data.city,
        status: 'active',
        created_at: new Date(),
        updated_at: new Date(),
        expire_date: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000) // 1 year default
      }
    });

    await this.prisma.companyMember.create({
      data: {
        company_id: company.id,
        user_id: userId,
        role: 'owner',
        joined_at: new Date()
      }
    });

    return company;
  }

  async listUserCompanies(userId: number) {
    const memberships = await this.prisma.companyMember.findMany({
      where: { user_id: userId },
      include: {
        company: {
          include: {
            companyType: true,
            city: true
          }
        }
      }
    });
    return memberships.map(m => m.company);
  }

  async getCompany(userId: number, companyId: number) {
    const member = await this.prisma.companyMember.findFirst({
      where: { user_id: userId, company_id: companyId }
    });
    if (!member) throw new ForbiddenException('Not a member of this company');

    return this.prisma.company.findUnique({
      where: { id: companyId },
      include: {
        companyType: true,
        city: true
      }
    });
  }

  async updateCompany(userId: number, companyId: number, data: CompanyUpdateDto) {
    const member = await this.prisma.companyMember.findFirst({
      where: { user_id: userId, company_id: companyId, role: { in: ['owner', 'admin'] } }
    });
    if (!member) throw new ForbiddenException('Not authorized');

    return this.prisma.company.update({
      where: { id: companyId },
      data: {
        name: data.name,
        company_type_id: data.company_type,
        description: data.description,
        address: data.address,
        phone: data.phone,
        allows_b2b: data.allows_b2b,
        allows_b2c: data.allows_b2c,
        city_id: data.city,
        currency_id: data.currency,
        updated_at: new Date()
      }
    });
  }

  async updateLogo(userId: number, companyId: number, file: Express.Multer.File) {
    const member = await this.prisma.companyMember.findFirst({
      where: { user_id: userId, company_id: companyId, role: { in: ['owner', 'admin'] } }
    });
    if (!member) throw new ForbiddenException('Not authorized');

    // Handle upload logic... for now just return the path
    return this.prisma.company.update({
      where: { id: companyId },
      data: { logo: file.path }
    });
  }

  // ==============================
  // Public Companies
  // ==============================
  
  async listPublicCompanies(filters: any) {
    const { type, search, city, page = 1, page_size = 20 } = filters;
    const skip = (page - 1) * page_size;

    const where: any = { status: 'active' };
    if (type) where.companyType = { ctype: type };
    if (city) where.city_id = city;
    if (search) where.name = { contains: search };

    const [companies, total] = await Promise.all([
      this.prisma.company.findMany({
        where,
        skip,
        take: Number(page_size),
        include: { companyType: true, city: true }
      }),
      this.prisma.company.count({ where })
    ]);

    return { items: companies, count: total };
  }

  async getPublicCompany(companyId: number) {
    const company = await this.prisma.company.findUnique({
      where: { id: companyId },
      include: { companyType: true, city: true }
    });
    if (!company) throw new NotFoundException('Company not found');
    return company;
  }

  // ==============================
  // Members
  // ==============================
  
  async listMembers(userId: number, companyId: number) {
    return this.prisma.companyMember.findMany({
      where: { company_id: companyId },
      include: { user: true }
    });
  }

  async inviteMember(userId: number, companyId: number, data: InviteMemberDto) {
    const userToInvite = await this.prisma.user.findFirst({ where: { email: data.email } });
    if (!userToInvite) throw new NotFoundException('User not found');

    const member = await this.prisma.companyMember.create({
      data: {
        company_id: companyId,
        user_id: userToInvite.id,
        role: data.role || 'staff',
        joined_at: new Date()
      }
    });

    // Fetch company name for notification
    const company = await this.prisma.company.findUnique({ where: { id: companyId } });
    await this.notificationsService.sendCompanyInvite({
      ...member,
      user_id: userToInvite.id,
      company_id: companyId,
      role: data.role || 'staff',
      company: { name: company?.name || 'Company' }
    });
    return member;
  }

  async createMember(userId: number, companyId: number, data: CreateMemberDto) {
    // In a real scenario, this would create a new User and assign them to CompanyMember
    return { message: 'createMember not fully implemented' };
  }

  async removeMember(userId: number, companyId: number, memberId: number) {
    return this.prisma.companyMember.deleteMany({
      where: { company_id: companyId, user_id: memberId }
    });
  }

  // ==============================
  // Services
  // ==============================
  
  async listServices(userId: number, companyId: number) {
    return this.prisma.companyService.findMany({
      where: { company_id: companyId }
    });
  }

  async createService(userId: number, companyId: number, data: CompanyServiceCreateDto) {
    return this.prisma.companyService.create({
      data: {
        company_id: companyId,
        title: data.title,
        price: data.price,
        description: data.description,
        created_at: new Date(),
        updated_at: new Date()
      }
    });
  }

  async updateService(userId: number, companyId: number, serviceId: number, data: CompanyServiceUpdateDto) {
    return this.prisma.companyService.update({
      where: { id: serviceId },
      data: {
        ...data,
        updated_at: new Date()
      }
    });
  }

  async deleteService(userId: number, companyId: number, serviceId: number) {
    return this.prisma.companyService.delete({
      where: { id: serviceId }
    });
  }

  async listCatalogs() {
    return this.prisma.companyServiceCatalog.findMany({
      where: { is_active: true },
      orderBy: { sort_order: 'asc' }
    });
  }

  // ==============================
  // Company Types
  // ==============================
  
  async listCompanyTypes() {
    return this.prisma.companyType.findMany();
  }

  async createCompanyType(data: CompanyTypeCreateDto) {
    return this.prisma.companyType.create({
      data: {
        name: data.name,
        ctype: data.ctype,
        created_at: new Date()
      }
    });
  }

  async updateCompanyType(id: number, data: CompanyTypeUpdateDto) {
    return this.prisma.companyType.update({
      where: { id },
      data
    });
  }

  async deleteCompanyType(id: number) {
    return this.prisma.companyType.delete({ where: { id } });
  }

  // ==============================
  // Service Types
  // ==============================
  
  async listServiceTypes() {
    return this.prisma.serviceType.findMany();
  }

  async createServiceType(data: ServiceTypeCreateDto) {
    return this.prisma.serviceType.create({
      data: {
        name: data.name,
        description: data.description,
        created_at: new Date()
      }
    });
  }

  async updateServiceType(id: number, data: ServiceTypeUpdateDto) {
    return this.prisma.serviceType.update({
      where: { id },
      data
    });
  }

  async deleteServiceType(id: number) {
    return this.prisma.serviceType.delete({ where: { id } });
  }

  // ==============================
  // Company Works
  // ==============================

  async listWorks(companyId: number) {
    return this.prisma.companyWork.findMany({
      where: { company_id: companyId },
      include: { companyWorkImage: true },
      orderBy: { created_at: 'desc' }
    });
  }

  async getWork(companyId: number, workId: number) {
    return this.prisma.companyWork.findUnique({
      where: { id: workId, company_id: companyId },
      include: { companyWorkImage: true }
    });
  }

  async createWork(companyId: number, data: CompanyWorkCreateDto) {
    return this.prisma.companyWork.create({
      data: {
        company_id: companyId,
        title: data.title,
        body: data.body,
        created_at: new Date(),
        updated_at: new Date()
      }
    });
  }

  async updateWork(companyId: number, workId: number, data: CompanyWorkUpdateDto) {
    return this.prisma.companyWork.update({
      where: { id: workId, company_id: companyId },
      data: {
        ...data,
        updated_at: new Date()
      }
    });
  }

  async deleteWork(companyId: number, workId: number) {
    return this.prisma.companyWork.delete({
      where: { id: workId, company_id: companyId }
    });
  }

  // ==============================
  // Company Contacts
  // ==============================

  async listContacts(companyId: number) {
    return this.prisma.contact.findMany({
      where: { company_id: companyId },
      orderBy: { created_at: 'desc' }
    });
  }

  async createContact(companyId: number, data: ContactCreateDto) {
    return this.prisma.contact.create({
      data: {
        company_id: companyId,
        name: data.name,
        email: data.email,
        phone: data.phone,
        notes: data.notes,
        created_at: new Date()
      }
    });
  }

  async updateContact(companyId: number, contactId: number, data: ContactUpdateDto) {
    return this.prisma.contact.update({
      where: { id: contactId, company_id: companyId },
      data
    });
  }

  async deleteContact(companyId: number, contactId: number) {
    return this.prisma.contact.delete({
      where: { id: contactId, company_id: companyId }
    });
  }

  // ==============================
  // Company Public Services
  // ==============================

  async listPublicServices(companyId: number) {
    return this.prisma.companyService.findMany({
      where: { company_id: companyId },
      orderBy: { created_at: 'desc' }
    });
  }

  async createPublicService(companyId: number, data: PublicServiceCreateDto) {
    return this.prisma.companyService.create({
      data: {
        company_id: companyId,
        title: data.title,
        price: data.price,
        description: data.description,
        created_at: new Date(),
        updated_at: new Date()
      }
    });
  }

  async updatePublicService(companyId: number, serviceId: number, data: PublicServiceUpdateDto) {
    return this.prisma.companyService.update({
      where: { id: serviceId, company_id: companyId },
      data: {
        ...data,
        updated_at: new Date()
      }
    });
  }

  async deletePublicService(companyId: number, serviceId: number) {
    return this.prisma.companyService.delete({
      where: { id: serviceId, company_id: companyId }
    });
  }

  // ==============================
  // Company Delivery Options
  // ==============================

  async listDeliveryOptions(companyId: number) {
    return this.prisma.deliveryOption.findMany({
      where: { company_id: companyId },
      orderBy: { created_at: 'desc' }
    });
  }

  async createDeliveryOption(companyId: number, data: DeliveryOptionCreateDto) {
    return this.prisma.deliveryOption.create({
      data: {
        company_id: companyId,
        name: data.name,
        cost: data.cost,
        estimated_days_min: data.estimated_days_min,
        estimated_days_max: data.estimated_days_max,
        description: data.description,
        is_active: data.is_active ?? true,
        created_at: new Date()
      }
    });
  }

  async updateDeliveryOption(companyId: number, optionId: number, data: DeliveryOptionUpdateDto) {
    return this.prisma.deliveryOption.update({
      where: { id: optionId, company_id: companyId },
      data
    });
  }

  async deleteDeliveryOption(companyId: number, optionId: number) {
    return this.prisma.deliveryOption.delete({
      where: { id: optionId, company_id: companyId }
    });
  }

  // ==============================
  // Posters
  // ==============================
  
  async listCompanyPosters(userId: number, companyId: number) {
    // Stub
    return [];
  }

  async createPoster(userId: number, companyId: number, data: PosterCreateDto, file: Express.Multer.File) {
    // Stub
    return { message: 'Poster created' };
  }

  async listAllPosters() {
    // Stub
    return [];
  }

  async reviewPoster(posterId: number, data: PosterReviewDto) {
    // Stub
    return { message: 'Poster reviewed' };
  }

  async listActivePosters() {
    const now = new Date();
    return this.prisma.poster.findMany({
      where: {
        status: 'approved',
        is_active: true,
        expires_at: { gt: now }
      },
      include: { company: { select: { id: true, name: true, logo: true } } },
      orderBy: { approved_at: 'desc' }
    });
  }

  async togglePosterActive(userId: number, companyId: number, posterId: number) {
    const poster = await this.prisma.poster.findUnique({ where: { id: posterId } });
    if (!poster || Number(poster.company_id) !== companyId) {
      throw new Error('Poster not found');
    }
    return this.prisma.poster.update({
      where: { id: posterId },
      data: { is_active: !poster.is_active }
    });
  }

  async extendPoster(posterId: number, data: any) {
    const poster = await this.prisma.poster.findUnique({ where: { id: posterId } });
    if (!poster) throw new Error('Poster not found');

    let newExpiresAt = poster.expires_at || new Date();
    // if expired, start from now
    if (newExpiresAt < new Date()) {
      newExpiresAt = new Date();
    }
    
    // add days
    newExpiresAt.setDate(newExpiresAt.getDate() + data.duration_days);

    return this.prisma.poster.update({
      where: { id: posterId },
      data: {
        expires_at: newExpiresAt,
        duration_days: (poster.duration_days || 0) + data.duration_days,
        status: 'approved'
      }
    });
  }

  // ==============================
  // Subscriptions
  // ==============================
  
  async requestSubscription(userId: number, companyId: number, data: CompanySubscriptionRequestCreateDto) {
    // Stub
    return { message: 'requestSubscription requested' };
  }

  async listCompanySubscriptions(userId: number, companyId: number) {
    // Stub
    return [];
  }

  async listAllSubscriptions() {
    // Stub
    return [];
  }

  async reviewSubscription(requestId: number, data: CompanySubscriptionRequestReviewDto) {
    // Stub
    return { message: 'Subscription reviewed' };
  }
}
