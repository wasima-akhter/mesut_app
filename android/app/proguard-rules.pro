# Flutter Wrapper Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Google Play Core & Deferred Components (R8 suppression for Flutter embedding)
-dontwarn com.google.android.play.core.**

# Google Play Services & Firebase
-dontwarn com.google.android.gms.**
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-keep class com.google.firebase.** { *; }

# Google Maps
-keep class com.google.android.gms.maps.** { *; }
-keep interface com.google.android.gms.maps.** { *; }

# Flutter Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# AndroidX Security / Crypto (Flutter Secure Storage)
-keep class androidx.security.crypto.** { *; }
-dontwarn androidx.security.crypto.**

# Desugar JDK Libs
-keep class j$.** { *; }

# Attributes required for reflection & serialized models
-keepattributes EnclosingMethod
-keepattributes InnerClasses
-keepattributes Signature
-keepattributes *Annotation*
