import os

dto_dir = "src/companies/dto"
os.makedirs(dto_dir, exist_ok=True)

dtos = {
    "company.dto.ts": """import { IsString, IsInt, IsOptional, IsBoolean, IsNumber, IsDateString, IsArray, ValidateNested } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';

export class CompanyRegisterDto {
  @ApiProperty() @IsString() name: string;
  @ApiProperty() @IsInt() @Type(() => Number) company_type: number;
  @ApiPropertyOptional() @IsString() @IsOptional() description?: string;
  @ApiPropertyOptional() @IsString() @IsOptional() address?: string;
  @ApiPropertyOptional() @IsString() @IsOptional() phone?: string;
  @ApiPropertyOptional() @IsBoolean() @IsOptional() allows_b2b?: boolean = true;
  @ApiPropertyOptional() @IsBoolean() @IsOptional() allows_b2c?: boolean = true;
  @ApiPropertyOptional() @IsInt() @Type(() => Number) @IsOptional() city?: number;
}

export class CompanyUpdateDto {
  @ApiPropertyOptional() @IsString() @IsOptional() name?: string;
  @ApiPropertyOptional() @IsInt() @Type(() => Number) @IsOptional() company_type?: number;
  @ApiPropertyOptional() @IsString() @IsOptional() description?: string;
  @ApiPropertyOptional() @IsString() @IsOptional() address?: string;
  @ApiPropertyOptional() @IsString() @IsOptional() phone?: string;
  @ApiPropertyOptional() @IsBoolean() @IsOptional() allows_b2b?: boolean;
  @ApiPropertyOptional() @IsBoolean() @IsOptional() allows_b2c?: boolean;
  @ApiPropertyOptional() @IsInt() @Type(() => Number) @IsOptional() city?: number;
  @ApiPropertyOptional() @IsInt() @Type(() => Number) @IsOptional() currency?: number;
}

export class InviteMemberDto {
  @ApiProperty() @IsString() email: string;
  @ApiPropertyOptional() @IsString() @IsOptional() role?: string = 'staff';
}

export class CreateMemberDto {
  @ApiProperty() @IsString() email: string;
  @ApiProperty() @IsString() username: string;
  @ApiProperty() @IsString() password: string;
  @ApiProperty() @IsString() first_name: string;
  @ApiProperty() @IsString() last_name: string;
  @ApiPropertyOptional() @IsString() @IsOptional() role?: string = 'staff';
}

export class CompanyCategoryDto {
  @ApiProperty() @IsString() name: string;
}

export class DeliveryOptionDto {
  @ApiPropertyOptional() @IsInt() @Type(() => Number) @IsOptional() id?: number;
  @ApiPropertyOptional() @IsString() @IsOptional() name?: string;
  @ApiPropertyOptional() @IsNumber() @Type(() => Number) @IsOptional() cost?: number;
  @ApiPropertyOptional() @IsInt() @Type(() => Number) @IsOptional() estimated_days_min?: number;
  @ApiPropertyOptional() @IsInt() @Type(() => Number) @IsOptional() estimated_days_max?: number;
  @ApiPropertyOptional() @IsString() @IsOptional() description?: string;
  @ApiPropertyOptional() @IsBoolean() @IsOptional() is_active?: boolean;
  @ApiPropertyOptional() @IsInt() @Type(() => Number) @IsOptional() company?: number;
}

export class ExpenseDto {
  @ApiPropertyOptional() @IsNumber() @Type(() => Number) @IsOptional() amount?: number;
  @ApiPropertyOptional() @IsString() @IsOptional() category?: string;
  @ApiPropertyOptional() @IsString() @IsOptional() description?: string;
  @ApiPropertyOptional() @IsDateString() @IsOptional() date?: string;
}

export class FinancialTransactionDto {
  @ApiProperty() @IsString() type: string; // 'income' or 'expense'
  @ApiProperty() @IsString() category: string;
  @ApiProperty() @IsNumber() @Type(() => Number) amount: number;
  @ApiPropertyOptional() @IsString() @IsOptional() description?: string;
  @ApiPropertyOptional() @IsString() @IsOptional() payment_method?: string = 'cash';
}

export class ContactDto {
  @ApiPropertyOptional() @IsInt() @Type(() => Number) @IsOptional() id?: number;
  @ApiProperty() @IsString() name: string;
  @ApiPropertyOptional() @IsString() @IsOptional() email?: string;
  @ApiProperty() @IsString() phone: string;
  @ApiPropertyOptional() @IsString() @IsOptional() notes?: string;
}

export class CompanyServiceCreateDto {
  @ApiProperty() @IsString() title: string;
  @ApiPropertyOptional() @IsNumber() @Type(() => Number) @IsOptional() price?: number;
  @ApiPropertyOptional() @IsString() @IsOptional() description?: string;
}

export class CompanyServiceUpdateDto {
  @ApiPropertyOptional() @IsString() @IsOptional() title?: string;
  @ApiPropertyOptional() @IsNumber() @Type(() => Number) @IsOptional() price?: number;
  @ApiPropertyOptional() @IsString() @IsOptional() description?: string;
}

export class CompanyServiceRequestCreateDto {
  @ApiProperty() @IsString() service_code: string;
  @ApiPropertyOptional() @IsString() @IsOptional() notes?: string;
}

export class CompanySubscriptionRequestCreateDto {
  @ApiProperty() @IsInt() @Type(() => Number) subscription_plan: number;
  @ApiPropertyOptional() @IsString() @IsOptional() notes?: string;
}

export class CompanySubscriptionRequestReviewDto {
  @ApiProperty() @IsString() status: string;
  @ApiPropertyOptional() @IsString() @IsOptional() notes?: string;
}

export class CompanyServiceRequestActionDto {
  @ApiProperty() @IsString() status: string;
  @ApiPropertyOptional() @IsString() @IsOptional() notes?: string;
  @ApiPropertyOptional() @IsDateString() @IsOptional() starts_at?: string;
  @ApiPropertyOptional() @IsDateString() @IsOptional() ends_at?: string;
}

export class CompanyStatusActionDto {
  @ApiProperty() @IsString() status: string;
}

export class CompanyServiceCatalogCreateDto {
  @ApiProperty() @IsString() code: string;
  @ApiProperty() @IsString() name: string;
  @ApiPropertyOptional() @IsString() @IsOptional() description?: string;
  @ApiPropertyOptional() @IsString() @IsOptional() category?: string = "general";
  @ApiPropertyOptional() @IsBoolean() @IsOptional() is_active?: boolean = true;
  @ApiPropertyOptional() @IsInt() @Type(() => Number) @IsOptional() sort_order?: number = 0;
  @ApiPropertyOptional() @IsString() @IsOptional() route?: string;
}

export class CompanyServiceCatalogUpdateDto {
  @ApiPropertyOptional() @IsString() @IsOptional() name?: string;
  @ApiPropertyOptional() @IsString() @IsOptional() description?: string;
  @ApiPropertyOptional() @IsString() @IsOptional() category?: string;
  @ApiPropertyOptional() @IsBoolean() @IsOptional() is_active?: boolean;
  @ApiPropertyOptional() @IsInt() @Type(() => Number) @IsOptional() sort_order?: number;
  @ApiPropertyOptional() @IsString() @IsOptional() route?: string;
}

export class CompanyOfferInvolvesDto {
  @ApiProperty() @IsString() name: string;
  @ApiPropertyOptional() @IsInt() @Type(() => Number) @IsOptional() quantity?: number = 1;
  @ApiProperty() @IsNumber() @Type(() => Number) cost: number;
}

export class CompanyOfferCreateDto {
  @ApiPropertyOptional() @IsInt() @Type(() => Number) @IsOptional() panel_power?: number = 610;
  @ApiPropertyOptional() @IsInt() @Type(() => Number) @IsOptional() panel_count?: number = 1;
  @ApiPropertyOptional() @IsString() @IsOptional() panel_type?: string = 'mono';
  @ApiPropertyOptional() @IsString() @IsOptional() panel_notes?: string;
  @ApiPropertyOptional() @IsNumber() @Type(() => Number) @IsOptional() battery_power?: number = 5.12;
  @ApiPropertyOptional() @IsInt() @Type(() => Number) @IsOptional() battery_count?: number = 1;
  @ApiPropertyOptional() @IsString() @IsOptional() battery_type?: string = 'lithium';
  @ApiPropertyOptional() @IsString() @IsOptional() battery_notes?: string;
  @ApiPropertyOptional() @IsInt() @Type(() => Number) @IsOptional() inverter_power?: number = 5;
  @ApiPropertyOptional() @IsInt() @Type(() => Number) @IsOptional() inverter_count?: number = 1;
  @ApiPropertyOptional() @IsString() @IsOptional() inverter_type?: string = 'hybrid';
  @ApiPropertyOptional() @IsString() @IsOptional() inverter_notes?: string;
  @ApiPropertyOptional() @IsString() @IsOptional() notes?: string;
  @ApiProperty() @IsNumber() @Type(() => Number) price: number;
  @ApiPropertyOptional() @IsDateString() @IsOptional() expires_at?: string;
  
  @ApiPropertyOptional({ type: [CompanyOfferInvolvesDto] })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CompanyOfferInvolvesDto)
  @IsOptional()
  involves?: CompanyOfferInvolvesDto[];
}

export class ServiceTypeCreateDto {
  @ApiProperty() @IsString() name: string;
  @ApiPropertyOptional() @IsString() @IsOptional() description?: string;
}

export class ServiceTypeUpdateDto {
  @ApiPropertyOptional() @IsString() @IsOptional() name?: string;
  @ApiPropertyOptional() @IsString() @IsOptional() description?: string;
}

export class ServiceTypeSelectionDto {
  @ApiProperty() @IsInt() @Type(() => Number) id: number;
  @ApiProperty() @IsBoolean() selected: boolean;
}

export class CompanyWorkCreateDto {
  @ApiPropertyOptional() @IsString() @IsOptional() title?: string;
  @ApiPropertyOptional() @IsString() @IsOptional() body?: string;
}

export class CompanyWorkUpdateDto {
  @ApiPropertyOptional() @IsString() @IsOptional() title?: string;
  @ApiPropertyOptional() @IsString() @IsOptional() body?: string;
}

export class PosterCreateDto {
  @ApiPropertyOptional() @IsString() @IsOptional() text?: string;
  @ApiPropertyOptional() @IsString() @IsOptional() action_type?: string = 'company_profile';
  @ApiPropertyOptional() @IsInt() @Type(() => Number) @IsOptional() action_id?: number;
}

export class PosterUpdateDto {
  @ApiPropertyOptional() @IsString() @IsOptional() text?: string;
  @ApiPropertyOptional() @IsString() @IsOptional() action_type?: string;
  @ApiPropertyOptional() @IsInt() @Type(() => Number) @IsOptional() action_id?: number;
}

export class PosterReviewDto {
  @ApiProperty() @IsString() status: string;
  @ApiPropertyOptional() @IsInt() @Type(() => Number) @IsOptional() duration_days?: number = 7;
}

export class PosterExtendDto {
  @ApiProperty() @IsDateString() expires_at: string;
}
"""
}

for filename, content in dtos.items():
    with open(os.path.join(dto_dir, filename), "w") as f:
        f.write(content)

print("Company DTOs generated successfully.")
