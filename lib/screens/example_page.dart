import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/example_widget.dart';
import '../models/content_model.dart';
import '../providers/auth_provider.dart';
import '../providers/subscription_provider.dart';
import '../widgets/custom_painter.dart';

class ExamplePage extends StatefulWidget {
  final List<Example> examples;
  final int initialIndex;

  const ExamplePage({
    super.key,
    required this.examples,
    required this.initialIndex,
  });

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _showSubscriptionDialog(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final bool isAuthenticated = authProvider.user != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isAuthenticated ? 'محتوى مدفوع' : 'تسجيل الدخول مطلوب',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          isAuthenticated
              ? 'فيديو الشرح ضمن المحتوى المدفوع، قم بالترقية لمشاهدته'
              : 'لمشاهدة فيديوهات الشرح يجب عليك تسجيل الدخول أولاً.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              if (isAuthenticated) {
                Navigator.pushNamed(context, '/payment');
              } else {
                Navigator.pushNamed(context, '/login');
              }
            },
            child: Text(isAuthenticated ? 'ترقية' : 'تسجيل الدخول'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentExample = widget.examples[_currentIndex];
    final subscriptionProvider = context.watch<SubscriptionProvider>();

    return CustomPaint(
      painter: PaperBackgroundPainter(),
      size: Size.infinite,
      child: ExampleWidget(
        data: currentExample,
        title: currentExample.name,
        onPrevious: _currentIndex > 0
            ? () {
                setState(() {
                  _currentIndex--;
                });
              }
            : null,
        onNext: _currentIndex < widget.examples.length - 1
            ? () {
                setState(() {
                  _currentIndex++;
                });
              }
            : null,
        onVideo: () {
          if (currentExample.video != null) {
            final canAccess = subscriptionProvider.canAccessContent(
              currentExample.video!.isPremium,
            );

            if (canAccess) {
              Navigator.pushNamed(
                context,
                '/video-player',
                arguments: {
                  'videoId': currentExample.id,
                  'videoUrl': currentExample.video!.videoUrl,
                },
              );
            } else {
              _showSubscriptionDialog(context);
            }
          }
        },
      ),
    );
  }
}
