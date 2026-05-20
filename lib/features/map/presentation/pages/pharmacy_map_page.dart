import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/pharmacy_model.dart';
import '../providers/map_providers.dart';
import 'package:geolocator/geolocator.dart';

final _gjilanCenter = LatLng(42.4635, 21.4695);
final _gjilanBounds =
    LatLngBounds(LatLng(42.4380, 21.4350), LatLng(42.4920, 21.5050));

class PharmacyMapPage extends ConsumerStatefulWidget {
  const PharmacyMapPage({super.key});

  @override
  ConsumerState<PharmacyMapPage> createState() => _PharmacyMapPageState();
}

class _PharmacyMapPageState extends ConsumerState<PharmacyMapPage>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  final List<Marker> _markers = [];
  bool _showList = false;
  late AnimationController _animController;
  // ignore: unused_field
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Seed pharmacies if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pharmacyRepositoryProvider).seedGjilanPharmacies();
    });
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation =
        CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _mapController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pharmaciesAsync = ref.watch(pharmaciesProvider);
    final selectedPharmacy = ref.watch(selectedPharmacyProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(AppStrings.findPharmacy,
            style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
          // Toggle view button
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: _showList
                  ? AppColors.primarySurface
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: Icon(
                _showList ? Icons.map_rounded : Icons.list_rounded,
                color: _showList ? AppColors.primary : AppColors.textSecondary,
              ),
              onPressed: () {
                setState(() {
                  _showList = !_showList;
                  if (_showList) {
                    _animController.forward();
                  } else {
                    _animController.reverse();
                  }
                });
              },
              tooltip: _showList ? 'Shfaq hart\u00ebn' : 'Shfaq list\u00ebn',
            ),
          ),
        ],
      ),
      body: pharmaciesAsync.when(
        data: (pharmacies) {
          _updateMarkers(pharmacies);

          return Stack(
            children: [
              // Map or List view
              if (_showList)
                _buildPharmacyList(pharmacies)
              else
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _gjilanCenter,
                    initialZoom: 14.0,
                    minZoom: 12.5,
                    maxZoom: 18.0,
                    cameraConstraint:
                        CameraConstraint.containCenter(bounds: _gjilanBounds),
                    onTap: (_, __) => ref
                        .read(selectedPharmacyProvider.notifier)
                        .state = null,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.pharmacity.app',
                      maxZoom: 19,
                    ),
                    MarkerLayer(markers: _markers),
                  ],
                ),

              // Gjilan label (only on map view)
              if (!_showList)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow.withValues(alpha: 0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on_rounded,
                            size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          'Gjilan',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${pharmacies.length} farmaci',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Selected pharmacy bottom sheet (only on map view)
              if (selectedPharmacy != null && !_showList)
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: MediaQuery.of(context).padding.bottom + 12,
                  child: _PharmacyBottomSheet(
                    pharmacy: selectedPharmacy,
                    onClose: () => ref
                        .read(selectedPharmacyProvider.notifier)
                        .state = null,
                    onCall: () => _callPharmacy(selectedPharmacy.phone),
                    onDirections: () => _openDirections(
                        selectedPharmacy.latitude, selectedPharmacy.longitude),
                  ),
                ),

              // Recenter button
              if (!_showList)
                Positioned(
                  right: 16,
                  bottom: selectedPharmacy != null
                      ? MediaQuery.of(context).padding.bottom + 200
                      : MediaQuery.of(context).padding.bottom + 24,
                  child: FloatingActionButton.small(
                    heroTag: 'recenter',
                    onPressed: () {
                      _mapController.move(_gjilanCenter, 14.0);
                    },
                    backgroundColor: AppColors.white,
                    child: const Icon(Icons.my_location_rounded,
                        color: AppColors.primary, size: 20),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded,
                    size: 56, color: AppColors.textHint),
                const SizedBox(height: 12),
                Text(AppStrings.failedToLoadPharmacies,
                    style: AppTextStyles.titleMedium),
                const SizedBox(height: 8),
                Text('$e',
                    style: AppTextStyles.bodySmall,
                    textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(pharmaciesProvider),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Provo p\u00ebrs\u00ebri'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPharmacyList(List<PharmacyModel> pharmacies) {
    return pharmacies.isEmpty
        ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowMedium,
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.local_pharmacy_outlined,
                          size: 48, color: AppColors.textHint),
                      SizedBox(height: 12),
                      Text(AppStrings.noPharmacies,
                          style: AppTextStyles.titleMedium),
                      SizedBox(height: 4),
                      Text(AppStrings.noPharmaciesSub,
                          style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            itemCount: pharmacies.length,
            itemBuilder: (ctx, i) => _PharmacyListCard(
              pharmacy: pharmacies[i],
              onTap: () {
                // Switch to map view and center on this pharmacy
                setState(() {
                  _showList = false;
                  _animController.reverse();
                });
                ref.read(selectedPharmacyProvider.notifier).state =
                    pharmacies[i];
                _mapController.move(
                  LatLng(pharmacies[i].latitude, pharmacies[i].longitude),
                  15.0,
                );
              },
              onCall: () => _callPharmacy(pharmacies[i].phone),
              onDirections: () => _openDirections(
                pharmacies[i].latitude,
                pharmacies[i].longitude,
              ),
            ),
          );
  }

  void _updateMarkers(List<PharmacyModel> pharmacies) {
    _markers
      ..clear()
      ..addAll(pharmacies.map(
        (pharmacy) => Marker(
          point: LatLng(pharmacy.latitude, pharmacy.longitude),
          width: 80,
          height: 100,
          child: GestureDetector(
            onTap: () {
              ref.read(selectedPharmacyProvider.notifier).state = pharmacy;
              _mapController.move(
                  LatLng(pharmacy.latitude, pharmacy.longitude), 15.0);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.local_pharmacy_rounded,
                      color: AppColors.primary, size: 22),
                ),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ));
  }

  Future<void> _callPharmacy(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final uri = Uri.parse('tel:${phone.replaceAll(' ', '')}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openDirections(double lat, double lng) async {
    String origin = '';
    try {
      final position = await Geolocator.getCurrentPosition();
      origin = '&origin=${position.latitude},${position.longitude}';
    } catch (_) {
      // If location fails, open without origin
    }
    final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1$origin&destination=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

// Pharmacy list card for list view
class _PharmacyListCard extends StatelessWidget {
  final PharmacyModel pharmacy;
  final VoidCallback onTap;
  final VoidCallback onCall;
  final VoidCallback onDirections;

  const _PharmacyListCard({
    required this.pharmacy,
    required this.onTap,
    required this.onCall,
    required this.onDirections,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pharmacy icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.gradientStart, AppColors.gradientEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.local_pharmacy_rounded,
                    color: AppColors.white, size: 28),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pharmacy.name,
                      style: AppTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 13, color: AppColors.textHint),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            pharmacy.address,
                            style: AppTextStyles.caption.copyWith(fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          pharmacy.isOpen24h
                              ? Icons.schedule_rounded
                              : Icons.access_time_rounded,
                          size: 13,
                          color: pharmacy.isOpen24h
                              ? AppColors.success
                              : AppColors.textHint,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          pharmacy.isOpen24h
                              ? 'Hapur 24/7'
                              : '${pharmacy.openingHours ?? '08:00'} - ${pharmacy.closingHours ?? '20:00'}',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 10,
                            color: pharmacy.isOpen24h
                                ? AppColors.success
                                : AppColors.textHint,
                          ),
                        ),
                        if (pharmacy.rating != null) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.star_rounded,
                              size: 13, color: AppColors.warning),
                          const SizedBox(width: 2),
                          Text(
                            '${pharmacy.rating}',
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textHint,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Action buttons
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: onCall,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.phone_rounded,
                          color: AppColors.primary, size: 18),
                    ),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: onDirections,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.directions_rounded,
                          color: AppColors.primary, size: 18),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PharmacyBottomSheet extends StatelessWidget {
  final PharmacyModel pharmacy;
  final VoidCallback onClose;
  final VoidCallback onCall;
  final VoidCallback onDirections;

  const _PharmacyBottomSheet({
    required this.pharmacy,
    required this.onClose,
    required this.onCall,
    required this.onDirections,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, -6)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child:
                    pharmacy.imageUrl != null && pharmacy.imageUrl!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: CachedNetworkImage(
                                imageUrl: pharmacy.imageUrl!,
                                fit: BoxFit.cover),
                          )
                        : const Icon(Icons.local_pharmacy_rounded,
                            color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pharmacy.name,
                        style: AppTextStyles.titleMedium
                            .copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(pharmacy.address, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onClose,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.close_rounded,
                      size: 16, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (pharmacy.rating != null)
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 14, color: AppColors.warning),
                      const SizedBox(width: 4),
                      Text('${pharmacy.rating}',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.warning)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                if (pharmacy.isOpen24h)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(AppStrings.open24h,
                        style: TextStyle(
                            color: AppColors.success,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  )
                else if (pharmacy.openingHours != null &&
                    pharmacy.closingHours != null)
                  Text('${pharmacy.openingHours} - ${pharmacy.closingHours}',
                      style: AppTextStyles.bodySmall),
                const Spacer(),
              ],
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCall,
                  icon: const Icon(Icons.phone_rounded, size: 18),
                  label: const Text(AppStrings.call,
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onDirections,
                  icon: const Icon(Icons.directions_rounded, size: 18),
                  label: const Text(AppStrings.getDirections,
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
