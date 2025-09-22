import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/image_provider.dart' as img_provider;
import '../providers/user_provider.dart';
import '../models/generated_image.dart';
import '../theme/app_theme.dart';
import '../widgets/common/error_message.dart';

class GenerateScreen extends StatefulWidget {
  const GenerateScreen({super.key});

  @override
  State<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _promptController = TextEditingController();
  ImageStyle _selectedStyle = ImageStyle.realistic;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<img_provider.ImageProvider, UserProvider>(
        builder: (context, imageProvider, userProvider, child) {
          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  title: const Text('Generate Ocean Images'),
                  floating: true,
                  pinned: true,
                  expandedHeight: 100,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: AppTheme.oceanGradientDecoration,
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'AI-powered underwater scenes',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.monetization_on,
                                          color: Colors.amber,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${userProvider.tokenBalance}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  bottom: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    tabs: const [
                      Tab(
                          text: 'Generate',
                          icon: Icon(Icons.add_photo_alternate)),
                      Tab(text: 'Gallery', icon: Icon(Icons.photo_library)),
                    ],
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _GenerateTab(
                  promptController: _promptController,
                  selectedStyle: _selectedStyle,
                  onStyleChanged: (style) {
                    setState(() {
                      _selectedStyle = style;
                    });
                  },
                  imageProvider: imageProvider,
                  userProvider: userProvider,
                ),
                _GalleryTab(
                  imageProvider: imageProvider,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GenerateTab extends StatelessWidget {
  final TextEditingController promptController;
  final ImageStyle selectedStyle;
  final Function(ImageStyle) onStyleChanged;
  final img_provider.ImageProvider imageProvider;
  final UserProvider userProvider;

  const _GenerateTab({
    required this.promptController,
    required this.selectedStyle,
    required this.onStyleChanged,
    required this.imageProvider,
    required this.userProvider,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Token status
          if (userProvider.tokenBalance <= 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppTheme.coral.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.coral.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.warning_amber_outlined,
                    color: AppTheme.coral,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No Tokens Available',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.coral,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Purchase tokens in Profile to generate images',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.deepNavy,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

          // Prompt input
          Text(
            'Describe Your Underwater Scene',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: promptController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText:
                  'A school of colorful tropical fish swimming around a vibrant coral reef...',
              helperText:
                  'Be descriptive! The more details, the better the result.',
            ),
          ),

          const SizedBox(height: 24),

          // Style selection
          Text(
            'Choose Art Style',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ImageStyle.values.map((style) {
              final isSelected = style == selectedStyle;
              return ChoiceChip(
                label: Text(style.displayName),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) onStyleChanged(style);
                },
                selectedColor: AppTheme.oceanBlue,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.deepNavy,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Prompt suggestions
          Text(
            'Need Inspiration?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _promptSuggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _promptSuggestions[index];
                return Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: 12),
                  child: Card(
                    child: InkWell(
                      onTap: () {
                        promptController.text = suggestion;
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          suggestion,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Generate button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed:
                  userProvider.tokenBalance > 0 && !imageProvider.isGenerating
                      ? () => _generateImage(context)
                      : null,
              icon: imageProvider.isGenerating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(
                imageProvider.isGenerating
                    ? 'Generating...'
                    : 'Generate Image (1 Token)',
              ),
              style: AppTheme.primaryButtonStyle.copyWith(
                padding: MaterialStateProperty.all(
                  const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),

          if (imageProvider.error != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.coral.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.coral.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: AppTheme.coral),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      imageProvider.error!,
                      style: TextStyle(color: AppTheme.deepNavy),
                    ),
                  ),
                  TextButton(
                    onPressed: () => imageProvider.clearError(),
                    child: const Text('Dismiss'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _generateImage(BuildContext context) async {
    final prompt = promptController.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a prompt')),
      );
      return;
    }

    final result = await imageProvider.generateImage(
      prompt: prompt,
      style: selectedStyle,
      onTokensUsed: (tokens) {
        userProvider.useTokens(tokens);
        userProvider.incrementImagesGenerated();
      },
    );

    if (result != null) {
      promptController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image generated successfully!')),
      );
    }
  }

  static const List<String> _promptSuggestions = [
    'A school of colorful tropical fish swimming around a vibrant coral reef',
    'A majestic sea turtle gliding through crystal clear blue water',
    'An ancient shipwreck covered in coral and marine life',
    'A diver exploring an underwater cave filled with bioluminescent creatures',
    'A pod of dolphins playing in sunbeams filtering through water',
    'A giant octopus camouflaged among rocks and seaweed',
    'An underwater garden of sea anemones and clownfish',
    'A deep ocean scene with mysterious depths and whale songs',
  ];
}

class _GalleryTab extends StatelessWidget {
  final img_provider.ImageProvider imageProvider;

  const _GalleryTab({
    required this.imageProvider,
  });

  @override
  Widget build(BuildContext context) {
    if (imageProvider.images.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No images generated yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Create your first underwater scene!',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: imageProvider.images.length,
      itemBuilder: (context, index) {
        final image = imageProvider.images[index];
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _showImageDetail(context, image),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: AppTheme.lightAqua,
                    child: const Center(
                      child: Icon(
                        Icons.image,
                        size: 48,
                        color: AppTheme.oceanBlue,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        image.prompt,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.oceanBlue,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              image.style.displayName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (image.isFavorite)
                            Icon(
                              Icons.favorite,
                              color: AppTheme.coral,
                              size: 16,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showImageDetail(BuildContext context, GeneratedImage image) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 300,
              width: double.infinity,
              color: AppTheme.lightAqua,
              child: const Center(
                child: Icon(
                  Icons.image,
                  size: 100,
                  color: AppTheme.oceanBlue,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    image.prompt,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Chip(
                        label: Text(image.style.displayName),
                        backgroundColor: AppTheme.lightAqua,
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          context
                              .read<img_provider.ImageProvider>()
                              .toggleImageFavorite(image.id);
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          image.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: AppTheme.coral,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
