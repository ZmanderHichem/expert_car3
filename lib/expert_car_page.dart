import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Pour formater la date
import 'package:firebase_auth/firebase_auth.dart'; // Pour la déconnexion

class ExpertCarPage extends StatefulWidget {
  final String? carModel; // Modèle de voiture passé en paramètre

  const ExpertCarPage({super.key, required this.carModel});

  @override
  State<ExpertCarPage> createState() => _ExpertCarPageState();
}

class _ExpertCarPageState extends State<ExpertCarPage> {
  final TextEditingController _kmController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();
  final TextEditingController _otherServiceController = TextEditingController();
  final List<String> _services = [
    'Vidange huile Moteur',
    'Vidange huile Boite de vitesse',
    'Vidange huile Frein',
    'Vidange Liquide de Refroidissement',
    'Changement filtre a huile',
    'Changement filtre a air',
    'Changement filtre carburant',
    'Changement filtre Habitacle',
    'Changement plaquettes de frein',
    'Autre',
  ];
  List<String> _selectedServices = [];
  bool _isOtherServiceSelected = false;
  DateTime? _selectedDate; // Pour stocker la date sélectionnée

  String? _currentCarModel; // Modèle de voiture actuellement sélectionné

  @override
  void initState() {
    super.initState();
    _currentCarModel =
        widget.carModel; // Initialiser avec la voiture passée en paramètre
    debugPrint("Voiture initiale : $_currentCarModel");
  }

  // Méthode pour afficher le sélecteur de date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Date initiale
      firstDate: DateTime(2000), // Date minimale
      lastDate: DateTime(2100), // Date maximale
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked; // Mettre à jour la date sélectionnée
      });
      debugPrint(
          "Date sélectionnée : ${DateFormat('yyyy-MM-dd').format(picked)}");
    }
  }

  // Méthode pour enregistrer les données
  Future<void> _saveData() async {
    if (_kmController.text.isEmpty ||
        _selectedServices.isEmpty ||
        _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs")),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Utilisateur non connecté")),
        );
        return;
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
        const SnackBar(content: Text("Données enregistrées avec succès")),
      );

      // Réinitialiser les champs
      _kmController.clear();
      _remarkController.clear();
      _otherServiceController.clear();
      setState(() {
        _selectedServices = [];
        _isOtherServiceSelected = false;
        _selectedDate = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e")),
      );
    }
  }

  // Méthode pour déconnecter l'utilisateur
  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/login_page');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la déconnexion: $e")),
      );
    }
  }

  // Méthode pour changer de voiture
  void _onCarChanged(String newCarModel) {
    setState(() {
      _currentCarModel = newCarModel; // Mettre à jour la voiture sélectionnée
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.blue, // Couleur de fond bleue
      body: Container(
        width: double.infinity,
        height: double.infinity, // Prendre toute la hauteur
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(60)), // Radius de 60
        ),
        child: Padding(
          padding:
              const EdgeInsets.only(top: 60), // Décaler le contenu vers le bas
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _kmController,
                  decoration: const InputDecoration(
                    labelText: 'Kilométrage actuel',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                // Bouton pour sélectionner la date
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: Text(
                    _selectedDate == null
                        ? 'Sélectionner une date'
                        : 'Date sélectionnée : ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}',
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8.0,
                  children: _services.map((service) {
                    final isSelected = _selectedServices.contains(service);
                    return FilterChip(
                      label: Text(service),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedServices.add(service);
                            if (service == 'Autre') {
                              _isOtherServiceSelected = true;
                            }
                          } else {
                            _selectedServices.remove(service);
                            if (service == 'Autre') {
                              _isOtherServiceSelected = false;
                            }
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                _isOtherServiceSelected
                    ? Column(
                        children: [
                          const SizedBox(height: 16),
                          TextField(
                            controller: _otherServiceController,
                            decoration: const InputDecoration(
                              labelText: 'Service autre',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox(),
                const SizedBox(height: 16),
                TextField(
                  controller: _remarkController,
                  decoration: const InputDecoration(
                    labelText: 'Remarque pour le prochain service',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _saveData,
                  child: const Text('Enregistrer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Méthode pour afficher la boîte de dialogue de sélection de voiture
  Future<String?> _showCarSelectionDialog(BuildContext context) async {
    final List<String> carModels = await _getCarModels();
    debugPrint("Voitures récupérées : $carModels");

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choisir une voiture'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: carModels.length,
              itemBuilder: (context, index) {
                final car = carModels[index];
                return ListTile(
                  title: Text(car),
                  onTap: () {
                    Navigator.pop(
                        context, car); // Retourner la voiture sélectionnée
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Méthode pour récupérer la liste des voitures depuis Firestore
  Future<List<String>> _getCarModels() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint("Utilisateur non connecté");
      return [];
    }

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
}

// Widget CarLogo
class CarLogo extends StatelessWidget {
  final String? carModel;

  const CarLogo({
    super.key,
    required this.carModel,
  });

  @override
  Widget build(BuildContext context) {
    if (carModel == null) {
      return const SizedBox
          .shrink(); // Retourne un widget vide si carModel est null
    }

    // Chemin du logo
    final logoPath = 'lib/assets/logos/${carModel!.toLowerCase()}.png';

    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.white,
      child: CircleAvatar(
        radius: 18,
        backgroundImage: AssetImage(logoPath),
        onBackgroundImageError: (exception, stackTrace) {
          debugPrint("Erreur de chargement du logo : $exception");
        },
        child: carModel == null
            ? const Icon(Icons.error_outline, color: Colors.red)
            : null,
      ),
    );
  }
}
