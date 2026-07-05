import { Module } from '@nestjs/common';
import { OffersService } from './offers.service';
import { PrismaModule } from '../prisma/prisma.module';
import { NotificationsModule } from '../notifications/notifications.module';
import { UserOfferRequestsController } from './controllers/user-offer-requests.controller';
import { CompanyOffersController } from './controllers/company-offers.controller';
import { InvolvementTemplatesController } from './controllers/involvement-templates.controller';
import { AdminOffersController } from './controllers/admin-offers.controller';

@Module({
  imports: [PrismaModule, NotificationsModule],
  controllers: [
    UserOfferRequestsController,
    CompanyOffersController,
    InvolvementTemplatesController,
    AdminOffersController,
  ],
  providers: [OffersService],
  exports: [OffersService],
})
export class OffersModule {}
