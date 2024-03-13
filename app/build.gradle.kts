plugins {
  id("com.android.application")
  id("org.jetbrains.kotlin.android")
}

android {
  namespace = "com.rajendra.sketchide"
  compileSdk = 34

  defaultConfig {
    applicationId = "com.rajendra.sketchide"
    minSdk = 26
    targetSdk = 34
    versionCode = 1
    versionName = "1.0"

    testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    multiDexEnabled = true
  }

  buildFeatures {
    viewBinding = true
    buildConfig = true
  }

  buildTypes {
    release {
      isMinifyEnabled = false
      proguardFiles(
        getDefaultProguardFile("proguard-android-optimize.txt"),
        "proguard-rules.pro"
      )
    }
  }

  compileOptions {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
  }

  kotlinOptions {
    jvmTarget = "17"
  }
}

dependencies {

  implementation("androidx.appcompat:appcompat:1.6.1")
  implementation("com.google.android.material:material:1.11.0")
  implementation("androidx.constraintlayout:constraintlayout:2.1.4")
  implementation("androidx.core:core-ktx:1.12.0")

  testImplementation("junit:junit:4.13.2")
  testImplementation("org.testng:testng:6.9.6")
  androidTestImplementation("androidx.test.ext:junit:1.1.5")
  androidTestImplementation("androidx.test.espresso:espresso-core:3.5.1")

  implementation("androidx.navigation:navigation-ui:2.7.7")
  implementation("androidx.navigation:navigation-fragment:2.7.7")
  implementation("com.github.androidbulb:CircleImageViewLibrary:1.0")
  implementation("com.blankj:utilcodex:1.31.1")
  implementation("com.google.code.gson:gson:2.10.1")
  implementation("org.apache.commons:commons-text:1.11.0")
}