import { IsString, IsNumber, IsOptional } from 'class-validator';

export class CustomerFormDto {
  @IsString()
  full_name: string;

  @IsOptional()
  @IsString()
  email?: string;

  @IsOptional()
  @IsString()
  phone_number?: string;

  @IsOptional()
  @IsString()
  address?: string;

  @IsOptional()
  @IsString()
  customer_type?: string = 'b2c';

  @IsOptional()
  @IsNumber()
  buyer_company_id?: number;

  @IsOptional()
  @IsNumber()
  buyer_profile_id?: number;
}

export class SupplierFormDto {
  @IsString()
  name: string;

  @IsOptional()
  @IsString()
  contact_name?: string;

  @IsOptional()
  @IsString()
  email?: string;

  @IsOptional()
  @IsString()
  phone_number?: string;

  @IsOptional()
  @IsString()
  address?: string;

  @IsOptional()
  @IsString()
  tax_id?: string;

  @IsOptional()
  @IsString()
  supplier_type?: string = 'external';

  @IsOptional()
  @IsNumber()
  seller_company_id?: number;
}
