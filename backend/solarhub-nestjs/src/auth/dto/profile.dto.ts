import { IsString, IsEmail, IsOptional, IsNumber } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class UpdateProfileDto {
  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  username?: string;

  @ApiPropertyOptional()
  @IsEmail()
  @IsOptional()
  email?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  phone?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  first_name?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  last_name?: string;

  @ApiPropertyOptional()
  @IsNumber()
  @IsOptional()
  city_id?: number;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  security_question?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  security_answer?: string;
}

export class LanguageUpdateDto {
  @ApiPropertyOptional({ example: 'en' })
  @IsString()
  language: string;
}

export class DeleteAccountDto {
  @ApiPropertyOptional()
  @IsString()
  password?: string;

  @ApiPropertyOptional()
  @IsString()
  reason?: string;
}
