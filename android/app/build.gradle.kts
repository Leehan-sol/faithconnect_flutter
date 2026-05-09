import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

// ====================================================================
// 릴리즈 서명 키 로드
// ====================================================================
// android/key.properties 가 존재하면 release 빌드를 진짜 키로 서명.
// 없으면 debug 키로 폴백 (다른 노트북/CI에서 release 테스트 빌드 가능).
// key.properties는 .gitignore — 노트북마다 따로 만들어야 함.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasKeystoreConfig = keystorePropertiesFile.exists()
if (hasKeystoreConfig) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.reboot.faithconnect"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.reboot.faithconnect"
        minSdk = flutter.minSdkVersion       // Flutter 기본값 (현재 24, Android 7)

        // Play Store 정책으로 신규 앱은 targetSdk 35 필수 (2025-08~), 업데이트도 35 필수 (2025-11~).
        // Flutter SDK 기본값(현재 36)에 의존하지 않고 명시적으로 35로 고정.
        // → SDK 업그레이드 시 갑작스러운 behavior change 유입 방지, 팀원/CI 환경 일관성 확보.
        // 36으로 올릴 때는 Android 16 behavior changes 검증 후 변경할 것.
        targetSdk = 35

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        // key.properties 가 있을 때만 release 서명 설정 등록.
        // 파일이 없으면 release 빌드는 자동으로 debug 키로 폴백 (아래 buildTypes 참조).
        if (hasKeystoreConfig) {
            create("release") {
                storeFile = keystoreProperties["storeFile"]?.let { file(it as String) }
                storePassword = keystoreProperties["storePassword"] as String?
                keyAlias = keystoreProperties["keyAlias"] as String?
                keyPassword = keystoreProperties["keyPassword"] as String?
            }
        }
    }

    buildTypes {
        release {
            // key.properties 있으면 release 키로, 없으면 debug 키 폴백.
            // → 다른 노트북에서 key.properties 없이도 `flutter run --release` 가능 (테스트용).
            // → Play Store 업로드용 AAB 만들 땐 반드시 key.properties + keystore 준비 필요.
            signingConfig = if (hasKeystoreConfig) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }

            // R8 코드 축소·난독화 활성화 (AGP 8+ 기본 minifier — ProGuard 대체).
            // - isMinifyEnabled: 미사용 클래스/메서드 제거 + 식별자 난독화 → APK 크기 감소 + 역분석 난이도 상승
            // - isShrinkResources: 미사용 리소스(PNG/XML/string 등) 제거 → 추가 크기 절감
            // - 두 옵션은 함께 켜야 함 (shrinkResources는 minifyEnabled=true 필수)
            isMinifyEnabled = true
            isShrinkResources = true

            // proguard-android-optimize.txt: AGP 기본 최적화 룰
            // proguard-rules.pro: 앱별 커스텀 룰 (Firebase, Flutter 등)
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
