import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';
import '../main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentIndex = 4;

  // Predefined PFP options
  final List<String> pfpOptions = [
    'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
    'https://cdn-icons-png.flaticon.com/512/3135/3135768.png',
    'https://cdn-icons-png.flaticon.com/512/3135/3135789.png',
    'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
    'https://cdn-icons-png.flaticon.com/512/4140/4140048.png',
    'https://cdn-icons-png.flaticon.com/512/4140/4140050.png',
  ];

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, '/products');
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/locations');
    } else if (index == 3) {
      Navigator.pushReplacementNamed(context, '/purchases');
    } else if (index == 4) {
      return;
    }
  }

  void _showEditPersonalDataDialog() {
    final TextEditingController nameController = TextEditingController(text: AppState.userName);
    final TextEditingController emailController = TextEditingController(text: AppState.userEmail);
    final TextEditingController phoneController = TextEditingController(text: AppState.userPhone);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Të dhëna personale'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: 'Emri i plotë'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(hintText: 'Email'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(hintText: 'Numri i telefonit'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Anulo'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  // Update in allUsers as well
                  for (var user in AppState.allUsers) {
                    if (user['email'] == AppState.userEmail) {
                      user['name'] = nameController.text.trim();
                      user['phone'] = phoneController.text.trim();
                      if (emailController.text.trim().isNotEmpty) {
                        user['email'] = emailController.text.trim();
                      }
                      break;
                    }
                  }
                  AppState.userName = nameController.text.trim();
                  AppState.userPhone = phoneController.text.trim();
                  if (emailController.text.trim().isNotEmpty) {
                    AppState.userEmail = emailController.text.trim();
                  }
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Të dhënat u përditësuan!')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F4C81)),
              child: const Text('Ruaj', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showChangePfpDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ndrysho foton e profilit'),
          content: Container(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: pfpOptions.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    AppState.updateUserPfp(AppState.userEmail, pfpOptions[index]);
                    setState(() {});
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Foto e profilit u ndryshua!')),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppState.userPfp == pfpOptions[index] 
                            ? const Color(0xFF0F4C81) 
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        pfpOptions[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Mbyll'),
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog() {
    final TextEditingController currentPassController = TextEditingController();
    final TextEditingController newPassController = TextEditingController();
    final TextEditingController confirmPassController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ndrysho Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPassController,
                obscureText: true,
                decoration: const InputDecoration(hintText: 'Fjalëkalimi aktual'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: newPassController,
                obscureText: true,
                decoration: const InputDecoration(hintText: 'Fjalëkalimi i ri'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: confirmPassController,
                obscureText: true,
                decoration: const InputDecoration(hintText: 'Konfirmo fjalëkalimin'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Anulo'),
            ),
            ElevatedButton(
              onPressed: () {
                if (newPassController.text != confirmPassController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fjalëkalimet nuk përputhen!')),
                  );
                  return;
                }
                setState(() {
                  for (var user in AppState.allUsers) {
                    if (user['email'] == AppState.userEmail) {
                      user['password'] = newPassController.text;
                      break;
                    }
                  }
                  AppState.userPassword = newPassController.text;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fjalëkalimi u ndryshua me sukses!')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F4C81)),
              child: const Text('Ndrysho', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showNotificationsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Njoftimet'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Njoftimet e porosive'),
                value: true,
                onChanged: (value) {},
              ),
              SwitchListTile(
                title: const Text('Njoftimet e promovimeve'),
                value: true,
                onChanged: (value) {},
              ),
              SwitchListTile(
                title: const Text('Njoftimet e zbritjeve'),
                value: false,
                onChanged: (value) {},
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Mbylle'),
            ),
          ],
        );
      },
    );
  }

  void _showChatSupport() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Chat Support'),
          content: Container(
            height: 200,
            child: Column(
              children: [
                const Text('Si mund t\'ju ndihmojmë?'),
                const SizedBox(height: 10),
                Expanded(
                  child: TextField(
                    maxLines: null,
                    decoration: const InputDecoration(
                      hintText: 'Shkruani mesazhin tuaj...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Mbylle'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mesazhi u dërgua! Do t\'ju kontaktojmë së shpejti.')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F4C81)),
              child: const Text('Dërgo', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _signOut() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('A jeni i sigurt që dëshironi të dilni?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Anulo'),
            ),
            ElevatedButton(
              onPressed: () {
                AppState.clearUser();
                AppState.purchases.clear();
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Dil', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String displayName = AppState.userName.isNotEmpty ? AppState.userName : 'Përdorues';
    String displayContact = '';
    
    if (AppState.userPhone.isNotEmpty) {
      displayContact = AppState.userPhone;
    } else if (AppState.userEmail.isNotEmpty) {
      displayContact = AppState.userEmail;
    } else {
      displayContact = 'Nuk ka të dhëna';
    }

    // Get user's PFP
    String pfpUrl = AppState.userPfp.isNotEmpty 
        ? AppState.userPfp 
        : AppState.getUserPfp(AppState.userEmail);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // User Header with PFP
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          shape: BoxShape.circle,
                        ),
                        child: pfpUrl.isNotEmpty 
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(40),
                                child: Image.network(
                                  pfpUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Text(
                                        displayName.isNotEmpty 
                                          ? displayName.substring(0, 1).toUpperCase()
                                          : 'U',
                                        style: const TextStyle(fontSize: 32, color: Color(0xFF0F4C81), fontWeight: FontWeight.bold),
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Center(
                                child: Text(
                                  displayName.isNotEmpty 
                                    ? displayName.substring(0, 1).toUpperCase()
                                    : 'U',
                                  style: const TextStyle(fontSize: 32, color: Color(0xFF0F4C81), fontWeight: FontWeight.bold),
                                ),
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _showChangePfpDialog,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFF0F4C81), 
                              shape: BoxShape.circle
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                displayName,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (AppState.isAdmin)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.amber),
                                ),
                                child: const Text(
                                  'Admin',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.amber,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Text(
                          displayContact,
                          style: const TextStyle(color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.check_circle, size: 14, color: Color(0xFF0F4C81)),
                              SizedBox(width: 4),
                              Text('Anëtar', style: TextStyle(color: Color(0xFF0F4C81), fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  if (AppState.isAdmin) ...[
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.admin_panel_settings, color: Color(0xFF0F4C81)),
                      title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Menaxho përdoruesit dhe produktet'),
                      trailing: const Icon(Icons.chevron_right, color: Color(0xFF0F4C81)),
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/admin');
                      },
                    ),
                    const Divider(),
                  ],
                  
                  InkWell(
                    onTap: _showEditPersonalDataDialog,
                    child: _buildMenuItem('Të dhëna personale', 'Shiko dhe përditëso informacionin tënd', Icons.person_outline),
                  ),
                  InkWell(
                    onTap: _showChangePfpDialog,
                    child: _buildMenuItem('Ndrysho foton', 'Zgjidh një foto të re profili', Icons.photo_camera),
                  ),
                  InkWell(
                    onTap: _showChangePasswordDialog,
                    child: _buildMenuItem('Ndrysho password', 'Përditëso fjalëkalimin tënd', Icons.lock_outline),
                  ),
                  InkWell(
                    onTap: _showNotificationsDialog,
                    child: _buildMenuItem('Njoftimet', 'Menaxho preferencat e njoftimeve', Icons.notifications_none),
                  ),
                  InkWell(
                    onTap: _showChatSupport,
                    child: _buildMenuItem('Chat Support', 'Na kontakto për ndihmë', Icons.chat_bubble_outline),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  InkWell(
                    onTap: _signOut,
                    child: _buildMenuItem('Sign Out', 'Dil nga llogaria jote', Icons.logout, isLogout: true),
                  ),
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

  Widget _buildMenuItem(String title, String subtitle, IconData icon, {bool isLogout = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF5F5F5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFE3F2FD),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: isLogout ? Colors.red : const Color(0xFF0F4C81), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, 
                  style: TextStyle(
                    color: isLogout ? Colors.red : Colors.black, 
                    fontWeight: FontWeight.bold,
                    fontSize: 15
                  )
                ),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: isLogout ? Colors.red : const Color(0xFF0F4C81), size: 24),
        ],
      ),
    );
  }
}