import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Param,
  Body,
  Headers,
  UseGuards,
  Request,
  ParseIntPipe,
} from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiHeader } from '@nestjs/swagger';
import { CrmService } from '../services/crm.service';
import { SupplierFormDto } from '../dto/crm.dto';
import { AuthGuard } from '@nestjs/passport';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../auth/decorators/roles.decorator';

@ApiTags('Company Suppliers (CRM)')
@ApiBearerAuth()
@ApiHeader({ name: 'company-id', required: true })
@Controller('shop/company-suppliers')
@UseGuards(AuthGuard('jwt'), RolesGuard)
@Roles('admin', 'manager', 'sales', 'staff')
export class CompanySuppliersController {
  constructor(private readonly crmService: CrmService) {}

  @Get()
  async findAll(@Request() req, @Headers('company-id') companyId: string) {
    return this.crmService.findAllSuppliers(req.user.id, parseInt(companyId));
  }

  @Get(':id')
  async findOne(
    @Request() req,
    @Headers('company-id') companyId: string,
    @Param('id', ParseIntPipe) id: number,
  ) {
    return this.crmService.findOneSupplier(
      req.user.id,
      parseInt(companyId),
      id,
    );
  }

  @Post()
  async create(
    @Request() req,
    @Headers('company-id') companyId: string,
    @Body() data: SupplierFormDto,
  ) {
    return this.crmService.createSupplier(
      req.user.id,
      parseInt(companyId),
      data,
    );
  }

  @Put(':id')
  async update(
    @Request() req,
    @Headers('company-id') companyId: string,
    @Param('id', ParseIntPipe) id: number,
    @Body() data: SupplierFormDto,
  ) {
    return this.crmService.updateSupplier(
      req.user.id,
      parseInt(companyId),
      id,
      data,
    );
  }

  @Delete(':id')
  @Roles('admin', 'manager')
  async remove(
    @Request() req,
    @Headers('company-id') companyId: string,
    @Param('id', ParseIntPipe) id: number,
  ) {
    return this.crmService.deleteSupplier(req.user.id, parseInt(companyId), id);
  }
}
