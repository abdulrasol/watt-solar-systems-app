import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AuthModule } from './auth/auth.module';
import { PrismaModule } from './prisma/prisma.module';
import { MailerModule } from '@nestjs-modules/mailer';
import { AppConfigModule } from './app-config/app-config.module';
import { NotificationsModule } from './notifications/notifications.module';
import { CompaniesModule } from './companies/companies.module';
import { OffersModule } from './offers/offers.module';
import { ShopModule } from './shop/shop.module';

@Module({
  imports: [
    PrismaModule,
    AuthModule,
    MailerModule.forRoot({
      transport: {
        host: 'smtp.example.com', // Replace with real SMTP
        port: 587,
        auth: {
          user: 'user@example.com',
          pass: 'password',
        },
      },
      defaults: {
        from: '"No Reply" <noreply@solarhub.com>',
      },
    }),
    AppConfigModule,
    NotificationsModule,
    CompaniesModule,
    OffersModule,
    ShopModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule { }
