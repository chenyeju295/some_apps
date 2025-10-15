import 'package:get/get.dart';
import 'storage_service.dart';
import '../models/user_model.dart';
import '../../../core/values/app_constants.dart';

class TokenService extends GetxService {
  // 使用 getter 方式动态获取依赖，避免初始化顺序问题
  StorageService get _storageService => Get.find<StorageService>();

  final RxInt tokenBalance = 0.obs;
  final RxInt totalGenerations = 0.obs;

  Future<TokenService> init() async {
    await _loadTokenBalance();
    return this;
  }

  Future<void> _loadTokenBalance() async {
    final user = _storageService.getUser();
    if (user != null) {
      tokenBalance.value = user.tokenBalance;
      totalGenerations.value = user.totalGenerations;
    } else {
      // First time user - give initial tokens
      tokenBalance.value = AppConstants.initialTokens;
      await _saveUser();
    }
  }

  Future<void> _saveUser() async {
    final user =
        _storageService.getUser() ??
        UserModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          tokenBalance: tokenBalance.value,
          createdAt: DateTime.now(),
          totalGenerations: totalGenerations.value,
        );

    final updatedUser = user.copyWith(
      tokenBalance: tokenBalance.value,
      totalGenerations: totalGenerations.value,
    );

    await _storageService.saveUser(updatedUser);
  }

  // Check if user has enough tokens
  bool hasEnoughTokens(int required) {
    return tokenBalance.value >= required;
  }

  // Consume tokens
  Future<bool> consumeTokens(int amount) async {
    if (!hasEnoughTokens(amount)) {
      return false;
    }

    tokenBalance.value -= amount;
    totalGenerations.value += 1;
    await _saveUser();
    return true;
  }

  // Add tokens (from IAP)
  Future<void> addTokens(int amount) async {
    tokenBalance.value += amount;
    await _saveUser();
  }

  // Get token balance
  int getBalance() {
    return tokenBalance.value;
  }

  // Check if user needs to buy tokens
  bool needsToBuyTokens() {
    return tokenBalance.value < AppConstants.tokensPerGeneration;
  }

  // Check if user has tokens (alias for hasEnoughTokens)
  bool hasTokens() {
    return hasEnoughTokens(AppConstants.tokensPerGeneration);
  }

  // Use a single token for generation
  void useToken() {
    consumeTokens(AppConstants.tokensPerGeneration);
  }

  // Get formatted balance string
  String getFormattedBalance() {
    return tokenBalance.value.toString();
  }

  // Reset tokens (for testing)
  Future<void> resetTokens() async {
    tokenBalance.value = AppConstants.initialTokens;
    totalGenerations.value = 0;
    await _saveUser();
  }
}
