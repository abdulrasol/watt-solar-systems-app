import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CompanyWorkCreateDto {
  @ApiPropertyOptional()
  title?: string;

  @ApiPropertyOptional()
  body?: string;
}

export class CompanyWorkUpdateDto extends CompanyWorkCreateDto {}

export class ContactCreateDto {
  @ApiProperty()
  name: string;

  @ApiPropertyOptional()
  email?: string;

  @ApiProperty()
  phone: string;

  @ApiPropertyOptional()
  notes?: string;
}

export class ContactUpdateDto extends ContactCreateDto {}

export class PublicServiceCreateDto {
  @ApiProperty()
  title: string;

  @ApiPropertyOptional()
  price?: number;

  @ApiPropertyOptional()
  description?: string;
}

export class PublicServiceUpdateDto extends PublicServiceCreateDto {}

export class DeliveryOptionCreateDto {
  @ApiProperty()
  name: string;

  @ApiProperty()
  cost: number;

  @ApiPropertyOptional()
  estimated_days_min?: number;

  @ApiPropertyOptional()
  estimated_days_max?: number;

  @ApiPropertyOptional()
  description?: string;

  @ApiPropertyOptional()
  is_active?: boolean;
}

export class DeliveryOptionUpdateDto extends DeliveryOptionCreateDto {}
