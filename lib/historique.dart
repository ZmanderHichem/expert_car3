import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'theme/app_theme.dart';
import 'widgets/animated_card.dart';

class HistoriquePage extends StatelessWidget {
  final String? carModel;

  const HistoriquePage({super.key, required this.carModel});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Historique des Services', style: AppTextStyles.h2),
            const SizedBox(height: 24),
            
            if (user != null && carModel != null)
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection(carModel!)
                    .doc('services')
                    .collection('services')
                    .orderBy('date', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (snapshot.hasError) {
                    return _buildErrorState();
                  }
                  
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildEmptyState();
                  }

                  final documents = snapshot.data!.docs;
                  
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      final data = documents[index].data() as Map<String, dynamic>;
                      return _buildServiceCard(data, index);
                    },
                  );
                },
              )
            else
              _buildErrorState(),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> data, int index) {
    final serviceNames = data['services'] ?? [];
    final Timestamp timestamp = data['date'];
    final DateTime date = timestamp.toDate();
    final int kilometrage = data['km_actuel'] ?? 0;
    final String remarque = data['remarque'] ?? '';

    String serviceNameString = '';
    if (serviceNames is List<dynamic>) {
      serviceNameString = serviceNames.join(', ');
    } else {
      serviceNameString = serviceNames.toString();
    }

    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    final String formattedDate = formatter.format(date);

    // Couleur basée sur l'ancienneté
    final daysSince = DateTime.now().difference(date).inDays;
    Color accentColor = AppTheme.success;
    if (daysSince > 365) {
      accentColor = AppTheme.error;
    } else if (daysSince > 180) {
      accentColor = AppTheme.warning;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: AnimatedCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 50,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        serviceNameString,
                        style: AppTextStyles.h3,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            formattedDate,
                            style: AppTextStyles.body2,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$kilometrage km',
                    style: AppTextStyles.caption.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            if (remarque.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.note_alt_outlined,
                      size: 16,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        remarque,
                        style: AppTextStyles.body2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: AppTheme.textLight,
                ),
                const SizedBox(width: 4),
                Text(
                  'Il y a $daysSince jour${daysSince > 1 ? 's' : ''}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return AnimatedCard(
      child: Column(
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: AppTheme.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun service enregistré',
            style: AppTextStyles.h3.copyWith(color: AppTheme.textLight),
          ),
          const SizedBox(height: 8),
          Text(
            'Commencez par ajouter votre premier service',
            style: AppTextStyles.body2,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return AnimatedCard(
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Erreur de chargement',
            style: AppTextStyles.h3.copyWith(color: AppTheme.error),
          ),
          const SizedBox(height: 8),
          Text(
            'Impossible de récupérer l\'historique',
            style: AppTextStyles.body2,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}