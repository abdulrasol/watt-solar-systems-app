import { Module } from '@nestjs/common';
import { CompaniesService } from './companies.service';

import { NotificationsModule } from '../notifications/notifications.module';
import { CompaniesController, PublicCompaniesController } from './controllers/companies.controller';
import { CompanyMembersController } from './controllers/members.controller';
import { CompanyServicesController, CompanyServiceCatalogsController } from './controllers/services.controller';
import { CompanyPostersController } from './controllers/posters.controller';
import { CompanySubscriptionsController } from './controllers/subscriptions.controller';

import { CompanyTypesController } from './controllers/company-types.controller';
import { ServiceTypesController } from './controllers/service-types.controller';
import { CompanyWorksController } from './controllers/company-works.controller';
import { CompanyContactsController } from './controllers/contacts.controller';
import { CompanyDeliveryOptionsController } from './controllers/delivery-options.controller';
import { CompanyPublicServicesController } from './controllers/public-services.controller';

@Module({
  imports: [NotificationsModule],
  providers: [CompaniesService],
  controllers: [
    CompanyPostersController,
    CompaniesController,
    PublicCompaniesController,
    CompanyMembersController,
    CompanyServicesController,
    CompanyServiceCatalogsController,
    CompanySubscriptionsController,
    CompanyTypesController,
    ServiceTypesController,
    CompanyWorksController,
    CompanyContactsController,
    CompanyDeliveryOptionsController,
    CompanyPublicServicesController
  ]
})
export class CompaniesModule {}
