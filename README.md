# FaithConnect (Flutter) 🙏

익명으로 기도 요청을 공유하고, 다른 사람들의 기도에 응답하는 신앙 커뮤니티 앱의 **Android 버전**입니다.
**무작위로 받는 푸시 알림을 통해 누군가의 기도를 발견하고 응답할 수 있습니다.**

> 📱 **iOS(SwiftUI) 원본 보기**: [Leehan-sol/FaithConnect](https://github.com/Leehan-sol/FaithConnect)

---

## 🧭 프로젝트 배경

iOS(SwiftUI)로 먼저 출시한 FaithConnect를 **Android에도 제공**하기 위해 Flutter로 포팅한 프로젝트입니다.

- 동일한 백엔드 API · 동일한 Clean Architecture를 유지하면서, 플랫폼별 UI/상태관리 차이를 직접 비교하며 학습
- iOS의 `@Published` / `@MainActor` 패턴을 Flutter의 **Riverpod Notifier + 불변 State** 로 옮기는 과정에서 두 생태계의 상태관리 철학을 체득
- 하나의 서비스를 두 플랫폼으로 모두 다뤄본 경험을 목표로 함

---

## 📱 앱 개요

FaithConnect는 개인의 신앙을 나누고 서로를 지지하는 익명 기반의 기도 공유 플랫폼입니다.

### 핵심 기능
- **익명 기도 요청**: 신원을 드러내지 않고 기도 요청을 등록
- **카테고리 기반 분류**: 건강, 가족, 일, 관계 등 다양한 주제로 구분
- **익명 응답**: 다른 사람의 기도 요청에 익명으로 응답 및 격려
- **푸시 알림**: 무작위로 다른 사람의 기도 요청을 받고 응답할 수 있음 (FCM)
- **나의 기도 관리**: 올린 기도와 받은 응답 확인
- **사용자 차단 / 신고**: 부적절한 사용자/콘텐츠 차단 및 신고
- **계정 관리**: 회원가입, 아이디·비밀번호 찾기, 회원 탈퇴
- **고객 지원**: 문의하기, 약관/개인정보처리방침 조회

---

## 📸 스크린샷

> _추후 추가 예정_

---

## 🏗️ 아키텍처

iOS 원본과 동일한 **Clean Architecture** 3계층 구조를 Flutter로 그대로 옮겼습니다.

```
📁 lib/
├── 🔷 app/                          # 라우팅 (go_router)
│   └── router.dart
│
├── 🧩 core/                         # 공통 인프라
│   ├── providers.dart               # Riverpod Provider 정의 & DI
│   ├── theme/app_colors.dart
│   └── utils/time_ago.dart
│
├── 🎨 presentation/                 # UI 계층 (Flutter Widget)
│   ├── components/                  # 재사용 컴포넌트 (버튼, 입력, 다이얼로그 등)
│   ├── splash/                      # 스플래시 & 초기 인증 체크
│   ├── login/  signup/              # 로그인 / 회원가입
│   ├── find_id/  find_password/     # 아이디·비밀번호 찾기
│   ├── main_tab/                    # 메인 탭 네비게이션
│   ├── home/                        # 기도 목록 탭
│   ├── prayer_detail/               # 기도 상세 + 댓글/대댓글
│   ├── prayer_editor/               # 기도 작성
│   ├── my_prayer/                   # 내 기도 & 받은 응답
│   ├── my_page/                     # 프로필 / 회원 탈퇴
│   ├── block_list/                  # 차단 목록
│   ├── inquiry/                     # 문의하기
│   └── policy/                      # 약관·개인정보처리방침 (WebView)
│
│   ※ 각 화면은 view / notifier / state 3파일 구성
│      예) home_view.dart + home_notifier.dart + home_state.dart
│
├── 📚 domain/                       # 비즈니스 로직 계층
│   ├── entities/                    # 핵심 모델 (Prayer, PrayerResponse, User …)
│   ├── usecases/                    # PrayerUseCase, AuthUseCase
│   ├── events/                      # PrayerEventBus (Stream 기반 이벤트 버스)
│   └── interfaces/                  # Repository 프로토콜
│
└── 💾 data/                         # 데이터 접근 계층
    ├── repositories/                # AuthRepository, PrayerRepository
    ├── network/                     # Dio 기반 APIClient, 엔드포인트, 에러
    ├── dtos/                        # DTO 정의 (auth / prayer / inquiry / report)
    └── storage/
        ├── token_storage.dart       # flutter_secure_storage (Keychain 대응)
        └── user_session.dart        # 사용자 세션 (메모리)
```

### 데이터 흐름

```
View → Notifier → UseCase → Repository → APIClient → Network
  ↓        ↓          ↓           ↓           ↓
ref.read  State    이벤트 발행    Dio 호출    HTTP
```

예시: 기도 목록 로드
```
HomeView
  → HomeNotifier (Riverpod Notifier<HomeState>)
    → PrayerUseCase.loadPrayers()
      → PrayerRepository.loadPrayers()
        → APIClient.loadPrayers()   // Dio
          → state = state.copyWith(prayers: …)
            → ref.watch 한 View 자동 리빌드
```

### iOS ↔ Flutter 상태관리 대응

| iOS (SwiftUI)                          | Flutter (Riverpod) |
|----------------------------------------|--------------------|
| `class HomeViewModel: ObservableObject` | `class HomeNotifier extends Notifier<HomeState>` |
| `@Published var prayers: [Prayer]`     | `HomeState.prayers` (immutable) + `copyWith` |
| `@MainActor`                           | Notifier는 기본적으로 main isolate |
| `Combine` Publisher                    | `Stream` + `PrayerEventBus` |

---

## 📖 주요 페이지

### 1. 스플래시 (`SplashView`)
앱 시작 시 저장된 토큰을 검증하고 로그인/홈으로 분기.

### 2. 로그인 / 회원가입 (`LoginView`, `SignupView`)
- 이메일·비밀번호 로그인, 회원가입
- 토큰 저장 (`flutter_secure_storage`)
- 아이디·비밀번호 찾기 흐름 포함

### 3. 홈 탭 (`HomeView`)
- 카테고리 필터링 (건강 / 가족 / 일 / 관계 / 기타)
- 최신순 기도 목록, 무한 스크롤
- 탭하면 기도 상세로 이동

### 4. 기도 상세 (`PrayerDetailView`)
- 기도 본문, 댓글·대댓글 표시
- 응답 작성, 본인 게시물 삭제
- 신고 / 차단 진입점

### 5. 기도 작성 (`PrayerEditorView`)
- 제목 · 내용 · 카테고리 선택 후 등록

### 6. 내 기도 탭 (`MyPrayerView`)
- 내가 올린 기도, 내가 한 응답 목록
- 스와이프 삭제

### 7. 마이페이지 (`MyPageView`)
- 프로필, 차단 목록, 문의하기, 약관/개인정보, 로그아웃, 회원 탈퇴

---

## 🔐 인증 흐름

1. **로그인**: `LoginNotifier` → `AuthUseCase.login()` → 토큰 `flutter_secure_storage`에 저장
2. **앱 시작**: `SplashView`에서 토큰 존재 여부 확인 후 홈/로그인으로 분기
3. **API 요청**: `APIClient`(Dio Interceptor)가 모든 요청에 토큰 헤더 자동 부착
4. **푸시 토큰**: 로그인 직후 FCM 토큰 발급 → 서버 등록
5. **로그아웃 / 탈퇴**: 토큰 삭제 + `UserSession` 초기화

---

## 🚀 빌드 및 실행

### 요구사항
- Flutter SDK **3.9.2+** / Dart 3.x
- Android Studio (에뮬레이터 / SDK)
- Android **minSdk 24 (Android 7.0)** · targetSdk 35
- Firebase 프로젝트 (FCM 사용)

### 실행
```bash
flutter pub get
flutter run
```

---

## 📋 기술 스택

| 영역 | iOS 원본 | Flutter (현재 레포) |
|-----|---------|--------------------|
| **UI Framework** | SwiftUI | Flutter (Material) |
| **아키텍처** | Clean Architecture | Clean Architecture (동일) |
| **상태관리** | `@Published` / `@MainActor` | **Riverpod 3.x** (`Notifier` + 불변 State) |
| **라우팅** | NavigationStack | **go_router 17** |
| **비동기** | async/await | async/await |
| **반응형** | Combine | Stream (이벤트 버스) |
| **HTTP** | URLSession | **Dio 5** |
| **보안 저장소** | Keychain | **flutter_secure_storage** |
| **푸시 알림** | APNs | **Firebase Messaging + flutter_local_notifications** |
| **언어** | Swift 5+ | Dart 3.9+ |
| **최소 배포** | iOS 14+ | Android 7.0+ (API 24) |
