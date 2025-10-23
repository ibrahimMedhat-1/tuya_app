allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://maven-other.tuya.com/repository/maven-releases/") }
        maven { url = uri("https://maven-other.tuya.com/repository/maven-commercial-releases/") }
        maven { url = uri("https://jitpack.io") }
        // Add JCenter mirror for old dependencies
        maven { url = uri("https://maven.aliyun.com/repository/jcenter") }
    }
    
    // Global dependency resolution strategy - excludes conflicting libraries
    configurations.all {
        resolutionStrategy {
            force("com.google.code.findbugs:jsr305:1.3.9")
            force("com.squareup.okhttp3:okhttp-jvm:5.0.0-alpha.11")
            force("com.squareup.okhttp3:okhttp-urlconnection:5.0.0-alpha.11")
            force("com.squareup.okio:okio-jvm:3.2.0")
        }
        // Exclude problematic dependencies globally
        exclude(group = "com.gyf.immersionbar", module = "immersionbar")
        exclude(group = "com.thingclips.smart", module = "thingplugin-annotation")
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
