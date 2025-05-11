pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }

    resolutionStrategy {
        eachPlugin {
            when (requested.id.id) {
                "com.android.application" -> 
                    useModule("com.android.tools.build:gradle:8.1.0")
                "com.google.gms.google-services" -> 
                    useModule("com.google.gms:google-services:4.4.2")
                "org.jetbrains.kotlin.android" -> 
                    useModule("org.jetbrains.kotlin:kotlin-gradle-plugin:2.0.0")
                "dev.flutter.flutter-plugin-loader" ->
                    useModule("dev.flutter:flutter-gradle-plugin:1.0.0")
            }
        }
    }


}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.1.0" apply false
    id("org.jetbrains.kotlin.android") version "2.0.0" apply false
}

include(":app")
