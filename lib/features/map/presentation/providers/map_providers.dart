import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/models/pharmacy_model.dart';
import '../../data/repositories/pharmacy_repository.dart';

final pharmacyRepositoryProvider = Provider<PharmacyRepository>((ref) => PharmacyRepository());

final pharmaciesProvider = StreamProvider<List<PharmacyModel>>((ref) {
  return ref.read(pharmacyRepositoryProvider).getPharmacies();
});

final userLocationProvider = FutureProvider<Position?>((ref) async {
  try {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition();
  } catch (e) {
    return null;
  }
});

final selectedPharmacyProvider = StateProvider<PharmacyModel?>((ref) => null);

final seedingPharmaciesProvider = StateProvider<bool>((ref) => false);
