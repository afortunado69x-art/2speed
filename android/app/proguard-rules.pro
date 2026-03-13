# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# SQLite
-keep class net.sqlcipher.** { *; }
-keep class net.sqlcipher.database.** { *; }

# File picker
-keep class com.mr.flutter.plugin.filepicker.** { *; }

# Syncfusion PDF
-keep class com.syncfusion.** { *; }

# Keep all model classes
-keep class com.grimread.speedreader.** { *; }

# Dart/Flutter reflection
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes EnclosingMethod

# Remove debug logs in release
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}
