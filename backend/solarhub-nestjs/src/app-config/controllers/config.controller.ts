import { Controller, Get, Post, Put, Delete, Body, Param, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { AppConfigService } from '../app-config.service';
import { ConfigCreateDto, ConfigUpdateDto } from '../dto/config.dto';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { SuperuserGuard } from '../../auth/guards/superuser.guard';

import { RawResponse } from '../../common/decorators/raw-response.decorator';

@ApiTags('App Config')
@Controller('config')
export class ConfigController {
  constructor(private readonly configService: AppConfigService) {}

  @Get()
  @RawResponse()
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
