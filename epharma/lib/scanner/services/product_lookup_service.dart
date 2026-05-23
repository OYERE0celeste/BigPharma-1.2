import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/product_lookup_result.dart';
import 'external_api_service.dart';

export '../models/product_lookup_result.dart';

class ProductLookupService {
  static final _client = http.Client();

  static const _defaultHeaders = {
    'Accept': 'application/json',
    'User-Agent': 'BigPharma/1.0 (scanner lookup)',
  };

  static Future<ProductLookupResult?> lookupCode(String code) async {
    final normalized = code.trim();
    if (normalized.isEmpty) {
      return null;
    }

    final barcodeCandidates = _extractBarcodeCandidates(normalized);
    debugPrint('Lookup candidates for "$normalized": $barcodeCandidates');

    for (final candidate in barcodeCandidates) {
      final result = await lookupBarcode(candidate, scannedValue: normalized);
      if (result != null) {
        return result;
      }
    }

    if (_looksLikeUrl(normalized)) {
      return lookupQRCode(normalized);
    }

    final decoded = _tryParseJson(normalized);
    if (decoded != null) {
      return _fromJsonPayload(decoded, normalized);
    }

    return null;
  }

  static Future<ProductLookupResult?> lookupBarcode(
    String barcode, {
    String? scannedValue,
  }) async {
    try {
      final result = await _lookupOpenFoodFactsV3(
        barcode,
        scannedValue: scannedValue,
      );
      if (result != null) {
        return result;
      }

      final legacyResult = await _lookupOpenFoodFactsLegacy(
        barcode,
        scannedValue: scannedValue,
      );
      if (legacyResult != null) {
        return legacyResult;
      }

      final upcItemDbResult = await _lookupUpcItemDb(
        barcode,
        scannedValue: scannedValue,
      );
      if (upcItemDbResult != null) {
        return upcItemDbResult;
      }

      return await ExternalApiService.lookupBarcode(barcode);
    } catch (e) {
      debugPrint('Barcode lookup exception for $barcode: $e');
      return null;
    }
  }

  static Future<ProductLookupResult?> _lookupOpenFoodFactsV3(
    String barcode, {
    String? scannedValue,
  }) async {
    try {
      final uri = Uri.parse(
        'https://world.openfoodfacts.net/api/v3/product/$barcode'
        '?product_type=all'
        '&fields=product_name,product_name_fr,generic_name,brands,brands_tags,'
        'categories,categories_tags,image_front_small_url,image_front_url,'
        'image_url,ingredients_text,ingredients_text_fr',
      );

      final response = await _client.get(uri, headers: _defaultHeaders);
      if (response.statusCode != 200) {
        debugPrint(
          'OpenFoodFacts v3 lookup failed for $barcode: HTTP ${response.statusCode}',
        );
        return null;
      }

      final body = json.decode(response.body) as Map<String, dynamic>;
      if (body['status'] != 'success' || body['product'] == null) {
        debugPrint('OpenFoodFacts v3 returned no product for $barcode');
        return null;
      }

      final product = body['product'] as Map<String, dynamic>;
      return _fromOpenFactsProduct(
        barcode,
        product,
        source: 'OpenFoodFacts',
        scannedValue: scannedValue,
      );
    } catch (e) {
      debugPrint('OpenFoodFacts v3 lookup exception for $barcode: $e');
      return null;
    }
  }

  static Future<ProductLookupResult?> _lookupOpenFoodFactsLegacy(
    String barcode, {
    String? scannedValue,
  }) async {
    try {
      final uri = Uri.parse(
        'https://world.openfoodfacts.org/api/v0/product/$barcode.json',
      );

      final response = await _client.get(uri, headers: _defaultHeaders);
      if (response.statusCode != 200) {
        debugPrint(
          'OpenFoodFacts legacy lookup failed for $barcode: HTTP ${response.statusCode}',
        );
        return null;
      }

      final body = json.decode(response.body) as Map<String, dynamic>;
      if (body['status'] != 1 || body['product'] == null) {
        debugPrint('OpenFoodFacts legacy returned no product for $barcode');
        return null;
      }

      final product = body['product'] as Map<String, dynamic>;
      return _fromOpenFactsProduct(
        barcode,
        product,
        source: 'OpenFoodFacts Legacy',
        scannedValue: scannedValue,
      );
    } catch (e) {
      debugPrint('OpenFoodFacts legacy lookup exception for $barcode: $e');
      return null;
    }
  }

  static Future<ProductLookupResult?> _lookupUpcItemDb(
    String barcode, {
    String? scannedValue,
  }) async {
    try {
      final uri = Uri.parse(
        'https://api.upcitemdb.com/prod/trial/lookup?upc=$barcode',
      );

      final response = await _client.get(uri, headers: _defaultHeaders);
      if (response.statusCode != 200) {
        debugPrint(
          'UPCItemDB lookup failed for $barcode: HTTP ${response.statusCode}',
        );
        return null;
      }

      final body = json.decode(response.body) as Map<String, dynamic>;
      if (body['code'] != 'OK' || body['total'] == 0) {
        debugPrint('UPCItemDB returned no product for $barcode');
        return null;
      }

      final items = body['items'] as List<dynamic>?;
      if (items == null || items.isEmpty) {
        return null;
      }

      final item = items.first as Map<String, dynamic>;
      final name = _firstNonEmptyString([item['title'], item['description']]);
      if (name == null) {
        return null;
      }

      final brand = _firstNonEmptyString([item['brand']]);
      final description = _firstNonEmptyString([
        item['description'],
        item['attributes']?.toString(),
      ]);
      final category = _firstNonEmptyString([
        item['category'],
        item['subcategory'],
      ]);
      final imageUrl = _firstNonEmptyString([
        (item['images'] as List<dynamic>?)?.cast<String?>().firstWhere(
          (url) => url != null && url.isNotEmpty,
          orElse: () => null,
        ),
      ]);

      final rawData = <String, dynamic>{
        ...item,
        if (scannedValue != null) 'scannedValue': scannedValue,
        'matchedBarcode': barcode,
      };

      return ProductLookupResult(
        name: name,
        brand: brand,
        description: description,
        category: category,
        imageUrl: imageUrl,
        source: 'UPCItemDB',
        barcode: barcode,
        rawData: rawData,
      );
    } catch (e) {
      debugPrint('UPCItemDB lookup exception for $barcode: $e');
      return null;
    }
  }

  static ProductLookupResult? _fromOpenFactsProduct(
    String barcode,
    Map<String, dynamic> product, {
    required String source,
    String? scannedValue,
  }) {
    final name = _firstNonEmptyString([
      product['product_name'],
      product['product_name_fr'],
      product['generic_name'],
    ]);
    if (name == null) {
      return null;
    }

    final brand = _cleanTaxonomyLabel(
      _firstNonEmptyString([
        product['brands'],
        _extractFirstListValue(product['brands_tags']),
      ]),
    );
    final description = _firstNonEmptyString([
      product['generic_name'],
      product['ingredients_text_fr'],
      product['ingredients_text'],
      product['categories'],
    ]);
    final category = _cleanTaxonomyLabel(
      _firstNonEmptyString([
        product['categories'],
        _extractFirstListValue(product['categories_tags']),
      ]),
    );
    final imageUrl = _firstNonEmptyString([
      product['image_front_url'],
      product['image_front_small_url'],
      product['image_url'],
    ]);

    final rawData = <String, dynamic>{
      ...product,
      if (scannedValue != null) 'scannedValue': scannedValue,
      'matchedBarcode': barcode,
    };

    return ProductLookupResult(
      name: name,
      brand: brand,
      description: description,
      category: category,
      imageUrl: imageUrl,
      source: source,
      barcode: barcode,
      rawData: rawData,
    );
  }

  static Future<ProductLookupResult?> lookupQRCode(String qrCode) async {
    try {
      final gtin = _extractGs1DigitalLinkGtin(Uri.tryParse(qrCode));
      if (gtin != null) {
        final result = await lookupBarcode(gtin, scannedValue: qrCode);
        if (result != null) {
          return result;
        }
      }

      if (_looksLikeUrl(qrCode)) {
        final uri = Uri.parse(qrCode);
        return _fetchWebMetadata(uri);
      }

      final decoded = _tryParseJson(qrCode);
      if (decoded != null) {
        return _fromJsonPayload(decoded, qrCode);
      }

      return await ExternalApiService.lookupQRCode(qrCode);
    } catch (e) {
      debugPrint('QR lookup exception for $qrCode: $e');
    }
    return null;
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

  static ProductLookupResult? _fromJsonPayload(
    Map<String, dynamic> data,
    String rawValue,
  ) {
    final name = _firstNonEmptyString([
      data['name'],
      data['productName'],
      data['title'],
    ]);
    if (name == null) {
      return null;
    }

    return ProductLookupResult(
      name: name,
      brand: _firstNonEmptyString([data['brand'], data['manufacturer']]),
      description: _firstNonEmptyString([data['description'], data['summary']]),
      category: _firstNonEmptyString([data['category'], data['type']]),
      imageUrl: _firstNonEmptyString([data['image'], data['imageUrl']]),
      source: 'QR Payload',
      barcode:
          _firstNonEmptyString([data['barcode'], data['gtin']]) ?? rawValue,
      rawData: data,
    );
  }

  static Future<ProductLookupResult?> _fetchWebMetadata(Uri uri) async {
    try {
      final response = await _client.get(
        uri,
        headers: {'User-Agent': 'BigPharma/1.0 (metadata lookup)'},
      );
      if (response.statusCode != 200) {
        return null;
      }

      final html = response.body;
      final title =
          _extractMeta(html, r'(?:og:title|twitter:title)') ??
          _extractTitle(html);
      final description = _extractMeta(
        html,
        r'(?:og:description|twitter:description|description)',
      );
      final imageUrl = _extractMeta(html, r'(?:og:image|twitter:image)');

      if (title == null || title.isEmpty) {
        return null;
      }

      return ProductLookupResult(
        name: title,
        description: description,
        imageUrl: imageUrl,
        category: uri.host,
        source: 'Web',
        barcode: uri.toString(),
        rawData: {'url': uri.toString()},
      );
    } catch (_) {
      return null;
    }
  }

  static List<String> _extractBarcodeCandidates(String raw) {
    final candidates = <String>[];

    void addCandidate(String? value) {
      if (value == null || value.isEmpty) {
        return;
      }

      final trimmed = value.trim();
      if (_looksLikeBarcode(trimmed) && !candidates.contains(trimmed)) {
        candidates.add(trimmed);
      }
    }

    void addGtinVariants(String? value) {
      if (value == null) {
        return;
      }

      addCandidate(value);

      if (value.length == 14 && value.startsWith('0')) {
        addCandidate(value.substring(1));
      } else if (value.length == 13) {
        addCandidate('0$value');
      }
    }

    final compact = raw.replaceAll(RegExp(r'\s+'), '');
    final digitsOnly = raw.replaceAll(RegExp(r'\D'), '');
    final gs1Payload = _stripGs1Prefix(raw);

    addGtinVariants(compact);
    addGtinVariants(digitsOnly);
    addGtinVariants(_extractGs1DigitalLinkGtin(Uri.tryParse(raw)));
    addGtinVariants(_extractGs1Ai01FromParenthesized(raw));
    addGtinVariants(_extractGs1Ai01FromPlain(gs1Payload));

    return candidates;
  }

  static String _stripGs1Prefix(String value) {
    return value
        .replaceAll('\u001d', '')
        .replaceAll(RegExp(r'^\](?:d2|d1|Q3|Q1|e0)'), '')
        .trim();
  }

  static String? _extractGs1Ai01FromParenthesized(String value) {
    return RegExp(r'\(01\)(\d{14})').firstMatch(value)?.group(1);
  }

  static String? _extractGs1Ai01FromPlain(String value) {
    if (value.startsWith('01') && value.length >= 16) {
      return value.substring(2, 16);
    }
    return RegExp(r'01(\d{14})').firstMatch(value)?.group(1);
  }

  static String? _extractGs1DigitalLinkGtin(Uri? uri) {
    if (uri == null) {
      return null;
    }

    final segments = uri.pathSegments;
    for (var i = 0; i < segments.length - 1; i++) {
      if (segments[i] == '01') {
        final candidate = segments[i + 1];
        if (RegExp(r'^\d{14}$').hasMatch(candidate)) {
          return candidate;
        }
      }
    }

    final queryCandidate =
        uri.queryParameters['gtin'] ?? uri.queryParameters['barcode'];
    if (queryCandidate != null &&
        RegExp(r'^\d{8,14}$').hasMatch(queryCandidate)) {
      return queryCandidate;
    }

    return null;
  }

  static bool _looksLikeUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  static bool _looksLikeBarcode(String value) {
    return RegExp(r'^\d{8,14}$').hasMatch(value);
  }

  static String? _extractTitle(String html) {
    final match = RegExp(
      r'<title[^>]*>([^<]+)<\/title>',
      caseSensitive: false,
    ).firstMatch(html);
    return match?.group(1)?.trim();
  }

  static String? _extractMeta(String html, String propertyPattern) {
    final regex = RegExp(
      '<meta[^>]+(?:property|name)=["\']$propertyPattern["\'][^>]+content=["\']([^"\']+)["\']',
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
    if (value == null || value.isEmpty) {
      return null;
    }
    final cleaned = value.replaceFirst(RegExp(r'^[a-z]{2,3}:'), '');
    return cleaned.replaceAll('-', ' ');
  }
}
