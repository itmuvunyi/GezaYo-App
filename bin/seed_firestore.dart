import 'dart:convert';
import 'dart:io';

/// Command line tool to seed 1 single transaction document into Cloud Firestore for project `gezayo-2179c`.
/// Usage: `dart run bin/seed_firestore.dart`
void main() async {
  print('GezaYo Single Transaction Seeder Initiated...');

  final projectId = 'gezayo-2179c';
  final baseUrl =
      'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents';

  final client = HttpClient();

  Future<void> setDocument(
      String collection, String docId, Map<String, dynamic> fields) async {
    final url = Uri.parse('$baseUrl/$collection/$docId');
    final request = await client.openUrl('PATCH', url);
    request.headers.contentType = ContentType.json;

    final firestoreMap = <String, dynamic>{};
    fields.forEach((key, value) {
      if (value is String) {
        firestoreMap[key] = {'stringValue': value};
      } else if (value is double) {
        firestoreMap[key] = {'doubleValue': value};
      } else if (value is int) {
        firestoreMap[key] = {'integerValue': value.toString()};
      } else if (value is bool) {
        firestoreMap[key] = {'booleanValue': value};
      }
    });

    final payload = json.encode({'fields': firestoreMap});
    request.write(payload);

    final response = await request.close();
    if (response.statusCode == 200) {
      print('  Seeded $collection/$docId');
    } else {
      final body = await response.transform(utf8.decoder).join();
      print('  Failed $collection/$docId (${response.statusCode}): $body');
    }
  }

  // Seed ONLY 1 single transaction document
  print('\nSeeding 1 single transaction document...');
  await setDocument('transactions', 'tx-101', {
    'id': 'tx-101',
    'title': 'Delivery #GZ-8821',
    'dateText': 'Today, 11:42 AM',
    'amountRwf': 4500.0,
    'type': 'jobEarning',
    'status': 'completed',
  });

  client.close();
  print('\nCloud Firestore Seeding Completed Successfully!');
}
