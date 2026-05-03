import 'dart:async';
import '../entities/prayer.dart';
import '../entities/my_response.dart';
import '../entities/prayer_response.dart';

/// iOS PrayerEventType.swift 대응
/// Combine PassthroughSubject → Dart StreamController
sealed class PrayerEvent {}

class PrayerAdded extends PrayerEvent {
  final Prayer prayer;
  PrayerAdded(this.prayer);
}

class PrayerUpdated extends PrayerEvent {
  final Prayer prayer;
  PrayerUpdated(this.prayer);
}

class PrayerDeleted extends PrayerEvent {
  final int prayerId;
  PrayerDeleted(this.prayerId);
}

class ResponseAdded extends PrayerEvent {
  final MyResponse response;
  ResponseAdded(this.response);
}

class ResponseUpdated extends PrayerEvent {
  final PrayerResponse response;
  ResponseUpdated(this.response);
}

class ResponseDeleted extends PrayerEvent {
  final int responseId;
  final int prayerRequestId;
  ResponseDeleted(this.responseId, this.prayerRequestId);
}

class UserBlocked extends PrayerEvent {
  final int userId;
  UserBlocked(this.userId);
}

/// 앱 전역 이벤트 버스 (싱글톤)
class PrayerEventBus {
  PrayerEventBus._();
  static final instance = PrayerEventBus._();

  final _controller = StreamController<PrayerEvent>.broadcast();

  Stream<PrayerEvent> get stream => _controller.stream;

  void fire(PrayerEvent event) => _controller.add(event);
}
