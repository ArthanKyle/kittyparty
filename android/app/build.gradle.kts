// android/app/build.gradle.kts

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.kittyparty"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.kittyparty"
        minSdk = 23
        targetSdk = 36

        // Flutter provides these values
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        multiDexEnabled = true
    }

    /**
     * RELEASE SIGNING (Kotlin DSL)
     *
     * Option 1 (recommended): use environment variables (or gradle.properties via System.getenv not needed)
     * - KEYSTORE_FILE        e.g. C:\\path\\to\\keystore.jks  OR  keystore.jks (relative to android/app)
     * - KEYSTORE_PASSWORD
     * - KEY_ALIAS
     * - KEY_PASSWORD
     *
     * Option 2 (quick test): set signingConfig to "debug" in release buildType below.
     */
    signingConfigs {
        create("release") {
            // If KEYSTORE_FILE is not set, it will look for android/app/keystore.jks
            val ksFile = System.getenv("KEYSTORE_FILE") ?: "keystore.jks"
            storeFile = file(ksFile)

            // These must be present for a real release signing
            storePassword = System.getenv("KEYSTORE_PASSWORD")
            keyAlias = System.getenv("KEY_ALIAS")
            keyPassword = System.getenv("KEY_PASSWORD")
        }
    }

    buildTypes {
        getByName("debug") {
            // keep default debug behavior
        }

        getByName("release") {
            // Enable R8 / Proguard (Kotlin DSL syntax)
            isMinifyEnabled = true
            isShrinkResources = true

            // Use proper release signing config:
            signingConfig = signingConfigs.getByName("release")

            // QUICK TEST ONLY (uncomment if you don't have a release keystore yet)
            // signingConfig = signingConfigs.getByName("debug")

            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

tasks.withType<JavaCompile>().configureEach {
    options.compilerArgs.addAll(listOf("-Xlint:none", "-nowarn"))
}
