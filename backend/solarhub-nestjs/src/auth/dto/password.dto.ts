import { IsString, IsNotEmpty, MinLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class PasswordResetRequestDto {
  @ApiProperty({ description: 'Username, Email, or Mobile', example: 'ali_ahmed' })
  @IsString()
  @IsNotEmpty()
  identifier: string; // User requested mobile, email or username
}

export class PasswordResetTokenDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  token: string;
}

export class PasswordResetConfirmDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  token: string;

  @ApiProperty({ minLength: 6 })
  @IsString()
  @MinLength(6)
  password: string;
}
