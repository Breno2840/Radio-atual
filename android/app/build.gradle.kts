// android/app/build.gradle.kts (Kotlin DSL)

import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// --- FUNÇÃO AUXILIAR PARA LER PROPRIEDADES DE ARQUIVOS ---
fun getSigningConfigProperties(): Properties {
    val properties = Properties()
    // Busca o arquivo key.properties na pasta 'android/' (criado pelo CI/CD)
    val propertiesFile = rootProject.file("key.properties")
    if (propertiesFile.exists()) {
        propertiesFile.inputStream().use { properties.load(it) }
    }
    return properties
}

// --- LEITURA DAS PROPRIEDADES DO local.properties ---
val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localProperties.load(FileInputStream(localPropertiesFile))
}

val flutterVersionCode = localProperties.getProperty("flutter.versionCode", "1")!!
val flutterVersionName = localProperties.getProperty("flutter.versionName", "1.0")!!

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

    // --- CONFIGURAÇÃO DE ASSINATURA (SIGNING CONFIG) ---
    signingConfigs {
        val signingProps = getSigningConfigProperties()

        create("release") {
            if (signingProps.isNotEmpty()) {
                // Usado no CI/CD (GitHub Actions)
                storeFile = rootProject.file("app/upload-keystore.jks")
                keyAlias = signingProps.getProperty("keyAlias")
                storePassword = signingProps.getProperty("storePassword")
                keyPassword = signingProps.getProperty("keyPassword")
            } else {
                // Fallback para ambiente local (debug)
                keyAlias = "androiddebugkey"
                storePassword = "android"
                keyPassword = "android"
                storeFile = rootProject.file("../.android/debug.keystore")
            }
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
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