import os

DTO_DIR = "src/shop/dto"
os.makedirs(DTO_DIR, exist_ok=True)

# 1. products.dto.ts
products_dto = """import { IsString, IsNumber, IsOptional, IsBoolean, IsArray, IsObject } from 'class-validator';

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
"""

with open(f"{DTO_DIR}/products.dto.ts", "w") as f:
    f.write(products_dto)


# 2. crm.dto.ts
crm_dto = """import { IsString, IsNumber, IsOptional } from 'class-validator';

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
"""

with open(f"{DTO_DIR}/crm.dto.ts", "w") as f:
    f.write(crm_dto)


# 3. orders.dto.ts
orders_dto = """import { IsString, IsNumber, IsOptional, IsArray, IsObject, ValidateNested } from 'class-validator';
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
"""

with open(f"{DTO_DIR}/orders.dto.ts", "w") as f:
    f.write(orders_dto)

# 4. filters.dto.ts
filters_dto = """import { IsString, IsNumber, IsOptional, Min } from 'class-validator';
import { Type } from 'class-transformer';

export class ShopFiltersDto {
  @IsOptional()
  @IsString()
  q?: string;

  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  category_id?: number;

  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  company_id?: number;

  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  min_price?: number;

  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  max_price?: number;

  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  page?: number = 1;

  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  page_size?: number = 20;
}
"""

with open(f"{DTO_DIR}/filters.dto.ts", "w") as f:
    f.write(filters_dto)

print("Shop DTOs generated successfully!")
