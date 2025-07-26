buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.3.15") // Sử dụng cú pháp Kotlin DSL
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: File = rootProject.layout.buildDirectory.dir("../../build").get().asFile
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir: File = newBuildDir.resolve(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
    afterEvaluate {
        tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
            kotlinOptions {
                jvmTarget = "21" // Hoặc "11" nếu bạn muốn tương thích rộng hơn
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
    
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

