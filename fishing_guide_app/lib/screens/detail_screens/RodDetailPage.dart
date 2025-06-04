import 'package:fishing_guide_app/screens/RodPage.dart';
import 'package:flutter/material.dart';
import 'package:fishing_guide_app/screens/HomePage.dart';
import 'package:fishing_guide_app/screens/BaitPage.dart';
import 'package:fishing_guide_app/screens/FishPage.dart';
import 'package:fishing_guide_app/screens/MapPage.dart';
import 'package:fishing_guide_app/screens/BookPage.dart';

class RodDetailPage extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;

  const RodDetailPage({
    required this.title,
    required this.description,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(imagePath),
            SizedBox(height: 20),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 10),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}