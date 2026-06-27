import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opei/core/providers/providers.dart';
import 'package:opei/data/models/money_movement_availability.dart';
import 'package:opei/data/repositories/money_movement_availability_repository.dart';

final moneyMovementAvailabilityProvider =
    AsyncNotifierProvider<
      MoneyMovementAvailabilityController,
      MoneyMovementAvailability
    >(MoneyMovementAvailabilityController.new);

class MoneyMovementAvailabilityController
    extends AsyncNotifier<MoneyMovementAvailability> {
  late MoneyMovementAvailabilityRepository _repository;

  @override
  Future<MoneyMovementAvailability> build() async {
    _repository = ref.read(moneyMovementAvailabilityRepositoryProvider);
    try {
      return await _repository.fetchAvailability();
    } catch (error) {
      debugPrint(
        '⚠️ Money movement availability unavailable, using defaults: $error',
      );
      return MoneyMovementAvailability.defaults();
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading<MoneyMovementAvailability>();
    state = await AsyncValue.guard(_repository.fetchAvailability);
  }
}

MoneyMovementAvailability availabilityFromAsync(
  AsyncValue<MoneyMovementAvailability> value,
) {
  return value.when(
    data: (availability) => availability,
    error: (_, _) => MoneyMovementAvailability.defaults(),
    loading: MoneyMovementAvailability.defaults,
  );
}

MoneyMovementAvailability availabilityFromRef(Ref ref) {
  if (!ref.exists(moneyMovementAvailabilityProvider)) {
    return MoneyMovementAvailability.defaults();
  }
  return availabilityFromAsync(ref.read(moneyMovementAvailabilityProvider));
}

MoneyMovementAvailability availabilityFromWidgetRef(WidgetRef ref) {
  if (!ref.exists(moneyMovementAvailabilityProvider)) {
    return MoneyMovementAvailability.defaults();
  }
  return availabilityFromAsync(ref.read(moneyMovementAvailabilityProvider));
}
