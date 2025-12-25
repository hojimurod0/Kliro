plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.klero"
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
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.klero"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// Windows'da assets fayllarini nusxalash muammosini hal qilish uchun
// Build dan oldin flutter_assets papkasini tozalash
afterEvaluate {
    tasks.findByName("compileFlutterBuildDebug")?.let { task ->
        val cleanTask = tasks.register<Delete>("cleanFlutterAssetsDebug") {
            description = "Clean Flutter debug assets before build to prevent Windows file copy errors"
            val assetsDir = file("${project.buildDir}/intermediates/flutter/debug/flutter_assets")
            delete(assetsDir)
            doFirst {
                if (assetsDir.exists()) {
                    println("🧹 Cleaning Flutter debug assets directory: ${assetsDir.absolutePath}")
                }
            }
        }
        task.dependsOn(cleanTask)
    }
    
    tasks.findByName("compileFlutterBuildRelease")?.let { task ->
        val cleanTask = tasks.register<Delete>("cleanFlutterAssetsRelease") {
            description = "Clean Flutter release assets before build to prevent Windows file copy errors"
            val assetsDir = file("${project.buildDir}/intermediates/flutter/release/flutter_assets")
            delete(assetsDir)
            doFirst {
                if (assetsDir.exists()) {
                    println("🧹 Cleaning Flutter release assets directory: ${assetsDir.absolutePath}")
                }
            }
        }
        task.dependsOn(cleanTask)
    }
}