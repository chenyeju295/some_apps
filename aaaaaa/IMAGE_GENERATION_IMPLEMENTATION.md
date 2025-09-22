# 🎨 AI Image Generation Implementation

## 🎯 系统概述
完整的AI壁纸生成系统，使用Together AI的FLUX.1-dev模型，集成Crystal代币经济，支持多样化生成设置和批量处理。

## 🔧 技术实现

### API集成 - Together AI FLUX.1-dev
```dart
// API配置
static const String _baseUrl = 'https://api.together.xyz/v1/images/generations';
static const String _apiKey = 'tgp_v1_MmM3xO9NcFhbEUG7hpYkv9664YbSDWdib0n3DyeHCZ0';

// 生成请求
{
  'model': 'black-forest-labs/FLUX.1-dev',
  'prompt': enhancedPrompt,
  'width': sizeMap['width'],
  'height': sizeMap['height'], 
  'steps': quality == 'hd' ? 50 : 28,
  'seed': null,
}
```

### 提示词增强系统
根据风格自动增强用户提示词：
- **Realistic**: `photorealistic, high detail, professional photography`
- **Artistic**: `artistic style, creative composition, painterly`
- **Anime**: `anime style, manga artwork, Japanese animation`
- **Fantasy**: `fantasy art, magical, ethereal, otherworldly`
- **Vintage**: `vintage style, retro aesthetic, classic`
- **Modern**: `modern contemporary art, sleek design, minimalist`

## 💎 Crystal代币集成

### 消费标准
```dart
class CrystalCosts {
  static const int basicGeneration = 100;      // 标准生成
  static const int hdGeneration = 150;         // 高清生成  
  static const int premiumGeneration = 200;    // 高级生成
  static const int batchDiscount = 80;         // 批量折扣价格

  static int calculateGenerationCost({
    required String quality,
    required String style,
    bool isBatch = false,
  }) {
    int baseCost = basicGeneration;
    
    // 质量加成
    if (quality == 'hd') baseCost = hdGeneration;
    
    // 风格加成
    if (style == 'fantasy' || style == 'anime') {
      baseCost += 50; // 复杂风格额外费用
    }
    
    // 批量折扣
    if (isBatch) baseCost = batchDiscount;
    
    return baseCost;
  }
}
```

### 余额检查与扣费
```dart
// 生成前检查余额
final crystalCost = CrystalCosts.calculateGenerationCost(
  quality: selectedQuality.value,
  style: selectedStyle.value,
);

if (!balanceController.hasEnoughCrystals(crystalCost)) {
  // 显示余额不足提示
  return;
}

// 生成成功后扣费
balanceController.spendCrystals(crystalCost);
```

## 🎚️ 生成参数设置

### 图片尺寸选项
- **Portrait**: 1024x1792 (手机壁纸)
- **Square**: 1024x1024 (通用)
- **Landscape**: 1792x1024 (桌面壁纸)

### 质量选项
- **Standard**: 28 steps, 100 crystals
- **HD**: 50 steps, 150 crystals

### 风格选项
6种预设风格，每种都有专门的提示词增强。

## 🔄 生成流程

### 单张生成
1. **参数验证**: 检查提示词是否为空
2. **余额检查**: 验证Crystal余额是否充足
3. **提示词增强**: 根据选择的风格自动增强
4. **API调用**: 向Together AI发送生成请求
5. **结果处理**: 保存到历史记录，扣除代币
6. **UI反馈**: 显示生成结果和剩余余额

### 批量生成
1. **数量限制**: 最多5张批量生成
2. **成本计算**: 批量折扣价格 × 数量
3. **确认对话框**: 显示总成本和剩余余额
4. **逐个生成**: 依次生成每张图片
5. **进度反馈**: 实时显示生成进度

### 随机生成
从选定类别的预设提示词中随机选择一个进行生成。

## 🎛️ UI功能特性

### GenerationView增强
- **Crystal余额显示**: AppBar右上角实时显示余额
- **参数设置面板**: 尺寸、风格、质量选择
- **类别选择**: 横向滚动的类别卡片
- **提示词管理**: 多选、全选、清除功能
- **自定义提示词**: 支持500字符的详细描述
- **生成按钮**: 根据当前设置动态显示

### 生成成本提示
- 生成前显示将消耗的Crystal数量
- 生成过程中显示扣费信息
- 生成完成后显示剩余余额

## 🔗 系统集成点

### 与余额系统联动
```dart
// 在GenerationController中获取余额控制器
final balanceController = Get.find<BalanceController>();

// 检查余额
if (!balanceController.hasEnoughCrystals(crystalCost)) {
  // 余额不足处理
}

// 扣除费用
balanceController.spendCrystals(crystalCost);
```

### 与历史记录联动
生成成功的壁纸自动保存到本地历史记录，可在收藏页面查看。

### 与导航系统联动
生成完成后自动跳转到壁纸详情页面查看结果。

## 📱 用户体验

### 智能提示
- 余额不足时提示访问商城
- 生成参数变化时实时更新成本预览
- 批量生成时显示详细的成本分析

### 错误处理
- 网络错误重试机制
- API错误详细提示
- 生成失败不扣除代币

### 进度反馈
- 生成过程中显示Loading overlay
- 批量生成显示当前进度
- 成功/失败都有明确的用户反馈

## 🚀 性能优化

### API调用优化
- 批量生成间隔1秒，避免频率限制
- 错误重试机制
- 超时时间设置（30秒连接，60秒接收）

### 内存优化
- 图片URL直接使用，避免大文件缓存
- 及时释放生成状态
- 合理的历史记录数量限制

## 🔮 扩展能力

### 风格系统扩展
```dart
// 可轻松添加新风格
case 'cyberpunk':
  stylePrompt = 'cyberpunk style, neon lights, futuristic, dark';
  break;
```

### 参数系统扩展
- 支持添加更多图片尺寸
- 支持自定义steps参数
- 支持种子值保存和重复生成

### 代币系统扩展
- 支持VIP用户折扣
- 支持节日活动定价
- 支持批量包优惠

---

## ✅ 当前状态

### 已完成功能
- ✅ Together AI FLUX.1-dev集成
- ✅ 完整的Crystal代币扣费系统
- ✅ 6种风格的智能提示词增强
- ✅ 3种图片尺寸支持
- ✅ 标准/HD质量选择
- ✅ 单张、批量、随机生成
- ✅ 实时余额显示
- ✅ 完整的错误处理
- ✅ 进度反馈系统
- ✅ 历史记录集成

### 系统架构优势
- **模块化设计**: AI服务、余额控制、UI分离
- **响应式更新**: GetX实现实时状态同步
- **经济平衡**: 合理的代币消费设计
- **用户友好**: 清晰的成本提示和操作反馈
- **扩展性强**: 支持新风格、参数、功能的简单添加

这个AI生成系统为应用提供了完整的核心功能，结合Crystal经济体系，为用户提供了专业、流畅的AI壁纸生成体验。🎨✨
