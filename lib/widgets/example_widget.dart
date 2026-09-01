import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/content_model.dart';

class ExampleWidget extends StatefulWidget {
  final Example data;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onVideo;
  final String? title;

  const ExampleWidget({
    super.key,
    required this.data,
    this.onPrevious,
    this.onNext,
    this.onVideo,
    this.title,
  });

  @override
  State<ExampleWidget> createState() => _ExampleWidgetState();
}

class _ExampleWidgetState extends State<ExampleWidget> {
  int? _selectedIndex;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void didUpdateWidget(ExampleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.id != widget.data.id) {
      _selectedIndex = null;
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSound(bool isCorrect) async {
    try {
      final String assetPath = isCorrect ? 'sounds/clapping.mp3' : 'sounds/fail.mp3';
      await _audioPlayer.stop(); // Stop any currently playing sound
      await _audioPlayer.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          widget.title ?? 'تمرين',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // ---------- Question Image Section ----------
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 0), // Full width
                      child: Image.network(
                        widget.data.questionImageUrl,
                        width: double.infinity,
                        fit: BoxFit.fitWidth,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                        errorBuilder: (_, _, _) => Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image_rounded,
                                  size: 64, color: colorScheme.outline),
                              const SizedBox(height: 12),
                              Text('فشل تحميل الصورة',
                                  style: theme.textTheme.bodyMedium),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ---------- Text Instruction Section (Centered) ----------
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      child: Center( // Centered instruction as requested
                        child: Text(
                          'اختر الإجابة الصحيحة',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    
                    GridView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 2.5, // Adjusted for balanced centering
                      ),
                      itemCount: widget.data.solutions.length,
                      itemBuilder: (context, index) {
                        final solution = widget.data.solutions[index];
                        final isSelected = _selectedIndex == index;
                        final hasResponded = _selectedIndex != null;

                        Color borderColor = colorScheme.outlineVariant;
                        Color backgroundColor = colorScheme.surface;
                        Color textColor = colorScheme.onSurface;
                        IconData? icon;

                        if (hasResponded) {
                          if (solution.isCorrect) {
                            borderColor = Colors.green;
                            backgroundColor = Colors.green.withValues(alpha: 0.1);
                            textColor = Colors.green.shade800;
                            icon = Icons.check_circle_rounded;
                          } else if (isSelected) {
                            borderColor = Colors.red;
                            backgroundColor = Colors.red.withValues(alpha: 0.1);
                            textColor = Colors.red.shade800;
                            icon = Icons.cancel_rounded;
                          }
                        } else if (isSelected) {
                          borderColor = colorScheme.primary;
                          backgroundColor = colorScheme.primary.withValues(alpha: 0.05);
                        }

                        return InkWell(
                          onTap: hasResponded
                              ? null
                              : () {
                                  setState(() => _selectedIndex = index);
                                  _playSound(solution.isCorrect);
                                },
                          borderRadius: BorderRadius.circular(16),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: borderColor,
                                width: (isSelected || (hasResponded && solution.isCorrect)) ? 2.5 : 1.5,
                              ),
                            ),
                            child: Stack( // Center content perfectly
                              alignment: Alignment.center,
                              children: [
                                if (icon != null)
                                  Positioned(
                                    right: 8,
                                    child: Icon(icon, color: borderColor, size: 20),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                  child: Text(
                                    solution.label,
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: textColor,
                                      fontWeight: FontWeight.w600, // Reverted from bold/bigger
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // ---------- Bottom Navigation (Fixed) ----------
            Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(top: BorderSide(color: colorScheme.outlineVariant, width: 0.5)),
              ),
              child: Row(
                children: [
                  if (widget.onPrevious != null)
                    _buildNavIconButton(
                      onPressed: widget.onPrevious,
                      icon: Icons.arrow_back_rounded,
                      colorScheme: colorScheme,
                    )
                  else
                    const SizedBox(width: 48),
                  const Spacer(),
                    ElevatedButton.icon(
                      onPressed: widget.onVideo,
                      icon: const Icon(Icons.play_circle_rounded),
                      label: const Text('فيديو الشرح'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  const Spacer(),
                  if (widget.onNext != null)
                    _buildNavIconButton(
                      onPressed: widget.onNext,
                      icon: Icons.arrow_forward_rounded,
                      colorScheme: colorScheme,
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIconButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required ColorScheme colorScheme,
  }) {
    final bool isEnabled = onPressed != null;
    return Material(
      color: isEnabled
          ? colorScheme.secondaryContainer.withValues(alpha: 0.5)
          : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isEnabled
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}
