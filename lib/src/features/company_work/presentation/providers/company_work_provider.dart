import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/core/cashe/cashe_interface.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/features/company_work/domain/entities/company_work.dart';
import 'package:solar_hub/src/features/company_work/domain/repositories/company_work_repository.dart';

class CompanyWorkState {
  const CompanyWorkState({
    this.works = const [],
    this.isLoading = false,
    this.isMoreLoading = false,
    this.hasMore = true,
    this.page = 1,
    this.pageSize = 12,
    this.totalCount = 0,
    this.error,
  });

  final List<CompanyWork> works;
  final bool isLoading;
  final bool isMoreLoading;
  final bool hasMore;
  final int page;
  final int pageSize;
  final int totalCount;
  final String? error;

  CompanyWork? byId(int id) {
    for (final work in works) {
      if (work.id == id) return work;
    }
    return null;
  }

  CompanyWorkState copyWith({
    List<CompanyWork>? works,
    bool? isLoading,
    bool? isMoreLoading,
    bool? hasMore,
    int? page,
    int? pageSize,
    int? totalCount,
    String? error,
    bool clearError = false,
  }) {
    return CompanyWorkState(
      works: works ?? this.works,
      isLoading: isLoading ?? this.isLoading,
      isMoreLoading: isMoreLoading ?? this.isMoreLoading,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      totalCount: totalCount ?? this.totalCount,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class CompanyWorkNotifier extends Notifier<CompanyWorkState> {
  late final CompanyWorkRepository _repository;

  @override
  CompanyWorkState build() {
    _repository = getIt<CompanyWorkRepository>();
    Future.microtask(() => fetchWorks(isRefresh: true));
    return const CompanyWorkState(isLoading: true);
  }

  int? get _companyId => getIt<CasheInterface>().user()?.company?.id;

  Future<void> fetchWorks({bool isRefresh = false}) async {
    final companyId = _companyId;
    if (companyId == null) {
      state = state.copyWith(
        isLoading: false,
        isMoreLoading: false,
        error: 'No company selected',
      );
      return;
    }

    if (isRefresh) {
      state = state.copyWith(
        isLoading: true,
        page: 1,
        hasMore: true,
        clearError: true,
      );
    } else {
      if (state.isMoreLoading || !state.hasMore) return;
      state = state.copyWith(isMoreLoading: true, clearError: true);
    }

    try {
      final page = isRefresh ? 1 : state.page;
      final works = await _repository.getCompanyWorks(
        companyId,
        page: page,
        pageSize: state.pageSize,
      );
      final totalCount = await _repository.getCompanyWorksCount(
        companyId,
        page: page,
        pageSize: state.pageSize,
      );

      final allWorks = isRefresh ? works : [...state.works, ...works];
      state = state.copyWith(
        works: allWorks,
        isLoading: false,
        isMoreLoading: false,
        totalCount: totalCount,
        hasMore: allWorks.length < totalCount,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isMoreLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> nextPage() async {
    if (state.isMoreLoading || !state.hasMore) return;
    state = state.copyWith(page: state.page + 1);
    await fetchWorks();
  }

  void upsertWork(CompanyWork work) {
    final index = state.works.indexWhere((item) => item.id == work.id);
    if (index == -1) {
      state = state.copyWith(
        works: [work, ...state.works],
        totalCount: state.totalCount + 1,
      );
      return;
    }

    final updated = [...state.works];
    updated[index] = work;
    state = state.copyWith(works: updated);
  }

  Future<void> deleteWork(int workId) async {
    final companyId = _companyId;
    if (companyId == null) return;
    await _repository.deleteWork(companyId, workId);
    state = state.copyWith(
      works: state.works.where((item) => item.id != workId).toList(),
      totalCount: state.totalCount > 0 ? state.totalCount - 1 : 0,
    );
  }
}

final companyWorkNotifierProvider =
    NotifierProvider<CompanyWorkNotifier, CompanyWorkState>(
      CompanyWorkNotifier.new,
    );

class PublicCompanyWorksState extends CompanyWorkState {
  const PublicCompanyWorksState({
    super.works,
    super.isLoading,
    super.isMoreLoading,
    super.hasMore,
    super.page,
    super.pageSize = 6,
    super.totalCount,
    super.error,
  });

  @override
  PublicCompanyWorksState copyWith({
    List<CompanyWork>? works,
    bool? isLoading,
    bool? isMoreLoading,
    bool? hasMore,
    int? page,
    int? pageSize,
    int? totalCount,
    String? error,
    bool clearError = false,
  }) {
    return PublicCompanyWorksState(
      works: works ?? this.works,
      isLoading: isLoading ?? this.isLoading,
      isMoreLoading: isMoreLoading ?? this.isMoreLoading,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      totalCount: totalCount ?? this.totalCount,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class PublicCompanyWorksNotifier extends Notifier<PublicCompanyWorksState> {
  PublicCompanyWorksNotifier(this._companyId);

  late final CompanyWorkRepository _repository;
  final int _companyId;

  @override
  PublicCompanyWorksState build() {
    _repository = getIt<CompanyWorkRepository>();
    Future.microtask(() => fetchWorks(isRefresh: true));
    return const PublicCompanyWorksState(isLoading: true);
  }

  Future<void> fetchWorks({bool isRefresh = false}) async {
    if (isRefresh) {
      state = state.copyWith(
        isLoading: true,
        page: 1,
        hasMore: true,
        clearError: true,
      );
    } else {
      if (state.isMoreLoading || !state.hasMore) return;
      state = state.copyWith(isMoreLoading: true, clearError: true);
    }

    try {
      final page = isRefresh ? 1 : state.page;
      final works = await _repository.getPublicWorks(
        _companyId,
        page: page,
        pageSize: state.pageSize,
      );
      final totalCount = await _repository.getPublicWorksCount(
        _companyId,
        page: page,
        pageSize: state.pageSize,
      );

      final allWorks = isRefresh ? works : [...state.works, ...works];
      state = state.copyWith(
        works: allWorks,
        isLoading: false,
        isMoreLoading: false,
        totalCount: totalCount,
        hasMore: allWorks.length < totalCount,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isMoreLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> nextPage() async {
    if (state.isMoreLoading || !state.hasMore) return;
    state = state.copyWith(page: state.page + 1);
    await fetchWorks();
  }
}

final publicCompanyWorksProvider =
    NotifierProvider.family<
      PublicCompanyWorksNotifier,
      PublicCompanyWorksState,
      int
    >(PublicCompanyWorksNotifier.new);

class CompanyWorkFormState {
  const CompanyWorkFormState({
    this.isLoading = false,
    this.error,
    this.selectedImages = const [],
    this.existingImages = const [],
  });

  final bool isLoading;
  final String? error;
  final List<File> selectedImages;
  final List<CompanyWorkImage> existingImages;

  bool get isSubmitting => isLoading;

  CompanyWorkFormState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    List<File>? selectedImages,
    List<CompanyWorkImage>? existingImages,
  }) {
    return CompanyWorkFormState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      selectedImages: selectedImages ?? this.selectedImages,
      existingImages: existingImages ?? this.existingImages,
    );
  }
}

class CompanyWorkFormNotifier extends Notifier<CompanyWorkFormState> {
  late final CompanyWorkRepository _repository;

  @override
  CompanyWorkFormState build() {
    _repository = getIt<CompanyWorkRepository>();
    return const CompanyWorkFormState();
  }

  int? get _companyId => getIt<CasheInterface>().user()?.company?.id;

  void initialize(CompanyWork? work) {
    state = CompanyWorkFormState(existingImages: work?.images ?? const []);
  }

  void addImages(List<File> files) {
    state = state.copyWith(selectedImages: [...state.selectedImages, ...files]);
  }

  void removeSelectedImage(File file) {
    state = state.copyWith(
      selectedImages: state.selectedImages
          .where((item) => item.path != file.path)
          .toList(),
    );
  }

  Future<void> removeExistingImage(CompanyWorkImage image) async {
    final companyId = _companyId;
    if (companyId == null) return;
    await _repository.deleteWorkImage(companyId, image.id);
    state = state.copyWith(
      existingImages: state.existingImages
          .where((item) => item.id != image.id)
          .toList(),
    );
  }

  Future<bool> saveWork({
    int? workId,
    required String title,
    required String body,
  }) async {
    final companyId = _companyId;
    if (companyId == null) {
      state = state.copyWith(error: 'No company selected');
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final payload = <String, dynamic>{
        'title': title.trim(),
        'body': body.trim(),
      };

      final CompanyWork work;
      if (workId == null) {
        work = await _repository.createWork(
          companyId,
          payload,
          images: state.selectedImages,
        );
      } else {
        work = await _repository.updateWork(
          companyId,
          workId,
          payload,
          images: state.selectedImages,
        );
      }

      ref.read(companyWorkNotifierProvider.notifier).upsertWork(work);
      state = const CompanyWorkFormState();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    } finally {
      if (state.isLoading) {
        state = state.copyWith(isLoading: false);
      }
    }
  }
}

final companyWorkFormNotifierProvider =
    NotifierProvider<CompanyWorkFormNotifier, CompanyWorkFormState>(
      CompanyWorkFormNotifier.new,
    );
