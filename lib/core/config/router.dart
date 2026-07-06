import 'package:go_router/go_router.dart';
import '../../screens/splash_screen.dart';
import '../../screens/welcome_screen.dart';
import '../../screens/onboarding_screen.dart';
import '../../screens/main_layout_screen.dart';
import '../../screens/search_screen.dart';
import '../../screens/prompt_detail_screen.dart';
import '../../screens/category_detail_screen.dart';
import '../../screens/settings_screen.dart';
import '../../screens/history_screen.dart';
import '../../screens/notifications_screen.dart';
import '../../screens/premium_screen.dart';
import '../../screens/custom_prompt_screen.dart';
import '../../screens/prompt_generator_screen.dart';
import '../../screens/terms_conditions_screen.dart';

final goRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const MainLayoutScreen(),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: '/prompt-generator',
      builder: (context, state) => const PromptGeneratorScreen(),
    ),
    GoRoute(
      path: '/prompt/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return PromptDetailScreen(promptId: id);
      },
    ),
    GoRoute(
      path: '/category/:name',
      builder: (context, state) {
        final name = state.pathParameters['name']!;
        return CategoryDetailScreen(categoryName: name);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/terms',
      builder: (context, state) => const TermsConditionsScreen(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/premium',
      builder: (context, state) => const PremiumScreen(),
    ),
    GoRoute(
      path: '/custom-prompt',
      builder: (context, state) => const CustomPromptScreen(),
    ),
  ],
);
