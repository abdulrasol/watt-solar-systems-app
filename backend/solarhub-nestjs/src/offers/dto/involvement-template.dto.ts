import { IsNumber, IsString } from 'class-validator';

export class InvolvementTemplateInDto {
  @IsString()
  name: string;

  @IsNumber()
  cost: number;
}
