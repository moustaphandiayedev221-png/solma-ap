import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/address_model.dart';
import '../../data/address_repository.dart';

final addressRepositoryProvider =
    Provider<AddressRepository>((ref) => AddressRepository());

final userAddressesProvider = FutureProvider<List<AddressModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.read(addressRepositoryProvider).getAddresses(user.id);
});

final defaultAddressProvider = Provider<AddressModel?>((ref) {
  final async = ref.watch(userAddressesProvider);
  return async.valueOrNull?.where((a) => a.isDefault).firstOrNull ??
      async.valueOrNull?.firstOrNull;
});

final addressByIdProvider =
    FutureProvider.family<AddressModel?, String>((ref, id) async {
  return ref.read(addressRepositoryProvider).getById(id);
});
