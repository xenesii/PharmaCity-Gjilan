import 'package:cloud_firestore/cloud_firestore.dart';

/// Seeds the Firestore database with categories and products.
/// Call this once from the seed data page.
Future<SeedResult> seedDatabase() async {
  final firestore = FirebaseFirestore.instance;
  final batch = firestore.batch();
  final results = SeedResult();

  // ──────────────────────────────────────────────
  // 1. Kategoritë (Categories)
  // ──────────────────────────────────────────────
  final categories = [
    {
      'name': 'Vitaminat',
      'imageUrl': 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=400&q=80',
      'iconName': 'bolt',
      'sortOrder': 1,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Kujdesi Personal',
      'imageUrl': 'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=400&q=80',
      'iconName': 'spa',
      'sortOrder': 2,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Ftohje & Flut',
      'imageUrl': 'https://images.unsplash.com/photo-1582750433449-648ed127bb54?w=400&q=80',
      'iconName': 'healing',
      'sortOrder': 3,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Baby & Foshnje',
      'imageUrl': 'https://images.unsplash.com/photo-1594824476967-48c8b964273f?w=400&q=80',
      'iconName': 'child_care',
      'sortOrder': 4,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'name': "Sh\u00ebndeti i L\u00ebkur\u00ebs",
      'imageUrl': 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?w=400&q=80',
      'iconName': 'face',
      'sortOrder': 5,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Dh\u00ebmb\u00ebt & Goja',
      'imageUrl': 'https://images.unsplash.com/photo-1571607388263-1044f9ea01dd?w=400&q=80',
      'iconName': 'smile',
      'sortOrder': 6,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Sport & Fitness',
      'imageUrl': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&q=80',
      'iconName': 'fitness_center',
      'sortOrder': 7,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Anti-Allergjik',
      'imageUrl': 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=400&q=80',
      'iconName': 'allergies',
      'sortOrder': 8,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    },
  ];

  final categoryRefs = <String>{};
  for (final cat in categories) {
    final docRef = firestore.collection('categories').doc();
    batch.set(docRef, cat);
    categoryRefs.add(docRef.id);
    results.categoriesCreated++;
  }

  // ──────────────────────────────────────────────
  // 2. Produktet (Products)
  // ──────────────────────────────────────────────
  final now = DateTime.now();

  final products = [
    // ── Vitaminat ──
    _p('Vitamina C 1000mg', 'P\u00ebrforcon sistemin imunitar. 100 tableta.', 8.50, 6.99,
        'Vitaminat', 50, '100 tableta', 4.5, 23, true,
        'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=400&q=80', now),
    _p('Vitamina D3 2000 IU', 'Mban kocka t\u00eb sh\u00ebndetshme. 90 kapsula.', 12.00, 9.99,
        'Vitaminat', 40, '90 kapsula', 4.8, 45, true,
        'https://images.unsplash.com/photo-1577174881658-0f30ed549adc?w=400&q=80', now),
    _p('Multivitamin Kompleks', 'Vitamina A-Z p\u00ebr energji ditore. 60 tableta.', 18.00, 14.50,
        'Vitaminat', 35, '60 tableta', 4.3, 67, true,
        'https://images.unsplash.com/photo-1550572017-edd951b55104?w=400&q=80', now),
    _p('Vitamina B12 500 mcg', 'P\u00ebr nervat dhe prodhimin e energjis\u00eb.', 9.50, null,
        'Vitaminat', 60, '100 tableta', 4.1, 12, false,
        'https://images.unsplash.com/photo-1585435557343-3b092031a831?w=400&q=80', now),
    _p('Zink 15mg', 'Mineral thelb\u00ebsor p\u00ebr imunitet.', 7.00, 5.50,
        'Vitaminat', 45, '90 tableta', 4.6, 31, false,
        'https://images.unsplash.com/photo-1597733336794-12d05021d510?w=400&q=80', now),

    // ── Kujdesi Personal ──
    _p('Shampo Organike 250ml', 'Shampo natyral p\u00ebr flok\u00eb t\u00eb sh\u00ebndetsh\u00ebm.', 12.00, 9.90,
        'Kujdesi Personal', 30, '250ml', 4.7, 88, true,
        'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=400&q=80', now),
    _p('Krem Hidratues 50ml', 'Hidratim i thell\u00eb p\u00ebr fytyr\u00eb.', 15.00, 12.50,
        'Kujdesi Personal', 25, '50ml', 4.4, 54, true,
        'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?w=400&q=80', now),
    _p('Deodorant Fresh 48h', 'Mbrojtje 48-or\u00ebshe pa alkool.', 4.50, 3.90,
        'Kujdesi Personal', 80, '100ml', 4.2, 102, false,
        'https://images.unsplash.com/photo-1601612628452-9e99ced43524?w=400&q=80', now),
    _p('Sapun i L\u00ebng\u00ebt 500ml', 'Sapun dore me ekstrakt aloe vera.', 3.20, null,
        'Kujdesi Personal', 100, '500ml', 4.0, 44, false,
        'https://images.unsplash.com/photo-1589227365533-cee630bd59bd?w=400&q=80', now),

    // ── Ftohje & Flut ──
    _p('Fervex 8 shashe', 'Pluhur p\u00ebr simptomat e ftohjes.', 6.50, 5.20,
        'Ftohje & Flut', 40, '8 shashe', 4.6, 120, true,
        'https://images.unsplash.com/photo-1582750433449-648ed127bb54?w=400&q=80', now),
    _p('Nurofen Fast 400mg', 'P\u00ebr dhimbje koke dhe temperatur\u00eb.', 7.80, 6.50,
        'Ftohje & Flut', 35, '30 tableta', 4.5, 200, true,
        'https://images.unsplash.com/photo-1550572017-edd951b55104?w=400&q=80', now),
    _p('Panadol Extra 500mg', 'Leht\u00ebsim i shpejt\u00eb i dhimbjes.', 5.50, 4.50,
        'Ftohje & Flut', 60, '24 tableta', 4.3, 180, true,
        'https://images.unsplash.com/photo-1585435557343-3b092031a831?w=400&q=80', now),
    _p('Balsam Eukalipt 20g', 'P\u00ebr inhalim dhe leht\u00ebsim t\u00eb hund\u00ebs.', 3.80, null,
        'Ftohje & Flut', 55, '20g', 4.0, 34, false,
        'https://images.unsplash.com/photo-1597733336794-12d05021d510?w=400&q=80', now),

    // ── Baby & Foshnje ──
    _p('Pelena Baby Size 3', 'Pelena t\u00eb buta p\u00ebr foshnje, 30 cop\u00eb.', 9.90, 8.50,
        'Baby & Foshnje', 20, '30 cop\u00eb', 4.8, 156, true,
        'https://images.unsplash.com/photo-1594824476967-48c8b964273f?w=400&q=80', now),
    _p('Shampo Baby 200ml', 'Shampo pa lot p\u00ebr foshnje.', 5.50, 4.50,
        'Baby & Foshnje', 35, '200ml', 4.6, 89, true,
        'https://images.unsplash.com/photo-1589227365533-cee630bd59bd?w=400&q=80', now),
    _p('Krem p\u00ebr Skuqje 50g', 'Krem mbrojt\u00ebs p\u00ebr foshnje.', 6.00, null,
        'Baby & Foshnje', 30, '50g', 4.4, 41, false,
        'https://images.unsplash.com/photo-1601612628452-9e99ced43524?w=400&q=80', now),

    // ── Shëndeti i Lëkurës ──
    _p('Bepanthen Plus 30g', 'Krem p\u00ebr sh\u00ebrimin e plag\u00ebve.', 9.50, 7.90,
        "Sh\u00ebndeti i L\u00ebkur\u00ebs", 25, '30g', 4.7, 73, true,
        'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?w=400&q=80', now),
    _p('Krem Kortizonik 15g', 'P\u00ebr alergji dhe skuqje t\u00eb l\u00ebkur\u00ebs.', 7.20, null,
        "Sh\u00ebndeti i L\u00ebkur\u00ebs", 20, '15g', 4.1, 28, false,
        'https://images.unsplash.com/photo-1597733336794-12d05021d510?w=400&q=80', now),
    _p('Sunscreen SPF 50', 'Mbrojtje nga dielli 200ml.', 14.00, 11.50,
        "Sh\u00ebndeti i L\u00ebkur\u00ebs", 40, '200ml', 4.5, 66, true,
        'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=400&q=80', now),

    // ── Dhëmbët & Goja ──
    _p('Past\u00eb Dh\u00ebmb\u00ebsh Whitening 100ml', 'Zbardh dhe forcon smaltin.', 4.80, 3.90,
        'Dh\u00ebmb\u00ebt & Goja', 60, '100ml', 4.3, 95, true,
        'https://images.unsplash.com/photo-1571607388263-1044f9ea01dd?w=400&q=80', now),
    _p('Fur\u00e7\u00eb Dh\u00ebmb\u00ebsh Soft', 'Qime t\u00eb buta p\u00ebr mishrat e dh\u00ebmb\u00ebve.', 2.50, 1.90,
        'Dh\u00ebmb\u00ebt & Goja', 100, '1 cop\u00eb', 4.1, 50, false,
        'https://images.unsplash.com/photo-1607613009820-a29f7bb81c04?w=400&q=80', now),
    _p('Shp\u00eblar\u00ebs Goje 300ml', 'Mbrojtje nga kariesi dhe pllaka.', 5.00, 4.20,
        'Dh\u00ebmb\u00ebt & Goja', 45, '300ml', 4.2, 33, false,
        'https://images.unsplash.com/photo-1589227365533-cee630bd59bd?w=400&q=80', now),

    // ── Sport & Fitness ──
    _p('Protein Whey 500g', 'Pluhur proteinash p\u00ebr muskuj.', 25.00, 19.90,
        'Sport & Fitness', 15, '500g', 4.8, 112, true,
        'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&q=80', now),
    _p('BCAA 120 kapsula', 'Aminoacide p\u00ebr rikuperim.', 18.00, 15.00,
        'Sport & Fitness', 20, '120 kapsula', 4.4, 45, true,
        'https://images.unsplash.com/photo-1550572017-edd951b55104?w=400&q=80', now),
    _p('Izotonik 500ml', 'Pije p\u00ebr hidratim gjat\u00eb st\u00ebrvitjes.', 2.50, null,
        'Sport & Fitness', 80, '500ml', 4.0, 22, false,
        'https://images.unsplash.com/photo-1597733336794-12d05021d510?w=400&q=80', now),

    // ── Anti-Allergjik ──
    _p('Claritine 10mg', 'P\u00ebr alergji sezonale, 10 tableta.', 7.50, 6.20,
        'Anti-Allergjik', 50, '10 tableta', 4.5, 88, true,
        'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=400&q=80', now),
    _p('Loratadin 10mg', 'Antihistaminik p\u00ebr alergjit\u00eb.', 5.40, 4.30,
        'Anti-Allergjik', 45, '30 tableta', 4.2, 55, true,
        'https://images.unsplash.com/photo-1585435557343-3b092031a831?w=400&q=80', now),
    _p('Allergodil Pika Sysh', 'Pika p\u00ebr sy alergjik\u00eb.', 8.00, null,
        'Anti-Allergjik', 25, '10ml', 4.3, 30, false,
        'https://images.unsplash.com/photo-1597733336794-12d05021d510?w=400&q=80', now),
    _p('Nasonex Spray 60 doza', 'Spray hund\u00ebsh p\u00ebr alergji.', 14.50, 12.00,
        'Anti-Allergjik', 20, '60 doza', 4.6, 62, true,
        'https://images.unsplash.com/photo-1582750433449-648ed127bb54?w=400&q=80', now),
  ];

  for (final product in products) {
    final docRef = firestore.collection('products').doc();
    batch.set(docRef, product);
    results.productsCreated++;
  }

  // ──────────────────────────────────────────────
  // 3. Farmacitë (Pharmacies)
  // ──────────────────────────────────────────────
  final pharmacies = [
    {
      'name': 'Belladona Pharmacy',
      'address': 'Rr. Adem Jashari, XK, Gjilan 60000',
      'latitude': 42.4639,
      'longitude': 21.4694,
      'phone': '+383 44 111 111',
      'openingHours': '07:00',
      'closingHours': '22:00',
      'rating': 4.5,
      'isOpen24h': false,
      'isActive': true,
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
      'isOpen24h': false,
      'isActive': true,
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
      'isOpen24h': false,
      'isActive': true,
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
      'isOpen24h': false,
      'isActive': true,
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
      'isOpen24h': false,
      'isActive': true,
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
      'isOpen24h': false,
      'isActive': true,
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
      'isOpen24h': false,
      'isActive': true,
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
      'isOpen24h': false,
      'isActive': true,
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
      'isOpen24h': false,
      'isActive': true,
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
      'isOpen24h': false,
      'isActive': true,
    },
    {
      'name': "Barnatorja 'ARTA-D'",
      'address': 'Gjilan 60000',
      'latitude': 42.4641,
      'longitude': 21.4716,
      'phone': '+383 49 222 222',
      'openingHours': '08:00',
      'closingHours': '20:30',
      'rating': 4.4,
      'isOpen24h': false,
      'isActive': true,
    },
  ];

  for (final pharmacy in pharmacies) {
    // Kontrollo n\u00ebse farmacia ekziston tashm\u00eb
    final query = await firestore
        .collection('pharmacies')
        .where('name', isEqualTo: pharmacy['name'])
        .limit(1)
        .get();
    if (query.docs.isEmpty) {
      final docRef = firestore.collection('pharmacies').doc();
      await docRef.set(pharmacy);
      results.pharmaciesCreated++;
    }
  }

  return results;
}

/// Helper to build a product map.
Map<String, dynamic> _p(
  String name,
  String description,
  double price,
  double? discountPrice,
  String category,
  int stock,
  String unit,
  double rating,
  int reviewCount,
  bool isFeatured,
  String imageUrl,
  DateTime now,
) {
  return {
    'name': name,
    'description': description,
    'price': price,
    if (discountPrice != null) 'discountPrice': discountPrice,
    'category': category,
    'imageUrl': imageUrl,
    'imageUrls': [imageUrl],
    'stock': stock,
    'unit': unit,
    'rating': rating,
    'reviewCount': reviewCount,
    'isFeatured': isFeatured,
    'isPrescription': false,
    'isActive': true,
    'createdAt': Timestamp.fromDate(now),
    'updatedAt': Timestamp.fromDate(now),
  };
}

class SeedResult {
  int categoriesCreated = 0;
  int productsCreated = 0;
  int pharmaciesCreated = 0;

  int get total => categoriesCreated + productsCreated + pharmaciesCreated;
}
