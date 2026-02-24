import 'package:solar_hub/models/company_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<CompanyModel?> fetchCompany(String id) async {
  try {
    final res = await Supabase.instance.client.from('companies').select().eq('id', id).single();
    return CompanyModel.fromJson(res);
  } catch (e) {
    return null;
  }
}
