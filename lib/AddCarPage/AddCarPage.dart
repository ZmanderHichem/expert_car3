import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  final List<String> _carModels = [
    'Alfa Romeo',
    'Audi',
    'Bako',
    'Bestune',
    'BMW',
    'BYD',
    'Changan',
    'Chery',
    'Chevrolet',
    'Citroen',
    'Cupra',
    'Dacia',
    'Dfsk',
    'Dongfeng',
    'Faw',
    'Fiat',
    'Foday',
    'Ford',
    'GAC',
    'Geely',
    'GreatWall',
    'Haval',
    'Honda',
    'Hyundai',
    'JAC',
    'Jaguar',
    'Jeep',
    'Kia',
    'Land Rover',
    'Mahindra',
    'Mercedes-Benz',
    'MG',
    'Mini',
    'Mitsubishi',
    'Nissan',
    'Opel',
    'Peugeot',
    'Porsche',
    'Renault',
    'Seat',
    'Skoda',
    'Ssangyong',
    'Suzuki',
    'Tata',
    'Toyota',
    'Volkswagen',
    'Volvo',
    'Wallyscar',
  ];

  final List<String> _fuelTypes = [
    'Essence',
    'Gazoil',
    'Gazoil 50',
    'Hybrid',
    'Full Electrical',
  ];

  Future<void> _addCar() async {
    debugPrint("Début de la fonction _addCar()");

    if (_selectedCarModel == null || _selectedFuelType == null) {
      debugPrint(
          "Erreur: Modèle de voiture ou type de carburant non sélectionné");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    try {
      debugPrint("Récupération de l'utilisateur en cours...");
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        debugPrint("Utilisateur non connecté !");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Utilisateur non connecté')),
        );
        return;
      }

      debugPrint("Utilisateur ID: ${user.uid}");

      final kilometrage = _kilometrageController.text.isNotEmpty
          ? int.tryParse(_kilometrageController.text) ?? 0
          : 0;
      debugPrint("Kilométrage récupéré: $kilometrage");

      debugPrint("Mise à jour du document utilisateur...");
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'carModel': FieldValue.arrayUnion([_selectedCarModel]),
      });

      debugPrint("Ajout des détails de la voiture dans la sous-collection...");
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

      debugPrint("Voiture ajoutée avec succès");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Voiture ajoutée avec succès')),
      );

      debugPrint("Réinitialisation des champs...");
      setState(() {
        _selectedCarModel = null;
        _selectedFuelType = null;
        _kilometrageController.clear();
      });

      debugPrint("Fermeture du clavier...");
      FocusScope.of(context).unfocus();

      // Suppression de l'attente et de la navigation
      debugPrint("Ajout terminé, plus rien à exécuter après.");
    } catch (e, stackTrace) {
      debugPrint("Erreur pendant l'ajout de la voiture: $e");
      debugPrint("Stack trace: $stackTrace");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedCarModel,
                decoration:
                    const InputDecoration(labelText: 'Modèle de voiture'),
                items: _carModels.map((String model) {
                  return DropdownMenuItem<String>(
                    value: model,
                    child: Text(model),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() => _selectedCarModel = newValue);
                },
                validator: (value) =>
                    value == null ? 'Sélectionnez un modèle' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _kilometrageController,
                decoration: const InputDecoration(
                    labelText: 'Kilométrage actuel (optionnel)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedFuelType,
                decoration:
                    const InputDecoration(labelText: 'Type de carburant'),
                items: _fuelTypes.map((String fuel) {
                  return DropdownMenuItem<String>(
                    value: fuel,
                    child: Text(fuel),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() => _selectedFuelType = newValue);
                },
                validator: (value) =>
                    value == null ? 'Sélectionnez un carburant' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addCar,
                child: const Text('Ajouter la voiture'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
