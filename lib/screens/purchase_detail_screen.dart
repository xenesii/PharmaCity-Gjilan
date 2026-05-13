import 'package:flutter/material.dart';
import '../main.dart';
import '../widgets/bottom_nav.dart';

class PurchaseDetailScreen extends StatefulWidget {
  final Map<String, dynamic> purchase;
  final int purchaseIndex;

  const PurchaseDetailScreen({
    super.key, 
    required this.purchase,
    required this.purchaseIndex,
  });

  @override
  State<PurchaseDetailScreen> createState() => _PurchaseDetailScreenState();
}

class _PurchaseDetailScreenState extends State<PurchaseDetailScreen> {
  final int _currentIndex = 3;

  void _onNavTap(int index) {
    if (index == _currentIndex) return;
    
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, '/products');
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/locations');
    } else if (index == 3) return;
    else if (index == 4) {
      Navigator.pushReplacementNamed(context, '/profile');
    }
  }

  void _cancelOrder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Anulo porosinë'),
        content: const Text('A jeni i sigurt që dëshironi ta anuloni këtë porosi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Jo'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                AppState.purchases[widget.purchaseIndex]['status'] = 'Anuluar';
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Porosia u anulua!'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Po, Anulo'),
          ),
        ],
      ),
    );
  }

  void _reorder() {
    setState(() {
      AppState.addPurchase({
        'id': '#${1000 + AppState.purchases.length + 1}',
        'date': 'Sot, ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        'count': widget.purchase['count'],
        'total': widget.purchase['total'],
        'status': 'Në dorëzim',
        'product': widget.purchase['product']
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Porosia u ripërsërit!'),
        backgroundColor: Color(0xFF0F4C81),
      ),
    );
    Navigator.pop(context);
  }

  void _trackOrder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gjurmimi i porosisë'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTrackingStep(0, 'Porosia u konfirmua', widget.purchase['status'] != 'Anuluar'),
            _buildTrackingStep(1, 'Në përgatitje', widget.purchase['status'] == 'Në dorëzim' || widget.purchase['status'] == 'Përfunduar'),
            _buildTrackingStep(2, 'Në dorëzim', widget.purchase['status'] == 'Në dorëzim'),
            _buildTrackingStep(3, 'E përfunduar', widget.purchase['status'] == 'Përfunduar'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mbylle'),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingStep(int step, String title, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted ? const Color(0xFF0F4C81) : Colors.grey[300],
            ),
            child: Icon(
              isCompleted ? Icons.check : Icons.access_time,
              size: 18,
              color: isCompleted ? Colors.white : Colors.grey,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: isCompleted ? Colors.black : Colors.grey,
              fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.purchase['product'];
    final status = widget.purchase['status'];
    
    Color getStatusColor() {
      switch(status) {
        case 'Përfunduar': return Colors.green;
        case 'Anuluar': return Colors.red;
        default: return const Color(0xFF0F4C81);
      }
    }

    IconData getStatusIcon() {
      switch(status) {
        case 'Përfunduar': return Icons.check_circle;
        case 'Anuluar': return Icons.cancel;
        default: return Icons.local_shipping;
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Detajet e porosisë'),
        backgroundColor: const Color(0xFF0F4C81),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Status Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: getStatusColor().withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(getStatusIcon(), color: getStatusColor(), size: 30),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Porosia ${widget.purchase['id']}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.purchase['date'],
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: getStatusColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: getStatusColor(),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildActionButton(
                        icon: Icons.track_changes,
                        label: 'Gjurmo',
                        onTap: _trackOrder,
                        color: const Color(0xFF0F4C81),
                      ),
                      if (status == 'Në dorëzim')
                        _buildActionButton(
                          icon: Icons.cancel,
                          label: 'Anulo',
                          onTap: _cancelOrder,
                          color: Colors.red,
                        ),
                      if (status != 'Anuluar')
                        _buildActionButton(
                          icon: Icons.repeat,
                          label: 'Ripërsërit',
                          onTap: _reorder,
                          color: Colors.green,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Product Details
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detajet e produktit',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2EBE9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Image.network(
                          product['image'],
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.image_not_supported, size: 40);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['name'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              product['description'],
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  '€${product['price'].toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F4C81),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '€${product['oldPrice'].toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Order Summary
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Përmbledhja e porosisë',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryRow('Sasia', '${widget.purchase['count']} x produkt(e)'),
                  const Divider(),
                  _buildSummaryRow(
                    'Çmimi total',
                    '€${widget.purchase['total'].toStringAsFixed(2)}',
                    isBold: true,
                  ),
                  const Divider(),
                  _buildSummaryRow('Metoda e pagesës', 'Cash on Delivery'),
                  _buildSummaryRow('Adresa', 'Rruga Ekrem Rexha, Gjilan'),
                ],
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

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
              color: isBold ? const Color(0xFF0F4C81) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }
}
