import { IsString, IsNotEmpty } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CompanyApproveDto {
  @ApiProperty({ description: 'e.g. active, rejected' })
  @IsString()
  @IsNotEmpty()
  status: string;
}
