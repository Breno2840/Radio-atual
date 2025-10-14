pluginManagement {
    includeBuild("../flutter_modules/flutter_plugin_loader")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.2.0" apply false
    id("org.jetbrains.kotlin.android") version "1.9.22" apply false
}

include(":app")
// A LINHA MAIS IMPORTANTE QUE FALTAVA:
includeBuild("../flutter_modules/flutter_engine")
