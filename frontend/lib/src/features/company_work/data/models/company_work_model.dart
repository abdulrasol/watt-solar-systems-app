import 'package:solar_hub/src/features/company_work/domain/entities/company_work.dart';

class CompanyWorkImageModel extends CompanyWorkImage {
  const CompanyWorkImageModel({
    required super.id,
    required super.imageUrl,
    super.createdAt,
  });

  factory CompanyWorkImageModel.fromJson(Map<String, dynamic> json) {
    final entity = CompanyWorkImage.fromJson(json);
    return CompanyWorkImageModel(
      id: entity.id,
      imageUrl: entity.imageUrl,
      createdAt: entity.createdAt,
    );
  }
}

class CompanyWorkModel extends CompanyWork {
  const CompanyWorkModel({
    required super.id,
    required super.title,
    super.body,
    super.createdAt,
    super.updatedAt,
    super.images = const [],
  });

  factory CompanyWorkModel.fromJson(Map<String, dynamic> json) {
    final entity = CompanyWork.fromJson(json);
    return CompanyWorkModel(
      id: entity.id,
      title: entity.title,
      body: entity.body,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      images: entity.images,
    );
  }
}
