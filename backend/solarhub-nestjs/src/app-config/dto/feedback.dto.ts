import { IsString, IsInt, IsBoolean, IsOptional, IsNotEmpty } from 'class-validator';
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
