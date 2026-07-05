import { IsString, IsBoolean, IsOptional, IsNotEmpty } from 'class-validator';
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
