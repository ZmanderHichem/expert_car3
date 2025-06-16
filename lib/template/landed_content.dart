import 'package:flutter/material.dart';

class LandingContent extends StatelessWidget {
  const LandingContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Bienvenue sur Votre Carnet d'Entretien ",
            style: Theme.of(context)
                .textTheme
                .headlineLarge!
                .copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 16,
          ),
          Text(
            "Application Totalement gratuite pour vous aider a suivre votre voiture pour une meilleure performance.",
            style: TextStyle(fontSize: 24, color: Colors.blueGrey.shade300),
          ),
        ],
      ),
    );
  }
}
