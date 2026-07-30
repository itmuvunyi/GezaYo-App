import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final translationServiceProvider = Provider<TranslationService>((ref) {
  return TranslationService();
});

class TranslationService {
  final Map<String, Map<String, String>> _cache = {};

  // Basic dictionary fallback for core Rwandan localization terms
  static final Map<String, Map<String, String>> _localDictionary = {
    'Kinyarwanda': {
      'GezaYo': 'GezaYo',
      'Welcome Back': 'Murakaza neza',
      'Create Your Account': 'Kurema Konti Yanyu',
      'Sign In': 'Kwinjira',
      'Sign Up': 'Kwiyandikisha',
      'Food Delivery': 'Ibyo Kurya',
      'Groceries': 'Ibisanzwe',
      'Parcels': 'Ubutumwa / Ibipfunyika',
      'Errands': 'Imirimo Itandukanye',
      'Nearby Riders': 'Abamotari Begereye',
      'Request Rider': 'Saba Motari',
      'Notifications': 'Ibimenyeshejwe',
      'Security & Privacy': 'Umutekano n\'Ibyibanga',
      'Help Center': 'Ikusanyirizo ry\'Ubufasha',
      'Logout': 'Gusohoka',
      'Confirm Logout': 'Emeza Gusohoka',
      'Delete Account': 'Gusiba Konti',
    },
    'Français': {
      'GezaYo': 'GezaYo',
      'Welcome Back': 'Bon retour',
      'Create Your Account': 'Créer votre compte',
      'Sign In': 'Se connecter',
      'Sign Up': 'S\'inscrire',
      'Food Delivery': 'Livraison de nourriture',
      'Groceries': 'Courses',
      'Parcels': 'Colis',
      'Errands': 'Courses quotidiennes',
      'Nearby Riders': 'Livreurs à proximité',
      'Request Rider': 'Demander un livreur',
      'Notifications': 'Notifications',
      'Security & Privacy': 'Sécurité & Confidentialité',
      'Help Center': 'Centre d\'aide',
      'Logout': 'Se déconnecter',
      'Confirm Logout': 'Confirmer la déconnexion',
      'Delete Account': 'Supprimer le compte',
    },
    'Kiswahili': {
      'GezaYo': 'GezaYo',
      'Welcome Back': 'Karibu Tena',
      'Create Your Account': 'Tengeneza Akaunti',
      'Sign In': 'Ingia',
      'Sign Up': 'Jisajili',
      'Food Delivery': 'Utoaji wa Chakula',
      'Groceries': 'Vyakula',
      'Parcels': 'Vifurushi',
      'Errands': 'Kazi Ndogondogo',
      'Nearby Riders': 'Madereva Walio Karibu',
      'Request Rider': 'Omba Dereva',
      'Notifications': 'Arifa',
      'Security & Privacy': 'Usalama na Faragha',
      'Help Center': 'Kituo cha Msaada',
      'Logout': 'Ondoka',
      'Confirm Logout': 'Thibitisha Kuondoka',
      'Delete Account': 'Futa Akaunti',
    },
  };

  /// Translate text dynamically using MyMemory Translation API with local dictionary fallback
  Future<String> translate(String text, String targetLanguage) async {
    if (targetLanguage == 'English' || text.trim().isEmpty) {
      return text;
    }

    final cacheKey = '$targetLanguage:$text';
    if (_cache.containsKey(targetLanguage) &&
        _cache[targetLanguage]!.containsKey(text)) {
      return _cache[targetLanguage]![text]!;
    }

    // Check Local Dictionary first
    if (_localDictionary.containsKey(targetLanguage) &&
        _localDictionary[targetLanguage]!.containsKey(text)) {
      return _localDictionary[targetLanguage]![text]!;
    }

    final langCode = _getLangCode(targetLanguage);
    if (langCode == 'en') return text;

    try {
      final uri = Uri.parse(
          'https://api.mymemory.translated.net/get?q=${Uri.encodeComponent(text)}&langpair=en|$langCode');
      final response = await http.get(uri).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final translated =
            decoded['responseData']?['translatedText'] as String?;
        if (translated != null && translated.isNotEmpty) {
          _cache.putIfAbsent(targetLanguage, () => {})[text] = translated;
          return translated;
        }
      }
    } catch (e) {
      debugPrint('Translation Service note: $e');
    }

    return text; // Fallback to original text on network failure
  }

  String _getLangCode(String targetLanguage) {
    switch (targetLanguage) {
      case 'Kinyarwanda':
        return 'rw';
      case 'Français':
        return 'fr';
      case 'Kiswahili':
        return 'sw';
      default:
        return 'en';
    }
  }
}
