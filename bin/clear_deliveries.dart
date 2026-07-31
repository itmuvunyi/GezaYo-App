import 'dart:convert';
import 'dart:io';

/// Command line tool to clear/delete all delivery job documents from Cloud Firestore `deliveries` collection.
/// Usage: `dart run bin/clear_deliveries.dart`
void main() async {
  print('GezaYo Cloud Firestore Clear Deliveries Tool Initiated...\n');

  final projectId = 'gezayo-2179c';
  final baseUrl =
      'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents';

  final client = HttpClient();

  // 1. Specific document IDs to delete
  final docIds = ['GZ-8821', 'GZ-8794', 'GZ-9900'];

  for (final docId in docIds) {
    final url = Uri.parse('$baseUrl/deliveries/$docId');
    final request = await client.openUrl('DELETE', url);
    final response = await request.close();

    if (response.statusCode == 200) {
      print('  [DELETED] deliveries/$docId');
    } else {
      final body = await response.transform(utf8.decoder).join();
      print('  [INFO] deliveries/$docId response (${response.statusCode}): $body');
    }
  }

  // 2. Fetch and delete any remaining documents in deliveries collection
  try {
    final listUrl = Uri.parse('$baseUrl/deliveries');
    final getReq = await client.getUrl(listUrl);
    final getRes = await getReq.close();

    if (getRes.statusCode == 200) {
      final body = await getRes.transform(utf8.decoder).join();
      final Map<String, dynamic> data = json.decode(body);
      final List documents = data['documents'] ?? [];

      for (final doc in documents) {
        final String name = doc['name'] ?? '';
        final docName = name.split('/').last;
        final delUrl = Uri.parse('$baseUrl/deliveries/$docName');
        final delReq = await client.openUrl('DELETE', delUrl);
        final delRes = await delReq.close();
        if (delRes.statusCode == 200) {
          print('  [DELETED REMAINING] deliveries/$docName');
        }
      }
    }
  } catch (e) {
    print('  Note: $e');
  }

  client.close();
  print('\n[FINISHED] All seeded delivery documents deleted from Cloud Firestore!');
}
