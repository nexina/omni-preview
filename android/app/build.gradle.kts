import java.util.Properties
import java.io.File

val envProperties = Properties()
val envFile = File(rootProject.projectDir.parentFile, ".env")
if (!envFile.exists()) {
    throw GradleException(".env file not found in project root!")
}
envFile.reader().useLines { lines ->
    lines.forEach { line ->
        val trimmed = line.trim()
        if (trimmed.isNotEmpty() && !trimmed.startsWith("#") && "=" in trimmed) {
            val (key, value) = trimmed.split("=", limit = 2)
            envProperties.setProperty(key.trim(), value.trim())
        }
    }
}

// Extract typed values
val keyAliasValue = envProperties.getProperty("KEY_ALIAS")
    ?: throw GradleException("KEY_ALIAS not found in .env")
val keyPasswordValue = envProperties.getProperty("KEY_PASSWORD")
    ?: throw GradleException("KEY_PASSWORD not found in .env")
val storePasswordValue = envProperties.getProperty("STORE_PASSWORD")
    ?: throw GradleException("STORE_PASSWORD not found in .env")
val storeFileValue = envProperties.getProperty("STORE_FILE")
    ?: throw GradleException("STORE_FILE not found in .env")
    
plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "nexina.omni.preview"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget =  JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "nexina.omni.preview"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keyAliasValue
            keyPassword = keyPasswordValue
            storeFile = file(storeFileValue)
            storePassword = storePasswordValue
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}
