import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'theme/app_theme.dart';
import 'widgets/animated_card.dart';
import 'widgets/gradient_button.dart';

class ExpertCarPage extends StatefulWidget {
  final String? carModel;

  const ExpertCarPage({super.key, required this.carModel});

  @override
  State<ExpertCarPage> createState() => _ExpertCarPageState();
}

class _ExpertCarPageState extends State<ExpertCarPage> {
  final TextEditingController _kmController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();
  final TextEditingController _otherServiceController = TextEditingController();
  
  final List<Map<String, dynamic>> _services = [
    {'name': 'Vidange huile Moteur', 'icon': Icons.oil_barrel, 'color': AppTheme.primaryBlue},
    {'name': 'Vidange huile Boite de vitesse', 'icon': Icons.settings, 'color': AppTheme.accent},
    {'name': 'Vidange huile Frein', 'icon': Icons.car_repair, 'color': AppTheme.error},
    {'name': 'Vidange Liquide de Refroidissement', 'icon': Icons.thermostat, 'color': AppTheme.success},
    {'name': 'Changement filtre a huile', 'icon': Icons.filter_alt, 'color': AppTheme.warning},
    {'name': 'Changement filtre a air', 'icon': Icons.air, 'color': AppTheme.primaryBlue},
    {'name': 'Changement filtre carburant', 'icon': Icons.local_gas_station, 'color': AppTheme.accent},
    {'name': 'Changement filtre Habitacle', 'icon': Icons.hvac, 'color': AppTheme.success},
    {'name': 'Changement plaquettes de frein', 'icon': Icons.disc_full, 'color': AppTheme.error},
    {'name': 'Autre', 'icon': Icons.more_horiz, 'color': AppTheme.textSecondary},
  ];
  
  List<String> _selectedServices = [];
  bool _isOtherServiceSelected = false;
  DateTime? _selectedDate;
  String? _currentCarModel;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentCarModel = widget.carModel;
    _selectedDate = DateTime.now();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppTheme.primaryBlue,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveData() async {
    if (_kmController.text.isEmpty ||
        _selectedServices.isEmpty ||
        _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez remplir tous les champs"),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("Utilisateur non connecté");
      }

      final String carModel = _currentCarModel ?? 'default_car_model';

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection(carModel)
          .doc('services')
          .collection('services')
          .add({
        'km_actuel': int.parse(_kmController.text),
        'services': _selectedServices.contains('Autre')
            ? [
                ..._selectedServices.where((service) => service != 'Autre'),
                _otherServiceController.text
              ]
            : _selectedServices,
        'remarque': _remarkController.text,
        'date': Timestamp.fromDate(_selectedDate!),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Service enregistré avec succès"),
          backgroundColor: AppTheme.success,
        ),
      );

      // Réinitialiser les champs
      _kmController.clear();
      _remarkController.clear();
      _otherServiceController.clear();
      setState(() {
        _selectedServices = [];
        _isOtherServiceSelected = false;
        _selectedDate = DateTime.now();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur : $e"),
          backgroundColor: AppTheme.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
            Text('Ajouter un Service', style: AppTextStyles.h2),
            const SizedBox(height: 24),
            
            // Kilométrage
            AnimatedCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kilométrage actuel', style: AppTextStyles.h3),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _kmController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Ex: 50000',
                      suffixText: 'km',
                      prefixIcon: Icon(Icons.speed),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Date
            AnimatedCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Date du service', style: AppTextStyles.h3),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: AppTheme.primaryBlue),
                          const SizedBox(width: 12),
                          Text(
                            _selectedDate != null
                                ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                                : 'Sélectionner une date',
                            style: AppTextStyles.body1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Services
            AnimatedCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Services effectués', style: AppTextStyles.h3),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _services.map((service) {
                      final isSelected = _selectedServices.contains(service['name']);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedServices.remove(service['name']);
                              if (service['name'] == 'Autre') {
                                _isOtherServiceSelected = false;
                              }
                            } else {
                              _selectedServices.add(service['name']);
                              if (service['name'] == 'Autre') {
                                _isOtherServiceSelected = true;
                              }
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? (service['color'] as Color).withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: isSelected 
                                  ? service['color'] as Color
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                service['icon'] as IconData,
                                size: 16,
                                color: isSelected 
                                    ? service['color'] as Color
                                    : AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                service['name'] as String,
                                style: AppTextStyles.body2.copyWith(
                                  color: isSelected 
                                      ? service['color'] as Color
                                      : AppTheme.textSecondary,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            
            // Autre service
            if (_isOtherServiceSelected) ...[
              const SizedBox(height: 16),
              AnimatedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Autre service', style: AppTextStyles.h3),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _otherServiceController,
                      decoration: const InputDecoration(
                        hintText: 'Décrivez le service effectué',
                        prefixIcon: Icon(Icons.build),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Remarques
            AnimatedCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Remarques', style: AppTextStyles.h3),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _remarkController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Notes pour le prochain service...',
                      prefixIcon: Icon(Icons.note_alt),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Bouton d'enregistrement
            SizedBox(
              width: double.infinity,
              child: GradientButton(
                text: 'Enregistrer le service',
                icon: Icons.save,
                isLoading: _isLoading,
                onPressed: _saveData,
              ),
            ),
          ],
        ),
      ),
    );
  }
}