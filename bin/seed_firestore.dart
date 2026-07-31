import 'dart:convert';
import 'dart:io';

/// Command line tool to manage Firestore seeding.
/// Delivery jobs seeding is currently disabled to keep the Cloud Firestore `deliveries` collection clean and empty.
void main() async {
  print('GezaYo Cloud Firestore Seeder Initiated...\n');

  final projectId = 'gezayo-2179c';
  final baseUrl =
      'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents';

  final client = HttpClient();

  // Delivery job seeding is disabled to keep deliveries collection empty for user testing.
  print('Notice: Delivery jobs seeding is turned off to maintain an empty deliveries collection.');

  client.close();
  print('\n[FINISHED] Firestore seeder run complete (0 delivery jobs inserted).');
}
