# ============================================================
# FaithConnect ProGuard / R8 룰
# ============================================================
# 이 파일은 R8이 코드 축소/난독화 시 "건드리지 말 것" 또는
# "경고 무시할 것" 같은 예외를 명시합니다.
#
# 대부분의 라이브러리는 자체 consumer-rules를 AAR에 포함하므로
# 여기엔 안전망 + 앱 고유 룰만 최소한으로 유지합니다.
# 빌드 후 logcat에 ClassNotFoundException이 뜨면 해당 클래스를 keep 룰에 추가하세요.
# ============================================================


# ---------- Flutter 엔진/플러그인 ----------
# Flutter Gradle 플러그인이 대부분 자동 처리하지만 이중 안전망.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Flutter Play Core (Deferred Components) — 본 앱은 deferred components 사용 안 하지만
# Flutter embedding이 PlayStoreDeferredComponentManager를 reference 가지고 있어 R8가 missing class 에러를 냄.
# Play Core 의존성 추가 대신 dontwarn으로 R8 경고 무시 (런타임에 호출 안 되므로 안전).
-dontwarn com.google.android.play.core.**


# ---------- Firebase (FCM, Core) ----------
# AAR consumer-rules로 대부분 처리되지만 강제 보호.
# FCM이 RemoteMessage 직렬화 시 reflection을 사용하는 부분 안전망.
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**


# ---------- 앱 자체 코드 (MainActivity 등) ----------
# AndroidManifest.xml에서 직접 참조되는 클래스 보호.
-keep public class com.hansol.faithconnect_flutter.** { *; }


# ---------- 일반 안전 룰 ----------
# Parcelable: FCM RemoteMessage, Bundle 직렬화에 필요.
-keepclassmembers class * implements android.os.Parcelable {
    public static final ** CREATOR;
}

# Enum: valueOf/values() reflection 사용 시 필요.
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# 네이티브 메서드 (JNI) 보호.
-keepclasseswithmembernames class * {
    native <methods>;
}

# Serializable 직렬화에 필요한 메서드/필드 보호.
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}
