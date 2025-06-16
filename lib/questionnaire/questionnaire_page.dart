import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';

class QuestionnairePage extends StatefulWidget {
  final String userId;
  final String carModel;
  final int initialQuestionIndex;

  const QuestionnairePage({
    super.key,
    required this.userId,
    required this.carModel,
    this.initialQuestionIndex = 0,
  });

  @override
  _QuestionnairePageState createState() => _QuestionnairePageState();
}

class _QuestionnairePageState extends State<QuestionnairePage> {
  late int _currentQuestionIndex;
  String? _selectedAnswer;

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'À quel vidange avez-vous changé le filtre à huile?',
      'field': 'OilFilterChange',
      'options': [
        'Au dernier vidange',
        'Avant 20000 Km',
        'Avant 30000 Km',
        'Avant 60000 Km',
        'Jamais'
      ]
    },
    {
      'question': 'Quand avez-vous changé le filtre à air?',
      'field': 'airFilterChange',
      'options': [
        'Au dernier entretien',
        'Avant 20000 Km',
        'Avant 30000 Km',
        'Avant 60000 Km',
        'Jamais'
      ]
    },
    {
      'question': 'Quand avez-vous changé le filtre à Carburant?',
      'field': 'fuelFilterChange',
      'options': [
        'Au dernier entretien',
        'Avant 20000 Km',
        'Avant 30000 Km',
        'Avant 60000 Km',
        'Jamais'
      ]
    },
    {
      'question': 'Quand avez-vous changé la Courroie de distribution?',
      'field': 'distributionBeltChange',
      'options': [
        'Au dernier entretien',
        'Avant 20000 Km',
        'Avant 30000 Km',
        'Avant 60000 Km',
        'Jamais'
      ]
    },
    {
      'question': 'Quand avez-vous changé la Courroie Alternateur?',
      'field': 'alternatorBeltChange',
      'options': [
        'Au dernier entretien',
        'Avant 20000 Km',
        'Avant 30000 Km',
        'Avant 60000 Km',
        'Jamais'
      ]
    },
    {
      'question': 'Quand avez-vous changé les Plaquettes de frein?',
      'field': 'brakePadsChange',
      'options': [
        'Au dernier entretien',
        'Avant 20000 Km',
        'Avant 30000 Km',
        'Avant 60000 Km',
        'Jamais'
      ]
    },
  ];

  @override
  void initState() {
    super.initState();
    _currentQuestionIndex = widget.initialQuestionIndex;
  }

  Future<void> _saveAnswer() async {
    if (_selectedAnswer != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .collection(widget.carModel)
            .doc('maintenance')
            .set({
          _questions[_currentQuestionIndex]['field']: _selectedAnswer,
        }, SetOptions(merge: true));

        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final userDocRef =
              FirebaseFirestore.instance.collection('users').doc(widget.userId);

          final doc = await transaction.get(userDocRef);

          // Gestion des champs manquants de manière sécurisée
          final currentProgress =
              (doc.data()?['questionnaireProgress'] ?? 0) as int;
          final hasCompleted =
              (doc.data()?['questionnaireCompleted'] ?? false) as bool;

          // Mise à jour conditionnelle
          final newProgress = currentProgress + 1;
          transaction.update(userDocRef, {
            'questionnaireProgress': newProgress,
            'questionnaireCompleted': newProgress >= 6 || hasCompleted,
          });
        });

        if (_currentQuestionIndex < _questions.length - 1) {
          setState(() {
            _currentQuestionIndex++;
            _selectedAnswer = null;
          });
        } else {
          debugPrint('Questionnaire terminé');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (context) => BottomNavBar(carModel: widget.carModel)),
          );
        }
      } catch (e) {
        debugPrint('Erreur sauvegarde: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de sauvegarde: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Question (${_currentQuestionIndex + 1}/6)'),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / 6,
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              child: Column(
                key: ValueKey(_currentQuestionIndex),
                children: [
                  // Ajouter l'image ici
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Text(
                      _questions[_currentQuestionIndex]['question'],
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount:
                          _questions[_currentQuestionIndex]['options'].length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 15),
                      itemBuilder: (context, index) {
                        final option =
                            _questions[_currentQuestionIndex]['options'][index];
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedAnswer = option;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                color: _selectedAnswer == option
                                    ? Colors.blue.withOpacity(0.1)
                                    : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: _selectedAnswer == option
                                        ? Colors.blue
                                        : Colors.transparent,
                                    width: 2)),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: _selectedAnswer == option
                                      ? Colors.blue
                                      : Colors.grey[300],
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Text(
                                    option,
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: _selectedAnswer == option
                                            ? Colors.blue
                                            : Colors.black,
                                        fontWeight: _selectedAnswer == option
                                            ? FontWeight.bold
                                            : FontWeight.normal),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _saveAnswer,
                    child: Text(
                        _currentQuestionIndex < 5 ? 'Suivant' : 'Terminer'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
