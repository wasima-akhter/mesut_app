# Flutter Multilingual Integration Guide  
### Parent App & Teacher App (Aula 360)

This is the **canonical, Flutter-only** step-by-step guide for integrating English (`en`) and Spanish (`es`) in the mobile apps.

Related docs:
- [Parent App API Guide](PARENT_APP_API_GUIDE.md)
- [Teacher App API Guide](TEACHER_APP_API_GUIDE.md)
- [Multilingual overview (shared contract)](MULTILINGUAL_INTEGRATION_GUIDE.md)

---

## Table of contents

1. [What Flutter owns vs what the backend owns](#1-what-flutter-owns-vs-what-the-backend-owns)
2. [Architecture](#2-architecture)
3. [Locale contract](#3-locale-contract)
4. [API response shapes](#4-api-response-shapes)
5. [Step-by-step integration](#5-step-by-step-integration)
6. [Folder structure recommendation](#6-folder-structure-recommendation)
7. [Models & parsing](#7-models--parsing)
8. [UI: badges, lists, details](#8-ui-badges-lists-details)
9. [Language switch flow](#9-language-switch-flow)
10. [PENDING polling](#10-pending-polling)
11. [Which screens / fields are localized](#11-which-screens--fields-are-localized)
12. [Writes (create / update)](#12-writes-create--update)
13. [Socket / push messages](#13-socket--push-messages)
14. [Testing checklist](#14-testing-checklist)
15. [Common mistakes](#15-common-mistakes)
16. [QA acceptance criteria](#16-qa-acceptance-criteria)

---

## 1. What Flutter owns vs what the backend owns

| Concern | Owner | How |
| :--- | :--- | :--- |
| Buttons, tabs, labels, empty states, validation copy | **Flutter** | ARB / `easy_localization` / `flutter_localizations` |
| Names, titles, bodies, homework text, report text, fee titles, chat body | **Backend on read** | API returns already-localized strings for `x-locale` |
| Persist user language preference | **Backend** | `POST /api/v1/settings/language` |
| Machine translation + cache | **Backend worker** | BullMQ + PostgreSQL `Translation` table |
| Client-side Google Translate / ML Kit for DB fields | **Forbidden** | Never |

**Rule:** Flutter **displays** API text. Flutter **does not** translate database content.

---

## 2. Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Flutter App                             │
│  ┌──────────────────┐    ┌───────────────────────────────┐  │
│  │ UI chrome (ARB)  │    │ Domain models + screens       │  │
│  │ en / es strings  │    │ Render API fields as-is       │  │
│  └────────┬─────────┘    └──────────────▲────────────────┘  │
│           │                             │                   │
│  ┌────────▼─────────┐    ┌──────────────┴────────────────┐  │
│  │ LocaleController │───▶│ Dio + LocaleInterceptor       │  │
│  │ (en | es)        │    │ x-locale + Accept-Language    │  │
│  └──────────────────┘    └──────────────┬────────────────┘  │
└─────────────────────────────────────────┼───────────────────┘
                                          │ HTTPS
                                          ▼
┌─────────────────────────────────────────────────────────────┐
│ Server (producer)                                           │
│  Resolve locale → localizeFields / getOrTranslateContent    │
│  READY → return translated text                             │
│  miss  → return source text + PENDING + enqueue job         │
└──────────────────────────────┬──────────────────────────────┘
                               │ BullMQ (Redis/Valkey)
                               ▼
┌─────────────────────────────────────────────────────────────┐
│ Worker (consumer)                                           │
│  process-translation → Google/mock MT → Translation READY   │
└─────────────────────────────────────────────────────────────┘
```

**Important ops note:** If the `worker` container is not running, every item stays `PENDING` forever. Flutter must still show the original text (non-blocking).

---

## 3. Locale contract

Supported values: `en`, `es` (lowercase in headers).

### Header precedence on the server

| Priority | Source | Example |
| :---: | :--- | :--- |
| 1 | `x-locale` | `x-locale: es` |
| 2 | Query `locale` / `lang` | `?locale=es` |
| 3 | Saved user preference | `EN` / `ES` in settings |
| 4 | `Accept-Language` | `es;q=1.0,en;q=0.5` |
| 5 | Default | `en` |

### Flutter must send on **every** request

```http
x-locale: es
Accept-Language: es;q=1.0,en;q=0.5
Authorization: Bearer <access_token>
Accept: application/json
```

`x-locale` is the source of truth for **what language the API should return**.

---

## 4. API response shapes

Backend may send metadata in **either** form. Flutter must parse both.

### A) Flat (announcements / some feeds)

```json
{
  "id": "…",
  "title": "Reunión importante",
  "body": "…",
  "sourceLocale": "en",
  "displayedLocale": "es",
  "isTranslated": true,
  "translationStatus": "READY"
}
```

### B) Nested `localization` (most entity DTOs)

```json
{
  "id": "…",
  "fullName": "Niño 8",
  "gradeLevel": "Grado 5",
  "localization": {
    "sourceLocale": "en",
    "displayedLocale": "es",
    "isTranslated": true,
    "translationStatus": "READY"
  }
}
```

### `translationStatus` values

| Status | Meaning | Flutter UI |
| :--- | :--- | :--- |
| `READY` | Cache hit / same locale | Show text normally |
| `PENDING` | Worker translating | Show returned text + “Translating…” badge; optional poll |
| `PROCESSING` | Worker in progress | Same as `PENDING` |
| `STALE` | Source edited; new job queued | Show current text |
| `FAILED` | Provider error | Show returned (source) text; optional error badge |

Standard envelope (all APIs):

```json
{
  "success": true,
  "message": "…",
  "data": { },
  "meta": { },
  "traceId": "…"
}
```

---

## 5. Step-by-step integration

### Step 0 — Prerequisites

- Base URL from Parent/Teacher API guides (e.g. `https://alua.localbox.online/api/v1`)
- Auth already working (`Authorization: Bearer …`)
- Confirm backend `worker` is up in the environment you hit

### Step 1 — Add UI localization packages

Recommended stack (team may already use equivalents):

```yaml
# pubspec.yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  easy_localization: ^3.0.7   # or flutter_intl / slang — pick one and stick to it
  dio: ^5.0.0
  shared_preferences: ^2.2.0
```

Create ARB (or JSON) catalogs for **UI chrome only**:

```
assets/translations/en.json
assets/translations/es.json
```

Example keys: `common.save`, `tabs.home`, `empty.noChildren`, `translation.translating`.

### Step 2 — Single source of truth for app locale

```dart
// lib/core/locale/app_locale.dart
enum AppLocale {
  en,
  es;

  String get code => name; // 'en' | 'es'

  static AppLocale parse(String? raw) {
    final v = (raw ?? 'en').toLowerCase();
    return v.startsWith('es') ? AppLocale.es : AppLocale.en;
  }
}
```

```dart
// lib/core/locale/locale_controller.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_locale.dart';

class LocaleController extends ChangeNotifier {
  static const _prefsKey = 'app_locale';
  AppLocale _locale = AppLocale.en;

  AppLocale get locale => _locale;
  String get code => _locale.code;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _locale = AppLocale.parse(prefs.getString(_prefsKey));
    notifyListeners();
  }

  /// Updates local UI + persistence. Call API sync separately (Step 7).
  Future<void> setLocale(AppLocale next) async {
    if (next == _locale) return;
    _locale = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, next.code);
    notifyListeners();
  }
}
```

Wire `LocaleController` at app root (Provider / Riverpod / Bloc — match existing app architecture).

### Step 3 — Dio `LocaleInterceptor` (mandatory)

```dart
// lib/core/network/locale_interceptor.dart
import 'package:dio/dio.dart';

class LocaleInterceptor extends Interceptor {
  LocaleInterceptor(this._getLocaleCode);

  final String Function() _getLocaleCode;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final locale = _getLocaleCode(); // 'en' | 'es'
    options.headers['x-locale'] = locale;
    options.headers['Accept-Language'] = '$locale;q=1.0,en;q=0.5';
    handler.next(options);
  }
}
```

Register once when creating Dio:

```dart
dio.interceptors.add(
  LocaleInterceptor(() => localeController.code),
);
```

**Do not** forget refresh-token / retry clients — they must reuse the same Dio (or same interceptor).

### Step 4 — Shared `LocalizationMeta` parser

```dart
// lib/core/localization/localization_meta.dart
class LocalizationMeta {
  const LocalizationMeta({
    required this.sourceLocale,
    required this.displayedLocale,
    required this.isTranslated,
    required this.translationStatus,
  });

  final String sourceLocale;
  final String displayedLocale;
  final bool isTranslated;
  final String translationStatus;

  bool get isPending =>
      translationStatus == 'PENDING' || translationStatus == 'PROCESSING';

  bool get showTranslatedBadge =>
      isTranslated &&
      sourceLocale.toLowerCase() != displayedLocale.toLowerCase() &&
      !isPending;

  /// Supports flat announcement fields OR nested `localization`.
  static LocalizationMeta? tryParse(Map<String, dynamic>? json) {
    if (json == null) return null;

    final nested = json['localization'];
    final Map<String, dynamic> src =
        nested is Map<String, dynamic> ? Map<String, dynamic>.from(nested) : json;

    final source = src['sourceLocale'] as String?;
    final displayed = src['displayedLocale'] as String?;
    final status = src['translationStatus'] as String?;
    if (source == null || displayed == null || status == null) return null;

    return LocalizationMeta(
      sourceLocale: source.toLowerCase(),
      displayedLocale: displayed.toLowerCase(),
      isTranslated: src['isTranslated'] as bool? ?? false,
      translationStatus: status.toUpperCase(),
    );
  }
}
```

### Step 5 — Attach meta on every localized model

Example — child:

```dart
class ChildModel {
  ChildModel({
    required this.id,
    required this.fullName,
    required this.gradeLevel,
    this.localization,
  });

  final String id;
  final String fullName;
  final String? gradeLevel;
  final LocalizationMeta? localization;

  factory ChildModel.fromJson(Map<String, dynamic> json) {
    return ChildModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String? ?? '',
      gradeLevel: json['gradeLevel'] as String?,
      localization: LocalizationMeta.tryParse(json),
    );
  }
}
```

Repeat for: announcements, homework, teachers, reports, invoices/fees, messages, session details, notes.

### Step 6 — Render API text as-is

```dart
Text(child.fullName)           // ✅ from API
Text(context.tr('tabs.home'))  // ✅ from ARB
Text(translateLocally(apiTitle)) // ❌ forbidden for DB content
```

### Step 7 — Persist language preference

Parent & Teacher apps:

```http
POST /api/v1/settings/language
Content-Type: application/json
Authorization: Bearer …
x-locale: es

{ "language": "ES" }
```

Body uses uppercase `EN` | `ES` (see Parent/Teacher API guides).

### Step 8 — On language change, refetch everything

Order matters:

1. `await localeController.setLocale(AppLocale.es)` — updates interceptor **before** next HTTP call  
2. Update Flutter UI localization (`easy_localization.setLocale` / equivalent)  
3. `POST /settings/language`  
4. Clear Dio / repository / Riverpod / Bloc caches  
5. Invalidate and refetch active screens (children, announcements, homework, …)

If you update the UI locale but forget step 4–5, lists stay in the previous language until restart.

---

## 6. Folder structure recommendation

```
lib/
  core/
    locale/
      app_locale.dart
      locale_controller.dart
    localization/
      localization_meta.dart
      translation_badge.dart
    network/
      api_client.dart
      locale_interceptor.dart
  features/
    settings/
      presentation/language_settings_page.dart
      data/language_api.dart
    children/
      data/models/child_model.dart
      …
  l10n/ or assets/translations/
    en.json
    es.json
```

Keep localization helpers in `core/` so Parent and Teacher apps (or shared package) stay consistent.

---

## 7. Models & parsing

### Envelope helper

```dart
T unwrapData<T>(Response response, T Function(dynamic raw) map) {
  final body = response.data as Map<String, dynamic>;
  if (body['success'] != true) {
    throw DioException(
      requestOptions: response.requestOptions,
      message: body['message']?.toString() ?? 'Request failed',
    );
  }
  return map(body['data']);
}
```

### List with pending detection

```dart
bool anyPending(Iterable<LocalizationMeta?> metas) =>
    metas.any((m) => m?.isPending == true);
```

Use this to decide whether a screen should poll (Section 10).

---

## 8. UI: badges, lists, details

### Reusable badge widget

```dart
// lib/core/localization/translation_badge.dart
import 'package:flutter/material.dart';
import 'localization_meta.dart';

class TranslationBadge extends StatelessWidget {
  const TranslationBadge({super.key, required this.meta});

  final LocalizationMeta? meta;

  @override
  Widget build(BuildContext context) {
    final m = meta;
    if (m == null) return const SizedBox.shrink();

    if (m.isPending) {
      return _chip(
        color: Colors.amber.shade100,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.amber.shade900,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              // Prefer ARB: context.tr('translation.translating')
              'Translating…',
              style: TextStyle(fontSize: 11, color: Colors.amber.shade900),
            ),
          ],
        ),
      );
    }

    if (m.showTranslatedBadge) {
      return _chip(
        color: Colors.blue.shade50,
        child: Text(
          '${m.sourceLocale.toUpperCase()} → ${m.displayedLocale.toUpperCase()}',
          style: TextStyle(fontSize: 11, color: Colors.blue.shade800),
        ),
      );
    }

    if (m.translationStatus == 'FAILED') {
      return _chip(
        color: Colors.red.shade50,
        child: Text(
          'Translation unavailable',
          style: TextStyle(fontSize: 11, color: Colors.red.shade800),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _chip({required Color color, required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: child,
    );
  }
}
```

### List tile pattern

```dart
ListTile(
  title: Row(
    children: [
      Expanded(child: Text(child.fullName)),
      TranslationBadge(meta: child.localization),
    ],
  ),
  subtitle: Text(child.gradeLevel ?? '—'),
);
```

**Never** hide content while `PENDING`. Always show the string the API returned.

---

## 9. Language switch flow

```dart
Future<void> changeLanguage({
  required AppLocale next,
  required LocaleController localeController,
  required Future<void> Function(Locale) setUiLocale,
  required Future<void> Function(String code) persistOnServer,
  required Future<void> Function() clearCachesAndRefetch,
}) async {
  // 1) Local first so next Dio calls carry the new x-locale
  await localeController.setLocale(next);
  await setUiLocale(Locale(next.code));

  // 2) Persist preference (uppercase EN/ES)
  try {
    await persistOnServer(next.code.toUpperCase());
  } catch (_) {
    // Show toast; still keep local locale so UI matches user intent
  }

  // 3) Drop stale EN/ES payloads
  await clearCachesAndRefetch();
}
```

Settings UI: a simple segmented control / dropdown `English | Español` that calls `changeLanguage`.

On cold start:

1. `localeController.load()` from `SharedPreferences`
2. Optionally `GET /settings` and reconcile if server preference differs
3. Apply UI locale before first authenticated fetch

---

## 10. PENDING polling

Optional but recommended for list/detail screens that show badges.

```dart
class PendingRefetchController {
  Timer? _timer;

  void sync({
    required bool hasPending,
    required VoidCallback refetch,
    Duration interval = const Duration(seconds: 3),
  }) {
    if (!hasPending) {
      _timer?.cancel();
      _timer = null;
      return;
    }
    _timer ??= Timer.periodic(interval, (_) => refetch());
  }

  void dispose() {
    _timer?.cancel();
  }
}
```

Rules:
- Poll only while the **current screen** has pending items
- Stop when all `READY` / `FAILED` or user leaves the screen
- Do **not** block navigation or show a full-screen loader for PENDING

---

## 11. Which screens / fields are localized

### Parent app (typical)

| Screen / API area | Localized fields |
| :--- | :--- |
| Announcements | `title`, `body` |
| Children list/detail | `fullName`, `gradeLevel` |
| Child reports | report text, subject/teacher/cohort display names |
| Homework | `title`, `description` |
| Teachers list | `fullName`, `designation`, `bio` |
| Invoices / fees | fee title, student name when present |
| Legal | `content` |
| Chat | message `body`, participant display name |

### Teacher app (typical)

| Screen / API area | Localized fields |
| :--- | :--- |
| Announcements | `title`, `body` |
| My students | `fullName`, `gradeLevel` |
| Student detail | student fields + note text + latest report text |
| Reports list/detail | report text + cohort/subject names |
| Session detail | roster names + report text |
| Homework | `title`, `description` |
| Chat | same as parent |

### Never expect translation for

IDs, emails, phones, URLs, dates/times, amounts, currencies, status enums (`ACTIVE`, `PAID`, …), enrollment numbers, avatar URLs.

Proper names (e.g. “Abdullah”) may look unchanged after MT — that is normal.

---

## 12. Writes (create / update)

When the app **creates** content (message, note, etc.):

- Send the user’s text in the language they typed
- Do **not** pre-translate before POST
- Optional: send `sourceLocale` if the specific endpoint documents it (e.g. announcements)
- On next GET with another `x-locale`, backend returns localized text (or PENDING)

---

## 13. Socket / push messages

- **Push notification title/body**: backend should already respect user language preference when sending; display payload text as received
- **Socket `new_message`**: body may arrive in source language; either:
  - show as received, or
  - refetch the conversation thread with current `x-locale` after insert
- Always keep `x-locale` on HTTP; sockets do not replace the locale header contract for REST

---

## 14. Testing checklist

### Manual

1. Login as parent → set Español → confirm Network tab shows `x-locale: es` on every call  
2. Children list: names either Spanish/`[ES]…` (mock) or PENDING badge → then READY after worker  
3. Switch back to English → lists refetch to English  
4. Airplane mode during PENDING → UI still shows original text (no blank cards)  
5. Teacher app: same checks on students + reports + homework  
6. Kill worker in staging → PENDING persists; app remains usable  

### Automated (suggested)

- Unit: `LocalizationMeta.tryParse` for flat + nested + missing  
- Unit: interceptor sets headers from `LocaleController`  
- Golden/widget: badge visible when `PENDING`  
- Integration: language change triggers cache clear (mock Dio)

---

## 15. Common mistakes

| Mistake | Result |
| :--- | :--- |
| No `x-locale` header | Wrong/default language from preference or `en` |
| UI locale changed but API cache not cleared | Mixed EN/ES screens |
| Client-side MT of API fields | Double translation / drift from admin |
| Blocking spinner on PENDING | Feels broken; violates contract |
| Parsing only flat meta | Nested `localization` ignored → no badges |
| Worker not running | Endless “Translating…” |
| Sending `language: "es"` instead of `"ES"` on settings | 422 / ignored (follow API guide) |

---

## 16. QA acceptance criteria

- [ ] Every authenticated request includes `x-locale` and `Accept-Language`  
- [ ] UI chrome fully localized via ARB for `en` and `es`  
- [ ] Dynamic lists show API text for active locale without client MT  
- [ ] PENDING shows content + badge; READY updates after poll/refetch  
- [ ] Language switch updates UI + server preference + refetched data  
- [ ] Parent and Teacher apps behave the same on the shared contract  
- [ ] Offline / FAILED never blanks the screen  

---

## Quick reference — copy/paste for PR description

```text
Flutter multilingual integration
- Dio LocaleInterceptor: x-locale + Accept-Language
- LocalizationMeta.tryParse (flat + nested)
- TranslationBadge for PENDING / translated
- POST /settings/language on switch
- Clear caches + refetch after switch
- No client-side MT for DB fields
```

For endpoint paths and payloads, always prefer the Parent/Teacher API guides over this document when they diverge; this guide defines **how** Flutter integrates with the multilingual system, not every REST field.
