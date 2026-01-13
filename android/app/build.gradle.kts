import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// key.properties faylini o'qish
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

android {
    namespace = "com.kliro.app"
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
        applicationId = "com.kliro.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Release build uchun signing config
            if (keystorePropertiesFile.exists()) {
                signingConfig = signingConfigs.getByName("release")
            } else {
                // Agar key.properties yo'q bo'lsa, debug signing ishlatiladi
                signingConfig = signingConfigs.getByName("debug")
            }
            // Code shrinking va optimization - release build uchun yoqilgan
            isMinifyEnabled = true
            isShrinkResources = true
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

// Media permissionlarni merged manifest'dan olib tashlash
afterEvaluate {
    // Helper funksiya: manifest faylini tozalash
    fun cleanManifestFile(manifestFile: java.io.File, permissionsToRemove: List<String>): Boolean {
        if (!manifestFile.exists()) return false
        
        var content = manifestFile.readText()
        val originalContent = content
        
        permissionsToRemove.forEach { permission ->
            // Barcha variantlarni olib tashlash (single tag va paired tag)
            content = content.replace(
                Regex("<uses-permission[^>]*android\\.permission\\.$permission[^>]*/>", RegexOption.IGNORE_CASE),
                ""
            )
            content = content.replace(
                Regex("<uses-permission[^>]*android\\.permission\\.$permission[^>]*>\\s*</uses-permission>", RegexOption.IGNORE_CASE),
                ""
            )
        }
        
        if (content != originalContent) {
            manifestFile.writeText(content)
            println("✅ Media permissions removed from: ${manifestFile.absolutePath}")
            return true
        }
        return false
    }
    
    // Release build uchun - bundle jarayonidan oldin barcha manifest'larni tozalash
    tasks.named("bundleRelease").configure {
        doFirst {
            val permissionsToRemove = listOf(
                "READ_MEDIA_IMAGES",
                "READ_MEDIA_VIDEO",
                "READ_MEDIA_VISUAL_USER_SELECTED",
                "READ_MEDIA_AUDIO"
            )
            
            // Barcha mumkin bo'lgan manifest fayllarni topish
            val manifestDirs = listOf(
                file("${buildDir}/intermediates/merged_manifests/release"),
                file("${buildDir}/intermediates/packaged_manifests/release"),
                file("${buildDir}/intermediates/bundle_manifest/release"),
                file("${buildDir}/intermediates/merged_manifests/release/processReleaseManifest"),
                file("${buildDir}/generated/res/resValues/release")
            )
            
            var cleanedCount = 0
            manifestDirs.forEach { dir ->
                if (dir.exists() && dir.isDirectory) {
                    dir.walkTopDown().forEach { file ->
                        if (file.name == "AndroidManifest.xml" && file.isFile) {
                            if (cleanManifestFile(file, permissionsToRemove)) {
                                cleanedCount++
                            }
                        }
                    }
                }
            }
            
            // To'g'ridan-to'g'ri fayl path'larni ham tekshirish
            val directPaths = listOf(
                file("${buildDir}/intermediates/merged_manifests/release/AndroidManifest.xml"),
                file("${buildDir}/intermediates/packaged_manifests/release/AndroidManifest.xml")
            )
            
            directPaths.forEach { manifestFile ->
                if (cleanManifestFile(manifestFile, permissionsToRemove)) {
                    cleanedCount++
                }
            }
            
            if (cleanedCount > 0) {
                println("✅ Total $cleanedCount manifest file(s) cleaned")
            }
        }
    }
    
    // processReleaseManifest task uchun ham
    tasks.named("processReleaseManifest").configure {
        doLast {
            val permissionsToRemove = listOf(
                "READ_MEDIA_IMAGES",
                "READ_MEDIA_VIDEO",
                "READ_MEDIA_VISUAL_USER_SELECTED",
                "READ_MEDIA_AUDIO"
            )
            
            val manifestFile = file("${buildDir}/intermediates/merged_manifests/release/AndroidManifest.xml")
            cleanManifestFile(manifestFile, permissionsToRemove)
        }
    }
    
    // Debug build uchun ham
    tasks.named("processDebugManifest").configure {
        doLast {
            val permissionsToRemove = listOf(
                "READ_MEDIA_IMAGES",
                "READ_MEDIA_VIDEO",
                "READ_MEDIA_VISUAL_USER_SELECTED",
                "READ_MEDIA_AUDIO"
            )
            
            val manifestFile = file("${buildDir}/intermediates/merged_manifests/debug/AndroidManifest.xml")
            cleanManifestFile(manifestFile, permissionsToRemove)
        }
    }
    
    // Windows'da assets fayllarini nusxalash muammosini hal qilish uchun
    // Build dan oldin flutter_assets papkasini tozalash
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