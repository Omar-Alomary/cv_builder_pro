# Flutter engine entry points invoked through JNI and plugin registration.
-keep class io.flutter.embedding.engine.FlutterJNI { *; }
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }
-keepclasseswithmembernames,includedescriptorclasses class * {
    native <methods>;
}

# Google Android SDK parcel entry points, if supplied by a native dependency.
# Other Google SDK internals use the consumer rules shipped with their libraries.
-keepclassmembers class com.google.android.gms.** implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator CREATOR;
}

# Native PDF printing callbacks and WebView JavaScript bridge entry points.
-keep class net.nfet.flutter.printing.** { *; }
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# GetX, the Dart pdf package, ATS and JSON models are compiled as Dart AOT.
# R8 does not process Dart classes. They are protected by --obfuscate, while
# --split-debug-info stores the matching Dart symbols outside the APK.
# Do not suppress missing-class errors or disable shrinking globally.
