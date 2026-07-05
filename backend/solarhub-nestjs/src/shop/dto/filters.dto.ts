import { IsString, IsNumber, IsOptional, Min } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiPropertyOptional } from '@nestjs/swagger';

/**
 * DTO للفلاتر المشتركة بين B2B و B2C وكل قوائم المنتجات
 * يُستخدم كـ @Query() في controllers
 * يُعادل query parameters في Django views
 */
export class ShopFiltersDto {
  @ApiPropertyOptional({ description: 'بحث نصي في اسم المنتج أو الوصف', example: 'panel' })
  @IsOptional()
  @IsString()
  q?: string;

  @ApiPropertyOptional({ description: 'فلتر حسب التصنيف', example: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  category_id?: number;

  @ApiPropertyOptional({ description: 'فلتر حسب الشركة البائعة', example: 5 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  company_id?: number;

  @ApiPropertyOptional({ description: 'أقل سعر', example: 100 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  min_price?: number;

  @ApiPropertyOptional({ description: 'أعلى سعر', example: 5000 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  max_price?: number;

  @ApiPropertyOptional({ description: 'رقم الصفحة', example: 1, default: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  page?: number = 1;

  @ApiPropertyOptional({ description: 'عدد العناصر في كل صفحة', example: 20, default: 20 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  page_size?: number = 20;
}
