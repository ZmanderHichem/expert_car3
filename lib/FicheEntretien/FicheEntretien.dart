import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_card.dart';

class FicheEntretien extends StatefulWidget {
  const FicheEntretien({super.key});

  @override
  _FicheEntretienState createState() => _FicheEntretienState();
}

class _FicheEntretienState extends State<FicheEntretien> {
  final List<Map<String, dynamic>> entretiens = [
    {
      "nom": "Vidange d'huile",
      "description": "Tous les 5 000 à 10 000 km. Remplacement de l'huile moteur et du filtre à huile pour assurer la lubrification optimale du moteur.",
      "icon": Icons.oil_barrel,
      "color": AppTheme.primaryBlue,
      "interval": "5 000 - 10 000 km",
      "importance": "Critique",
    },
    {
      "nom": "Filtre à air",
      "description": "Tous les 15 000 à 30 000 km. Remplacement du filtre à air pour maintenir une combustion optimale.",
      "icon": Icons.air,
      "color": AppTheme.success,
      "interval": "15 000 - 30 000 km",
      "importance": "Important",
    },
    {
      "nom": "Plaquettes de frein",
      "description": "Tous les 20 000 à 30 000 km. Contrôle et remplacement des plaquettes de frein pour votre sécurité.",
      "icon": Icons.disc_full,
      "color": AppTheme.error,
      "interval": "20 000 - 30 000 km",
      "importance": "Critique",
    },
    {
      "nom": "Bougies d'allumage",
      "description": "Tous les 30 000 à 50 000 km. Remplacement des bougies d'allumage pour un démarrage optimal.",
      "icon": Icons.flash_on,
      "color": AppTheme.warning,
      "interval": "30 000 - 50 000 km",
      "importance": "Important",
    },
    {
      "nom": "Liquide de refroidissement",
      "description": "Tous les 40 000 à 60 000 km. Remplacement du liquide de refroidissement pour éviter la surchauffe.",
      "icon": Icons.thermostat,
      "color": AppTheme.accent,
      "interval": "40 000 - 60 000 km",
      "importance": "Important",
    },
    {
      "nom": "Courroies de distribution",
      "description": "Tous les 60 000 à 100 000 km. Vérification et remplacement des courroies de distribution.",
      "icon": Icons.settings,
      "color": AppTheme.primaryBlue,
      "interval": "60 000 - 100 000 km",
      "importance": "Critique",
    },
    {
      "nom": "Filtre à carburant",
      "description": "Tous les 60 000 à 100 000 km. Remplacement du filtre à carburant pour une alimentation propre.",
      "icon": Icons.local_gas_station,
      "color": AppTheme.success,
      "interval": "60 000 - 100 000 km",
      "importance": "Modéré",
    },
    {
      "nom": "Pneus",
      "description": "Tous les 40 000 à 80 000 km. Vérification de l'usure des pneus et de la pression.",
      "icon": Icons.tire_repair,
      "color": AppTheme.warning,
      "interval": "40 000 - 80 000 km",
      "importance": "Important",
    },
    {
      "nom": "Batterie",
      "description": "Tous les 40 000 à 50 000 km. Vérification de l'état de la batterie et des connexions.",
      "icon": Icons.battery_full,
      "color": AppTheme.accent,
      "interval": "40 000 - 50 000 km",
      "importance": "Important",
    },
    {
      "nom": "Vidange de boîte de vitesses",
      "description": "Tous les 60 000 à 100 000 km. Vidange de la boîte de vitesses si nécessaire.",
      "icon": Icons.settings_applications,
      "color": AppTheme.error,
      "interval": "60 000 - 100 000 km",
      "importance": "Modéré",
    },
  ];

  String? selectedEntretien;
  Map<String, dynamic>? selectedEntretienData;

  Color _getImportanceColor(String importance) {
    switch (importance) {
      case 'Critique':
        return AppTheme.error;
      case 'Important':
        return AppTheme.warning;
      case 'Modéré':
        return AppTheme.success;
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Guide d\'Entretien', style: AppTextStyles.h2),
            const SizedBox(height: 8),
            Text(
              'Consultez les intervalles d\'entretien recommandés',
              style: AppTextStyles.body2,
            ),
            const SizedBox(height: 24),
            
            // Sélecteur d'entretien
            AnimatedCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sélectionner un type d\'entretien', style: AppTextStyles.h3),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedEntretien,
                    decoration: const InputDecoration(
                      hintText: 'Choisissez un entretien',
                      prefixIcon: Icon(Icons.build_circle_outlined),
                    ),
                    items: entretiens.map((entretien) {
                      return DropdownMenuItem<String>(
                        value: entretien['nom'],
                        child: Row(
                          children: [
                            Icon(
                              entretien['icon'] as IconData,
                              color: entretien['color'] as Color,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(entretien['nom'])),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedEntretien = newValue;
                        selectedEntretienData = entretiens.firstWhere(
                          (e) => e['nom'] == newValue,
                        );
                      });
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Détails de l'entretien sélectionné
            if (selectedEntretienData != null) ...[
              AnimatedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: (selectedEntretienData!['color'] as Color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            selectedEntretienData!['icon'] as IconData,
                            color: selectedEntretienData!['color'] as Color,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedEntretienData!['nom'],
                                style: AppTextStyles.h3,
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getImportanceColor(selectedEntretienData!['importance']).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  selectedEntretienData!['importance'],
                                  style: AppTextStyles.caption.copyWith(
                                    color: _getImportanceColor(selectedEntretienData!['importance']),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Intervalle
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.schedule, color: AppTheme.primaryBlue),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Intervalle recommandé', style: AppTextStyles.caption),
                              Text(
                                selectedEntretienData!['interval'],
                                style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Description
                    Text('Description', style: AppTextStyles.h3),
                    const SizedBox(height: 8),
                    Text(
                      selectedEntretienData!['description'],
                      style: AppTextStyles.body1,
                    ),
                  ],
                ),
              ),
            ] else ...[
              // État vide
              AnimatedCard(
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 64,
                      color: AppTheme.textLight,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Sélectionnez un entretien',
                      style: AppTextStyles.h3.copyWith(color: AppTheme.textLight),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choisissez un type d\'entretien pour voir les détails',
                      style: AppTextStyles.body2,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Liste rapide des entretiens
            Text('Aperçu rapide', style: AppTextStyles.h3),
            const SizedBox(height: 16),
            
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: entretiens.length,
              itemBuilder: (context, index) {
                final entretien = entretiens[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: AnimatedCard(
                    onTap: () {
                      setState(() {
                        selectedEntretien = entretien['nom'];
                        selectedEntretienData = entretien;
                      });
                    },
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: (entretien['color'] as Color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            entretien['icon'] as IconData,
                            color: entretien['color'] as Color,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(entretien['nom'], style: AppTextStyles.body1),
                              Text(entretien['interval'], style: AppTextStyles.caption),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getImportanceColor(entretien['importance']).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            entretien['importance'],
                            style: AppTextStyles.caption.copyWith(
                              color: _getImportanceColor(entretien['importance']),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}