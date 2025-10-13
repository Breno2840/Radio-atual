import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android") version "2.1.0"  // <= ADICIONE A VERSÃO AQUI
    id("dev.flutter.flutter-gradle-plugin")
}

fun getSigningConfigProperties(): Properties {
    val properties = Properties()
    val propertiesFile = rootProject.file("key.properties")
    if (propertiesFile.exists()) {
        propertiesFile.inputStream().use { properties.load(it) }
    }
    return properties
}

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

    signingConfigs {
        val signingProps = getSigningConfigProperties()

        create("release") {
            if (signingProps.isNotEmpty()) {
                storeFile = rootProject.file("app/meuapp.keystore")
                storePassword = signingProps.getProperty("storePassword")
                keyAlias = signingProps.getProperty("keyAlias")
                keyPassword = signingProps.getProperty("keyPassword")
                storeType = "PKCS12"
            } else {
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
    implementation("org.jetbrains.kotlin:kotlin-stdlib:2.1.0")  // <= ATUALIZE A VERSÃO AQUI
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("com.google.android.material:material:1.12.0")
}