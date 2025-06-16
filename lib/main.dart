import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'expert_car_page.dart';
import 'historique.dart';
import 'AddCarPage/AddCarPage.dart';
import 'profile/ProfilePage.dart'; // Import de la page de profil
import 'FicheEntretien/FicheEntretien.dart';
import 'dashboard_page/dashboard_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'template/onboard_content.dart'; // Ajouter l'import du composant OnboardContent

// Lancement de Firebase
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
      theme: ThemeData(primarySwatch: Colors.blue),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(snapshot.data!.uid)
                  .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
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
              body: OnboardContent(), // Utiliser OnboardContent ici
            );
          }
        },
      ),
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
  // Cette méthode ne peut pas être utilisée ici car elle nécessite un contexte d'État
  // Elle devrait être définie dans un StatefulWidget ou un contexte d'État similaire
}

// Barre de navigation avec AppBar sur toutes les pages
class BottomNavBar extends StatefulWidget {
  final String? carModel;
  const BottomNavBar({super.key, required this.carModel});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;
  String? _currentCarModel;
  String? _userName; // Variable to store the user's name

  Future<bool> _canAddCar() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    return true;
  }

  @override
  void initState() {
    super.initState();
    _currentCarModel = widget.carModel;
    _fetchUserName(); // Fetch the user's name
    debugPrint("Initialisation avec carModel: $_currentCarModel");
  }

  Future<void> _fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final String firstName = userDoc['prenom'] ?? 'Unknown';
      final String lastName = userDoc['nom'] ?? 'User';
      setState(() {
        _userName = '$firstName $lastName';
      });
    } catch (e) {
      debugPrint("Erreur lors de la récupération du nom de l'utilisateur : $e");
    }
  }

  List<Widget> get _pages => <Widget>[
        DashboardPage(),

        ExpertCarPage(carModel: _currentCarModel),
        // const AddCarPage(),
        HistoriquePage(carModel: _currentCarModel),

        ProfilePage(), // Ajout de la page de profil
        FicheEntretien()
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onHover(bool isHovered) {
    // Logique pour changer l'apparence de l'icône lors du survol
    // Vous pouvez utiliser un état pour changer la couleur ou l'opacité
  }

  Widget _buildIcon(IconData icon) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(left: 5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.2),
      ),
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _userName ?? 'Utilisateur', // Use the user's name if available
          style: const TextStyle(
            color: Colors.white, // Couleur du texte en blanc
            fontWeight: FontWeight.bold, // Texte en gras
          ),
        ),
        backgroundColor: Colors.blue,
        actions: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.start, // Aligner les icônes à gauche
            children: [
              _buildIcon(Icons.notifications),
              SizedBox(width: 5),
              _buildIcon(FontAwesomeIcons.car), // Logo voiture
              SizedBox(width: 10),
            ],
          ),
          PopupMenuButton<String>(
            offset: const Offset(0, 50), // Décaler la fenêtre vers le bas
            onSelected: (String value) async {
              if (value == 'add_car') {
                bool canAdd = await _canAddCar();
                if (canAdd) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        child: AddCarPage(),
                      );
                    },
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          "Veuillez améliorer votre abonnement pour ajouter une autre voiture."),
                      backgroundColor: Color.fromARGB(255, 95, 92, 92),
                    ),
                  );
                }
              } else if (value == 'logout') {
                await _signOut(context);
              } else if (value == 'switch_car') {
                final selectedCar = await _showCarSelectionDialog(context);
                if (selectedCar != null) {
                  setState(() {
                    _currentCarModel = selectedCar;
                  });
                }
              } else if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'email',
                enabled: false, // Désactiver la sélection de cette option
                child: Text(
                  ' ${FirebaseAuth.instance.currentUser?.email ?? "Non connecté"}',
                  style: TextStyle(
                    color: Colors.black, // Couleur du texte
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              PopupMenuItem<String>(
                value: 'add_car',
                child: Row(
                  children: [
                    Icon(Icons.add, color: Colors.black), // Icone d'ajout
                    SizedBox(width: 8),
                    Text('Ajouter une voiture',
                        style: TextStyle(color: Colors.black)),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'switch_car',
                child: Row(
                  children: [
                    Icon(Icons.swap_horiz,
                        color: Colors.black), // Icone de changement
                    SizedBox(width: 8),
                    Text('Changer de voiture',
                        style: TextStyle(color: Colors.black)),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.black), // Icone de profil
                    SizedBox(width: 8),
                    Text('Profil', style: TextStyle(color: Colors.black)),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.exit_to_app,
                        color: Colors.red), // Icone de déconnexion
                    SizedBox(width: 8),
                    Text('Déconnexion', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: CarLogo(
                carModel: _currentCarModel,
              ),
            ),
          )
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: 'Ajouter Service',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historique',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Fiche Entretien',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

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
