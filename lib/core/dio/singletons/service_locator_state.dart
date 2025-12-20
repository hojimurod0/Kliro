import 'dart:async';

/// ServiceLocator initialization state
enum ServiceLocatorState {
  initializing,
  ready,
  error,
}

/// ServiceLocator initialization state controller
/// Stream orqali state o'zgarishlarini kuzatish mumkin
class ServiceLocatorStateController {
  ServiceLocatorStateController._();
  
  static final ServiceLocatorStateController _instance = ServiceLocatorStateController._();
  static ServiceLocatorStateController get instance => _instance;

  final _stateController = StreamController<ServiceLocatorState>.broadcast();
  final _completer = Completer<void>();
  
  ServiceLocatorState _currentState = ServiceLocatorState.initializing;
  
  /// Current state
  ServiceLocatorState get currentState => _currentState;
  
  /// State stream
  Stream<ServiceLocatorState> get stateStream => _stateController.stream;
  
  /// Initialization complete future
  Future<void> get initializationComplete => _completer.future;
  
  /// State o'zgartirish
  void _setState(ServiceLocatorState state) {
    if (_currentState != state) {
      _currentState = state;
      _stateController.add(state);
    }
  }
  
  /// Initializing state ga o'tkazish
  void setInitializing() {
    _setState(ServiceLocatorState.initializing);
  }
  
  /// Ready state ga o'tkazish
  void setReady() {
    _setState(ServiceLocatorState.ready);
    if (!_completer.isCompleted) {
      _completer.complete();
    }
  }
  
  /// Error state ga o'tkazish
  void setError(Object error) {
    _setState(ServiceLocatorState.error);
    if (!_completer.isCompleted) {
      _completer.completeError(error);
    }
  }
  
  /// Dispose
  void dispose() {
    _stateController.close();
  }
  
  /// Reset (testing uchun)
  void reset() {
    _currentState = ServiceLocatorState.initializing;
    if (_completer.isCompleted) {
      // Yeni completer yaratish
      // Completer ni qayta yaratish uchun yangi instance yaratamiz
      // Lekin bu singleton pattern, shuning uchun faqat state ni reset qilamiz
      // Completer ni qayta yaratish mumkin emas, shuning uchun faqat state ni o'zgartiramiz
    }
    // State controller ni yangilash
    _stateController.add(_currentState);
  }
}

