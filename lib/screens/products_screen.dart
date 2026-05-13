import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';
import '../main.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  int _currentIndex = 1;

  // All products
  final List<Map<String, dynamic>> products = [
    {'id': '1', 'name': 'LAINO Pro-Intensive', 'description': '250ml', 'price': 9.90, 'oldPrice': 19.90, 'image': 'https://via.placeholder.com/150x200.png/EEEEEE/0F4C81?text=LAINO'},
    {'id': '2', 'name': 'CeraVe Retinol', 'description': '50ml', 'price': 9.90, 'oldPrice': 19.90, 'image': 'https://via.placeholder.com/150x200.png/EEEEEE/0F4C81?text=CeraVe'},
    {'id': '3', 'name': 'LIQUID Vitamin D', 'description': '30ml', 'price': 9.90, 'oldPrice': 19.90, 'image': 'https://via.placeholder.com/150x200.png/EEEEEE/0F4C81?text=Vitamin'},
    {'id': '4', 'name': 'ACTIVELAB Multi', 'description': '60 tabs', 'price': 9.90, 'oldPrice': 19.90, 'image': 'https://via.placeholder.com/150x200.png/EEEEEE/0F4C81?text=Multivit'},
    {'id': '5', 'name': 'DEPRAXIM', 'description': '30 caps', 'price': 9.90, 'oldPrice': 19.90, 'image': 'https://via.placeholder.com/150x200.png/EEEEEE/0F4C81?text=Depraxim'},
    {'id': '6', 'name': 'MY BABY Teether', 'description': 'Baby', 'price': 9.90, 'oldPrice': 19.90, 'image': 'https://via.placeholder.com/150x200.png/EEEEEE/0F4C81?text=MyBaby'},
  ];

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    if (index == 0) Navigator.pushReplacementNamed(context, '/home');
    else if (index == 1) return;
    else if (index == 2) Navigator.pushReplacementNamed(context, '/locations');
    else if (index == 3) Navigator.pushReplacementNamed(context, '/purchases');
    else if (index == 4) Navigator.pushReplacementNamed(context, '/profile');
  }

  void _buyProduct(Map<String, dynamic> product) {
    setState(() {
      AppState.addPurchase(product);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product['name']} u shtua në shportë!'),
        backgroundColor: const Color(0xFF0F4C81),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Produktet', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0F4C81),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: const Color(0xFF0F4C81),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(25),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: Colors.grey),
                  hintText: 'Kërko produktin tuaj...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.62,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return _buildProductCard(products[index]);
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2EBE9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.network(product['image'], fit: BoxFit.contain),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4D4D),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('-20%', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(product['description'], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('€${product['price'].toStringAsFixed(2)}', 
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F4C81), fontSize: 13)),
                        Text('€${product['oldPrice'].toStringAsFixed(2)}', 
                          style: const TextStyle(fontSize: 10, color: Colors.grey, decoration: TextDecoration.lineThrough)),
                      ],
                    ),
                    InkWell(
                      onTap: () => _buyProduct(product),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFF0F4C81),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 16),
                      ),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}