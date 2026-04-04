import 'package:flutter_riverpod/legacy.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/features/offers/domain/entities/involve.dart';
import 'package:solar_hub/src/features/offers/domain/repositories/offers_repository.dart';

class InvolvesState {
  final bool isLoading;
  final bool isSaving;
  final List<Involve> items;
  final String? error;

  const InvolvesState({
    this.isLoading = false,
    this.isSaving = false,
    this.items = const [],
    this.error,
  });

  InvolvesState copyWith({
    bool? isLoading,
    bool? isSaving,
    List<Involve>? items,
    String? error,
  }) {
    return InvolvesState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      items: items ?? this.items,
      error: error,
    );
  }
}

final involvesProvider = StateNotifierProvider<InvolvesNotifier, InvolvesState>(
  (ref) => InvolvesNotifier(getIt<OffersRepository>()),
);

class InvolvesNotifier extends StateNotifier<InvolvesState> {
  final OffersRepository _repository;

  InvolvesNotifier(this._repository) : super(const InvolvesState());

  Future<void> getInvolves({bool force = false}) async {
    if (state.isLoading || (!force && state.items.isNotEmpty)) return;
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.getInvolves();
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.toString()),
      (items) =>
          state = state.copyWith(isLoading: false, items: items, error: null),
    );
  }

  Future<Involve?> createInvolve({
    required String name,
    required int cost,
  }) async {
    state = state.copyWith(isSaving: true, error: null);
    final result = await _repository.createInvolve({
      'name': name,
      'cost': cost,
    });
    return result.fold(
      (failure) {
        state = state.copyWith(isSaving: false, error: failure.toString());
        return null;
      },
      (item) {
        state = state.copyWith(
          isSaving: false,
          items: [item, ...state.items],
          error: null,
        );
        return item;
      },
    );
  }

  Future<Involve?> updateInvolve({
    required int id,
    required String name,
    required int cost,
  }) async {
    state = state.copyWith(isSaving: true, error: null);
    final result = await _repository.updateInvolve(id, {
      'name': name,
      'cost': cost,
    });
    return result.fold(
      (failure) {
        state = state.copyWith(isSaving: false, error: failure.toString());
        return null;
      },
      (item) {
        final items = state.items
            .map((current) => current.id == id ? item : current)
            .toList();
        state = state.copyWith(isSaving: false, items: items, error: null);
        return item;
      },
    );
  }

  Future<bool> deleteInvolve(int id) async {
    state = state.copyWith(isSaving: true, error: null);
    final result = await _repository.deleteInvolve(id);
    return result.fold(
      (failure) {
        state = state.copyWith(isSaving: false, error: failure.toString());
        return false;
      },
      (_) {
        state = state.copyWith(
          isSaving: false,
          items: state.items.where((item) => item.id != id).toList(),
          error: null,
        );
        return true;
      },
    );
  }
}
