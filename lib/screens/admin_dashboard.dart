import 'package:flutter/material.dart';
import '../main.dart';
import '../widgets/bottom_nav.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    if (index == 0) {
      return;
    }
    if (index == 1) {
      Navigator.pushReplacementNamed(context, '/products');
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/locations');
    } else if (index == 3) {
      Navigator.pushReplacementNamed(context, '/purchases');
    } else if (index == 4) {
      Navigator.pushReplacementNamed(context, '/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!AppState.isAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          backgroundColor: const Color(0xFF0F4C81),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.block, size: 80, color: Colors.red),
              const SizedBox(height: 20),
              const Text(
                'Qasje e ndaluar!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
              ),
              const SizedBox(height: 10),
              const Text('Vetëm administratorët mund të qasen në këtë faqe.'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F4C81),
                ),
                child: const Text('Kthehu në faqen kryesore'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0F4C81),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistics cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Përdorues',
                    AppState.allUsers.length.toString(),
                    Icons.people,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildStatCard(
                    'Produkte',
                    AppState.allProducts.length.toString(),
                    Icons.inventory_2,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Blerje',
                    AppState.purchases.length.toString(),
                    Icons.shopping_cart,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildStatCard(
                    'Total €',
                    AppState.purchases.fold(0.0, (sum, item) => sum + (item['total'] as double))
                        .toStringAsFixed(2),
                    Icons.euro_symbol,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Users list
            const Text(
              'Përdoruesit e regjistruar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: AppState.allUsers.length,
                itemBuilder: (context, index) {
                  final user = AppState.allUsers[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey[200],
                        backgroundImage: user['pfp'] != null && (user['pfp'] as String).isNotEmpty
                            ? NetworkImage(user['pfp'] as String)
                            : null,
                        child: user['pfp'] == null || (user['pfp'] as String).isEmpty
                            ? Text(
                                (user['name'] as String).substring(0, 1).toUpperCase(),
                                style: TextStyle(
                                  color: user['isAdmin'] == true ? Colors.black : Colors.blue[800],
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      title: Text(user['name'] as String),
                      subtitle: Text(user['email'] as String),
                      trailing: user['isAdmin'] == true 
                          ? const Chip(label: Text('Admin'), backgroundColor: Colors.amber)
                          : null,
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Products management
            const Text(
              'Menaxhimi i produkteve',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _showAddProductDialog();
                },
                icon: const Icon(Icons.add),
                label: const Text('Shto produkt'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F4C81),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: AppState.allProducts.length,
                itemBuilder: (context, index) {
                  final product = AppState.allProducts[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Image.network(product['image'] as String, fit: BoxFit.contain),
                        ),
                      ),
                      title: Text(product['name'] as String),
                      subtitle: Text('€${product['price']} • Stok: ${product['stock']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              _showEditProductDialog(product);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _showDeleteProductDialog(product['id'] as String);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
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

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Icon(icon, color: color, size: 28),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddProductDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController oldPriceController = TextEditingController();
    final TextEditingController stockController = TextEditingController();
    final TextEditingController categoryController = TextEditingController();
    final TextEditingController imageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Shto produkt të ri'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(hintText: 'Emri i produktit'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(hintText: 'Përshkrimi'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Çmimi (€)'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: oldPriceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Çmimi i vjetër (€)'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: stockController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Stoku'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(hintText: 'Kategoria'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: imageController,
                  decoration: const InputDecoration(hintText: 'URL e imazhit'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Anulo'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  AppState.addProduct({
                    'id': DateTime.now().millisecondsSinceEpoch.toString(),
                    'name': nameController.text,
                    'description': descriptionController.text,
                    'price': double.tryParse(priceController.text) ?? 0.0,
                    'oldPrice': double.tryParse(oldPriceController.text) ?? 0.0,
                    'stock': int.tryParse(stockController.text) ?? 0,
                    'category': categoryController.text,
                    'image': imageController.text.isNotEmpty 
                        ? imageController.text 
                        : 'https://via.placeholder.com/150x200.png/EEEEEE/0F4C81?text=Produkt',
                  });
                  Navigator.pop(context);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Produkti u shtua me sukses!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ju lutem plotësoni emrin e produktit!')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F4C81),
              ),
              child: const Text('Shto', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showEditProductDialog(Map<String, dynamic> product) {
    final TextEditingController nameController = TextEditingController(text: product['name'] as String);
    final TextEditingController descriptionController = TextEditingController(text: product['description'] as String);
    final TextEditingController priceController = TextEditingController(text: product['price'].toString());
    final TextEditingController oldPriceController = TextEditingController(text: product['oldPrice'].toString());
    final TextEditingController stockController = TextEditingController(text: product['stock'].toString());
    final TextEditingController categoryController = TextEditingController(text: product['category'] as String);
    final TextEditingController imageController = TextEditingController(text: product['image'] as String);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ndrysho produkt'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(hintText: 'Emri i produktit'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(hintText: 'Përshkrimi'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Çmimi (€)'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: oldPriceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Çmimi i vjetër (€)'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: stockController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Stoku'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(hintText: 'Kategoria'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: imageController,
                  decoration: const InputDecoration(hintText: 'URL e imazhit'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Anulo'),
            ),
            ElevatedButton(
              onPressed: () {
                AppState.updateProduct(product['id'] as String, {
                  'id': product['id'],
                  'name': nameController.text,
                  'description': descriptionController.text,
                  'price': double.tryParse(priceController.text) ?? 0.0,
                  'oldPrice': double.tryParse(oldPriceController.text) ?? 0.0,
                  'stock': int.tryParse(stockController.text) ?? 0,
                  'category': categoryController.text,
                  'image': imageController.text,
                });
                Navigator.pop(context);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Produkti u përditësua me sukses!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F4C81),
              ),
              child: const Text('Ruaj', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteProductDialog(String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Fshi produkt'),
          content: const Text('A jeni i sigurt që dëshironi të fshini këtë produkt?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Anulo'),
            ),
            ElevatedButton(
              onPressed: () {
                AppState.deleteProduct(id);
                Navigator.pop(context);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Produkti u fshi me sukses!')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Fshi', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}