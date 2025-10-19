import 'package:flutter/material.dart';
import 'package:lungcancer/api.dart';
import 'package:lungcancer/login.dart';
import 'package:lungcancer/aboutscreen.dart';
import 'package:lungcancer/privacyscreen.dart';
import 'package:lungcancer/resultscreen.dart';
import 'package:lungcancer/Contact.dart';
import 'package:lungcancer/uploadscreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  int _selectedIndex = 0;
  String? token;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    // Token kontrolü
    if (ApiService.isLoggedIn()) {
      token = ApiService.token;
    }

    _pages = [
      const SizedBox(), // Home placeholder
      if (token != null) UploadScreen(token: token!) else const SizedBox(),
      PredictionListScreen(),
      PrivacyPage(),
      AboutPage(),
      ContactPage(),
    ];
  }

  void _onItemTapped(int index) {
    if (index == 5) {
      _logout();
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() {
    ApiService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  Future<Map<String, dynamic>> fetchProfile() async {
    if (!ApiService.isLoggedIn()) throw Exception("Not logged in");
    final response = await ApiService.getProfile();
    if (response['success'] == true) {
      return response['data'];
    } else {
      throw Exception(response['message'] ?? "API error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Geri tuşunu engeller
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // AppBar geri oku kaldırıldı
          title: const Text('Lung Cancer Prediction'),
          backgroundColor: Colors.deepPurple,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Logout',
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.deepPurple,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.science), label: 'Predict'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Results'),
            BottomNavigationBarItem(icon: Icon(Icons.privacy_tip), label: 'Privacy'),
            BottomNavigationBarItem(icon: Icon(Icons.info), label: 'About'),
            BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Logout'),
          ],
        ),
        body: _selectedIndex == 0
            ? Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF6A0DAD),
                Color(0xFF00B894),
                Color(0xFF6A0DAD)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Center(
              child: FutureBuilder<Map<String, dynamic>>(
                future: fetchProfile(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const CircularProgressIndicator(
                        color: Colors.white);
                  } else if (snapshot.hasError) {
                    return Text(
                      'Failed to load profile: ${snapshot.error}',
                      style:
                      const TextStyle(color: Colors.white, fontSize: 18),
                    );
                  } else {
                    final data = snapshot.data!;
                    return Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            data['title'] ?? "Welcome",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                    blurRadius: 10,
                                    color: Colors.black26,
                                    offset: Offset(2, 2))
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            data['message'] ??
                                "Upload your scan to get prediction",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 18, color: Colors.white70),
                          ),
                          const SizedBox(height: 40),
                          GestureDetector(
                            onTap: token != null
                                ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        UploadScreen(token: token!)),
                              );
                            }
                                : null,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF6A0DAD), Color(0xFF00B894)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  'Upload Scan',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        )
            : _pages[_selectedIndex],
      ),
    );
  }
}
