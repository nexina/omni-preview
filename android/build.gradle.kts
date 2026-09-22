allprojects {
    repositories {
        google()
        mavenCentral()
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

    if (project.name == "uri_to_file") {
        if (project.state.executed) {
            project.configure<com.android.build.gradle.BaseExtension> {
                namespace = "in.lazymanstudios.uri_to_file"
            }
        } else {
            project.afterEvaluate {
                project.configure<com.android.build.gradle.BaseExtension> {
                    namespace = "in.lazymanstudios.uri_to_file"
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
