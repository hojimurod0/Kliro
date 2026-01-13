// Stub for Sentry when not available
class SentryStub {
  static final SentryStub _instance = SentryStub._();
  factory SentryStub() => _instance;
  SentryStub._();
  
  static void captureException(
    dynamic exception, {
    dynamic stackTrace,
    dynamic hint,
  }) {
    // Stub - do nothing
  }
}

class HintStub {
  static dynamic withMap(Map<String, dynamic> map) {
    return null;
  }
}

// Export as sentry namespace
class Sentry {
  static void captureException(
    dynamic exception, {
    dynamic stackTrace,
    dynamic hint,
  }) => SentryStub.captureException(exception, stackTrace: stackTrace, hint: hint);
}

class Hint {
  static dynamic withMap(Map<String, dynamic> map) => HintStub.withMap(map);
}

// Stub for SentryEvent
class SentryEvent {
  final dynamic request;
  
  SentryEvent({this.request});
  
  SentryEvent copyWith({dynamic request}) {
    return SentryEvent(request: request ?? this.request);
  }
}

// Stub for SentryFlutter
class SentryFlutter {
  static Future<void> init(
    void Function(dynamic options) optionsCallback, {
    required void Function() appRunner,
  }) async {
    // Stub - just run the app
    appRunner();
  }
}

