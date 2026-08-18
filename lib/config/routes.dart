// config/routes.dart
import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/home_screen.dart';
import '../screens/level_one_screen.dart';
import '../screens/level_two_screen.dart';
import '../screens/level_three_screen.dart';
import '../screens/level_four_screen.dart';
import '../screens/video_player_screen.dart';
import '../screens/payment_screen.dart';
import '../screens/receipt_verification_screen.dart';
import '../screens/feedback_screen.dart';
import '../screens/privacy_policy_screen.dart';
import '../screens/example_page.dart';
import '../models/content_model.dart';

import '../screens/receipt_upload_screen.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/signup':
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
     case '/level-one':
        return MaterialPageRoute(builder: (_) => const LevelOneScreen());
      case '/level-two':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => LevelTwoScreen(categoryId: args['categoryId']),
        );
      case '/level-three':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => LevelThreeScreen(
            categoryId: args['categoryId'],
            categoryName: args['categoryName'],
          ),
        );
      case '/level-four':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => LevelFourScreen(
            categoryId: args['categoryId'],
            categoryName: args['categoryName'],
          ),
        );
      case '/video-player':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => VideoPlayerScreen(
            videoId: args['videoId'],
            videoUrl: args['videoUrl'],
          ),
        );
      case '/payment':
        return MaterialPageRoute(builder: (_) => const PaymentScreen());
      case '/receipt-upload':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ReceiptUploadScreen(
            planName: args['planName'],
            price: args['price'],
          ),
        );
      case '/receipt-verification':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ReceiptVerificationScreen(
            receiptUrl: args['receiptUrl'],
          ),
        );
      case '/feedback':
        return MaterialPageRoute(builder: (_) => const FeedbackScreen());
      case '/privacy-policy':
        return MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen());

      case '/example-page':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ExamplePage(
            examples: args['examples'] as List<Example>,
            initialIndex: args['index'] as int,
          ),
        );
      default:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
  }
}
