import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';
import '../main.dart';

class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  int _currentIndex = 3;
  String _filterStatus = 'Të gjitha';
  bool _showOnlyUserPurchases = true;

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    if (index == 0) Navigator.pushReplacementNamed(context, '/home');
    else if (index == 1) Navigator.pushReplacementNamed(context, '/products');
    else if (index == 2) Navigator.pushReplacementNamed(context, '/locations');
    else if (index == 3) return;
    else if (index == 4) Navigator.pushReplacementNamed(context, '/profile');
  }

  List<Map<String, dynamic>> _getFilteredPurchases() {
    List<Map<String, dynamic>> filtered = AppState.purchases;
    
    if (_showOnlyUserPurchases) {
      filtered = filtered.where((p) => p['userId'] == AppState.userName).toList();
    }
    
    if (_filterStatus != 'Të gjitha') {
      filtered = filtered.where((p) => p['status'] == _filterStatus).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredPurchases = _getFilteredPurchases();
    double totalSpent = filteredPurchases.fold(0, (sum, item) => sum + (item['total'] as double));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Blerjet', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {},
          )
        ],
      ),
      body: AppState.purchases.isEmpty 
      ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey),
              const SizedBox(height: 20),
              const Text('Nuk keni blerje', style: TextStyle(fontSize: 18, color: Colors.grey)),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F4C81),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () => Navigator.pushReplacementNamed(context, '/products'),
                child: const Text('Shiko Produktet', style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        )
      : Column(
          children: [
            // Filter controls
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('Të gjitha', _filterStatus == 'Të gjitha'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Në pritje', _filterStatus == 'Në pritje'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Në dorëzim', _filterStatus == 'Në dorëzim'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Përfunduar', _filterStatus == 'Përfunduar'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Anuluar', _filterStatus == 'Anuluar'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Checkbox(
                        value: _showOnlyUserPurchases,
                        onChanged: (value) {
                          setState(() {
                            _showOnlyUserPurchases = value!;
                          });
                        },
                        activeColor: const Color(0xFF0F4C81),
                      ),
                      const Text('Vetëm blerjet e mia', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                  if (AppState.isAdmin && !_showOnlyUserPurchases)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Admin: Po shfaqen të gjitha blerjet e të gjithë përdoruesve',
                        style: TextStyle(color: Colors.orange, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
            
            // Stats summary
            if (filteredPurchases.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            filteredPurchases.length.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F4C81)),
                          ),
                          const Text('Blerje', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '€${totalSpent.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F4C81)),
                          ),
                          const Text('Shpenzuar', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            filteredPurchases.where((p) => p['status'] == 'Përfunduar').length.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
                          ),
                          const Text('Të përfunduara', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredPurchases.length,
                itemBuilder: (context, index) {
                  final p = filteredPurchases[index];
                  return _buildPurchaseItem(p);
                },
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

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _filterStatus = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F4C81) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF0F4C81) : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildPurchaseItem(Map<String, dynamic> p) {
    // Status color mapping
    Color statusColor;
    IconData statusIcon;
    String statusLabel = p['status'];
    
    if (statusLabel == 'Përfunduar') {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (statusLabel == 'Në dorëzim') {
      statusColor = Colors.blue;
      statusIcon = Icons.local_shipping;
    } else if (statusLabel == 'Në pritje') {
      statusColor = Colors.orange;
      statusIcon = Icons.hourglass_empty;
    } else {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Image.network(p['product']['image'], fit: BoxFit.contain),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            p['product']['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '€${p['total'].toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      p['date'],
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.inventory_2, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              '${p['count']} produkt(e)',
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                statusIcon,
                                size: 14,
                                color: statusColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                statusLabel,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (AppState.isAdmin && p.containsKey('userEmail'))
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Përdorues: ${p['userId']} (${p['userEmail']})',
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}