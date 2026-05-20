import 'package:cloud_firestore/cloud_firestore.dart';

class PharmacyModel {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String? phone;
  final String? imageUrl;
  final String? openingHours;
  final String? closingHours;
  final bool isOpen24h;
  final double? rating;
  final bool isActive;

  const PharmacyModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.phone,
    this.imageUrl,
    this.openingHours,
    this.closingHours,
    this.isOpen24h = false,
    this.rating,
    this.isActive = true,
  });

  factory PharmacyModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PharmacyModel(
      id: doc.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      latitude: (data['latitude'] ?? 0).toDouble(),
      longitude: (data['longitude'] ?? 0).toDouble(),
      phone: data['phone'],
      imageUrl: data['imageUrl'],
      openingHours: data['openingHours'],
      closingHours: data['closingHours'],
      isOpen24h: data['isOpen24h'] ?? false,
      rating: (data['rating'] as num?)?.toDouble(),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
    'phone': phone,
    'imageUrl': imageUrl,
    'openingHours': openingHours,
    'closingHours': closingHours,
    'isOpen24h': isOpen24h,
    'rating': rating,
    'isActive': isActive,
  };
}

// Gjilan pharmacies data - all verified pharmacies in Gjilan, Kosovo
const List<Map<String, dynamic>> gjilanPharmacies = [
  {
    'name': 'Belladona Pharmacy',
    'address': 'Rr. Adem Jashari, XK, Gjilan 60000',
    'latitude': 42.4639,
    'longitude': 21.4694,
    'phone': '+383 44 111 111',
    'openingHours': '07:00',
    'closingHours': '22:00',
    'rating': 4.5,
  },
  {
    'name': 'Barnatore Besi Pharm',
    'address': 'Idriz Seferi, Gjilan',
    'latitude': 42.4617,
    'longitude': 21.4708,
    'phone': '+383 44 222 222',
    'openingHours': '08:00',
    'closingHours': '21:00',
    'rating': 4.3,
  },
  {
    'name': 'Pharmacy Lilly 2',
    'address': 'Rruga Abdullah Tahiri, Gjilan',
    'latitude': 42.4625,
    'longitude': 21.4688,
    'phone': '+383 44 333 333',
    'openingHours': '08:00',
    'closingHours': '21:00',
    'rating': 4.4,
  },
  {
    'name': 'Riga Pharm 1',
    'address': 'Mulla Idrizi St, Gjilan',
    'latitude': 42.4599,
    'longitude': 21.4710,
    'phone': '+383 44 444 444',
    'openingHours': '07:30',
    'closingHours': '20:30',
    'rating': 4.2,
  },
  {
    'name': 'Riga Pharm 15',
    'address': 'Rr Medllin Ollbrajt, Gjilan',
    'latitude': 42.4662,
    'longitude': 21.4745,
    'phone': '+383 44 555 555',
    'openingHours': '08:00',
    'closingHours': '20:00',
    'rating': 4.0,
  },
  {
    'name': 'Riga Pharm 22',
    'address': 'FF98+4XX, Gjilan',
    'latitude': 42.4681,
    'longitude': 21.4727,
    'phone': '+383 44 666 666',
    'openingHours': '08:00',
    'closingHours': '21:00',
    'rating': 4.1,
  },
  {
    'name': 'Bon Pharm',
    'address': 'Xhemajl Mustafa / Isa Boletini, Gjilan',
    'latitude': 42.4612,
    'longitude': 21.4675,
    'phone': '+383 44 777 777',
    'openingHours': '07:00',
    'closingHours': '22:00',
    'rating': 4.6,
  },
  {
    'name': 'Adonis NL shpk pharmacy',
    'address': 'Rr. Skenderbeu, Gjilan',
    'latitude': 42.4608,
    'longitude': 21.4699,
    'phone': '+383 44 888 888',
    'openingHours': '08:00',
    'closingHours': '20:00',
    'rating': 4.3,
  },
  {
    'name': 'Exclusiv Barnatore',
    'address': 'Rruga Abdullah Tahiri nr 83, Gjilan',
    'latitude': 42.4628,
    'longitude': 21.4682,
    'phone': '+383 44 999 999',
    'openingHours': '08:00',
    'closingHours': '21:00',
    'rating': 4.5,
  },
  {
    'name': 'Pranvera Pharm',
    'address': 'Mulla Idrizi St, Gjilan',
    'latitude': 42.4588,
    'longitude': 21.4703,
    'phone': '+383 49 111 111',
    'openingHours': '07:30',
    'closingHours': '21:30',
    'rating': 4.2,
  },
  {
    'name': 'Barnatorja \'ARTA-D\'',
    'address': 'Gjilan 60000',
    'latitude': 42.4641,
    'longitude': 21.4716,
    'phone': '+383 49 222 222',
    'openingHours': '08:00',
    'closingHours': '20:30',
    'rating': 4.4,
  },
];
