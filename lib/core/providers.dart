import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/storage/token_storage.dart';
import '../data/network/api_client.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/prayer_repository.dart';
import '../domain/usecases/auth_usecase.dart';
import '../domain/usecases/prayer_usecase.dart';

/// Riverpod DI 설정
/// iOS에서는 수동으로 DI했지만 (LoginViewModel(authUseCase: AuthUseCase(repository: ...))),
/// Riverpod은 Provider 체인으로 자동 주입

final tokenStorageProvider = Provider<TokenStorage>(
  (_) => TokenStorage(),
);

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(tokenStorage: ref.watch(tokenStorageProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    apiClient: ref.watch(apiClientProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  ),
);

final authUseCaseProvider = Provider<AuthUseCase>(
  (ref) => AuthUseCase(repository: ref.watch(authRepositoryProvider)),
);

final prayerRepositoryProvider = Provider<PrayerRepository>(
  (ref) => PrayerRepository(apiClient: ref.watch(apiClientProvider)),
);

final prayerUseCaseProvider = Provider<PrayerUseCase>(
  (ref) => PrayerUseCase(repository: ref.watch(prayerRepositoryProvider)),
);
