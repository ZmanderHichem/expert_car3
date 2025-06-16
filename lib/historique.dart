import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoriquePage extends StatelessWidget {
  final String? carModel;

  const HistoriquePage({super.key, required this.carModel});

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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    debugPrint("Build de HistoriquePage avec carModel: $carModel");

    return Scaffold(
      backgroundColor: Colors.blue, // Couleur de fond bleue
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(60)), // Radius de 60
        ),
        child: Padding(
          padding:
              const EdgeInsets.only(top: 60), // Décaler le contenu vers le bas
          child: StreamBuilder<QuerySnapshot>(
            stream: user != null && carModel != null
                ? FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection(carModel!)
                    .doc('services')
                    .collection('services')
                    .orderBy('date', descending: true)
                    .snapshots()
                : null,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                debugPrint("HistoriquePage - En attente des données...");
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                debugPrint("HistoriquePage - Erreur : ${snapshot.error}");
                return const Center(
                  child: Text('Erreur lors de la récupération des données.'),
                );
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                debugPrint("HistoriquePage - Aucun service trouvé.");
                return const Center(
                  child: Text('Aucun service trouvé dans l\'historique.'),
                );
              }

              final List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
              debugPrint(
                  "HistoriquePage - Nombre de services trouvés : ${documents.length}");

              return ListView.builder(
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  final data = documents[index].data() as Map<String, dynamic>;
                  final serviceName = data['services'] ?? 'Service inconnu';
                  final Timestamp timestamp = data['date'];
                  final DateTime date = timestamp.toDate();
                  final Kilometrage = data['km_actuel'] ?? 'Aucune description';
                  final Remarque = data['remarque'] ?? 'Aucune description';

                  String serviceNameString = '';
                  if (serviceName is List<dynamic>) {
                    serviceNameString = serviceName.join(', ');
                  } else {
                    serviceNameString = serviceName.toString();
                  }

                  final DateFormat formatter = DateFormat('yyyy-MM-dd');
                  final String formattedDate = formatter.format(date);

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            serviceNameString,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Date : $formattedDate'),
                          const SizedBox(height: 8),
                          Text('Kilométrage : $Kilometrage'),
                          const SizedBox(height: 8),
                          Text('Remarque : $Remarque'),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class CarLogo extends StatelessWidget {
  final String? carModel;

  const CarLogo({super.key, required this.carModel});

  @override
  Widget build(BuildContext context) {
    if (carModel == null) {
      debugPrint("CarLogo - Aucun modèle de voiture sélectionné.");
      return const SizedBox.shrink();
    }

    final logoPath =
        'lib/assets/logos/${carModel!.toLowerCase().replaceAll(' ', '_')}.png';
    debugPrint("CarLogo - Chemin du logo : $logoPath");

    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.white,
      child: CircleAvatar(
        radius: 18,
        backgroundImage: AssetImage(logoPath),
        onBackgroundImageError: (exception, stackTrace) {
          debugPrint("CarLogo - Erreur de chargement du logo : $exception");
        },
        child: carModel == null
            ? const Icon(Icons.error_outline, color: Colors.red)
            : null,
      ),
    );
  }
}
