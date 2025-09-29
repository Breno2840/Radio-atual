// android/app/build.gradle.kts (Kotlin DSL)

import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localProperties.load(FileInputStream(localPropertiesFile))
}

val flutterVersionCode = localProperties.getProperty("flutter.versionCode", "1")!!
val flutterVersionName = localProperties.getProperty("flutter.versionName", "1.0")!!

// INÍCIO DA CONFIGURAÇÃO DE ASSINATURA:
val signingProperties = Properties()
val signingPropertiesFile = rootProject.file("key.properties")
if (signingPropertiesFile.exists()) {
    signingProperties.load(FileInputStream(signingPropertiesFile))
}

android {
    namespace = "com.breno.radioapp"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    sourceSets["main"].java.srcDirs("src/main/kotlin")

    defaultConfig {
        applicationId = "com.breno.radioapp"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutterVersionCode.toInt()
        versionName = flutterVersionName
    }

    // CRUCIAL: Configuração da Assinatura (Signing Config)
    signingConfigs {
        create("release") {
            // O nome do arquivo Keystore que o GitHub Actions cria
            storeFile = file(signingProperties.getProperty("storeFile") ?: "upload-keystore.jks")
            
            // Tenta obter a propriedade do key.properties. SE NÃO EXISTIR (CI/CD), usa a variável de ambiente
            keyAlias = signingProperties.getProperty("keyAlias") ?: System.getenv("KEY_ALIAS")
            storePassword = signingProperties.getProperty("storePassword") ?: System.getenv("STORE_PASS")
            keyPassword = signingProperties.getProperty("keyPassword") ?: System.getenv("KEY_PASS")
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            // CORREÇÃO: Aponta para a configuração de assinatura de Release
            signingConfig = signingConfigs.getByName("release") 
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.24")
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("com.google.android.material:material:1.12.0")
}
