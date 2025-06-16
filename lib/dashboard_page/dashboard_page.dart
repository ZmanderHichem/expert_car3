import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_card.dart';
import '../widgets/gradient_button.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Utilisateur non connecté')),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Raccourcis
            _buildShortcutsSection(),
            const SizedBox(height: 24),
            
            // Section Mes Voitures
            _buildCarsSection(user),
            const SizedBox(height: 24),
            
            // Section Prochains Services
            _buildNextServicesSection(user),
          ],
        ),
      ),
    );
  }

  Widget _buildShortcutsSection() {
    final shortcuts = [
      {'icon': Icons.search, 'label': 'Chercher', 'color': AppTheme.primaryBlue},
      {'icon': Icons.add_circle_outline, 'label': 'Ajouter', 'color': AppTheme.success},
      {'icon': Icons.history, 'label': 'Historique', 'color': AppTheme.warning},
      {'icon': Icons.build_circle_outlined, 'label': 'Service', 'color': AppTheme.accent},
      {'icon': Icons.notifications_outlined, 'label': 'Alertes', 'color': AppTheme.error},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Raccourcis', style: AppTextStyles.h3),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: shortcuts.length,
            itemBuilder: (context, index) {
              final shortcut = shortcuts[index];
              return Container(
                width: 80,
                margin: const EdgeInsets.only(right: 16),
                child: AnimatedCard(
                  onTap: () {
                    // Navigation logic here
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (shortcut['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          shortcut['icon'] as IconData,
                          color: shortcut['color'] as Color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        shortcut['label'] as String,
                        style: AppTextStyles.caption,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCarsSection(User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Mes Voitures', style: AppTextStyles.h3),
            TextButton.icon(
              onPressed: () {
                // Add car logic
              },
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Ajouter'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return _buildEmptyState();
            }

            final carData = snapshot.data!.data() as Map<String, dynamic>?;
            final cars = carData?['carModel'] as List<dynamic>?;

            if (cars == null || cars.isEmpty) {
              return _buildEmptyState();
            }

            return _buildCarsList(user, cars);
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return AnimatedCard(
      child: Column(
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: 64,
            color: AppTheme.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune voiture enregistrée',
            style: AppTextStyles.h3.copyWith(color: AppTheme.textLight),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoutez votre première voiture pour commencer',
            style: AppTextStyles.body2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          GradientButton(
            text: 'Ajouter une voiture',
            icon: Icons.add,
            onPressed: () {
              // Add car logic
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCarsList(User user, List<dynamic> cars) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cars.length,
      itemBuilder: (context, index) {
        final carModel = cars[index] as String;
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection(carModel)
              .doc('details')
              .get(),
          builder: (context, carSnapshot) {
            if (!carSnapshot.hasData) {
              return const SizedBox.shrink();
            }

            final carDetails = carSnapshot.data!.data() as Map<String, dynamic>?;
            final kilometrage = carDetails?['initialKilometrage'] ?? 'N/A';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: AnimatedCard(
                onTap: () {
                  // Navigate to car details
                },
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Image.asset(
                          'lib/assets/logos/${carModel.toLowerCase()}.png',
                          width: 32,
                          height: 32,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.directions_car, 
                                       color: AppTheme.primaryBlue, size: 32),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(carModel, style: AppTextStyles.h3),
                          const SizedBox(height: 4),
                          Text(
                            'Kilométrage : $kilometrage km',
                            style: AppTextStyles.body2,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.check_circle_outline,
                        color: AppTheme.success,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNextServicesSection(User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Prochains Services', style: AppTextStyles.h3),
        const SizedBox(height: 16),
        FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox.shrink();
            }

            final carData = snapshot.data!.data() as Map<String, dynamic>?;
            final cars = carData?['carModel'] as List<dynamic>?;

            if (cars == null || cars.isEmpty) {
              return const SizedBox.shrink();
            }

            return NextServiceReminder(
              userId: user.uid,
              carModel: cars.first.toString(),
            );
          },
        ),
      ],
    );
  }
}

class NextServiceReminder extends StatelessWidget {
  final String userId;
  final String carModel;

  const NextServiceReminder({
    super.key,
    required this.userId,
    required this.carModel,
  });

  final Map<String, int> serviceIntervals = const {
    'Changement filtre a huile': 10000,
    'Changement filtre a air': 20000,
    'Changement bougies': 40000,
    'Changement courroie accessoire': 40000,
    'Changement courroie de distribution': 60000,
    'Changement plaquette de frein': 40000,
  };

  Future<List<Map<String, dynamic>>> _getLastServices() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection(carModel)
        .doc('services')
        .collection('services')
        .orderBy('date', descending: true)
        .get();

    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  Map<String, Map<String, dynamic>> _calculateNextServices(
      List<Map<String, dynamic>> services) {
    final nextServices = <String, Map<String, dynamic>>{};

    for (var service in services) {
      final serviceNames = service['services'] as List<dynamic>?;
      final kmActuel = service['km_actuel'] as int?;

      if (serviceNames != null && kmActuel != null) {
        for (var serviceName in serviceNames) {
          final interval = serviceIntervals[serviceName];
          if (interval != null) {
            final nextChange = kmActuel + interval;
            final kmSinceLastChange = kmActuel % interval;

            if (kmSinceLastChange >= interval - 10000) {
              nextServices[serviceName] = {
                'nextChange': nextChange,
                'lastChange': kmActuel,
                'urgency': _getUrgencyLevel(kmSinceLastChange, interval),
              };
            }
          }
        }
      }
    }

    return nextServices;
  }

  String _getUrgencyLevel(int kmSince, int interval) {
    final percentage = (kmSince / interval) * 100;
    if (percentage >= 90) return 'urgent';
    if (percentage >= 75) return 'soon';
    return 'normal';
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency) {
      case 'urgent':
        return AppTheme.error;
      case 'soon':
        return AppTheme.warning;
      default:
        return AppTheme.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getLastServices(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return AnimatedCard(
            child: Column(
              children: [
                Icon(
                  Icons.build_circle_outlined,
                  size: 48,
                  color: AppTheme.textLight,
                ),
                const SizedBox(height: 12),
                Text(
                  'Aucun service récent',
                  style: AppTextStyles.body1.copyWith(color: AppTheme.textLight),
                ),
              ],
            ),
          );
        }

        final nextServices = _calculateNextServices(snapshot.data!);

        if (nextServices.isEmpty) {
          return AnimatedCard(
            child: Column(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 48,
                  color: AppTheme.success,
                ),
                const SizedBox(height: 12),
                Text(
                  'Aucun service prévu',
                  style: AppTextStyles.body1.copyWith(color: AppTheme.success),
                ),
                Text(
                  'Votre véhicule est à jour',
                  style: AppTextStyles.body2,
                ),
              ],
            ),
          );
        }

        return Column(
          children: nextServices.entries.map((entry) {
            final urgency = entry.value['urgency'] as String;
            final urgencyColor = _getUrgencyColor(urgency);
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: AnimatedCard(
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 60,
                      decoration: BoxDecoration(
                        color: urgencyColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.key, style: AppTextStyles.body1),
                          const SizedBox(height: 4),
                          Text(
                            'Prochain changement à ${entry.value['nextChange']} km',
                            style: AppTextStyles.body2,
                          ),
                          Text(
                            'Dernier changement à ${entry.value['lastChange']} km',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: urgencyColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        urgency == 'urgent' ? 'Urgent' : 
                        urgency == 'soon' ? 'Bientôt' : 'OK',
                        style: AppTextStyles.caption.copyWith(
                          color: urgencyColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}