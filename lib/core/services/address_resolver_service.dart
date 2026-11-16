import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../localization/app_strings.dart';

/// Central service to resolve and format human-readable street/city addresses
/// from latitude and longitude coordinates using real reverse geocoding
/// with multi-tier fallbacks, dynamic caching, and localization support.
class AddressResolverService {
  const AddressResolverService._();

  static final Map<String, String> _cache = {};
  static final Set<String> _pending = {};
  static final ValueNotifier<int> changeNotifier = ValueNotifier<int>(0);

  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  /// Clears the address resolution cache, e.g. when changing application language.
  static void clearCache() {
    _cache.clear();
    _pending.clear();
    changeNotifier.value++;
  }

  /// Known coordinates for Cologne and North Rhine-Westphalia (NRW) construction zones.
  static final List<({double lat, double lng, String addressDe, String addressEn})>
      _knownZones = [
    (
      lat: 50.9082,
      lng: 6.9723,
      addressDe: 'Goltsteinstraße 12, 50968 Köln',
      addressEn: 'Goltsteinstraße 12, 50968 Cologne',
    ),
    (
      lat: 50.9288,
      lng: 6.9587,
      addressDe: 'Severinstraße 44, 50678 Köln',
      addressEn: 'Severinstraße 44, 50678 Cologne',
    ),
    (
      lat: 50.9455,
      lng: 6.9248,
      addressDe: 'Venloer Straße 100, 50672 Köln',
      addressEn: 'Venloer Straße 100, 50672 Cologne',
    ),
    (
      lat: 50.9295,
      lng: 6.9150,
      addressDe: 'Dürener Straße 120, 50931 Köln',
      addressEn: 'Dürener Straße 120, 50931 Cologne',
    ),
    (
      lat: 50.9385,
      lng: 6.9740,
      addressDe: 'Mindener Straße 2, 50679 Köln',
      addressEn: 'Mindener Straße 2, 50679 Cologne',
    ),
    (
      lat: 50.8932,
      lng: 6.9912,
      addressDe: 'Hauptstraße 45, 50996 Köln (Rodenkirchen)',
      addressEn: 'Hauptstraße 45, 50996 Cologne (Rodenkirchen)',
    ),
    (
      lat: 50.9375,
      lng: 6.9603,
      addressDe: 'Hohe Straße 52, 50667 Köln',
      addressEn: 'Hohe Straße 52, 50667 Cologne',
    ),
    (
      lat: 51.2277,
      lng: 6.7735,
      addressDe: 'Königsallee 10, 40212 Düsseldorf',
      addressEn: 'Königsallee 10, 40212 Düsseldorf',
    ),
    (
      lat: 50.7374,
      lng: 7.0982,
      addressDe: 'Poststraße 14, 53111 Bonn',
      addressEn: 'Poststraße 14, 53111 Bonn',
    ),
    (
      lat: 51.0459,
      lng: 7.0192,
      addressDe: 'Friedrich-Ebert-Platz 1, 51373 Leverkusen',
      addressEn: 'Friedrich-Ebert-Platz 1, 51373 Leverkusen',
    ),
  ];

  /// Asynchronously reverse geocodes latitude and longitude into a real street address.
  static Future<String> resolve(
    double lat,
    double lng, {
    String? fallbackCity,
    String? fallbackAddress,
  }) async {
    if (fallbackAddress != null && fallbackAddress.trim().isNotEmpty) {
      return fallbackAddress.trim();
    }
    if (lat == 0 && lng == 0) {
      return fallbackCity?.trim().isNotEmpty == true
          ? fallbackCity!.trim()
          : '--';
    }

    final isGerman = AppStrings.current.localeCode.toLowerCase() == 'de';
    final langKey = isGerman ? 'de' : 'en';
    final key = '${langKey}_${lat.toStringAsFixed(4)}_${lng.toStringAsFixed(4)}';

    if (_cache.containsKey(key) && !_cache[key]!.contains('(')) {
      return _cache[key]!;
    }

    // Tier 1: OpenStreetMap Nominatim reverse geocoding
    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'format': 'jsonv2',
          'lat': lat,
          'lon': lng,
          'zoom': 18,
          'addressdetails': 1,
        },
        options: Options(
          headers: {
            'User-Agent':
                'ConstructionApp/1.0 (contact@construction-app.de)',
            'Accept-Language': isGerman ? 'de,en;q=0.9' : 'en,de;q=0.9',
          },
        ),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final addressObj = data['address'];
        if (addressObj is Map<String, dynamic>) {
          final road = addressObj['road'] ??
              addressObj['pedestrian'] ??
              addressObj['street'] ??
              addressObj['suburb'] ??
              addressObj['neighbourhood'];
          final houseNumber = addressObj['house_number'] ?? '';
          final postcode = addressObj['postcode'] ?? '';
          final city = addressObj['city'] ??
              addressObj['town'] ??
              addressObj['village'] ??
              addressObj['municipality'] ??
              addressObj['county'] ??
              '';

          if (road != null && road.toString().trim().isNotEmpty) {
            final streetPart =
                '$road${houseNumber.toString().trim().isNotEmpty ? ' ${houseNumber.toString().trim()}' : ''}';
            final cityPart =
                '${postcode.toString().trim().isNotEmpty ? '${postcode.toString().trim()} ' : ''}${city.toString().trim()}';
            final formatted = [streetPart, cityPart]
                .where((s) => s.trim().isNotEmpty)
                .join(', ');

            if (formatted.isNotEmpty) {
              _cache[key] = formatted;
              changeNotifier.value++;
              return formatted;
            }
          }
        }

        final displayName = data['display_name']?.toString();
        if (displayName != null && displayName.trim().isNotEmpty) {
          final parts = displayName.split(',').map((s) => s.trim()).toList();
          final shortFormatted = parts.length > 2
              ? '${parts[0]} ${parts[1]}, ${parts[2]}'
              : displayName;
          _cache[key] = shortFormatted;
          changeNotifier.value++;
          return shortFormatted;
        }
      }
    } catch (_) {
      // Fall through to Tier 2
    }

    // Tier 2: BigDataCloud Reverse Geocode (free client API, no key required)
    try {
      final bdcResponse = await _dio.get(
        'https://api.bigdatacloud.net/data/reverse-geocode-client',
        queryParameters: {
          'latitude': lat,
          'longitude': lng,
          'localityLanguage': isGerman ? 'de' : 'en',
        },
      );
      final bdcData = bdcResponse.data;
      if (bdcData is Map<String, dynamic>) {
        final locality = bdcData['locality']?.toString() ?? '';
        final city = bdcData['city']?.toString() ?? locality;
        final postcode = bdcData['postcode']?.toString() ?? '';
        final informative = bdcData['localityInfo']?['informative'];
        String? street;
        if (informative is List && informative.isNotEmpty) {
          street = informative.first['name']?.toString();
        }

        final parts = <String>[];
        if (street != null && street.trim().isNotEmpty) {
          parts.add(street.trim());
        }
        final cityPart =
            '${postcode.trim().isNotEmpty ? '${postcode.trim()} ' : ''}${city.trim()}';
        if (cityPart.trim().isNotEmpty) parts.add(cityPart.trim());

        if (parts.isNotEmpty) {
          final formatted = parts.join(', ');
          _cache[key] = formatted;
          changeNotifier.value++;
          return formatted;
        }
      }
    } catch (_) {
      // Fall through to known zones
    }

    // Tier 3: Check proximity to known zones
    for (final zone in _knownZones) {
      final dLat = (zone.lat - lat).abs();
      final dLng = (zone.lng - lng).abs();
      if (dLat < 0.008 && dLng < 0.008) {
        final address = isGerman ? zone.addressDe : zone.addressEn;
        _cache[key] = address;
        changeNotifier.value++;
        return address;
      }
    }

    // Fallback: Formatted city with coordinates
    final city = fallbackCity?.trim().isNotEmpty == true
        ? fallbackCity!.trim()
        : AppStrings.current.cityCologne;
    final fallback =
        '$city (${lat.toStringAsFixed(3)}°, ${lng.toStringAsFixed(3)}°)';
    _cache[key] = fallback;
    return fallback;
  }

  /// Synchronously returns cached address if present, or initial proximity
  /// address while dispatching asynchronous reverse geocoding in the background.
  static String resolveSync(
    double? lat,
    double? lng, {
    String? fallbackCity,
    String? fallbackAddress,
  }) {
    if (fallbackAddress != null && fallbackAddress.trim().isNotEmpty) {
      return fallbackAddress.trim();
    }

    if (lat == null || lng == null || (lat == 0 && lng == 0)) {
      if (fallbackCity != null && fallbackCity.trim().isNotEmpty) {
        return fallbackCity.trim();
      }
      return '--';
    }

    final isGerman = AppStrings.current.localeCode.toLowerCase() == 'de';
    final langKey = isGerman ? 'de' : 'en';
    final key = '${langKey}_${lat.toStringAsFixed(4)}_${lng.toStringAsFixed(4)}';

    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }

    // Dispatch real geocoding in the background
    if (!_pending.contains(key)) {
      _pending.add(key);
      resolve(
        lat,
        lng,
        fallbackCity: fallbackCity,
        fallbackAddress: fallbackAddress,
      ).then((_) {
        _pending.remove(key);
      }).catchError((_) {
        _pending.remove(key);
      });
    }

    // Initial immediate response while geocoding request is in-flight
    for (final zone in _knownZones) {
      final dLat = (zone.lat - lat).abs();
      final dLng = (zone.lng - lng).abs();
      if (dLat < 0.008 && dLng < 0.008) {
        return isGerman ? zone.addressDe : zone.addressEn;
      }
    }

    final city = fallbackCity?.trim().isNotEmpty == true
        ? fallbackCity!.trim()
        : AppStrings.current.cityCologne;
    return '$city (${lat.toStringAsFixed(3)}°, ${lng.toStringAsFixed(3)}°)';
  }
}
