import { Controller, Get, Post, Put, Delete, Body, Param, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { AppConfigService } from '../app-config.service';
import { CountryDto } from '../dto/country.dto';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { SuperuserGuard } from '../../auth/guards/superuser.guard';
import { RawResponse } from '../../common/decorators/raw-response.decorator';

@ApiTags('Countries')
@Controller('countries')
export class CountryController {
  constructor(private readonly configService: AppConfigService) {}

  @Get()
  @RawResponse()
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
