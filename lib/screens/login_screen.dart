import 'package:flutter/material.dart';
import '../main.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Guest login - still works but with limited features
                    AppState.userName = 'Mysafir';
                    AppState.isAdmin = false;
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  child: const Text('Vazhdo si mysafir'),
                ),
              ),
              const Spacer(),
              // Logo
              const Icon(Icons.local_hospital, size: 80, color: Color(0xFF0F4C81)),
              const SizedBox(height: 10),
              const Text(
                'PHARMA CITY',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F4C81)),
              ),
              const Text(
                'GJILAN',
                style: TextStyle(fontSize: 16, color: Color(0xFF14B1AB)),
              ),
              const Spacer(),
              
              // Inputs
              _buildInput(Icons.person_outline, 'Email / Numri i telefonit', controller: emailController),
              const SizedBox(height: 15),
              _buildInput(Icons.lock_outline, 'Fjalëkalimi', isPassword: true, controller: passwordController),
              
              const SizedBox(height: 30),
              
              // Login Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    String loginInput = emailController.text.trim();
                    String passwordInput = passwordController.text.trim();
                    
                    if (loginInput.isEmpty || passwordInput.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ju lutem plotësoni të gjitha fushat!')),
                      );
                      return;
                    }
                    
                    // Check if user exists in our system
                    bool userFound = false;
                    for (var user in AppState.allUsers) {
                      if ((user['email'] == loginInput || user['phone'] == loginInput) && 
                          user['password'] == passwordInput) {
                        AppState.userName = user['name'];
                        AppState.userEmail = user['email'];
                        AppState.userPhone = user['phone'];
                        AppState.isAdmin = user['isAdmin'] ?? false;
                        userFound = true;
                        break;
                      }
                    }
                    
                    if (userFound) {
                      Navigator.pushReplacementNamed(context, '/home');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Llogaria nuk ekziston. Ju lutem regjistrohuni fillimisht!')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F4C81),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    elevation: 0,
                  ),
                  child: const Text('Kyçu', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              
              const SizedBox(height: 20),
              
              const Text('Keni harruar fjalëkalimin?', 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Nuk keni llogari? ', style: TextStyle(fontSize: 13)),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/signup'),
                    child: const Text('Regjistrohu', 
                      style: TextStyle(color: Color(0xFF0F4C81), fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(IconData icon, String hint, {bool isPassword = false, TextEditingController? controller}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          icon: Icon(icon, color: Colors.grey),
          hintText: hint,
          border: InputBorder.none,
          hintStyle: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}