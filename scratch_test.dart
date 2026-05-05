import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('https://meal-db-sandy.vercel.app/meals');
  final headers = {
    'X-DB-NAME': 'f02bf7bc-fa63-477e-b9a2-3b9c28310f94',
    'Content-Type': 'application/json',
  };

  try {
    final response = await http.get(url, headers: headers);
    print('Status Code: ${response.statusCode}');
    print('Response Body:');
    print(response.body);
  } catch (e) {
    print('Error: $e');
  }
}
