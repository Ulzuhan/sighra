# Flutter ProGuard Shield

# Keep Flutter core classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep database & shared preferences model fields
-keepattributes Signature, *Annotation*, EnclosingMethod, InnerClasses
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Keep vibration plugin classes
-keep class com.vibration.vibration.** { *; }

# Keep just_audio loop players & platform channels
-keep class com.ryanheise.just_audio.** { *; }
-keep class com.ryanheise.just_audio.AudioPlayer { *; }

# SQLite database models
-keep class com.tekartik.sqflite.** { *; }

# =====================================================================
# Google Play Billing Client & In-App Purchase Channels
# =====================================================================
-keep class com.android.billingclient.** { *; }
-keep class io.flutter.plugins.inapppurchase.** { *; }

# =====================================================================
# Google Play Core (deferred components / SplitCompat)
# Flutter's embedding references these classes even when the app does
# not use Play Store dynamic delivery. Tell R8 to ignore them.
# =====================================================================
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.android.FlutterPlayStoreSplitApplication
-dontwarn io.flutter.embedding.engine.deferredcomponents.**
