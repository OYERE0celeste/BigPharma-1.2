import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product_lookup_result.dart';

/// Service for external product metadata lookup.
/// Supports DrugsAPI, Go-UPC and OpenFoodFacts / generic URL metadata.
class ExternalApiService {
  static const _defaultHeaders = {
    'Accept': 'application/json',
    'User-Agent': 'BigPharma/1.0 (scanner lookup)',
  };

  static const _networkTimeout = Duration(seconds: 10);

  static Uri _buildUri(String url) {
    return Uri.parse(url);
  }

  static Future<ProductLookupResult?> lookupBarcode(String barcode) async {
    final normalized = barcode.trim();
    if (normalized.isEmpty) return null;

    final candidates = <ProductLookupResult?>[
      await _lookupDrugsApi(normalized),
      await _lookupGoUpc(normalized),
      await _lookupOpenFoodFacts(normalized),
    ];

    return candidates.firstWhere(
      (result) => result != null,
      orElse: () => null,
    );
  }

  static Future<ProductLookupResult?> lookupQRCode(String qrCode) async {
    final normalized = qrCode.trim();
    if (normalized.isEmpty) return null;

    final gtin = _extractGs1DigitalLinkGtin(normalized);
    if (gtin != null) {
      final result = await lookupBarcode(gtin);
      if (result != null) return result;
    }

    if (_looksLikeUrl(normalized)) {
      return _fetchWebMetadata(Uri.parse(normalized));
    }

    final jsonPayload = _tryParseJson(normalized);
    if (jsonPayload != null) {
      return _fromJsonPayload(jsonPayload, normalized);
    }

    return null;
  }

  static Future<ProductLookupResult?> _lookupDrugsApi(String barcode) async {
    final baseUrl = const String.fromEnvironment(
      'DRUGS_API_URL',
      defaultValue: '',
    ).trim();
    final apiKey = const String.fromEnvironment(
      'DRUGS_API_KEY',
      defaultValue: '',
    ).trim();

    if (baseUrl.isEmpty || apiKey.isEmpty) {
      return null;
    }

    final url = baseUrl.replaceAll('{{barcode}}', Uri.encodeComponent(barcode));
    final uri = Uri.parse(url).replace(
      queryParameters: {
        ...Uri.parse(url).queryParameters,
        'api_key': apiKey,
        'key': apiKey,
        'barcode': barcode,
      },
    );

    try {
      final response = await _get(uri);
      if (response == null || response.statusCode != 200) {
        return null;
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      return _fromDrugsApiPayload(data, barcode);
    } catch (_) {
      return null;
    }
  }

  static Future<ProductLookupResult?> _lookupGoUpc(String barcode) async {
    final baseUrl = const String.fromEnvironment(
      'GO_UPC_API_URL',
      defaultValue: '',
    ).trim();
    final apiKey = const String.fromEnvironment(
      'GO_UPC_API_KEY',
      defaultValue: '',
    ).trim();

    if (baseUrl.isEmpty || apiKey.isEmpty) {
      return null;
    }

    final url = baseUrl.replaceAll('{{barcode}}', Uri.encodeComponent(barcode));
    final uri = Uri.parse(url).replace(
      queryParameters: {
        ...Uri.parse(url).queryParameters,
        'api_key': apiKey,
        'key': apiKey,
        'upc': barcode,
      },
    );

    try {
      final response = await _get(uri);
      if (response == null || response.statusCode != 200) {
        return null;
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      return _fromGoUpcPayload(data, barcode);
    } catch (_) {
      return null;
    }
  }

  static Future<ProductLookupResult?> _lookupOpenFoodFacts(
    String barcode,
  ) async {
    final uri = Uri.parse(
      'https://world.openfoodfacts.net/api/v3/product/$barcode'
      '?fields=product_name,product_name_fr,generic_name,brands,brands_tags,categories,categories_tags,'
      'image_front_small_url,image_front_url,image_url,ingredients_text,ingredients_text_fr',
    );

    try {
      final response = await _get(uri);
      if (response == null || response.statusCode != 200) {
        return null;
      }

      final body = json.decode(response.body) as Map<String, dynamic>;
      if (body['status'] != 'success' || body['product'] == null) {
        return null;
      }

      return _fromOpenFactsProduct(
        barcode,
        body['product'] as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<ProductLookupResult?> _fetchWebMetadata(Uri uri) async {
    try {
      final response = await _get(uri);
      if (response == null || response.statusCode != 200) {
        return null;
      }

      final html = response.body;
      final title =
          _extractMeta(html, r'(?:og:title|twitter:title)') ??
          _extractTitle(html);
      if (title == null || title.isEmpty) return null;

      return ProductLookupResult(
        name: title,
        description: _extractMeta(
          html,
          r'(?:og:description|twitter:description|description)',
        ),
        imageUrl: _extractMeta(html, r'(?:og:image|twitter:image)'),
        category: uri.host,
        source: 'Web',
        barcode: uri.toString(),
        rawData: {'url': uri.toString()},
      );
    } catch (_) {
      return null;
    }
  }

  static Future<http.Response?> _get(Uri uri) async {
    try {
      final response = await http
          .get(uri, headers: _defaultHeaders)
          .timeout(_networkTimeout);
      return response;
    } on TimeoutException {
      return null;
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic>? _tryParseJson(String value) {
    try {
      final decoded = json.decode(value);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {}
    return null;
  }

  static ProductLookupResult? _fromDrugsApiPayload(
    Map<String, dynamic> data,
    String barcode,
  ) {
    final name = _firstNonEmptyString([
      data['name'],
      data['product_name'],
      data['drug_name'],
      data['title'],
    ]);
    if (name == null) return null;

    return ProductLookupResult(
      name: name,
      brand: _firstNonEmptyString([
        data['brand'],
        data['manufacturer'],
        data['maker'],
      ]),
      description: _firstNonEmptyString([
        data['description'],
        data['summary'],
        data['indications'],
      ]),
      category: _firstNonEmptyString([
        data['category'],
        data['drug_type'],
        data['product_type'],
      ]),
      manufacturer: _firstNonEmptyString([
        data['manufacturer'],
        data['laboratory'],
      ]),
      dosage: _firstNonEmptyString([
        data['dosage'],
        data['strength'],
        data['dose'],
      ]),
      quantity: _firstNonEmptyString([
        data['quantity'],
        data['packaging'],
        data['size'],
      ]),
      ingredients: _firstNonEmptyString([
        data['ingredients'],
        data['active_ingredients'],
      ]),
      imageUrl: _firstNonEmptyString([
        data['image'],
        data['image_url'],
        data['imageUrl'],
      ]),
      externalId: data['id']?.toString() ?? data['product_id']?.toString(),
      source: 'DrugsAPI',
      barcode: barcode,
      rawData: data,
    );
  }

  static ProductLookupResult? _fromGoUpcPayload(
    Map<String, dynamic> data,
    String barcode,
  ) {
    final name = _firstNonEmptyString([
      data['name'],
      data['product_name'],
      data['title'],
    ]);
    if (name == null) return null;

    return ProductLookupResult(
      name: name,
      brand: _firstNonEmptyString([data['brand'], data['manufacturer']]),
      description: _firstNonEmptyString([data['description'], data['summary']]),
      category: _firstNonEmptyString([data['category'], data['type']]),
      manufacturer: _firstNonEmptyString([data['manufacturer'], data['lab']]),
      dosage: _firstNonEmptyString([data['dosage'], data['strength']]),
      quantity: _firstNonEmptyString([data['size'], data['large_size']]),
      ingredients: _firstNonEmptyString([
        data['ingredients'],
        data['contents'],
      ]),
      imageUrl: _firstNonEmptyString([
        data['image'],
        data['image_url'],
        data['imageUrl'],
      ]),
      externalId: data['id']?.toString() ?? data['upc']?.toString(),
      source: 'Go-UPC',
      barcode: barcode,
      rawData: data,
    );
  }

  static ProductLookupResult? _fromOpenFactsProduct(
    String barcode,
    Map<String, dynamic> product,
  ) {
    final name = _firstNonEmptyString([
      product['product_name'],
      product['product_name_fr'],
      product['generic_name'],
    ]);
    if (name == null) return null;

    return ProductLookupResult(
      name: name,
      brand: _firstNonEmptyString([
        product['brands'],
        _extractFirstListValue(product['brands_tags']),
      ]),
      description: _firstNonEmptyString([
        product['generic_name'],
        product['ingredients_text_fr'],
        product['ingredients_text'],
        product['categories'],
      ]),
      category: _cleanTaxonomyLabel(
        _firstNonEmptyString([
          product['categories'],
          _extractFirstListValue(product['categories_tags']),
        ]),
      ),
      imageUrl: _firstNonEmptyString([
        product['image_front_url'],
        product['image_front_small_url'],
        product['image_url'],
      ]),
      source: 'OpenFoodFacts',
      barcode: barcode,
      rawData: product,
    );
  }

  static ProductLookupResult? _fromJsonPayload(
    Map<String, dynamic> data,
    String rawValue,
  ) {
    final name = _firstNonEmptyString([
      data['name'],
      data['productName'],
      data['title'],
    ]);
    if (name == null) return null;

    return ProductLookupResult(
      name: name,
      brand: _firstNonEmptyString([data['brand'], data['manufacturer']]),
      description: _firstNonEmptyString([data['description'], data['summary']]),
      category: _firstNonEmptyString([data['category'], data['type']]),
      manufacturer: _firstNonEmptyString([
        data['manufacturer'],
        data['laboratory'],
      ]),
      dosage: _firstNonEmptyString([data['dosage'], data['strength']]),
      quantity: _firstNonEmptyString([data['quantity'], data['size']]),
      ingredients: _firstNonEmptyString([
        data['ingredients'],
        data['activeIngredients'],
        data['active_ingredients'],
      ]),
      imageUrl: _firstNonEmptyString([
        data['image'],
        data['imageUrl'],
        data['image_url'],
      ]),
      externalId: _firstNonEmptyString([
        data['barcode'],
        data['gtin'],
        data['productId'],
        data['id'],
      ]),
      source: 'QR Payload',
      barcode:
          _firstNonEmptyString([data['barcode'], data['gtin']]) ?? rawValue,
      rawData: data,
    );
  }

  static bool _looksLikeUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  static String? _extractTitle(String html) {
    final regex = RegExp(r'<title[^>]*>([^<]+)</title>', caseSensitive: false);
    return regex.firstMatch(html)?.group(1)?.trim();
  }

  static String? _extractMeta(String html, String pattern) {
    final regex = RegExp(
      "<meta[^>]+(?:property|name)\\s*=\\s*[\"']${pattern}[\"'][^>]+content\\s*=\\s*[\"']([^\"']+)[\"']",
      caseSensitive: false,
    );
    final match = regex.firstMatch(html);
    return match?.group(1)?.trim();
  }

  static String? _firstNonEmptyString(List<dynamic> values) {
    for (final value in values) {
      final normalized = value?.toString().trim();
      if (normalized != null && normalized.isNotEmpty && normalized != 'null') {
        return normalized;
      }
    }
    return null;
  }

  static String? _extractFirstListValue(dynamic value) {
    if (value is List && value.isNotEmpty) {
      return value.first?.toString().trim();
    }
    return null;
  }

  static String? _cleanTaxonomyLabel(String? value) {
    if (value == null || value.isEmpty) return null;
    return value
        .replaceFirst(RegExp(r'^[a-z]{2,3}:'), '')
        .replaceAll('-', ' ')
        .trim();
  }

  static String? _extractGs1DigitalLinkGtin(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null) return null;

    final segments = uri.pathSegments;
    for (var i = 0; i < segments.length - 1; i++) {
      if (segments[i] == '01' &&
          RegExp(r'^\d{14}????$').hasMatch(segments[i + 1])) {
        return segments[i + 1];
      }
    }

    final queryCandidate =
        uri.queryParameters['gtin'] ?? uri.queryParameters['barcode'];
    if (queryCandidate != null &&
        RegExp(r'^\d{8,14}????$').hasMatch(queryCandidate)) {
      return queryCandidate;
    }

    return null;
  }
}
