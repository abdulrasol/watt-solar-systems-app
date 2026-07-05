import os

dto_dir = "src/app-config/dto"
os.makedirs(dto_dir, exist_ok=True)

dtos = {
    "config.dto.ts": """import { IsString, IsBoolean, IsOptional, IsNotEmpty } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class ConfigCreateDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  key: string;

  @ApiPropertyOptional({ default: false })
  @IsBoolean()
  @IsOptional()
  value?: boolean;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  description?: string;
}

export class ConfigUpdateDto {
  @ApiProperty()
  @IsBoolean()
  value: boolean;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  description?: string;
}
""",

    "company.dto.ts": """import { IsString, IsNotEmpty } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CompanyApproveDto {
  @ApiProperty({ description: 'e.g. active, rejected' })
  @IsString()
  @IsNotEmpty()
  status: string;
}
""",

    "currency.dto.ts": """import { IsString, IsBoolean, IsOptional, IsNotEmpty } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CurrencyDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  code: string;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  symbol: string;

  @ApiPropertyOptional({ default: false })
  @IsBoolean()
  @IsOptional()
  is_default?: boolean;
}
""",

    "country.dto.ts": """import { IsString, IsOptional, IsNotEmpty } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CountryDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  code?: string;
}
""",

    "city.dto.ts": """import { IsString, IsInt, IsOptional, IsNotEmpty } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';

export class CityDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiProperty()
  @IsInt()
  @Type(() => Number)
  country_id: number;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  code: string;
}

export class CityUpdateDto {
  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  name?: string;

  @ApiPropertyOptional()
  @IsInt()
  @IsOptional()
  @Type(() => Number)
  country_id?: number;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  code?: string;
}
""",

    "subscription.dto.ts": """import { IsString, IsInt, IsNumber, IsBoolean, IsOptional, IsNotEmpty } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';

export class SubscriptionPlanDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiProperty()
  @IsInt()
  @Type(() => Number)
  duration_days: number;

  @ApiProperty()
  @IsNumber()
  @Type(() => Number)
  price: number;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  description?: string;

  @ApiPropertyOptional({ default: true })
  @IsBoolean()
  @IsOptional()
  is_active?: boolean;
}
""",

    "category.dto.ts": """import { IsString, IsOptional, IsNotEmpty } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class GlobalCategoryDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  icon?: string;
}
""",

    "feedback.dto.ts": """import { IsString, IsInt, IsBoolean, IsOptional, IsNotEmpty } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';

export class FeedbackFormDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiPropertyOptional()
  @IsInt()
  @IsOptional()
  @Type(() => Number)
  phone_number?: number;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  message: string;
}

export class FeedbackUpdateFormDto {
  @ApiProperty()
  @IsBoolean()
  is_read: boolean;
}
"""
}

for filename, content in dtos.items():
    with open(os.path.join(dto_dir, filename), "w") as f:
        f.write(content)

print("DTOs generated successfully.")
