import { PrismaService } from '../prisma/prisma.service';
import { ConfigCreateDto, ConfigUpdateDto } from './dto/config.dto';
import { CompanyApproveDto } from './dto/company.dto';
import { CurrencyDto } from './dto/currency.dto';
import { CountryDto } from './dto/country.dto';
import { CityDto, CityUpdateDto } from './dto/city.dto';
import { SubscriptionPlanDto } from './dto/subscription.dto';
import { GlobalCategoryDto } from './dto/category.dto';
import { FeedbackFormDto, FeedbackUpdateFormDto } from './dto/feedback.dto';
import * as path from 'path';
import * as fs from 'fs';

import { Injectable as NestInjectable, NotFoundException as NestNotFoundException, BadRequestException as NestBadRequestException } from '@nestjs/common';

@NestInjectable()
export class AppConfigService {
  constructor(private prisma: PrismaService) {}

  // --- AppConfig ---
  async listConfigs() {
    return this.prisma.appConfig.findMany();
  }

  async createConfig(data: ConfigCreateDto) {
    const exists = await this.prisma.appConfig.findUnique({ where: { key: data.key } });
    if (exists) {
      throw new NestBadRequestException('Configuration key already exists.');
    }
    return this.prisma.appConfig.create({
      data: {
        key: data.key,
        value: data.value ?? false,
        description: data.description,
        updated_at: new Date(),
      },
    });
  }

  async updateConfig(key: string, data: ConfigUpdateDto) {
    const config = await this.prisma.appConfig.findUnique({ where: { key } });
    if (!config) throw new NestNotFoundException(`Configuration '${key}' not found.`);

    return this.prisma.appConfig.update({
      where: { key },
      data: {
        value: data.value,
        description: data.description ?? config.description,
        updated_at: new Date(),
      },
    });
  }

  async deleteConfig(key: string) {
    const config = await this.prisma.appConfig.findUnique({ where: { key } });
    if (!config) throw new NestNotFoundException(`Configuration '${key}' not found.`);
    await this.prisma.appConfig.delete({ where: { key } });
    return {};
  }

  // --- Currency ---
  async getDefaultCurrency() {
    let currency = await this.prisma.currency.findFirst({ where: { is_default: true } });
    if (!currency) {
      currency = await this.prisma.currency.findFirst();
      if (!currency) {
        throw new NestNotFoundException('No currencies found in the system.');
      }
    }
    return currency;
  }

  async listCurrencies() {
    return this.prisma.currency.findMany();
  }

  async createCurrency(data: CurrencyDto) {
    return this.prisma.currency.create({
      data: {
        name: data.name,
        code: data.code,
        symbol: data.symbol,
        is_default: data.is_default ?? false,
        created_at: new Date(),
      },
    });
  }

  async updateCurrency(id: number, data: CurrencyDto) {
    const currency = await this.prisma.currency.findUnique({ where: { id } });
    if (!currency) throw new NestNotFoundException(`Currency not found.`);

    return this.prisma.currency.update({
      where: { id },
      data: {
        name: data.name,
        code: data.code,
        symbol: data.symbol,
        is_default: data.is_default ?? currency.is_default,
      },
    });
  }

  async deleteCurrency(id: number) {
    const currency = await this.prisma.currency.findUnique({ where: { id } });
    if (!currency) throw new NestNotFoundException(`Currency not found.`);
    await this.prisma.currency.delete({ where: { id } });
    return {};
  }

  // --- Country ---
  async listCountries() {
    return this.prisma.country.findMany();
  }

  async createCountry(data: CountryDto) {
    return this.prisma.country.create({
      data: {
        name: data.name,
        code: data.code ?? '',
        created_at: new Date(),
      },
    });
  }

  async updateCountry(id: number, data: CountryDto) {
    const country = await this.prisma.country.findUnique({ where: { id } });
    if (!country) throw new NestNotFoundException(`Country not found.`);
    return this.prisma.country.update({
      where: { id },
      data: {
        name: data.name,
        code: data.code ?? country.code,
      },
    });
  }

  async deleteCountry(id: number) {
    const country = await this.prisma.country.findUnique({ where: { id } });
    if (!country) throw new NestNotFoundException(`Country not found.`);
    await this.prisma.country.delete({ where: { id } });
    return {};
  }

  // --- City ---
  async listCities(country_id?: number) {
    return this.prisma.city.findMany({
      where: country_id ? { country_id } : undefined,
      include: { country: true },
    });
  }

  async createCity(data: CityDto) {
    return this.prisma.city.create({
      data: {
        name: data.name,
        code: data.code,
        country_id: data.country_id,
        created_at: new Date(),
      },
      include: { country: true },
    });
  }

  async updateCity(id: number, data: CityUpdateDto) {
    const city = await this.prisma.city.findUnique({ where: { id } });
    if (!city) throw new NestNotFoundException(`City not found.`);
    return this.prisma.city.update({
      where: { id },
      data: {
        name: data.name ?? city.name,
        code: data.code ?? city.code,
        country_id: data.country_id ?? city.country_id,
      },
      include: { country: true },
    });
  }

  async deleteCity(id: number) {
    const city = await this.prisma.city.findUnique({ where: { id } });
    if (!city) throw new NestNotFoundException(`City not found.`);
    await this.prisma.city.delete({ where: { id } });
    return {};
  }

  // --- SubscriptionPlan ---
  async listSubscriptions() {
    return this.prisma.subscriptionPlan.findMany();
  }

  async createSubscription(data: SubscriptionPlanDto) {
    return this.prisma.subscriptionPlan.create({
      data: {
        name: data.name,
        duration_days: data.duration_days,
        price: data.price,
        description: data.description,
        is_active: data.is_active ?? true,
        created_at: new Date(),
      },
    });
  }

  async updateSubscription(id: number, data: SubscriptionPlanDto) {
    const sub = await this.prisma.subscriptionPlan.findUnique({ where: { id } });
    if (!sub) throw new NestNotFoundException(`Subscription plan not found.`);
    return this.prisma.subscriptionPlan.update({
      where: { id },
      data: {
        name: data.name,
        duration_days: data.duration_days,
        price: data.price,
        description: data.description ?? sub.description,
        is_active: data.is_active ?? sub.is_active,
      },
    });
  }

  async deleteSubscription(id: number) {
    const sub = await this.prisma.subscriptionPlan.findUnique({ where: { id } });
    if (!sub) throw new NestNotFoundException(`Subscription plan not found.`);
    await this.prisma.subscriptionPlan.delete({ where: { id } });
    return {};
  }

  // --- GlobalCategory ---
  async listCategories() {
    return this.prisma.globalCategory.findMany();
  }

  async createCategory(data: GlobalCategoryDto) {
    return this.prisma.globalCategory.create({
      data: {
        name: data.name,
        icon: data.icon,
      },
    });
  }

  async updateCategory(id: number, data: GlobalCategoryDto) {
    const cat = await this.prisma.globalCategory.findUnique({ where: { id } });
    if (!cat) throw new NestNotFoundException(`Global Category not found.`);
    return this.prisma.globalCategory.update({
      where: { id },
      data: {
        name: data.name,
        icon: data.icon ?? cat.icon,
      },
    });
  }

  async deleteCategory(id: number) {
    const cat = await this.prisma.globalCategory.findUnique({ where: { id } });
    if (!cat) throw new NestNotFoundException(`Global Category not found.`);
    await this.prisma.globalCategory.delete({ where: { id } });
    return {};
  }

  // --- Notification ---
  async listNotifications() {
    return this.prisma.notification.findMany({
      orderBy: { created_at: 'desc' },
    });
  }

  // --- Feedback ---
  async listFeedbacks() {
    return this.prisma.feedback.findMany();
  }

  async createFeedback(data: FeedbackFormDto, imagePath?: string) {
    return this.prisma.feedback.create({
      data: {
        name: data.name,
        phone_number: data.phone_number,
        message: data.message,
        is_read: false,
        image: imagePath,
        created_at: new Date(),
      },
    });
  }

  async updateFeedback(id: number, data: FeedbackUpdateFormDto) {
    const feedback = await this.prisma.feedback.findUnique({ where: { id } });
    if (!feedback) throw new NestNotFoundException(`Feedback not found.`);
    return this.prisma.feedback.update({
      where: { id },
      data: {
        is_read: data.is_read,
      },
    });
  }

  async deleteFeedback(id: number) {
    const feedback = await this.prisma.feedback.findUnique({ where: { id } });
    if (!feedback) throw new NestNotFoundException(`Feedback not found.`);
    await this.prisma.feedback.delete({ where: { id } });
    return {};
  }

  // --- Company Admin ---
  async listCompanies() {
    return this.prisma.company.findMany({
      select: {
        id: true,
        name: true,
        company_type_id: true,
        status: true,
        created_at: true,
      },
    });
  }

  async updateCompanyStatus(id: number, data: CompanyApproveDto) {
    const validStatuses = ['active', 'rejected', 'pending']; // Expand as needed
    if (!validStatuses.includes(data.status)) {
      throw new NestBadRequestException('Invalid status provided.');
    }
    const company = await this.prisma.company.findUnique({ where: { id } });
    if (!company) throw new NestNotFoundException(`Company not found.`);
    return this.prisma.company.update({
      where: { id },
      data: { status: data.status },
    });
  }
}
