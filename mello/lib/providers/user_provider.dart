import 'package:flutter/foundation.dart';
import '../models/user_progress.dart';
import '../services/storage_service.dart';

class UserProvider extends ChangeNotifier {
  UserProgress? _userProgress;
  bool _isLoading = false;
  String? _error;

  UserProgress? get userProgress => _userProgress;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get tokenBalance => _userProgress?.tokenBalance ?? 500;
  bool get hasTokens => tokenBalance > 0;

  Future<void> initializeUser() async {
    // Use scheduleMicrotask to avoid setState during build
    await Future.microtask(() {});
    _setLoading(true);
    try {
      _userProgress = await StorageService.instance.getUserProgress();

      // Create new user if doesn't exist
      if (_userProgress == null) {
        _userProgress = UserProgress(
          userId: DateTime.now().millisecondsSinceEpoch.toString(),
          tokenBalance: 50, // Welcome bonus
          lastActiveDate: DateTime.now(),
          joinDate: DateTime.now(),
          preferences: const UserPreferences(),
        );
        await _saveUserProgress();
      } else {
        // Update last active date
        _userProgress = _userProgress!.copyWith(
          lastActiveDate: DateTime.now(),
        );
        await _saveUserProgress();
      }

      _error = null;
    } catch (e) {
      _error = 'Failed to initialize user: ${e.toString()}';
      print(_error);
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> useTokens(int amount) async {
    if (_userProgress == null || _userProgress!.tokenBalance < amount) {
      return false;
    }

    try {
      _userProgress = _userProgress!.copyWith(
        tokenBalance: _userProgress!.tokenBalance - amount,
        totalTokensUsed: _userProgress!.totalTokensUsed + amount,
      );

      await _saveUserProgress();
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to use tokens: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<void> addTokens(int amount) async {
    if (_userProgress == null) {
      print('Warning: Cannot add tokens - user progress is null');
      return;
    }

    if (amount <= 0) {
      print('Warning: Invalid token amount: $amount');
      return;
    }

    try {
      final oldBalance = _userProgress!.tokenBalance;
      _userProgress = _userProgress!.copyWith(
        tokenBalance: _userProgress!.tokenBalance + amount,
      );

      print(
          'Adding $amount tokens. Balance: $oldBalance -> ${_userProgress!.tokenBalance}');

      await _saveUserProgress();
      notifyListeners();

      print(
          'Tokens added successfully. New balance: ${_userProgress!.tokenBalance}');
    } catch (e) {
      _error = 'Failed to add tokens: ${e.toString()}';
      print('Error adding tokens: ${e.toString()}');
      notifyListeners();
    }
  }

  Future<void> incrementImagesGenerated() async {
    if (_userProgress == null) return;

    try {
      _userProgress = _userProgress!.copyWith(
        totalImagesGenerated: _userProgress!.totalImagesGenerated + 1,
      );

      await _saveUserProgress();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update image count: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> addBookmark(String contentId) async {
    if (_userProgress == null) return;

    try {
      final List<String> bookmarks =
          List.from(_userProgress!.bookmarkedContentIds);
      if (!bookmarks.contains(contentId)) {
        bookmarks.add(contentId);
        _userProgress =
            _userProgress!.copyWith(bookmarkedContentIds: bookmarks);
        await _saveUserProgress();
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to add bookmark: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> removeBookmark(String contentId) async {
    if (_userProgress == null) return;

    try {
      final List<String> bookmarks =
          List.from(_userProgress!.bookmarkedContentIds);
      bookmarks.remove(contentId);
      _userProgress = _userProgress!.copyWith(bookmarkedContentIds: bookmarks);
      await _saveUserProgress();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to remove bookmark: ${e.toString()}';
      notifyListeners();
    }
  }

  bool isBookmarked(String contentId) {
    return _userProgress?.bookmarkedContentIds.contains(contentId) ?? false;
  }

  Future<void> markContentCompleted(String contentId) async {
    if (_userProgress == null) return;

    try {
      final List<String> completed =
          List.from(_userProgress!.completedContentIds);
      if (!completed.contains(contentId)) {
        completed.add(contentId);
        _userProgress = _userProgress!.copyWith(completedContentIds: completed);
        await _saveUserProgress();
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to mark content completed: ${e.toString()}';
      notifyListeners();
    }
  }

  bool isContentCompleted(String contentId) {
    return _userProgress?.completedContentIds.contains(contentId) ?? false;
  }

  Future<void> updateCategoryProgress(String category, int progress) async {
    if (_userProgress == null) return;

    try {
      final Map<String, int> categoryProgress =
          Map.from(_userProgress!.categoryProgress);
      categoryProgress[category] = progress;
      _userProgress =
          _userProgress!.copyWith(categoryProgress: categoryProgress);
      await _saveUserProgress();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update category progress: ${e.toString()}';
      notifyListeners();
    }
  }

  int getCategoryProgress(String category) {
    return _userProgress?.categoryProgress[category] ?? 0;
  }

  Future<void> updatePreferences(UserPreferences preferences) async {
    if (_userProgress == null) return;

    try {
      _userProgress = _userProgress!.copyWith(preferences: preferences);
      await _saveUserProgress();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update preferences: ${e.toString()}';
      notifyListeners();
    }
  }

  UserPreferences get preferences =>
      _userProgress?.preferences ?? const UserPreferences();

  Future<void> resetUserData() async {
    try {
      await StorageService.instance.clearAllData();
      _userProgress = null;
      await initializeUser();
    } catch (e) {
      _error = 'Failed to reset user data: ${e.toString()}';
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> _saveUserProgress() async {
    if (_userProgress != null) {
      await StorageService.instance.saveUserProgress(_userProgress!);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Statistics getters
  int get totalImagesGenerated => _userProgress?.totalImagesGenerated ?? 0;
  int get totalTokensUsed => _userProgress?.totalTokensUsed ?? 0;
  int get totalBookmarks => _userProgress?.bookmarkedContentIds.length ?? 0;
  int get totalCompletedContent =>
      _userProgress?.completedContentIds.length ?? 0;
  DateTime? get joinDate => _userProgress?.joinDate;
  DateTime? get lastActiveDate => _userProgress?.lastActiveDate;

  int get daysActive {
    if (joinDate == null) return 0;
    return DateTime.now().difference(joinDate!).inDays + 1;
  }
}
