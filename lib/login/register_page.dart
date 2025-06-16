import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import pour Firestore
import 'login_page.dart'; // Import de la page de connexion
import '../questionnaire/questionnaire_page.dart'; // Import de la page de questionnaire

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _kilometrageController = TextEditingController();
  final _nomController =
      TextEditingController(); // Contrôleur pour le champ nom
  final _prenomController =
      TextEditingController(); // Contrôleur pour le champ prénom

  String? _selectedCarModel; // Pour stocker le modèle de voiture sélectionné
  String? _selectedFuelType; // Pour stocker le type de carburant sélectionné

  // Liste des modèles de voiture
  final List<String> _carModels = [
    'Alfaromeo',
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
    'DFSK',
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
    'KIA',
    'LandRover',
    'Mahindra',
    'MercedesBenz',
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

  // Liste des types de carburant
  final List<String> _fuelTypes = [
    'Essence',
    'Gazoil',
    'Gazoil 50',
    'Hybrid',
    'Full Electrical',
  ];

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Créer l'utilisateur avec Firebase Auth
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Enregistrer les informations supplémentaires dans Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(
                userCredential.user!.uid) // Utiliser l'UID comme ID du document
            .set({
          'email': _emailController.text,
          'password': _passwordController
              .text, // Attention : stocker les mots de passe en clair n'est pas sécurisé
          'carModel': [_selectedCarModel], // Stocker comme une liste
          'kilometrage': _kilometrageController.text, // Kilométrage actuel
          'fuelType': _selectedFuelType, // Type de carburant sélectionné
          'nom': _nomController.text, // Nom de l'utilisateur
          'prenom': _prenomController.text, // Prénom de l'utilisateur
          'voituresAutorisees': 1, // Nombre de voitures autorisées
          'createdAt': FieldValue.serverTimestamp(), // Ajouter un timestamp
        });

        // Créer une sous-collection nommée d'après le modèle de voiture
        if (_selectedCarModel != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .collection(_selectedCarModel!) // Nom de la sous-collection
              .doc('details') // Document dans la sous-collection
              .set({
            'initialKilometrage': _kilometrageController.text,
            'fuelType': _selectedFuelType,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        // Redirection vers le questionnaire après l'inscription
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => QuestionnairePage(
                userId: userCredential.user!.uid,
                carModel: _selectedCarModel!,
              ),
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Erreur d\'inscription')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Mot de passe'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre mot de passe';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre nom';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _prenomController,
                decoration: const InputDecoration(labelText: 'Prénom'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre prénom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Liste déroulante pour le modèle de voiture
              DropdownButtonFormField<String>(
                value: _selectedCarModel,
                decoration:
                    const InputDecoration(labelText: 'Modèle de voiture'),
                items: _carModels.map((String model) {
                  return DropdownMenuItem<String>(
                    value: model,
                    child: Row(
                      children: [
                        Image.asset(
                          'lib/assets/logos/${model.toLowerCase()}.png',
                          width: 24,
                          height: 24,
                          errorBuilder: (context, error, stackTrace) {
                            print(
                                'Erreur de chargement du logo pour $model: $error');
                            return const Icon(Icons.error, size: 24);
                          },
                        ),
                        const SizedBox(width: 8),
                        Text(model),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCarModel = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner un modèle de voiture';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Champ pour le kilométrage actuel
              TextFormField(
                controller: _kilometrageController,
                decoration:
                    const InputDecoration(labelText: 'Kilométrage actuel'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le kilométrage actuel';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Liste déroulante pour le type de carburant
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
                  setState(() {
                    _selectedFuelType = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner un type de carburant';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Container(
                height: 46,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                  gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    stops: [0.4, 0.8],
                    colors: [
                      Color.fromARGB(255, 239, 104, 80),
                      Color.fromARGB(255, 139, 33, 146)
                    ],
                  ),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: _register,
                  child: const DefaultTextStyle(
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    child: Text('Créer un compte'),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: const Text('Déjà un compte? Se connecter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
