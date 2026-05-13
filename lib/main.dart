import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/products_screen.dart';
import 'screens/locations_screen.dart';
import 'screens/purchases_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/admin_dashboard.dart';

void main() {
  runApp(const PharmaCityApp());
}

class PharmaCityApp extends StatelessWidget {
  const PharmaCityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pharma City',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF0F4C81),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/products': (context) => const ProductsScreen(),
        '/locations': (context) => const LocationsScreen(),
        '/purchases': (context) => const PurchasesScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/admin': (context) => const AdminDashboard(),
      },
    );
  }
}

// Global state class
class AppState {
  static String userName = '';
  static String userPhone = '';
  static String userEmail = '';
  static String userPassword = '';
  static bool isAdmin = false;
  static String userPfp = ''; // Profile picture URL
  
  static List<Map<String, dynamic>> purchases = [];
  
  static List<Map<String, dynamic>> allUsers = [
    {
      'name': 'Admin',
      'email': 'enesi',
      'phone': '123456789',
      'password': 'admin123',
      'isAdmin': true,
      'pfp': 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png'
    },
  ];
  
  static List<Map<String, dynamic>> allProducts = [
    {'id': '1', 'name': 'LAINO Pro-Intensive', 'description': '250ml', 'price': 9.90, 'oldPrice': 19.90, 'image': 'https://via.placeholder.com/150x200.png/EEEEEE/0F4C81?text=LAINO', 'category': 'Skincare', 'stock': 45},
    {'id': '2', 'name': 'CeraVe Retinol', 'description': '50ml', 'price': 9.90, 'oldPrice': 19.90, 'image': 'https://via.placeholder.com/150x200.png/EEEEEE/0F4C81?text=CeraVe', 'category': 'Skincare', 'stock': 32},
    {'id': '3', 'name': 'LIQUID Vitamin D', 'description': '30ml', 'price': 9.90, 'oldPrice': 19.90, 'image': 'https://via.placeholder.com/150x200.png/EEEEEE/0F4C81?text=Vitamin', 'category': 'Vitamins', 'stock': 18},
    {'id': '4', 'name': 'ACTIVELAB Multi', 'description': '60 tabs', 'price': 9.90, 'oldPrice': 19.90, 'image': 'https://via.placeholder.com/150x200.png/EEEEEE/0F4C81?text=Multivit', 'category': 'Vitamins', 'stock': 27},
    {'id': '5', 'name': 'DEPRAXIM', 'description': '30 caps', 'price': 9.90, 'oldPrice': 19.90, 'image': 'https://via.placeholder.com/150x200.png/EEEEEE/0F4C81?text=Depraxim', 'category': 'Medicine', 'stock': 15},
    {'id': '6', 'name': 'MY BABY Teether', 'description': 'Baby', 'price': 9.90, 'oldPrice': 19.90, 'image': 'https://via.placeholder.com/150x200.png/EEEEEE/0F4C81?text=MyBaby', 'category': 'Baby', 'stock': 20},
  ];
  
  static final List<String> statuses = ['Në pritje', 'Në dorëzim', 'Përfunduar', 'Anuluar'];
  
  static void addPurchase(Map<String, dynamic> product) {
    String randomStatus = statuses[DateTime.now().millisecondsSinceEpoch % statuses.length];
    
    purchases.insert(0, {
      'id': '#${1000 + purchases.length + 1}',
      'date': 'Sot, ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
      'count': 1,
      'total': product['price'],
      'status': randomStatus,
      'product': product,
      'userId': userName,
      'userEmail': userEmail,
    });
  }
  
  static void clearPurchases() {
    purchases.clear();
  }
  
  static void clearUser() {
    userName = '';
    userPhone = '';
    userEmail = '';
    userPassword = '';
    isAdmin = false;
    userPfp = '';
  }
  
  static void updateUserPfp(String email, String pfpUrl) {
    for (var user in allUsers) {
      if (user['email'] == email) {
        user['pfp'] = pfpUrl;
        if (userEmail == email) {
          userPfp = pfpUrl;
        }
        break;
      }
    }
  }
  
  static String getUserPfp(String email) {
    for (var user in allUsers) {
      if (user['email'] == email) {
        return user['pfp'] ?? '';
      }
    }
    return '';
  }
  
  static void addUser(String name, String email, String phone, String password, bool isAdminUser) {
    allUsers.add({
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'isAdmin': isAdminUser,
      'pfp': 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
    });
  }
  
  static void addProduct(Map<String, dynamic> product) {
    allProducts.add(product);
  }
  
  static void updateProduct(String id, Map<String, dynamic> updatedData) {
    int index = allProducts.indexWhere((p) => p['id'] == id);
    if (index != -1) {
      allProducts[index] = updatedData;
    }
  }
  
  static void deleteProduct(String id) {
    allProducts.removeWhere((p) => p['id'] == id);
  }
}