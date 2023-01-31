load("//tools/base/bazel:jvm_import.bzl", "jvm_import")
load("//tools/adt/idea/studio:studio.bzl", "intellij_plugin_import")
package(default_visibility = ["//visibility:public"])

intellij_plugin_import(
    name = "studio-sdk",
    files_root_dir = "AI-221/linux/android-studio/lib",
    target_dir = "lib",
    exports = [":studio-sdk-lib"],
)

jvm_import(
    name = "studio-sdk-lib",
    jars = glob(["AI-221/linux/android-studio/lib/*.jar","AI-221/linux/android-studio/plugins/java/lib/*.jar"],
                ["AI-221/linux/android-studio/lib/annotations-java5.jar"]),
)

intellij_plugin_import(
    name = "studio-sdk-plugin-Groovy",
    files_root_dir = "AI-221/linux/android-studio/plugins/Groovy",
    target_dir = "Groovy",
    exports = [":studio-sdk-plugin-Groovy-lib"],
)

jvm_import(
    name = "studio-sdk-plugin-Groovy-lib",
    jars = glob(["AI-221/linux/android-studio/plugins/Groovy/lib/*.jar"]),
)

intellij_plugin_import(
    name = "studio-sdk-plugin-Kotlin",
    files_root_dir = "AI-221/linux/android-studio/plugins/Kotlin",
    target_dir = "Kotlin",
    exports = [":studio-sdk-plugin-Kotlin-lib"],
)

jvm_import(
    name = "studio-sdk-plugin-Kotlin-lib",
    jars = glob(["AI-221/linux/android-studio/plugins/Kotlin/lib/*.jar"]),
)

intellij_plugin_import(
    name = "studio-sdk-plugin-toml",
    files_root_dir = "AI-221/linux/android-studio/plugins/toml",
    target_dir = "toml",
    exports = [":studio-sdk-plugin-toml-lib"],
)

jvm_import(
    name = "studio-sdk-plugin-toml-lib",
    jars = glob(["AI-221/linux/android-studio/plugins/toml/lib/*.jar"]),
)

intellij_plugin_import(
    name = "studio-sdk-plugin-git4idea",
    files_root_dir = "AI-221/linux/android-studio/plugins/git4idea",
    target_dir = "git4idea",
    exports = [":studio-sdk-plugin-git4idea-lib"],
)

jvm_import(
    name = "studio-sdk-plugin-git4idea-lib",
    jars = glob(["AI-221/linux/android-studio/plugins/git4idea/lib/*.jar"]),
)

intellij_plugin_import(
    name = "studio-sdk-plugin-webp",
    files_root_dir = "AI-221/linux/android-studio/plugins/webp",
    target_dir = "webp",
    exports = [":studio-sdk-plugin-webp-lib"],
)

jvm_import(
    name = "studio-sdk-plugin-webp-lib",
    jars = glob(["AI-221/linux/android-studio/plugins/webp/lib/*.jar"])
)

intellij_plugin_import(
    name = "studio-sdk-plugin-junit",
    files_root_dir = "AI-221/linux/android-studio/plugins/junit",
    target_dir = "junit",
    exports = [":studio-sdk-plugin-junit-lib"],
)

jvm_import(
    name = "studio-sdk-plugin-junit-lib",
    jars = glob(["AI-221/linux/android-studio/plugins/junit/lib/*.jar"]),
)

intellij_plugin_import(
    name = "studio-sdk-plugin-properties",
    files_root_dir = "AI-221/linux/android-studio/plugins/properties",
    target_dir = "properties",
    exports = [":studio-sdk-plugin-properties-lib"],
)

jvm_import(
    name = "studio-sdk-plugin-properties-lib",
    jars = glob(["AI-221/linux/android-studio/plugins/properties/lib/*.jar"]),
)

intellij_plugin_import(
    name = "studio-sdk-plugin-gradle",
    files_root_dir = "AI-221/linux/android-studio/plugins/gradle",
    target_dir = "gradle",
    exports = [":studio-sdk-plugin-gradle-lib"],
)

jvm_import(
    name = "studio-sdk-plugin-gradle-lib",
    jars = glob(["AI-221/linux/android-studio/plugins/gradle/lib/*.jar"]),
)

intellij_plugin_import(
    name = "studio-sdk-plugin-gradle-java",
    files_root_dir = "AI-221/linux/android-studio/plugins/plugin-java",
    target_dir = "gradle-java",
    exports = [":studio-sdk-plugin-gradle-java-lib"],
)

jvm_import(
    name = "studio-sdk-plugin-gradle-java-lib",
    jars = glob(["AI-221/linux/android-studio/plugins/gradle-java/lib/*.jar"]),
)

intellij_plugin_import(
    name = "studio-sdk-plugin-platform-images",
    files_root_dir = "AI-221/linux/android-studio/plugins/platform-images",
    target_dir = "platform-images",
    exports = [":studio-sdk-plugin-platform-images-lib"],
)

jvm_import(
    name = "studio-sdk-plugin-platform-images-lib",
    jars = glob(["AI-221/linux/android-studio/plugins/platform-images/lib/*.jar"]),
)

intellij_plugin_import(
    name = "studio-sdk-plugin-IntelliLang",
    files_root_dir = "AI-221/linux/android-studio/plugins/IntelliLang",
    target_dir = "IntelliLang",
    exports = [":studio-sdk-plugin-IntelliLang-lib"],
)

jvm_import(
    name = "studio-sdk-plugin-IntelliLang-lib",
    jars = glob(["AI-221/linux/android-studio/plugins/IntelliLang/lib/*.jar"]),
)
