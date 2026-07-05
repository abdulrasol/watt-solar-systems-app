import { Controller, Get, Post, Put, Delete, Body, Param, UseGuards } from '@nestjs/common';
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
