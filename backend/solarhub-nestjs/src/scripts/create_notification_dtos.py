import os

dto_dir = "src/notifications/dto"
os.makedirs(dto_dir, exist_ok=True)

dtos = {
    "notification.dto.ts": """import { IsString, IsInt, IsOptional, IsNotEmpty, IsObject } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';

export class SubscribeDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  token: string;

  @ApiProperty({ description: "'ios' or 'android'" })
  @IsString()
  @IsNotEmpty()
  platform: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  device_id?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  app_version?: string;
}

export class BroadcastDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  title: string;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  body: string;

  @ApiPropertyOptional()
  @IsObject()
  @IsOptional()
  data?: Record<string, any>;
}

export class GroupNotificationDto {
  @ApiProperty({ description: "'company', 'followers', 'custom'" })
  @IsString()
  @IsNotEmpty()
  group_type: string;

  @ApiProperty({ description: 'company_id, post_id, or array of user_ids' })
  @IsNotEmpty()
  group_id: any;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  title: string;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  body: string;

  @ApiPropertyOptional()
  @IsObject()
  @IsOptional()
  data?: Record<string, any>;
}

export class UserNotificationDto {
  @ApiProperty()
  @IsInt()
  @Type(() => Number)
  user_id: number;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  title: string;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  body: string;

  @ApiPropertyOptional()
  @IsObject()
  @IsOptional()
  data?: Record<string, any>;
}
"""
}

for filename, content in dtos.items():
    with open(os.path.join(dto_dir, filename), "w") as f:
        f.write(content)

print("Notification DTOs generated successfully.")
