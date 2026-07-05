import {
  IsString,
  IsNumber,
  IsOptional,
  IsArray,
  IsObject,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';

export class OrderItemFormDto {
  @IsOptional()
  @IsNumber()
  product_id?: number;

  @IsNumber()
  quantity: number;

  @IsNumber()
  unit_price: number;

  @IsNumber()
  total_line_price: number;

  @IsOptional()
  @IsString()
  product_name_snapshot?: string;

  @IsOptional()
  @IsArray()
  selected_options?: any[];
}

export class OrderFormDto {
  @IsOptional()
  @IsString()
  order_type?: string = 'b2c';

  @IsOptional()
  @IsNumber()
  customer_id?: number;

  @IsOptional()
  @IsString()
  guest_customer_name?: string;

  @IsOptional()
  @IsNumber()
  buyer_company_id?: number;

  @IsOptional()
  @IsNumber()
  buyer_user_id?: number;

  @IsOptional()
  @IsNumber()
  supplier_id?: number;

  @IsOptional()
  @IsNumber()
  offer_id?: number;

  @IsOptional()
  @IsString()
  status?: string = 'pending';

  @IsOptional()
  @IsString()
  payment_status?: string = 'unpaid';

  @IsOptional()
  @IsString()
  payment_method?: string = 'cash';

  @IsNumber()
  total_amount: number;

  @IsOptional()
  @IsNumber()
  discount_amount?: number = 0;

  @IsOptional()
  @IsNumber()
  tax_amount?: number = 0;

  @IsOptional()
  @IsNumber()
  paid_amount?: number = 0;

  @IsOptional()
  @IsNumber()
  shipping_cost?: number = 0;

  @IsOptional()
  @IsString()
  shipping_method?: string;

  @IsOptional()
  @IsObject()
  shipping_address?: any;

  @IsOptional()
  @IsString()
  currency_code?: string;

  @IsOptional()
  @IsString()
  currency_symbol?: string;

  @IsOptional()
  @IsString()
  notes?: string;

  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => OrderItemFormDto)
  items?: OrderItemFormDto[];
}
