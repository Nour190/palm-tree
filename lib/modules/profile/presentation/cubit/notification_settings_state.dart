enum NotificationSettingsStatus {
  initial,
  loading,
  loaded,
  updating,
  error,
}

class NotificationSettingsState {
  final NotificationSettingsStatus status;
  final bool isPushEnabled;
  final bool isEmailEnabled;
  final bool isSmsEnabled;
  final String? error;

  const NotificationSettingsState({
    this.status = NotificationSettingsStatus.initial,
    this.isPushEnabled = false,
    this.isEmailEnabled = false,
    this.isSmsEnabled = false,
    this.error,
  });

  NotificationSettingsState copyWith({
    NotificationSettingsStatus? status,
    bool? isPushEnabled,
    bool? isEmailEnabled,
    bool? isSmsEnabled,
    String? error,
    bool clearError = false,
  }) {
    return NotificationSettingsState(
      status: status ?? this.status,
      isPushEnabled: isPushEnabled ?? this.isPushEnabled,
      isEmailEnabled: isEmailEnabled ?? this.isEmailEnabled,
      isSmsEnabled: isSmsEnabled ?? this.isSmsEnabled,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
