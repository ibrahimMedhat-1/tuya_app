allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://github.com/Kotlin/kotlinx.serialization/releases") }
        maven { url = uri("https://maven-other.tuya.com/repository/maven-releases/") }
        maven { url = uri("https://maven.aliyun.com/repository/public") }
        maven { url = uri("https://oss.sonatype.org/content/repositories/snapshots/") }
        maven { url = uri("https://maven-other.tuya.com/repository/maven-commercial-releases/") }
        maven { url =uri("https://maven-other.tuya.com/repository/maven-releases/") }
        maven { url =uri("https://maven-other.tuya.com/repository/maven-commercial-releases/") }

        maven { url = uri("https://jitpack.io") }
        maven { url = uri("https://maven-other.tuya.com/repository/maven-snapshots/") }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    configurations.all {
        exclude(group = "com.thingclips.smart", module = "thingplugin-annotation")
        exclude(group = "com.thingclips.android.module", module = "thingmodule-annotation")
        exclude(group = "com.thingclips.smart", module = "thingsmart-modularCampAnno")
        exclude(group = "com.squareup.okhttp3", module = "okhttp-jvm")
        exclude(group = "commons-io", module = "commons-io")
        resolutionStrategy.cacheChangingModulesFor(0, "seconds")
        resolutionStrategy {
            force("com.squareup.okhttp3:okhttp:4.12.0")
            force("commons-io:commons-io:2.11.0")
        }
    }
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
