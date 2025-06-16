import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../AddCarPage/AddCarPage.dart';
import '../profile/ProfilePage.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String? carModel;
  final Function(String)? onCarChanged;

  const CustomAppBar({
    super.key,
    this.carModel,
    this.onCarChanged,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  String? _userName;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final String firstName = userDoc['prenom'] ?? 'Utilisateur';
      final String lastName = userDoc['nom'] ?? '';
      setState(() {
        _userName = '$firstName $lastName'.trim();
      });
    } catch (e) {
      debugPrint("Erreur lors de la récupération du nom : $e");
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login_page');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de la déconnexion: $e")),
        );
      }
    }
  }

  Future<List<String>> _getCarModels() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final List<dynamic> carModels = userDoc['carModel'] ?? [];
      return carModels.cast<String>();
    } catch (e) {
      debugPrint("Erreur lors de la récupération des voitures : $e");
      return [];
    }
  }

  Future<String?> _showCarSelectionDialog() async {
    final List<String> carModels = await _getCarModels();

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Choisir une voiture', style: AppTextStyles.h3),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: carModels.length,
              itemBuilder: (context, index) {
                final car = carModels[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.2)),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                      child: Icon(Icons.directions_car, color: AppTheme.primaryBlue),
                    ),
                    title: Text(car, style: AppTextStyles.body1),
                    onTap: () => Navigator.pop(context, car),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: AppTheme.elevatedShadow,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Bonjour,',
                      style: AppTextStyles.body2.copyWith(color: Colors.white70),
                    ),
                    Text(
                      _userName ?? 'Utilisateur',
                      style: AppTextStyles.h3.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  PopupMenuButton<String>(
                    offset: const Offset(0, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    onSelected: (String value) async {
                      switch (value) {
                        case 'add_car':
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              child: const AddCarPage(),
                            ),
                          );
                          break;
                        case 'switch_car':
                          final selectedCar = await _showCarSelectionDialog();
                          if (selectedCar != null && widget.onCarChanged != null) {
                            widget.onCarChanged!(selectedCar);
                          }
                          break;
                        case 'profile':
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ProfilePage()),
                          );
                          break;
                        case 'logout':
                          await _signOut();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        enabled: false,
                        child: Text(
                          FirebaseAuth.instance.currentUser?.email ?? "Non connecté",
                          style: AppTextStyles.caption,
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'add_car',
                        child: Row(
                          children: [
                            Icon(Icons.add_circle_outline, color: AppTheme.primaryBlue),
                            SizedBox(width: 12),
                            Text('Ajouter une voiture'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'switch_car',
                        child: Row(
                          children: [
                            Icon(Icons.swap_horiz, color: AppTheme.primaryBlue),
                            SizedBox(width: 12),
                            Text('Changer de voiture'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'profile',
                        child: Row(
                          children: [
                            Icon(Icons.person_outline, color: AppTheme.primaryBlue),
                            SizedBox(width: 12),
                            Text('Profil'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout, color: AppTheme.error),
                            SizedBox(width: 12),
                            Text('Déconnexion', style: TextStyle(color: AppTheme.error)),
                          ],
                        ),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: widget.carModel != null
                          ? Image.asset(
                              'lib/assets/logos/${widget.carModel!.toLowerCase()}.png',
                              width: 24,
                              height: 24,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.directions_car, color: Colors.white, size: 24),
                            )
                          : const Icon(Icons.directions_car, color: Colors.white, size: 24),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}