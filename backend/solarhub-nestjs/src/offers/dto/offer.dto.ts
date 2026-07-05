import { IsOptional, IsInt, IsNumber, IsString, IsArray, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';

export class InvolvementSnapshotInDto {
  @IsInt()
  template_id: number;

  @IsOptional()
  @IsInt()
  quantity?: number = 1;
}

export class OfferInDto {
  @IsNumber()
  price: number;

  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => InvolvementSnapshotInDto)
  template_involves?: InvolvementSnapshotInDto[] = [];

  @IsOptional()
  @IsInt()
  total_panel_power?: number = 0;

  @IsOptional()
  @IsInt()
  panel_power?: number = 0;

  @IsOptional()
  @IsInt()
  panel_count?: number = 0;

  @IsOptional()
  @IsString()
  panel_note?: string;

  @IsOptional()
  @IsNumber()
  battery_size?: number = 0.0;

  @IsOptional()
  @IsInt()
  battery_count?: number = 0;

  @IsOptional()
  @IsString()
  battery_note?: string;

  @IsOptional()
  @IsString()
  battery_type?: string = 'gel';

  @IsOptional()
  @IsNumber()
  inverter_size?: number = 0.0;

  @IsOptional()
  @IsInt()
  inverter_count?: number = 0;

  @IsOptional()
  @IsString()
  inverter_note?: string;

  @IsOptional()
  @IsString()
  inverter_type?: string = 'hybrid';

  @IsOptional()
  @IsString()
  note?: string;
}

export class OfferResponseInDto {
  @IsString()
  state: string;
}
