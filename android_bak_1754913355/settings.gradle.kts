import java.util.Properties

pluginManagement {
    val props = Properties()
    val local = file("local.properties")
    if (local.exists()) local.inputStream().use { props.load(it) }
    val flutterSdk = props.getProperty("flutter.sdk")
        ?: error("flutter.sdk not set in android/local.properties")

    includeBuild("$flutterSdk/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }

    plugins {
        id("com.google.gms.google-services") version "4.4.2"
        // (AGP / Kotlin plugin versions can also live here if you need to pin them)
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader")
}
