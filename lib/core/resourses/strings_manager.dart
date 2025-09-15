class AppStrings {
  // General Error Messages
  static const String serverFailureMessage = 'Please Try Again Later...';
  static const String offlineFailureMessage =
      'Please Check your Internet Connection';
  static const String unexpectedError = 'An Unexpected Error Occurred';
  static const String processingError = 'Error Processing Request';

  // HTTP Status Codes
  static const String success = "success";
  static const String badRequestError = "bad_request_error";
  static const String noContent = "no_content";
  static const String forbiddenError = "forbidden_error";
  static const String unauthorizedError = "unauthorized_error";
  static const String notFoundError = "not_found_error";
  static const String conflictError = "conflict_error";
  static const String internalServerError = "internal_server_error";
  static const String serviceUnavailable = "service_unavailable";
  static const String methodNotAllowed = "method_not_allowed";

  // Network Errors
  static const String unknownError = "unknown_error";
  static const String timeoutError = "timeout_error";
  static const String defaultError = "default_error";
  static const String cacheError = "cache_error";
  static const String noInternetError = "no_internet_error";
  static const String networkConnectionLost = "network_connection_lost";
  static const String poorNetworkConnection = "poor_network_connection";

  // Authentication Errors
  static const String invalidCredentials = "invalid_credentials";
  static const String sessionExpired = "session_expired";
  static const String accountLocked = "account_locked";
  static const String tooManyAttempts = "too_many_attempts";
  static const String accountNotVerified = "account_not_verified";
  static const String invalidToken = "invalid_token";
  static const String accessDenied = "access_denied";

  // Validation Errors
  static const String invalidInput = "invalid_input";
  static const String requiredField = "required_field";
  static const String invalidEmail = "invalid_email";
  static const String invalidPhone = "invalid_phone";
  static const String passwordTooWeak = "password_too_weak";
  static const String invalidDate = "invalid_date";
  static const String invalidUrl = "invalid_url";
  static const String passwordMismatch = "password_mismatch";

  // Data Errors
  static const String dataNotFound = "data_not_found";
  static const String duplicateEntry = "duplicate_entry";
  static const String invalidFormat = "invalid_format";
  static const String dataCorrupted = "data_corrupted";
  static const String dataTooLarge = "data_too_large";
  static const String invalidDataType = "invalid_data_type";
  static const String dataOutOfRange = "data_out_of_range";

  // File Operation Errors
  static const String fileNotFound = "file_not_found";
  static const String fileTooBig = "file_too_big";
  static const String unsupportedFormat = "unsupported_format";
  static const String uploadFailed = "upload_failed";
  static const String downloadFailed = "download_failed";
  static const String fileSaveFailed = "file_save_failed";
  static const String fileDeleteFailed = "file_delete_failed";

  // Permission Errors
  static const String permissionDenied = "permission_denied";
  static const String locationPermissionDenied = "location_permission_denied";
  static const String cameraPermissionDenied = "camera_permission_denied";
  static const String storagePermissionDenied = "storage_permission_denied";
  static const String microphonePermissionDenied =
      "microphone_permission_denied";
  static const String notificationPermissionDenied =
      "notification_permission_denied";

  // Supabase Specific Errors
  static const String supabaseConnectionError = "supabase_connection_error";
  static const String supabaseAuthError = "supabase_auth_error";
  static const String supabaseQueryError = "supabase_query_error";
  static const String supabaseStorageError = "supabase_storage_error";
  static const String realtimeSubscriptionError = "realtime_subscription_error";
  static const String edgeFunctionError = "edge_function_error";

  // User Interface Messages
  static const String loadingMessage = "Loading...";
  static const String refreshingMessage = "Refreshing...";
  static const String processingMessage = "Processing...";
  static const String successMessage = "Operation Completed Successfully";
  static const String confirmationMessage = "Are you sure you want to proceed?";
  static const String deleteConfirmationMessage =
      "Are you sure you want to delete?";

  // Form Actions
  static const String save = "Save";
  static const String update = "Update";
  static const String delete = "Delete";
  static const String cancel = "Cancel";
  static const String confirm = "Confirm";
  static const String submit = "Submit";
  static const String retry = "Retry";

  // State Messages
  static const String empty = "No Data Available";
  static const String noResults = "No Results Found";
  static const String noConnection = "No Internet Connection";
  static const String sessionTimeout = "Session Timed Out";
  static const String maintenance = "System Under Maintenance";
}
