import 'package:flutter_bloc/flutter_bloc.dart';
import '../service/notification_settings_service.dart';
import 'notification_settings_state.dart';

class NotificationSettingsCubit extends Cubit<NotificationSettingsState> {
  final NotificationSettingsService _service;

  NotificationSettingsCubit(this._service) : super(const NotificationSettingsState()) {
    _loadSettings();
  }

  Future<void> loadSettings() async {
    await _loadSettings();
  }
  Future<void> _loadSettings() async {
    emit(state.copyWith(status: NotificationSettingsStatus.loading));

    try {
      final pushEnabled = await _service.getPushNotifications();
      final emailEnabled = await _service.getEmailNotifications();
      final smsEnabled = await _service.getSmsNotifications();

      emit(state.copyWith(
        status: NotificationSettingsStatus.loaded,
        isPushEnabled: pushEnabled,
        isEmailEnabled: emailEnabled,
        isSmsEnabled: smsEnabled,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: NotificationSettingsStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> togglePushNotifications(bool enabled) async {
    emit(state.copyWith(status: NotificationSettingsStatus.updating));

    try {
      await _service.setPushNotifications(enabled);
      emit(state.copyWith(
        status: NotificationSettingsStatus.loaded,
        isPushEnabled: enabled,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: NotificationSettingsStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> toggleEmailNotifications(bool enabled) async {
    emit(state.copyWith(status: NotificationSettingsStatus.updating));

    try {
      await _service.setEmailNotifications(enabled);
      emit(state.copyWith(
        status: NotificationSettingsStatus.loaded,
        isEmailEnabled: enabled,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: NotificationSettingsStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> toggleSmsNotifications(bool enabled) async {
    emit(state.copyWith(status: NotificationSettingsStatus.updating));

    try {
      await _service.setSmsNotifications(enabled);
      emit(state.copyWith(
        status: NotificationSettingsStatus.loaded,
        isSmsEnabled: enabled,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: NotificationSettingsStatus.error,
        error: e.toString(),
      ));
    }
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }
}
