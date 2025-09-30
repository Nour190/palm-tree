import 'package:easy_localization/easy_localization.dart';

class AppStrings {
  // General Error Messages
  static String get serverFailureMessage => 'errors.server_failure'.tr();
  static String get offlineFailureMessage => 'errors.offline_failure'.tr();
  static String get unexpectedError => 'errors.unexpected_error'.tr();
  static String get processingError => 'errors.processing_error'.tr();

  // HTTP Status Codes
  static String get success => 'common.success'.tr();
  static String get badRequestError => 'errors.bad_request_error'.tr();
  static String get noContent => 'errors.no_content'.tr();
  static String get forbiddenError => 'errors.forbidden_error'.tr();
  static String get unauthorizedError => 'errors.unauthorized_error'.tr();
  static String get notFoundError => 'errors.not_found_error'.tr();
  static String get conflictError => 'errors.conflict_error'.tr();
  static String get internalServerError => 'errors.internal_server_error'.tr();
  static String get serviceUnavailable => 'errors.service_unavailable'.tr();
  static String get methodNotAllowed => 'errors.method_not_allowed'.tr();

  // Network Errors
  static String get unknownError => 'errors.unknown_error'.tr();
  static String get timeoutError => 'errors.timeout_error'.tr();
  static String get defaultError => 'errors.default_error'.tr();
  static String get cacheError => 'errors.cache_error'.tr();
  static String get noInternetError => 'errors.no_internet_error'.tr();
  static String get networkConnectionLost => 'errors.network_connection_lost'.tr();
  static String get poorNetworkConnection => 'errors.poor_network_connection'.tr();

  // Authentication Errors
  static String get invalidCredentials => 'errors.invalid_credentials'.tr();
  static String get sessionExpired => 'errors.session_expired'.tr();
  static String get accountLocked => 'errors.account_locked'.tr();
  static String get tooManyAttempts => 'errors.too_many_attempts'.tr();
  static String get accountNotVerified => 'errors.account_not_verified'.tr();
  static String get invalidToken => 'errors.invalid_token'.tr();
  static String get accessDenied => 'errors.access_denied'.tr();

  // Validation Errors
  static String get invalidInput => 'validation.invalid_input'.tr();
  static String get requiredField => 'validation.required_field'.tr();
  static String get invalidEmail => 'validation.email_invalid'.tr();
  static String get invalidPhone => 'validation.invalid_phone'.tr();
  static String get passwordTooWeak => 'validation.password_too_weak'.tr();
  static String get invalidDate => 'validation.invalid_date'.tr();
  static String get invalidUrl => 'validation.invalid_url'.tr();
  static String get passwordMismatch => 'validation.passwords_dont_match'.tr();

  // Data Errors
  static String get dataNotFound => 'errors.data_not_found'.tr();
  static String get duplicateEntry => 'errors.duplicate_entry'.tr();
  static String get invalidFormat => 'errors.invalid_format'.tr();
  static String get dataCorrupted => 'errors.data_corrupted'.tr();
  static String get dataTooLarge => 'errors.data_too_large'.tr();
  static String get invalidDataType => 'errors.invalid_data_type'.tr();
  static String get dataOutOfRange => 'errors.data_out_of_range'.tr();

  // File Operation Errors
  static String get fileNotFound => 'errors.file_not_found'.tr();
  static String get fileTooBig => 'errors.file_too_big'.tr();
  static String get unsupportedFormat => 'errors.unsupported_format'.tr();
  static String get uploadFailed => 'errors.upload_failed'.tr();
  static String get downloadFailed => 'errors.download_failed'.tr();
  static String get fileSaveFailed => 'errors.file_save_failed'.tr();
  static String get fileDeleteFailed => 'errors.file_delete_failed'.tr();

  // Permission Errors
  static String get permissionDenied => 'errors.permission_denied'.tr();
  static String get locationPermissionDenied => 'errors.location_permission_denied'.tr();
  static String get cameraPermissionDenied => 'errors.camera_permission_denied'.tr();
  static String get storagePermissionDenied => 'errors.storage_permission_denied'.tr();
  static String get microphonePermissionDenied => 'errors.microphone_permission_denied'.tr();
  static String get notificationPermissionDenied => 'errors.notification_permission_denied'.tr();

  // Supabase Specific Errors
  static String get supabaseConnectionError => 'errors.supabase_connection_error'.tr();
  static String get supabaseAuthError => 'errors.supabase_auth_error'.tr();
  static String get supabaseQueryError => 'errors.supabase_query_error'.tr();
  static String get supabaseStorageError => 'errors.supabase_storage_error'.tr();
  static String get realtimeSubscriptionError => 'errors.realtime_subscription_error'.tr();
  static String get edgeFunctionError => 'errors.edge_function_error'.tr();

  // User Interface Messages
  static String get loadingMessage => 'common.loading'.tr();
  static String get refreshingMessage => 'common.refreshing'.tr();
  static String get processingMessage => 'common.processing'.tr();
  static String get successMessage => 'common.success'.tr();
  static String get confirmationMessage => 'messages.confirmation'.tr();
  static String get deleteConfirmationMessage => 'messages.delete_confirmation'.tr();

  // Form Actions
  static String get save => 'common.save'.tr();
  static String get update => 'common.update'.tr();
  static String get delete => 'common.delete'.tr();
  static String get cancel => 'common.cancel'.tr();
  static String get confirm => 'common.confirm'.tr();
  static String get submit => 'common.submit'.tr();
  static String get retry => 'common.retry'.tr();

  // State Messages
  static String get empty => 'messages.no_data'.tr();
  static String get noResults => 'messages.no_results'.tr();
  static String get noConnection => 'messages.no_connection'.tr();
  static String get sessionTimeout => 'messages.session_timeout'.tr();
  static String get maintenance => 'messages.maintenance'.tr();
}
