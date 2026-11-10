allprojects {
    repositories {
        // Optional offline mirror of this SDK's official release engine jars.
        System.getenv("CV_FLUTTER_ENGINE_MAVEN")?.let { localEngineRepo ->
            maven {
                url = uri(localEngineRepo)
                content { includeGroup("io.flutter") }
            }
        }
        google()
        mavenCentral()
    }
}

// Keep the splash generator's native plugin on the app's Android Gradle Plugin
// version (declared in settings.gradle.kts), rather than resolving a second AGP.
subprojects {
    if (name == "flutter_native_splash") {
        buildscript.configurations.configureEach {
            resolutionStrategy.force("com.android.tools.build:gradle:8.11.1")
        }
        // The application already uses API 36. Avoid installing API 35 solely
        // for this development tool's empty native library.
        afterEvaluate {
            extensions.configure<com.android.build.api.dsl.LibraryExtension> {
                compileSdk = 36
            }
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
