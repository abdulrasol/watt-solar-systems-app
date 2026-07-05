import { Controller, Get, Post, Put, Delete, Body, Param, UseGuards, Request, Headers } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiHeader } from '@nestjs/swagger';
import { OffersService } from '../offers.service';
import { InvolvementTemplateInDto } from '../dto/involvement-template.dto';
import { AuthGuard } from '@nestjs/passport';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../auth/decorators/roles.decorator';

@ApiTags('Involvement Templates')
@ApiBearerAuth()
@ApiHeader({ name: 'company-id', description: 'Company ID', required: true })
@Controller('offers/involvements')
@UseGuards(AuthGuard('jwt'), RolesGuard)
@Roles('admin', 'manager', 'sales')
export class InvolvementTemplatesController {
  constructor(private readonly offersService: OffersService) {}

  @Get()
  async listInvolves(@Request() req, @Headers('company-id') companyId: string) {
    const userId = req.user.userId;
    const items = await this.offersService.listTemplates(userId, Number(companyId));
    return {
      status: 200,
      message: 'Templates retrieved',
      body: items,
      error: false,
      message_user: null,
    };
  }

  @Post()
  async createInvolve(@Request() req, @Headers('company-id') companyId: string, @Body() data: InvolvementTemplateInDto) {
    const userId = req.user.userId;
    const item = await this.offersService.createTemplate(userId, Number(companyId), data);
    return {
      status: 200,
      message: 'Template created',
      body: item,
      error: false,
      message_user: null,
    };
  }

  @Put(':id')
  async updateInvolve(@Request() req, @Headers('company-id') companyId: string, @Param('id') id: string, @Body() data: InvolvementTemplateInDto) {
    const userId = req.user.userId;
    const item = await this.offersService.updateTemplate(userId, Number(companyId), Number(id), data);
    return {
      status: 200,
      message: 'Template updated',
      body: item,
      error: false,
      message_user: null,
    };
  }

  @Delete(':id')
  async deleteInvolve(@Request() req, @Headers('company-id') companyId: string, @Param('id') id: string) {
    const userId = req.user.userId;
    await this.offersService.deleteTemplate(userId, Number(companyId), Number(id));
    return {
      status: 200,
      message: 'Item removed from catalog',
      body: {},
      error: false,
      message_user: null,
    };
  }
}
