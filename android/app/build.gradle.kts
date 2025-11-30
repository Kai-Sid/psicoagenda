plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // Plugin de Google services (ya declarado con apply false en el build.gradle de raíz)
    id("com.google.gms.google-services")
    // El plugin de Flutter debe ir después
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.psicoagenda"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.psicoagenda"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("com.google.firebase:firebase-auth-ktx:23.1.0")
    implementation("com.google.firebase:firebase-firestore-ktx:25.1.0")
}
