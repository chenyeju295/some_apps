import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_progress.dart';
import '../models/generated_image.dart';

class StorageService {
  static const String _userProgressKey = 'user_progress';
  static const String _generatedImagesKey = 'generated_images';
  static const String _bookmarkedContentKey = 'bookmarked_content';
  static const String _completedContentKey = 'completed_content';

  static StorageService? _instance;
  static StorageService get instance =>
      _instance ??= StorageService._internal();
  StorageService._internal();

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception(
          'StorageService not initialized. Call initialize() first.');
    }
    return _prefs!;
  }

  // User Progress Management
  Future<UserProgress?> getUserProgress() async {
    try {
      final String? jsonString = prefs.getString(_userProgressKey);
      if (jsonString != null) {
        final Map<String, dynamic> json = jsonDecode(jsonString);
        return UserProgress.fromJson(json);
      }
    } catch (e) {
      print('Error loading user progress: $e');
    }
    return null;
  }

  Future<bool> saveUserProgress(UserProgress progress) async {
    try {
      final String jsonString = jsonEncode(progress.toJson());
      return await prefs.setString(_userProgressKey, jsonString);
    } catch (e) {
      print('Error saving user progress: $e');
      return false;
    }
  }

  // Generated Images Management
  Future<List<GeneratedImage>> getGeneratedImages() async {
    try {
      final String? jsonString = prefs.getString(_generatedImagesKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        return jsonList.map((json) => GeneratedImage.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error loading generated images: $e');
    }
    return [];
  }

  Future<bool> saveGeneratedImages(List<GeneratedImage> images) async {
    try {
      final List<Map<String, dynamic>> jsonList =
          images.map((image) => image.toJson()).toList();
      final String jsonString = jsonEncode(jsonList);
      return await prefs.setString(_generatedImagesKey, jsonString);
    } catch (e) {
      print('Error saving generated images: $e');
      return false;
    }
  }

  Future<bool> addGeneratedImage(GeneratedImage image) async {
    final List<GeneratedImage> images = await getGeneratedImages();
    images.insert(0, image); // Add to beginning for recent-first order
    return await saveGeneratedImages(images);
  }

  Future<bool> updateGeneratedImage(GeneratedImage updatedImage) async {
    final List<GeneratedImage> images = await getGeneratedImages();
    final int index = images.indexWhere((img) => img.id == updatedImage.id);
    if (index != -1) {
      images[index] = updatedImage;
      return await saveGeneratedImages(images);
    }
    return false;
  }

  Future<bool> deleteGeneratedImage(String imageId) async {
    final List<GeneratedImage> images = await getGeneratedImages();
    images.removeWhere((img) => img.id == imageId);
    return await saveGeneratedImages(images);
  }

  // Bookmarked Content Management
  Future<List<String>> getBookmarkedContentIds() async {
    try {
      final List<String>? ids = prefs.getStringList(_bookmarkedContentKey);
      return ids ?? [];
    } catch (e) {
      print('Error loading bookmarked content: $e');
      return [];
    }
  }

  Future<bool> saveBookmarkedContentIds(List<String> contentIds) async {
    try {
      return await prefs.setStringList(_bookmarkedContentKey, contentIds);
    } catch (e) {
      print('Error saving bookmarked content: $e');
      return false;
    }
  }

  Future<bool> addBookmark(String contentId) async {
    final List<String> bookmarks = await getBookmarkedContentIds();
    if (!bookmarks.contains(contentId)) {
      bookmarks.add(contentId);
      return await saveBookmarkedContentIds(bookmarks);
    }
    return true; // Already bookmarked
  }

  Future<bool> removeBookmark(String contentId) async {
    final List<String> bookmarks = await getBookmarkedContentIds();
    bookmarks.remove(contentId);
    return await saveBookmarkedContentIds(bookmarks);
  }

  // Completed Content Management
  Future<List<String>> getCompletedContentIds() async {
    try {
      final List<String>? ids = prefs.getStringList(_completedContentKey);
      return ids ?? [];
    } catch (e) {
      print('Error loading completed content: $e');
      return [];
    }
  }

  Future<bool> saveCompletedContentIds(List<String> contentIds) async {
    try {
      return await prefs.setStringList(_completedContentKey, contentIds);
    } catch (e) {
      print('Error saving completed content: $e');
      return false;
    }
  }

  Future<bool> markContentCompleted(String contentId) async {
    final List<String> completed = await getCompletedContentIds();
    if (!completed.contains(contentId)) {
      completed.add(contentId);
      return await saveCompletedContentIds(completed);
    }
    return true; // Already completed
  }

  // Token Management
  Future<int> getTokenBalance() async {
    return prefs.getInt('token_balance') ??
        50; // Default 50 tokens for new users
  }

  Future<bool> setTokenBalance(int balance) async {
    return await prefs.setInt('token_balance', balance);
  }

  Future<bool> addTokens(int tokens) async {
    final int currentBalance = await getTokenBalance();
    return await setTokenBalance(currentBalance + tokens);
  }

  Future<bool> useTokens(int tokens) async {
    final int currentBalance = await getTokenBalance();
    if (currentBalance >= tokens) {
      return await setTokenBalance(currentBalance - tokens);
    }
    return false; // Insufficient tokens
  }

  // Settings Management
  Future<bool> getBoolSetting(String key, {bool defaultValue = false}) async {
    return prefs.getBool(key) ?? defaultValue;
  }

  Future<bool> setBoolSetting(String key, bool value) async {
    return await prefs.setBool(key, value);
  }

  Future<String> getStringSetting(String key,
      {String defaultValue = ''}) async {
    return prefs.getString(key) ?? defaultValue;
  }

  Future<bool> setStringSetting(String key, String value) async {
    return await prefs.setString(key, value);
  }

  // Clear all data
  Future<bool> clearAllData() async {
    try {
      await prefs.clear();
      return true;
    } catch (e) {
      print('Error clearing all data: $e');
      return false;
    }
  }
}
