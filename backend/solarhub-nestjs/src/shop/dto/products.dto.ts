import {
  IsString,
  IsNumber,
  IsOptional,
  IsBoolean,
  IsArray,
  IsObject,
} from 'class-validator';

export class ProductOptionDto {
  @IsString()
  name: string;

  @IsOptional()
  @IsNumber()
  retail_price?: number = 0;

  @IsOptional()
  @IsNumber()
  cost?: number = 0;

  @IsOptional()
  @IsNumber()
  wholesale_price?: number = 0;

  @IsOptional()
  @IsBoolean()
  is_required?: boolean = false;
}

export class ProductPricingTierDto {
  @IsOptional()
  @IsNumber()
  id?: number;

  @IsNumber()
  quantity: number;

  @IsNumber()
  unit_price: number;
}

export class ProductFormDto {
  @IsString()
  name: string;

  @IsOptional()
  @IsString()
  sku?: string;

  @IsOptional()
  @IsNumber()
  category_id?: number;

  @IsOptional()
  @IsArray()
  company_category_ids?: number[];

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsNumber()
  cost_price?: number = 0;

  @IsOptional()
  @IsNumber()
  retail_price?: number = 0;

  @IsOptional()
  @IsNumber()
  wholesale_price?: number = 0;

  @IsOptional()
  @IsNumber()
  discount?: number = 0;

  @IsOptional()
  @IsNumber()
  stock_quantity?: number = 0;

  @IsOptional()
  @IsNumber()
  min_stock_alert?: number = 5;

  @IsOptional()
  @IsObject()
  specs?: any = {};

  @IsOptional()
  @IsString()
  status?: string = 'active';

  @IsOptional()
  @IsArray()
  options?: ProductOptionDto[];

  @IsOptional()
  @IsArray()
  pricing_tiers?: ProductPricingTierDto[];
}
