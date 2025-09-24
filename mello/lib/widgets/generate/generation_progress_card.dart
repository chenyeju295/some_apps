import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../providers/enhanced_image_provider.dart';

class GenerationProgressCard extends StatelessWidget {
  final EnhancedImageProvider imageProvider;

  const GenerationProgressCard({
    super.key,
    required this.imageProvider,
  });

  @override
  Widget build(BuildContext context) {
    if (!imageProvider.isGenerating) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.oceanBlue.withOpacity(0.1),
            AppTheme.seaFoam.withOpacity(0.15),
            AppTheme.tropicalTeal.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.oceanBlue.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.oceanBlue.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppTheme.oceanGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.oceanBlue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      value: imageProvider.generationProgress,
                      strokeWidth: 3,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                      backgroundColor: Colors.white.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGenerationStateText(imageProvider.generationState),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.deepNavy,
                          ),
                    ),
                    if (imageProvider.generationStatusMessage.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        imageProvider.generationStatusMessage,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.oceanBlue,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.seaFoam.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(imageProvider.generationProgress * 100).toInt()}%',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppTheme.deepNavy,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: imageProvider.generationProgress,
              backgroundColor: AppTheme.lightAqua.withOpacity(0.5),
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.oceanBlue),
              minHeight: 8,
            ),
          ),

          const SizedBox(height: 12),

          // Stage indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStageIndicator(
                context,
                icon: Icons.edit_note,
                label: 'Prepare',
                isActive:
                    imageProvider.generationState == GenerationState.preparing,
                isCompleted: imageProvider.generationProgress > 0.1,
              ),
              _buildStageIndicator(
                context,
                icon: Icons.auto_awesome,
                label: 'Generate',
                isActive:
                    imageProvider.generationState == GenerationState.generating,
                isCompleted: imageProvider.generationProgress > 0.6,
              ),
              _buildStageIndicator(
                context,
                icon: Icons.image_outlined,
                label: 'Process',
                isActive:
                    imageProvider.generationState == GenerationState.processing,
                isCompleted: imageProvider.generationProgress > 0.8,
              ),
              _buildStageIndicator(
                context,
                icon: Icons.save_alt,
                label: 'Save',
                isActive:
                    imageProvider.generationState == GenerationState.saving,
                isCompleted:
                    imageProvider.generationState == GenerationState.completed,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStageIndicator(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isActive,
    required bool isCompleted,
  }) {
    Color iconColor;
    Color labelColor;

    if (isCompleted) {
      iconColor = AppTheme.seaFoam;
      labelColor = AppTheme.seaFoam;
    } else if (isActive) {
      iconColor = AppTheme.oceanBlue;
      labelColor = AppTheme.oceanBlue;
    } else {
      iconColor = Colors.grey[400]!;
      labelColor = Colors.grey[500]!;
    }

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isCompleted || isActive
                ? iconColor.withOpacity(0.2)
                : Colors.grey[100],
            shape: BoxShape.circle,
            border: Border.all(
              color: iconColor,
              width: isActive ? 2 : 1,
            ),
          ),
          child: Icon(
            isCompleted ? Icons.check : icon,
            color: iconColor,
            size: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  String _getGenerationStateText(GenerationState state) {
    switch (state) {
      case GenerationState.preparing:
        return 'Preparing Your Request';
      case GenerationState.generating:
        return 'Creating Ocean Masterpiece';
      case GenerationState.processing:
        return 'Processing Image Data';
      case GenerationState.saving:
        return 'Saving to Gallery';
      case GenerationState.completed:
        return 'Creation Complete!';
      default:
        return 'Generating Amazing Content';
    }
  }
}
