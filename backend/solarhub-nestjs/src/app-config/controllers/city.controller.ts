import { Controller, Get, Post, Put, Delete, Body, Param, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { AppConfigService } from '../app-config.service';
import { CityDto, CityUpdateDto } from '../dto/city.dto';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { SuperuserGuard } from '../../auth/guards/superuser.guard';
import { RawResponse } from '../../common/decorators/raw-response.decorator';

@ApiTags('Cities')
@Controller('cities')
export class CityController {
  constructor(private readonly configService: AppConfigService) {}

  @ApiQuery({ name: 'country_id', required: false })
  @Get()
  @RawResponse()
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
