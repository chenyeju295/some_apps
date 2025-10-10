# API Integration Guide

This guide explains how to integrate an AI image generation API into the Fashion Wallpaper app.

## 🎯 Overview

The app is designed to work with any text-to-image AI API. You need to:
1. Choose an AI service provider
2. Get API credentials
3. Update the app configuration
4. Implement the API call

## 🔌 Supported AI Services

### 1. Stable Diffusion API

**Best for**: Cost-effective, customizable
**Website**: https://stablediffusionapi.com

```dart
// lib/app/data/services/generation_service.dart

Future<String?> _callAIAPI(String prompt, GenerationRequestModel request) async {
  try {
    final response = await http.post(
      Uri.parse('https://stablediffusionapi.com/api/v3/text2img'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'key': AppConstants.apiKey,
        'prompt': prompt,
        'negative_prompt': 'bad quality, low resolution, blurry',
        'width': request.width.toString(),
        'height': request.height.toString(),
        'samples': '1',
        'num_inference_steps': '30',
        'guidance_scale': 7.5,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['output'][0] as String;
    }
    return null;
  } catch (e) {
    print('Error calling Stable Diffusion API: $e');
    return null;
  }
}
```

### 2. OpenAI DALL-E API

**Best for**: High quality, easy integration
**Website**: https://platform.openai.com

```dart
Future<String?> _callAIAPI(String prompt, GenerationRequestModel request) async {
  try {
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/images/generations'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AppConstants.apiKey}',
      },
      body: jsonEncode({
        'model': 'dall-e-3',
        'prompt': prompt,
        'n': 1,
        'size': '1024x1792', // Closest to 9:16
        'quality': 'hd',
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'][0]['url'] as String;
    }
    return null;
  } catch (e) {
    print('Error calling DALL-E API: $e');
    return null;
  }
}
```

### 3. Replicate API (Stable Diffusion Models)

**Best for**: Variety of models
**Website**: https://replicate.com

```dart
Future<String?> _callAIAPI(String prompt, GenerationRequestModel request) async {
  try {
    // Start prediction
    final startResponse = await http.post(
      Uri.parse('https://api.replicate.com/v1/predictions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token ${AppConstants.apiKey}',
      },
      body: jsonEncode({
        'version': 'MODEL_VERSION_ID',
        'input': {
          'prompt': prompt,
          'width': request.width,
          'height': request.height,
        },
      }),
    );

    if (startResponse.statusCode == 201) {
      final startData = jsonDecode(startResponse.body);
      final predictionId = startData['id'];

      // Poll for result
      for (int i = 0; i < 60; i++) {
        await Future.delayed(const Duration(seconds: 2));
        
        final getResponse = await http.get(
          Uri.parse('https://api.replicate.com/v1/predictions/$predictionId'),
          headers: {
            'Authorization': 'Token ${AppConstants.apiKey}',
          },
        );

        if (getResponse.statusCode == 200) {
          final getData = jsonDecode(getResponse.body);
          if (getData['status'] == 'succeeded') {
            return getData['output'][0] as String;
          }
        }
      }
    }
    return null;
  } catch (e) {
    print('Error calling Replicate API: $e');
    return null;
  }
}
```

### 4. Custom API (Self-hosted)

If you're hosting your own model:

```dart
Future<String?> _callAIAPI(String prompt, GenerationRequestModel request) async {
  try {
    final response = await http.post(
      Uri.parse('${AppConstants.apiBaseUrl}/generate'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AppConstants.apiKey}',
      },
      body: jsonEncode({
        'prompt': prompt,
        'width': request.width,
        'height': request.height,
        'num_inference_steps': 30,
        'guidance_scale': 7.5,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['image_url'] as String;
    }
    return null;
  } catch (e) {
    print('Error calling custom API: $e');
    return null;
  }
}
```

## 📝 Step-by-Step Integration

### Step 1: Choose Your AI Service

Select one of the above services based on:
- **Budget**: DALL-E is more expensive, Stable Diffusion is cheaper
- **Quality**: DALL-E usually has better quality
- **Speed**: Varies by service and model
- **Customization**: Self-hosted gives most control

### Step 2: Get API Credentials

1. Sign up for your chosen service
2. Get your API key
3. Note the API endpoint URL

### Step 3: Update App Constants

Edit `lib/core/values/app_constants.dart`:

```dart
class AppConstants {
  // API Configuration
  static const String apiBaseUrl = 'https://your-api-url.com';
  static const String apiKey = 'your-api-key-here';
  
  // ... rest of the file
}
```

### Step 4: Implement API Call

Edit `lib/app/data/services/generation_service.dart`:

Replace the `_callAIAPI` method with your chosen implementation from above.

### Step 5: Handle Different Response Formats

Different APIs return images in different formats:

**Direct URL:**
```dart
return data['image_url'] as String;
```

**Base64 String:**
```dart
final base64Image = data['image_base64'] as String;
// Save to file and return local path
final tempDir = await getTemporaryDirectory();
final file = File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.png');
await file.writeAsBytes(base64Decode(base64Image));
return file.path;
```

**Array of URLs:**
```dart
final images = data['images'] as List;
return images.first as String;
```

### Step 6: Add Error Handling

```dart
Future<String?> _callAIAPI(String prompt, GenerationRequestModel request) async {
  try {
    final response = await http.post(
      // ... your API call
    ).timeout(const Duration(seconds: 120)); // Add timeout

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      // Validate response
      if (data['image_url'] == null) {
        throw Exception('No image URL in response');
      }
      
      return data['image_url'] as String;
    } else if (response.statusCode == 429) {
      throw Exception('Rate limit exceeded. Please try again later.');
    } else if (response.statusCode == 401) {
      throw Exception('Invalid API key');
    } else {
      throw Exception('API error: ${response.statusCode}');
    }
  } on TimeoutException {
    throw Exception('Request timeout. Please try again.');
  } catch (e) {
    print('Error calling AI API: $e');
    rethrow;
  }
}
```

## 🧪 Testing

### Test with Mock Data

Before integrating the real API, test with mock responses:

```dart
Future<String?> _callAIAPI(String prompt, GenerationRequestModel request) async {
  // Mock delay
  await Future.delayed(const Duration(seconds: 2));
  
  // Return test image
  return 'https://picsum.photos/${request.width}/${request.height}';
}
```

### Test API Connection

Create a test method:

```dart
Future<bool> testAPIConnection() async {
  try {
    final testPrompt = 'test image';
    final testRequest = GenerationRequestModel(
      prompt: testPrompt,
      style: 'test',
      outfitType: 'test',
      scene: 'test',
    );
    
    final result = await _callAIAPI(testPrompt, testRequest);
    return result != null;
  } catch (e) {
    print('API test failed: $e');
    return false;
  }
}
```

## 💰 Cost Considerations

### Pricing Comparison

**DALL-E 3**:
- ~$0.04 per HD image (1024x1792)
- High quality, slower

**Stable Diffusion API**:
- ~$0.002-0.01 per image
- Good quality, faster

**Replicate**:
- ~$0.0023 per second
- Varies by model

**Self-hosted**:
- Infrastructure costs
- No per-image costs
- Full control

### Optimize Costs

1. **Caching**: Cache generated images
2. **Lower quality for preview**: Generate low-res preview first
3. **Batch processing**: If API supports it
4. **Use smaller models**: For faster/cheaper generation

## 🔒 Security

### Protect API Keys

**DON'T:**
- Hardcode API keys in source code
- Commit keys to git
- Share keys publicly

**DO:**
- Use environment variables
- Store in secure backend
- Rotate keys regularly

### Better Approach: Backend Proxy

For production, create a backend:

```dart
// Instead of calling AI API directly, call your backend
Future<String?> _callAIAPI(String prompt, GenerationRequestModel request) async {
  final response = await http.post(
    Uri.parse('https://your-backend.com/api/generate'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $userToken', // User token, not API key
    },
    body: jsonEncode({
      'prompt': prompt,
      'style': request.style,
      'outfit': request.outfitType,
      'scene': request.scene,
    }),
  );
  // ... handle response
}
```

Your backend then:
1. Validates user
2. Checks token balance
3. Calls AI API with your secret key
4. Returns image URL

## 📊 Monitoring

Add analytics to track:
- Generation success rate
- Average generation time
- Error types and frequency
- Cost per generation

```dart
// Add to generation_service.dart
void _logGeneration({
  required bool success,
  required Duration duration,
  String? error,
}) {
  // Your analytics service
  print('Generation: ${success ? 'SUCCESS' : 'FAILED'}, '
        'Duration: ${duration.inSeconds}s, '
        'Error: ${error ?? 'none'}');
}
```

## 🚀 Advanced Features

### Retry Logic

```dart
Future<String?> _callAIAPIWithRetry(
  String prompt,
  GenerationRequestModel request, {
  int maxRetries = 3,
}) async {
  for (int i = 0; i < maxRetries; i++) {
    try {
      final result = await _callAIAPI(prompt, request);
      if (result != null) return result;
    } catch (e) {
      if (i == maxRetries - 1) rethrow;
      await Future.delayed(Duration(seconds: (i + 1) * 2));
    }
  }
  return null;
}
```

### Queue Management

For handling multiple requests:

```dart
class GenerationQueue {
  final Queue<GenerationRequest> _queue = Queue();
  bool _isProcessing = false;

  void addToQueue(GenerationRequest request) {
    _queue.add(request);
    _processQueue();
  }

  Future<void> _processQueue() async {
    if (_isProcessing || _queue.isEmpty) return;
    
    _isProcessing = true;
    while (_queue.isNotEmpty) {
      final request = _queue.removeFirst();
      await _processRequest(request);
    }
    _isProcessing = false;
  }
}
```

## 📞 Support

If you encounter issues:

1. Check API documentation
2. Verify API key is valid
3. Check rate limits
4. Review error messages
5. Test with curl/Postman first

## ✅ Checklist

Before going to production:

- [ ] API credentials configured
- [ ] Error handling implemented
- [ ] Timeout handling added
- [ ] Cost monitoring set up
- [ ] Backend proxy considered
- [ ] Rate limiting handled
- [ ] Retry logic added
- [ ] Analytics integrated
- [ ] Testing completed
- [ ] Documentation updated

---

**Need Help?** Check the specific API documentation for your chosen service.

