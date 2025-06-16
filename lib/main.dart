import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'theme/app_theme.dart';
import 'widgets/custom_app_bar.dart';
import 'expert_car_page.dart';
import 'historique.dart';
import 'AddCarPage/AddCarPage.dart';
import 'profile/ProfilePage.dart';
import 'FicheEntretien/FicheEntretien.dart';
import 'dashboard_page/dashboard_page.dart';
import 'template/onboard_content.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expert Car',
      theme: AppTheme.lightTheme,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasData) {
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(snapshot.data!.uid)
                  .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                } else if (userSnapshot.hasData) {
                  final List<dynamic> carModels =
                      userSnapshot.data!['carModel'] ?? [];
                  final List<String> carModelsList = carModels.cast<String>();
                  final String? carModel =
                      carModelsList.isNotEmpty ? carModelsList.first : null;

                  return BottomNavBar(carModel: carModel);
                } else {
                  return const Scaffold(
                    body: OnboardContent(),
                  );
                }
              },
            );
          } else {
            return const Scaffold(
              body: OnboardContent(),
            );
          }
        },
      ),
    );
  }
}

class BottomNavBar extends StatefulWidget {
  final String? carModel;
  const BottomNavBar({super.key, required this.carModel});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;
  String? _currentCarModel;

  @override
  void initState() {
    super.initState();
    _currentCarModel = widget.carModel;
  }

  List<Widget> get _pages => <Widget>[
        const DashboardPage(),
        ExpertCarPage(carModel: _currentCarModel),
        HistoriquePage(carModel: _currentCarModel),
        const ProfilePage(),
        const FicheEntretien(),
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onCarChanged(String newCarModel) {
    setState(() {
      _currentCarModel = newCarModel;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: CustomAppBar(
        carModel: _currentCarModel,
        onCarChanged: _onCarChanged,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 20,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            currentIndex: _selectedIndex,
            selectedItemColor: AppTheme.primaryBlue,
            unselectedItemColor: AppTheme.textLight,
            selectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
            ),
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Accueil',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.build_outlined),
                activeIcon: Icon(Icons.build),
                label: 'Service',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                activeIcon: Icon(Icons.history),
                label: 'Historique',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profil',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.description_outlined),
                activeIcon: Icon(Icons.description),
                label: 'Guide',
              ),
            ],
          ),
        ),
      ),
    );
  }
}