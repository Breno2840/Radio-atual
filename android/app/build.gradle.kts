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
    // Busca o arquivo key.properties que o CI/CD cria na pasta 'android/'
    val propertiesFile = project.rootProject.file("android/key.properties")
    if (propertiesFile.exists()) {
        propertiesFile.inputStream().use { properties.load(it) }
    }
    return properties
}

// --- LEITURA DAS PROPRIEDADES LOCAL.PROPERTIES ---
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
        // Obter as propriedades que foram injetadas no key.properties pelo CI/CD
        val signingProps = getSigningConfigProperties()

        create("release") {
            // Verifica se o arquivo key.properties foi carregado (indicando CI/CD)
            if (signingProps.isNotEmpty()) {
                // Configuração usada APENAS no CI/CD:
                // storeFile é o arquivo que o workflow decodifica e salva em android/app/
                storeFile = file("android/app/" + signingProps.getProperty("storeFile", "upload-keystore.jks"))
                keyAlias = signingProps.getProperty("keyAlias")
                storePassword = signingProps.getProperty("storePassword")
                keyPassword = signingProps.getProperty("keyPassword")
            } else {
                // Configuração de fallback para o ambiente de debug/desenvolvimento local
                // Você pode usar uma chave de debug padrão aqui
                keyAlias = "androiddebugkey" 
                storePassword = "android"
                keyPassword = "android"
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
            // CRUCIAL: Aplica a configuração de assinatura 'release' que acabamos de definir
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
