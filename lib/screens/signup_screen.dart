import 'package:flutter/material.dart';
import '../main.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.local_hospital, size: 60, color: Color(0xFF0F4C81)),
              const SizedBox(height: 20),
              const Text('Krijo Llogari', 
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              
              _buildInput(Icons.person_outline, 'Emri i plotë', controller: nameController),
              const SizedBox(height: 15),
              _buildInput(Icons.email_outlined, 'Email', controller: emailController),
              const SizedBox(height: 15),
              _buildInput(Icons.phone_outlined, 'Numri i telefonit', controller: phoneController),
              const SizedBox(height: 15),
              _buildInput(Icons.lock_outline, 'Fjalëkalimi', isPassword: true, controller: passwordController),
              
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    String name = nameController.text.trim();
                    String email = emailController.text.trim();
                    String phone = phoneController.text.trim();
                    String password = passwordController.text.trim();
                    
                    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ju lutem plotësoni të gjitha fushat!')),
                      );
                      return;
                    }
                    
                    // Check if email already exists
                    for (var user in AppState.allUsers) {
                      if (user['email'] == email) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ky email është regjistruar tashmë!')),
                        );
                        return;
                      }
                    }
                    
                    // Add user to system (not admin by default)
                    AppState.allUsers.add({
                      'name': name,
                      'email': email,
                      'phone': phone,
                      'password': password,
                      'isAdmin': false,
                      'pfp': 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
                    });
                    
                    AppState.userName = name;
                    AppState.userEmail = email;
                    AppState.userPhone = phone;
                    AppState.userPassword = password;
                    AppState.userPfp = 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png';
                    AppState.isAdmin = false;
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Llogaria u krijua me sukses!')),
                    );
                    
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F4C81),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    elevation: 0,
                  ),
                  child: const Text('Krijo Llogarinë', 
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: const [
                    Icon(Icons.arrow_back, size: 20),
                    SizedBox(width: 8),
                    Text('Kthehu', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
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