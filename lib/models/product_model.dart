class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double oldPrice;
  final String imageUrl;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.oldPrice,
    required this.imageUrl,
    required this.category,
  });
}

// Demo Data with realistic placeholders
final List<Product> demoProducts = [
  Product(
    id: '1',
    name: 'LAINO Pro-Intensive',
    description: 'Karatetarsk: 250ml',
    price: 9.90,
    oldPrice: 19.90,
    imageUrl: 'https://via.placeholder.com/150x200.png/EEEEEE/0F4C81?text=LAINO',
    category: 'Skincare',
  ),
  Product(
    id: '2',
    name: 'CeraVe Retinol',
    description: 'Karatetarsk: 50ml',
    price: 9.90,
    oldPrice: 19.90,
    imageUrl: 'https://via.placeholder.com/150x200.png/EEEEEE/0F4C81?text=CeraVe',
    category: 'Skincare',
  ),
  Product(
    id: '3',
    name: 'LIQUID Vitamin D',
    description: 'Karatetarsk: 30ml',
    price: 9.90,
    oldPrice: 19.90,
    imageUrl: 'https://via.placeholder.com/150x200.png/EEEEEE/0F4C81?text=Vitamin',
    category: 'Vitamins',
  ),
  Product(
    id: '4',
    name: 'ACTIVELAB Multi',
    description: 'Karatetarsk: 60 tabs',
    price: 9.90,
    oldPrice: 19.90,
    imageUrl: 'https://via.placeholder.com/150x200.png/EEEEEE/0F4C81?text=Multivit',
    category: 'Vitamins',
  ),
  Product(
    id: '5',
    name: 'DEPRAXIM',
    description: 'Karatetarsk: 30 caps',
    price: 9.90,
    oldPrice: 19.90,
    imageUrl: 'https://via.placeholder.com/150x200.png/EEEEEE/0F4C81?text=Depraxim',
    category: 'Medicine',
  ),
  Product(
    id: '6',
    name: 'MY BABY Teether',
    description: 'Karatetarsk: Baby',
    price: 9.90,
    oldPrice: 19.90,
    imageUrl: 'https://via.placeholder.com/150x200.png/EEEEEE/0F4C81?text=MyBaby',
    category: 'Baby',
  ),
];