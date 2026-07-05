import { IsOptional, IsInt, IsBoolean, IsNumber, IsString } from 'class-validator';

export class OfferRequestInDto {
  @IsOptional()
  @IsInt()
  city_id?: number;

  @IsOptional()
  @IsBoolean()
  all_cities?: boolean = false;

  @IsOptional()
  @IsInt()
  total_panel_power?: number = 0;

  @IsOptional()
  @IsInt()
  panel_power?: number;

  @IsOptional()
  @IsInt()
  panel_count?: number;

  @IsOptional()
  @IsString()
  panel_note?: string;

  @IsOptional()
  @IsNumber()
  total_battery_power?: number = 0.0;

  @IsOptional()
  @IsNumber()
  battery_size?: number;

  @IsOptional()
  @IsInt()
  battery_count?: number;

  @IsOptional()
  @IsString()
  battery_note?: string;

  @IsOptional()
  @IsString()
  battery_type?: string = 'gel';

  @IsOptional()
  @IsNumber()
  total_inverters_power?: number = 0.0;

  @IsOptional()
  @IsNumber()
  inverter_size?: number;

  @IsOptional()
  @IsInt()
  inverter_count?: number;

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
