import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseKeystore = keystorePropertiesFile.exists()
if (hasReleaseKeystore) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

// Debug-signed release only when CI=true or -PallowDebugReleaseSigning=true.
val allowDebugReleaseSigning =
    (project.findProperty("allowDebugReleaseSigning") as String?) == "true" ||
        System.getenv("CI") == "true"

android {
    namespace = "com.arcus.arcus"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.arcus.arcus"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = when {
                hasReleaseKeystore -> signingConfigs.getByName("release")
                allowDebugReleaseSigning -> signingConfigs.getByName("debug")
                else -> null
            }
        }
    }
}

gradle.taskGraph.whenReady {
    val releasing = allTasks.any { task ->
        val n = task.name
        n.contains("Release", ignoreCase = true) &&
            (n.startsWith("assemble") || n.startsWith("bundle") || n.startsWith("package"))
    }
    if (releasing && !hasReleaseKeystore && !allowDebugReleaseSigning) {
        throw GradleException(
            """
            Missing apps/arcus/android/key.properties — refuse to ship an unsigned/debug-signed release.
            Copy android/key.properties.example → android/key.properties and point storeFile at your upload keystore.
            See docs/android/RELEASE_SIGNING.md.
            For CI-only debug-signed release artifacts, set CI=true or pass -PallowDebugReleaseSigning=true.
            """.trimIndent(),
        )
    }
    if (releasing && !hasReleaseKeystore && allowDebugReleaseSigning) {
        logger.warn(
            "WARNING: Building release with the debug keystore (CI/allowDebugReleaseSigning). Do not upload to Play Store.",
        )
    }
}

// integration_test is a Flutter dev_dependency but can appear in GeneratedPluginRegistrant.java
// and break release Java compile. Strip it before compiling release sources.
tasks.matching { it.name.startsWith("compileRelease") }.configureEach {
    doFirst {
        val registrant = file("src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java")
        if (!registrant.exists()) return@doFirst
        val original = registrant.readText()
        if (!original.contains("integration_test")) return@doFirst
        val stripped = original.replace(
            Regex(
                """\s*try \{\s*flutterEngine\.getPlugins\(\)\.add\(new dev\.flutter\.plugins\.integration_test\.IntegrationTestPlugin\(\)\);\s*\} catch \(Exception e\) \{\s*Log\.e\(TAG, "Error registering plugin integration_test,[\s\S]*?\}\s*""",
            ),
            "\n",
        )
        registrant.writeText(stripped)
        logger.lifecycle("Stripped integration_test from GeneratedPluginRegistrant for release.")
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
