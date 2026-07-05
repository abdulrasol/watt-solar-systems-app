import { IsString, IsInt, IsOptional, IsNotEmpty } from 'class-validator';
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
