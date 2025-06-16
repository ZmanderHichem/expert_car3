import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    double screenHeight = MediaQuery.of(context).size.height;

    // Define the data for each square
    final List<Map<String, dynamic>> squareData = [
      {'icon': Icons.search, 'label': 'Chercher une voiture'},
      {'icon': Icons.add, 'label': 'Ajouter une voiture'},
      {'icon': Icons.history, 'label': 'Historique de Maintenance'},
      {'icon': Icons.build, 'label': 'Ajouter un Service'},
      {'icon': Icons.notifications, 'label': 'Voir les notifications'},
    ];

    final Map<String, int> serviceIntervals = {
      'Changement filtre a huile': 10000,
      'Changement filtre a air': 20000,
      'Changement bougies': 40000,
      'Changement courroie accessoire': 40000,
      'Changement courroie de distribution': 60000,
      'Changement plaquette de frein': 40000,
    };

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text('Utilisateur non connecté'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 181, 212, 237),
      body: SafeArea(
        child: Column(
          children: [
            // Conteneur sans couleur de fond
            Flexible(
              flex: 1,
              child: Container(
                width: double.infinity,
                height: screenHeight * 0.2,
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Shortcuts',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 132, 128, 128),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      height: 70,
                      width: double.infinity,
                      child: PageView.builder(
                        controller: PageController(
                          viewportFraction: 0.25,
                          initialPage: 0,
                        ),
                        itemCount: squareData.length,
                        padEnds: false,
                        itemBuilder: (context, index) {
                          return Container(
                            width: MediaQuery.of(context).size.width * 0.5,
                            margin: EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color.fromARGB(255, 0, 94, 255)
                                      .withOpacity(1.0 - index * 0.1),
                                  const Color.fromARGB(255, 255, 16, 68)
                                      .withOpacity(0.5 - index * 0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  squareData[index]['icon'],
                                  color: Colors.white,
                                  size: 30,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  squareData[index]['label'],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Réduction de l'espace entre les sections
            SizedBox(height: 10),
            // Conteneur avec fond blanc et bord arrondi en haut
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Erreur : ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return Center(child: Text('Aucune voiture enregistrée'));
                    }

                    final carData =
                        snapshot.data!.data() as Map<String, dynamic>?;
                    final cars = carData?['carModel'];

                    if (cars == null || (cars is List && cars.isEmpty)) {
                      return Center(child: Text('Aucune voiture enregistrée'));
                    }

                    List<Future<Map<String, dynamic>>> carFutures = [];

                    if (cars is List) {
                      for (var car in cars) {
                        if (car is String) {
                          var carFuture = FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .collection(car)
                              .doc('details')
                              .get()
                              .then((doc) {
                            final initialKilometrage =
                                doc.data()?['initialKilometrage'] ?? 'N/A';
                            return {
                              "modele": car,
                              "kilometrage": initialKilometrage,
                              "logoUrl": ""
                            };
                          });
                          carFutures.add(carFuture);
                        }
                      }
                    }

                    return FutureBuilder<List<Map<String, dynamic>>>(
                      future: Future.wait(carFutures),
                      builder: (context, carSnapshot) {
                        if (carSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (carSnapshot.hasError) {
                          return Center(
                              child: Text(
                                  'Erreur lors de la récupération des voitures'));
                        }
                        final carList = carSnapshot.data ?? [];

                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              ListView.builder(
                                padding: EdgeInsets.all(20),
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: carList.length,
                                itemBuilder: (context, index) {
                                  final car = carList[index];
                                  final carModel =
                                      car['modele'] ?? 'Modèle inconnu';
                                  final kilometrage =
                                      car['kilometrage'] ?? 'N/A';
                                  final logoUrl = car['logoUrl'] ?? '';

                                  return Card(
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ListTile(
                                      leading: Image.asset(
                                        'lib/assets/logos/${carModel.toLowerCase()}.png',
                                        width: 50,
                                        height: 50,
                                        errorBuilder: (context, error,
                                                stackTrace) =>
                                            Icon(Icons.car_rental, size: 50),
                                      ),
                                      title: Text(carModel,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      subtitle:
                                          Text('Kilométrage : $kilometrage km'),
                                    ),
                                  );
                                },
                              ),
                              if (carList.isNotEmpty)
                                NextServiceReminder(
                                  userId: user.uid,
                                  carModel: carList.first['modele'],
                                ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NextServiceReminder extends StatelessWidget {
  final String userId;
  final String carModel;

  NextServiceReminder(
      {super.key, required this.userId, required this.carModel});

  final Map<String, int> serviceIntervals = {
    'Changement filtre a huile': 10000,
    'Changement filtre a air': 20000,
    'Changement bougies': 40000,
    'Changement courroie accessoire': 40000,
    'Changement courroie de distribution': 60000,
    'Changement plaquette de frein': 40000,
  };

  Future<List<Map<String, dynamic>>> _getLastServices() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection(carModel)
        .doc('services')
        .collection('services')
        .orderBy('date', descending: true)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    }
    return [];
  }

  Map<String, Map<String, dynamic>> _calculateNextServices(
      List<Map<String, dynamic>> services) {
    final nextServices = <String, Map<String, dynamic>>{};

    // Parcourir tous les services pour trouver le dernier changement pour chaque type
    for (var service in services) {
      final serviceNames = service['services'] as List<dynamic>?;
      final kmActuel = service['km_actuel'] as int?;

      if (serviceNames != null && kmActuel != null) {
        for (var serviceName in serviceNames) {
          final interval = serviceIntervals[serviceName];
          if (interval != null) {
            final nextChange = kmActuel + interval;
            final kmSinceLastChange = kmActuel % interval;

            if (kmSinceLastChange >= interval - 10000) {
              nextServices[serviceName] = {
                'nextChange': nextChange,
                'lastChange': kmActuel,
              };
            }
          }
        }
      }
    }

    return nextServices;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getLastServices(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('Aucun service récent trouvé');
        }

        final nextServices = _calculateNextServices(snapshot.data!);

        if (nextServices.isEmpty) {
          return Text('Aucun service prévu dans les prochains 10 000 km');
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Services à prévoir :',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            ...nextServices.entries.map((entry) => ListTile(
                  title: Text(entry.key),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Prochain changement à ${entry.value['nextChange']} km'),
                      Text(
                          'Dernier changement à ${entry.value['lastChange']} km',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )),
          ],
        );
      },
    );
  }
}
