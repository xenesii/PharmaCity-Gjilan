import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';

class LocationsScreen extends StatefulWidget {
  const LocationsScreen({super.key});

  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  int _currentIndex = 2;

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (index == 1) Navigator.pushReplacementNamed(context, '/products');
    else if (index == 2) return;
    else if (index == 3) Navigator.pushReplacementNamed(context, '/purchases');
    else if (index == 4) Navigator.pushReplacementNamed(context, '/profile');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          // Map placeholder
          Container(
            color: const Color(0xFFE8F5E9),
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              children: [
                const Center(child: Text('Map View',
                  style: TextStyle(color: Colors.grey, fontSize: 16))),
                Positioned(
                  top: 200,
                  left: 100,
                  child: Icon(Icons.location_on, size: 40, color: Colors.green[700]),
                ),
                Positioned(
                  top: 150,
                  left: 200,
                  child: Icon(Icons.location_on, size: 40, color: Colors.green[700]),
                ),
                Positioned(
                  top: 280,
                  left: 160,
                  child: Icon(Icons.location_on, size: 40, color: Colors.green[700]),
                ),
              ],
            ),
          ),
          
          // Bottom Cards
          Positioned(
            bottom: 90,
            left: 12,
            right: 12,
            child: Row(
              children: [
                Expanded(
                  child: _buildLocationCard('RIGA PHARM, GJILAN', 'rruga Mehdi Olberajt', '2.8 km'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildLocationCard('RONI PHARM, Gjilan', 'Beqir Musliu', '1.5 km'),
                ),
              ],
            ),
          )
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildLocationCard(String name, String address, String distance) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(name, 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(distance, style: const TextStyle(color: Colors.green, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, size: 12, color: Colors.grey),
              const SizedBox(width: 2),
              Expanded(
                child: Text(address, 
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.access_time, size: 12, color: Colors.grey),
                  SizedBox(width: 2),
                  Text('08:00-23:00', style: TextStyle(fontSize: 10)),
                ],
              ),
              const Text('Hapur', 
                style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.navigation, size: 14, color: Colors.green),
                SizedBox(width: 4),
                Text('Navigo', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
    );
  }
}