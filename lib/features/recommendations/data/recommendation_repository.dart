import 'dart:convert';

import 'package:http/http.dart' as http;

class RecommendationRepository {
  RecommendationRepository({required this.baseUrl});

  final String baseUrl;

  Future<List<Map<String, dynamic>>> getRecommendations({
    required String productId,
    int limit = 5,
  }) async {
    final uri = Uri.parse('$baseUrl/recommendations/$productId?limit=$limit');

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load recommendations: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    return List<Map<String, dynamic>>.from(data['recommendations'] ?? []);
  }

  Future<List<Map<String, dynamic>>> getUserRecommendations({
    required String userId,
    int limit = 5,
  }) async {
    final uri = Uri.parse('$baseUrl/recommendations/user/$userId?limit=$limit');

    print('PERSONALISED REQUEST: $uri');

    final response = await http.get(uri).timeout(const Duration(seconds: 10));

    print('PERSONALISED STATUS: ${response.statusCode}');

    print('PERSONALISED RESPONSE: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load personalised recommendations: '
        '${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    return List<Map<String, dynamic>>.from(data['recommendations'] ?? []);
  }
}
