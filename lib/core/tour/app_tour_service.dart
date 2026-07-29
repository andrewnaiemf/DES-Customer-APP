import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tour_step_model.dart';

/// خدمة إدارة الجولة الإرشادية
class AppTourService extends ChangeNotifier {
  static AppTourService? _instance;
  static AppTourService get instance => _instance ??= AppTourService._();

  AppTourService._();

  // ─────────────────────────────────────────────────────────────────────────
  // 📊 State
  // ─────────────────────────────────────────────────────────────────────────
  
  bool _isInitialized = false;
  bool _isTourActive = false;
  int _currentStepIndex = 0;
  List<TourStep> _currentSteps = [];
  String? _currentScreenId;
  
  // Cache للشاشات المكتملة
  final Set<String> _completedScreenTours = {};
  
  // Version للتحكم في إعادة العرض بعد التحديثات
  static const String _tourVersionKey = 'app_tour_version';
  static const String _completedToursKey = 'completed_tours';
  static const String _currentAppTourVersion = '2.0.0'; // 🆕 تم التحديث - سيظهر التور للجميع!

  // ─────────────────────────────────────────────────────────────────────────
  // 🔧 Getters
  // ─────────────────────────────────────────────────────────────────────────
  
  bool get isTourActive => _isTourActive;
  bool get isInitialized => _isInitialized;
  int get currentStepIndex => _currentStepIndex;
  int get totalSteps => _currentSteps.length;
  TourStep? get currentStep => 
      _currentSteps.isNotEmpty && _currentStepIndex < _currentSteps.length
          ? _currentSteps[_currentStepIndex]
          : null;
  bool get isFirstStep => _currentStepIndex == 0;
  bool get isLastStep => _currentStepIndex == _currentSteps.length - 1;
  double get progress => 
      _currentSteps.isEmpty ? 0 : (_currentStepIndex + 1) / _currentSteps.length;

  // ─────────────────────────────────────────────────────────────────────────
  // 🚀 Initialization
  // ─────────────────────────────────────────────────────────────────────────
  
  Future<void> initialize() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    
    // التحقق من إصدار الجولة
    final savedVersion = prefs.getString(_tourVersionKey);
    
    if (savedVersion != _currentAppTourVersion) {
      // إصدار جديد - إعادة تعيين الجولات المكتملة
      await prefs.remove(_completedToursKey);
      await prefs.setString(_tourVersionKey, _currentAppTourVersion);
      _completedScreenTours.clear();
    } else {
      // تحميل الجولات المكتملة
      final completedList = prefs.getStringList(_completedToursKey) ?? [];
      _completedScreenTours.addAll(completedList);
    }

    _isInitialized = true;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🎯 Tour Control
  // ─────────────────────────────────────────────────────────────────────────
  
  /// بدء جولة لشاشة معينة
  Future<bool> startTour({
    required String screenId,
    required List<TourStep> steps,
    bool forceShow = false,
  }) async {
    if (!_isInitialized) await initialize();
    
    // التحقق من عدم تكرار العرض
    if (!forceShow && _completedScreenTours.contains(screenId)) {
      return false;
    }

    if (steps.isEmpty) return false;

    _currentScreenId = screenId;
    _currentSteps = steps;
    _currentStepIndex = 0;
    _isTourActive = true;

    // استدعاء callback الخطوة الأولى
    currentStep?.onShow?.call();

    notifyListeners();
    return true;
  }

  /// الانتقال للخطوة التالية
  void nextStep() {
    if (!_isTourActive || _currentSteps.isEmpty) return;

    currentStep?.onHide?.call();

    if (_currentStepIndex < _currentSteps.length - 1) {
      _currentStepIndex++;
      currentStep?.onShow?.call();
      notifyListeners();
    } else {
      completeTour();
    }
  }

  /// الرجوع للخطوة السابقة
  void previousStep() {
    if (!_isTourActive || _currentStepIndex <= 0) return;

    currentStep?.onHide?.call();
    _currentStepIndex--;
    currentStep?.onShow?.call();
    notifyListeners();
  }

  /// الانتقال لخطوة محددة
  void goToStep(int index) {
    if (!_isTourActive || index < 0 || index >= _currentSteps.length) return;

    currentStep?.onHide?.call();
    _currentStepIndex = index;
    currentStep?.onShow?.call();
    notifyListeners();
  }

  /// إكمال الجولة
  Future<void> completeTour() async {
    if (_currentScreenId != null) {
      _completedScreenTours.add(_currentScreenId!);
      await _saveCompletedTours();
    }

    currentStep?.onHide?.call();
    _isTourActive = false;
    _currentSteps = [];
    _currentStepIndex = 0;
    _currentScreenId = null;

    notifyListeners();
  }

  /// تخطي الجولة
  Future<void> skipTour() async {
    await completeTour();
  }

  /// إعادة تعيين جميع الجولات (من الإعدادات)
  Future<void> resetAllTours() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_completedToursKey);
    _completedScreenTours.clear();
    notifyListeners();
  }

  /// إعادة تعيين جولة شاشة معينة
  Future<void> resetScreenTour(String screenId) async {
    _completedScreenTours.remove(screenId);
    await _saveCompletedTours();
    notifyListeners();
  }

  /// التحقق من اكتمال جولة شاشة معينة
  bool isScreenTourCompleted(String screenId) {
    return _completedScreenTours.contains(screenId);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 💾 Storage
  // ─────────────────────────────────────────────────────────────────────────
  
  Future<void> _saveCompletedTours() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _completedToursKey,
      _completedScreenTours.toList(),
    );
  }
}
