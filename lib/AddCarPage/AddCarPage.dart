import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_card.dart';
import '../widgets/gradient_button.dart';

class AddCarPage extends StatefulWidget {
  const AddCarPage({super.key});

  @override
  _AddCarPageState createState() => _AddCarPageState();
}

class _AddCarPageState extends State<AddCarPage> {
  final _formKey = GlobalKey<FormState>();
  final _kilometrageController = TextEditingController();

  String? _selectedCarModel;
  String? _selectedFuelType;
  bool _isLoading = false;

  final List<Map<String, String>> _carModels = [
    {'name': 'Alfa Romeo', 'logo': 'alfaromeo'},
    {'name': 'Audi', 'logo': 'audi'},
    {'name': 'Bako', 'logo': 'bako'},
    {'name': 'Bestune', 'logo': 'bestune'},
    {'name': 'BMW', 'logo': 'bmw'},
    {'name': 'BYD', 'logo': 'byd'},
    {'name': 'Changan', 'logo': 'changan'},
    {'name': 'Chery', 'logo': 'chery'},
    {'name': 'Chevrolet', 'logo': 'chevrolet'},
    {'name': 'Citroen', 'logo': 'citroen'},
    {'name': 'Cupra', 'logo': 'cupra'},
    {'name': 'Dacia', 'logo': 'dacia'},
    {'name': 'Dfsk', 'logo': 'dfsk'},
    {'name': 'Dongfeng', 'logo': 'dongfeng'},
    {'name': 'Faw', 'logo': 'faw'},
    {'name': 'Fiat', 'logo': 'fiat'},
    {'name': 'Foday', 'logo': 'foday'},
    {'name': 'Ford', 'logo': 'ford'},
    {'name': 'GAC', 'logo': 'gac'},
    {'name': 'Geely', 'logo': 'geely'},
    {'name': 'GreatWall', 'logo': 'greatwall'},
    {'name': 'Haval', 'logo': 'haval'},
    {'name': 'Honda', 'logo': 'honda'},
    {'name': 'Hyundai', 'logo': 'hyundai'},
    {'name': 'JAC', 'logo': 'jac'},
    {'name': 'Jaguar', 'logo': 'jaguar'},
    {'name': 'Jeep', 'logo': 'jeep'},
    {'name': 'Kia', 'logo': 'kia'},
    {'name': 'Land Rover', 'logo': 'landrover'},
    {'name': 'Mahindra', 'logo': 'mahindra'},
    {'name': 'Mercedes-Benz', 'logo': 'mercedesbenz'},
    {'name': 'MG', 'logo': 'mg'},
    {'name': 'Mini', 'logo': 'mini'},
    {'name': 'Mitsubishi', 'logo': 'mitsubishi'},
    {'name': 'Nissan', 'logo': 'nissan'},
    {'name': 'Opel', 'logo': 'opel'},
    {'name': 'Peugeot', 'logo': 'peugeot'},
    {'name': 'Porsche', 'logo': 'porsche'},
    {'name': 'Renault', 'logo': 'renault'},
    {'name': 'Seat', 'logo': 'seat'},
    {'name': 'Skoda', 'logo': 'skoda'},
    {'name': 'Ssangyong', 'logo': 'ssangyong'},
    {'name': 'Suzuki', 'logo': 'suzuki'},
    {'name': 'Tata', 'logo': 'tata'},
    {'name': 'Toyota', 'logo': 'toyota'},
    {'name': 'Volkswagen', 'logo': 'volkswagen'},
    {'name': 'Volvo', 'logo': 'volvo'},
    {'name': 'Wallyscar', 'logo': 'wallyscar'},
  ];

  final List<Map<String, dynamic>> _fuelTypes = [
    {'name': 'Essence', 'icon': Icons.local_gas_station, 'color': AppTheme.error},
    {'name': 'Gazoil', 'icon': Icons.local_gas_station, 'color': AppTheme.warning},
    {'name': 'Gazoil 50', 'icon': Icons.local_gas_station, 'color': AppTheme.accent},
    {'name': 'Hybrid', 'icon': Icons.eco, 'color': AppTheme.success},
    {'name': 'Full Electrical', 'icon': Icons.electric_car, 'color': AppTheme.primaryBlue},
  ];

  Future<void> _addCar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCarModel == null || _selectedFuelType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un modèle et un type de carburant'),
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
        throw Exception('Utilisateur non connecté');
      }

      final kilometrage = _kilometrageController.text.isNotEmpty
          ? int.tryParse(_kilometrageController.text) ?? 0
          : 0;

      // Mise à jour du document utilisateur
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'carModel': FieldValue.arrayUnion([_selectedCarModel]),
      });

      // Ajout des détails de la voiture
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection(_selectedCarModel!)
          .doc('details')
          .set({
        'initialKilometrage': kilometrage,
        'fuelType': _selectedFuelType,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voiture ajoutée avec succès'),
          backgroundColor: AppTheme.success,
        ),
      );

      // Réinitialiser les champs
      setState(() {
        _selectedCarModel = null;
        _selectedFuelType = null;
        _kilometrageController.clear();
      });

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
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
    return Container(
      constraints: const BoxConstraints(maxHeight: 600),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text('Ajouter une voiture', style: AppTextStyles.h2),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Sélection du modèle
                        AnimatedCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Modèle de voiture', style: AppTextStyles.h3),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<String>(
                                value: _selectedCarModel,
                                decoration: const InputDecoration(
                                  hintText: 'Sélectionnez un modèle',
                                  prefixIcon: Icon(Icons.directions_car),
                                ),
                                items: _carModels.map((car) {
                                  return DropdownMenuItem<String>(
                                    value: car['name'],
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          'lib/assets/logos/${car['logo']}.png',
                                          width: 24,
                                          height: 24,
                                          errorBuilder: (context, error, stackTrace) =>
                                              const Icon(Icons.directions_car, size: 24),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(car['name']!),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() => _selectedCarModel = value);
                                },
                                validator: (value) =>
                                    value == null ? 'Sélectionnez un modèle' : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Kilométrage
                        AnimatedCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Kilométrage actuel', style: AppTextStyles.h3),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _kilometrageController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: 'Ex: 50000 (optionnel)',
                                  suffixText: 'km',
                                  prefixIcon: Icon(Icons.speed),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Type de carburant
                        AnimatedCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Type de carburant', style: AppTextStyles.h3),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _fuelTypes.map((fuel) {
                                  final isSelected = _selectedFuelType == fuel['name'];
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedFuelType = fuel['name'];
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? (fuel['color'] as Color).withOpacity(0.1)
                                            : Colors.grey.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(25),
                                        border: Border.all(
                                          color: isSelected
                                              ? fuel['color'] as Color
                                              : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            fuel['icon'] as IconData,
                                            size: 16,
                                            color: isSelected
                                                ? fuel['color'] as Color
                                                : AppTheme.textSecondary,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            fuel['name'] as String,
                                            style: AppTextStyles.body2.copyWith(
                                              color: isSelected
                                                  ? fuel['color'] as Color
                                                  : AppTheme.textSecondary,
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
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
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: GradientButton(
                    text: 'Ajouter la voiture',
                    icon: Icons.add,
                    isLoading: _isLoading,
                    onPressed: _addCar,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}