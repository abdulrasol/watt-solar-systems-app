import { Module } from '@nestjs/common';
import { AppConfigService } from './app-config.service';
import { ConfigController } from './controllers/config.controller';
import { CurrencyController } from './controllers/currency.controller';
import { CountryController } from './controllers/country.controller';
import { CityController } from './controllers/city.controller';
import { SubscriptionController } from './controllers/subscription.controller';
import { CategoryController } from './controllers/category.controller';
import { FeedbackController } from './controllers/feedback.controller';
import { AdminCompanyController } from './controllers/admin-company.controller';
import { NotificationController } from './controllers/notification.controller';

@Module({
  providers: [AppConfigService],
  controllers: [
    ConfigController,
    CurrencyController,
    CountryController,
    CityController,
    SubscriptionController,
    CategoryController,
    FeedbackController,
    AdminCompanyController,
    NotificationController,
  ],
  exports: [AppConfigService],
})
export class AppConfigModule {}
