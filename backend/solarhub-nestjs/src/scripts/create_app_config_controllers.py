import os

controller_dir = "src/app-config/controllers"
os.makedirs(controller_dir, exist_ok=True)

controllers = {
    "config.controller.ts": """import { Controller, Get, Post, Put, Delete, Body, Param, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { AppConfigService } from '../app-config.service';
import { ConfigCreateDto, ConfigUpdateDto } from '../dto/config.dto';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { SuperuserGuard } from '../../auth/guards/superuser.guard';

@ApiTags('App Config')
@Controller('config')
export class ConfigController {
  constructor(private readonly configService: AppConfigService) {}

  @Get()
  async listConfigs() {
    return this.configService.listConfigs();
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, SuperuserGuard)
  @Post()
  async createConfig(@Body() data: ConfigCreateDto) {
    return this.configService.createConfig(data);
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, SuperuserGuard)
  @Put(':key')
  async updateConfig(@Param('key') key: string, @Body() data: ConfigUpdateDto) {
    return this.configService.updateConfig(key, data);
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, SuperuserGuard)
  @Delete(':key')
  async deleteConfig(@Param('key') key: string) {
    return this.configService.deleteConfig(key);
  }
}
""",

    "currency.controller.ts": """import { Controller, Get, Post, Put, Delete, Body, Param, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { AppConfigService } from '../app-config.service';
import { CurrencyDto } from '../dto/currency.dto';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { SuperuserGuard } from '../../auth/guards/superuser.guard';

@ApiTags('Currencies')
@Controller()
export class CurrencyController {
  constructor(private readonly configService: AppConfigService) {}

  @Get('currency/default')
  async getDefaultCurrency() {
    return this.configService.getDefaultCurrency();
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, SuperuserGuard)
  @Get('currencies')
  async listCurrencies() {
    return this.configService.listCurrencies();
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, SuperuserGuard)
  @Post('currencies')
  async createCurrency(@Body() data: CurrencyDto) {
    return this.configService.createCurrency(data);
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, SuperuserGuard)
  @Put('currencies/:curr_id')
  async updateCurrency(@Param('curr_id') curr_id: number, @Body() data: CurrencyDto) {
    return this.configService.updateCurrency(Number(curr_id), data);
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, SuperuserGuard)
  @Delete('currencies/:curr_id')
  async deleteCurrency(@Param('curr_id') curr_id: number) {
    return this.configService.deleteCurrency(Number(curr_id));
  }
}
""",

    "country.controller.ts": """import { Controller, Get, Post, Put, Delete, Body, Param, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { AppConfigService } from '../app-config.service';
import { CountryDto } from '../dto/country.dto';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { SuperuserGuard } from '../../auth/guards/superuser.guard';

@ApiTags('Countries')
@Controller('countries')
export class CountryController {
  constructor(private readonly configService: AppConfigService) {}

  @Get()
  async listCountries() {
    return this.configService.listCountries();
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, SuperuserGuard)
  @Post()
  async createCountry(@Body() data: CountryDto) {
    return this.configService.createCountry(data);
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, SuperuserGuard)
  @Put(':country_id')
  async updateCountry(@Param('country_id') country_id: number, @Body() data: CountryDto) {
    return this.configService.updateCountry(Number(country_id), data);
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, SuperuserGuard)
  @Delete(':country_id')
  async deleteCountry(@Param('country_id') country_id: number) {
    return this.configService.deleteCountry(Number(country_id));
  }
}
""",

    "city.controller.ts": """import { Controller, Get, Post, Put, Delete, Body, Param, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { AppConfigService } from '../app-config.service';
import { CityDto, CityUpdateDto } from '../dto/city.dto';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { SuperuserGuard } from '../../auth/guards/superuser.guard';

@ApiTags('Cities')
@Controller('cities')
export class CityController {
  constructor(private readonly configService: AppConfigService) {}

  @ApiQuery({ name: 'country_id', required: false })
  @Get()
  async listCities(@Query('country_id') country_id?: number) {
    return this.configService.listCities(country_id ? Number(country_id) : undefined);
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, SuperuserGuard)
  @Post()
  async createCity(@Body() data: CityDto) {
    return this.configService.createCity(data);
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, SuperuserGuard)
  @Put(':city_id')
  async updateCity(@Param('city_id') city_id: number, @Body() data: CityUpdateDto) {
    return this.configService.updateCity(Number(city_id), data);
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, SuperuserGuard)
  @Delete(':city_id')
  async deleteCity(@Param('city_id') city_id: number) {
    return this.configService.deleteCity(Number(city_id));
  }
}
""",

    "subscription.controller.ts": """import { Controller, Get, Post, Put, Delete, Body, Param, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { AppConfigService } from '../app-config.service';
import { SubscriptionPlanDto } from '../dto/subscription.dto';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { SuperuserGuard } from '../../auth/guards/superuser.guard';

@ApiTags('Subscriptions')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, SuperuserGuard)
@Controller('subscriptions')
export class SubscriptionController {
  constructor(private readonly configService: AppConfigService) {}

  @Get()
  async listSubscriptions() {
    return this.configService.listSubscriptions();
  }

  @Post()
  async createSubscription(@Body() data: SubscriptionPlanDto) {
    return this.configService.createSubscription(data);
  }

  @Put(':sub_id')
  async updateSubscription(@Param('sub_id') sub_id: number, @Body() data: SubscriptionPlanDto) {
    return this.configService.updateSubscription(Number(sub_id), data);
  }

  @Delete(':sub_id')
  async deleteSubscription(@Param('sub_id') sub_id: number) {
    return this.configService.deleteSubscription(Number(sub_id));
  }
}
""",

    "category.controller.ts": """import { Controller, Get, Post, Put, Delete, Body, Param, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { AppConfigService } from '../app-config.service';
import { GlobalCategoryDto } from '../dto/category.dto';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { SuperUserGuard } from '../../auth/guards/superuser.guard';

@ApiTags('Categories')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, SuperUserGuard)
@Controller('categories')
export class CategoryController {
  constructor(private readonly configService: AppConfigService) {}

  @Get()
  async listCategories() {
    return this.configService.listCategories();
  }

  @Post()
  async createCategory(@Body() data: GlobalCategoryDto) {
    return this.configService.createCategory(data);
  }

  @Put(':id')
  async updateCategory(@Param('id') id: number, @Body() data: GlobalCategoryDto) {
    return this.configService.updateCategory(Number(id), data);
  }

  @Delete(':id')
  async deleteCategory(@Param('id') id: number) {
    return this.configService.deleteCategory(Number(id));
  }
}
""",

    "feedback.controller.ts": """import { Controller, Get, Post, Put, Delete, Body, Param, UseGuards, UseInterceptors, UploadedFile } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiConsumes } from '@nestjs/swagger';
import { FileInterceptor } from '@nestjs/platform-express';
import { AppConfigService } from '../app-config.service';
import { FeedbackFormDto, FeedbackUpdateFormDto } from '../dto/feedback.dto';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { SuperUserGuard } from '../../auth/guards/superuser.guard';
import { diskStorage } from 'multer';
import * as path from 'path';

@ApiTags('Feedbacks')
@Controller()
export class FeedbackController {
  constructor(private readonly configService: AppConfigService) {}

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, SuperUserGuard)
  @Get('feedbacks')
  async listFeedbacks() {
    return this.configService.listFeedbacks();
  }

  @Post('feedbacks')
  @ApiConsumes('multipart/form-data')
  @UseInterceptors(FileInterceptor('attachment', {
    storage: diskStorage({
      destination: './uploads/feedbacks',
      filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
      }
    })
  }))
  async createFeedback(@Body() data: FeedbackFormDto, @UploadedFile() image: Express.Multer.File) {
    return this.configService.createFeedback(data, image ? image.path : undefined);
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, SuperUserGuard)
  @Put('feedback/s:id') // Maintained typo for backward compatibility as noted
  async updateFeedback(@Param('id') id: number, @Body() data: FeedbackUpdateFormDto) {
    return this.configService.updateFeedback(Number(id), data);
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, SuperUserGuard)
  @Delete('feedback/:id')
  async deleteFeedback(@Param('id') id: number) {
    return this.configService.deleteFeedback(Number(id));
  }
}
""",

    "admin-company.controller.ts": """import { Controller, Get, Post, Body, Param, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { AppConfigService } from '../app-config.service';
import { CompanyApproveDto } from '../dto/company.dto';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { SuperUserGuard } from '../../auth/guards/superuser.guard';

@ApiTags('Admin Companies')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, SuperUserGuard)
@Controller('companies')
export class AdminCompanyController {
  constructor(private readonly configService: AppConfigService) {}

  @Get()
  async listCompanies() {
    return this.configService.listCompanies();
  }

  @Post(':company_id/status')
  async updateCompanyStatus(@Param('company_id') company_id: number, @Body() data: CompanyApproveDto) {
    return this.configService.updateCompanyStatus(Number(company_id), data);
  }
}
""",

    "notification.controller.ts": """import { Controller, Get, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { AppConfigService } from '../app-config.service';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { SuperUserGuard } from '../../auth/guards/superuser.guard';

@ApiTags('Notifications')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, SuperUserGuard)
@Controller('notifications')
export class NotificationController {
  constructor(private readonly configService: AppConfigService) {}

  @Get()
  async listNotifications() {
    return this.configService.listNotifications();
  }
}
"""
}

for filename, content in controllers.items():
    with open(os.path.join(controller_dir, filename), "w") as f:
        f.write(content)

print("Controllers generated successfully.")
