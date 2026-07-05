import { IsString, IsNotEmpty, IsEmail, MinLength, IsOptional, IsNumber } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class RegisterDto {
  @ApiProperty({ description: 'Username', example: 'new_user' })
  @IsString()
  @IsNotEmpty()
  username: string;

  @ApiProperty({ description: 'Email address', example: 'user@example.com' })
  @IsEmail()
  @IsNotEmpty()
  email: string;

  @ApiProperty({ description: 'Phone / Mobile', example: '+9647701234567' })
  @IsString()
  @IsNotEmpty()
  phone: string;

  @ApiProperty({ description: 'Password', minLength: 6, example: 'password123' })
  @IsString()
  @MinLength(6)
  password: string;

  @ApiProperty({ description: 'First Name', example: 'Ali' })
  @IsString()
  @IsNotEmpty()
  first_name: string;

  @ApiProperty({ description: 'Last Name', example: 'Ahmed' })
  @IsString()
  @IsNotEmpty()
  last_name: string;

  @ApiPropertyOptional({ description: 'City ID', example: 1 })
  @IsNumber()
  @IsOptional()
  city_id?: number;
}
