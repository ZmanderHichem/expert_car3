import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page Principale'),
        backgroundColor: Colors.blue, // Couleur de fond de l'AppBar
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Naviguer vers la page FicheEntretien
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FicheEntretien()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue, // Optional: Customize AppBar's color
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Voir les entretiens',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class FicheEntretien extends StatefulWidget {
  const FicheEntretien({super.key});

  @override
  _FicheEntretienState createState() => _FicheEntretienState();
}

class _FicheEntretienState extends State<FicheEntretien> {
  // Liste des entretiens
  final List<Map<String, String>> entretiens = [
    {
      "nom": "Vidange d'huile",
      "description":
          "Tous les 5 000 à 10 000 km. Remplacement de l'huile moteur et du filtre à huile.",
      "icon": "oil",
    },
    {
      "nom": "Filtre à air",
      "description":
          "Tous les 15 000 à 30 000 km. Remplacement du filtre à air.",
      "icon": "filter",
    },
    {
      "nom": "Plaquettes de frein",
      "description":
          "Tous les 20 000 à 30 000 km. Contrôle et remplacement des plaquettes de frein.",
      "icon": "brake",
    },
    {
      "nom": "Bougies d'allumage",
      "description":
          "Tous les 30 000 à 50 000 km. Remplacement des bougies d'allumage.",
      "icon": "spark",
    },
    {
      "nom": "Liquide de refroidissement",
      "description":
          "Tous les 40 000 à 60 000 km. Remplacement du liquide de refroidissement.",
      "icon": "coolant",
    },
    {
      "nom": "Courroies de distribution",
      "description":
          "Tous les 60 000 à 100 000 km. Vérification et remplacement des courroies de distribution.",
      "icon": "belt",
    },
    {
      "nom": "Filtre à carburant",
      "description":
          "Tous les 60 000 à 100 000 km. Remplacement du filtre à carburant.",
      "icon": "fuel",
    },
    {
      "nom": "Pneus",
      "description":
          "Tous les 40 000 à 80 000 km. Vérification de l'usure des pneus.",
      "icon": "tire",
    },
    {
      "nom": "Batterie",
      "description":
          "Tous les 40 000 à 50 000 km. Vérification de l'état de la batterie.",
      "icon": "battery",
    },
    {
      "nom": "Vidange de boîte de vitesses",
      "description":
          "Tous les 60 000 à 100 000 km. Vidange de la boîte de vitesses si nécessaire.",
      "icon": "gear",
    },
    // Vous pouvez ajouter d'autres entretiens ici...
  ];

  String? selectedEntretien;
  String description = '';
  IconData? selectedIcon;

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Liste déroulante avec icônes
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: DropdownButton<String>(
                  hint: Text(
                    'Sélectionnez un entretien',
                    style: TextStyle(fontSize: 16),
                  ),
                  value: selectedEntretien,
                  onChanged: (newValue) {
                    setState(() {
                      selectedEntretien = newValue;
                      // Mettre à jour la description et l'icône en fonction du choix
                      description = entretiens.firstWhere(
                          (e) => e['nom'] == newValue)['description']!;
                      selectedIcon = getIconByName(entretiens
                          .firstWhere((e) => e['nom'] == newValue)['icon']!);
                    });
                  },
                  items: entretiens.map((entretien) {
                    return DropdownMenuItem<String>(
                      value: entretien['nom'],
                      child: Row(
                        children: [
                          Icon(
                            getIconByName(entretien['icon']!),
                            color: Colors.blue,
                          ),
                          SizedBox(width: 10),
                          Text(entretien['nom']!),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 20),
              // Affichage de la description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  description.isEmpty
                      ? 'Sélectionnez un entretien pour voir la description'
                      : description,
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData getIconByName(String iconName) {
    switch (iconName) {
      case 'oil':
        return Icons.build;
      case 'filter':
        return Icons.air;
      case 'brake':
        return Icons.directions_car;
      case 'spark':
        return Icons.flash_on;
      case 'coolant':
        return Icons.local_drink;
      case 'belt':
        return Icons.loop;
      case 'fuel':
        return Icons.local_gas_station;
      case 'tire':
        return Icons.car_repair;
      case 'battery':
        return Icons.battery_full;
      case 'gear':
        return Icons.settings;
      default:
        return Icons.help;
    }
  }
}
