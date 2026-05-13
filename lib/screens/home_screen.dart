import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Sample products
  final List<Map<String, dynamic>> products = [
    {'id': '1', 'name': 'LAINO Pro-Intensive', 'description': '250ml', 'price': 9.90, 'oldPrice': 19.90, 'image': 'https://via.placeholder.com/150x200.png/EEEEEE/0F4C81?text=LAINO'},
    {'id': '2', 'name': 'CeraVe Retinol', 'description': '50ml', 'price': 9.90, 'oldPrice': 19.90, 'image': 'https://via.placeholder.com/150x200.png/EEEEEE/0F4C81?text=CeraVe'},
    {'id': '3', 'name': 'LIQUID Vitamin D', 'description': '30ml', 'price': 9.90, 'oldPrice': 19.90, 'image': 'https://via.placeholder.com/150x200.png/EEEEEE/0F4C81?text=Vitamin'},
    {'id': '4', 'name': 'ACTIVELAB Multi', 'description': '60 tabs', 'price': 9.90, 'oldPrice': 19.90, 'image': 'https://via.placeholder.com/150x200.png/EEEEEE/0F4C81?text=Multivit'},
  ];

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    if (index == 0) return;
    if (index == 1) Navigator.pushReplacementNamed(context, '/products');
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
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F4C81), Color(0xFF1A6DB5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Mirë se vini,', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      Text(
                        AppState.userName.isNotEmpty ? AppState.userName : 'Mysafir',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white24, 
                          shape: BoxShape.circle
                        ),
                        child: const Icon(Icons.location_on, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white24, 
                          shape: BoxShape.circle
                        ),
                        child: const Icon(Icons.notifications, color: Colors.white, size: 20),
                      ),
                    ],
                  )
                ],
              ),
            ),

            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Fletushkat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 180,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildBanner("PËRFITONI ZBRITJE", const Color(0xFF0F4C81)),
                          _buildBanner("NATURAL SKINCARE", const Color(0xFF5D4037)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Produktet në Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: products.take(4).length,
                      itemBuilder: (context, index) {
                        return _buildProductCard(products[index], context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildBanner(String text, Color color) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_hospital, size: 40, color: Colors.white),
            const SizedBox(height: 10),
            Text(text, textAlign: TextAlign.center, 
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, BuildContext context) {
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