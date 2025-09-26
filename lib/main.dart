import 'package:brevity/views/inner_screens/about_screen.dart';
import 'package:brevity/views/inner_screens/contact_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:brevity/controller/cubit/theme/theme_cubit.dart';
import 'package:brevity/models/article_model.dart';
import 'package:brevity/models/news_category.dart';
import 'package:brevity/views/auth/auth.dart';
import 'package:brevity/views/auth/email_verification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:brevity/firebase_options.dart';
import 'package:brevity/views/inner_screens/chat_screen.dart';
import 'package:brevity/views/inner_screens/profile.dart';
import 'package:brevity/views/inner_screens/search_result.dart';
import 'package:brevity/views/inner_screens/settings.dart';
import 'package:brevity/views/intro_screen/intro_screen.dart';
import 'package:brevity/views/inner_screens/bookmark.dart';
import 'package:brevity/views/nav_screen/home.dart';
import 'package:brevity/views/nav_screen/side_page.dart';
import 'package:brevity/views/splash_screen.dart';
import 'package:brevity/controller/services/bookmark_services.dart';
import 'package:brevity/controller/services/news_services.dart';
import 'package:brevity/controller/bloc/bookmark_bloc/bookmark_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:brevity/controller/cubit/user_profile/user_profile_cubit.dart';
import 'package:brevity/views/inner_screens/shared_news_screen.dart';
import 'package:brevity/controller/services/auth_service.dart';
import 'package:brevity/controller/services/backend_service.dart' as backend;
import 'package:brevity/controller/bloc/news_scroll_bloc/news_scroll_bloc.dart';
import 'package:brevity/controller/cubit/theme/theme_state.dart';
import 'package:brevity/models/theme_model.dart';
// ADD THESE IMPORTS
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:brevity/controller/services/notification_service.dart';
import 'package:app_links/app_links.dart';
// LOGGER IMPORT
import 'package:brevity/utils/logger.dart';

// Create a router with auth state handling
final _routes = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) {
        Log.d("[Main][RouteBuilder]: Building splash screen");
        return const SplashScreen();
      },
    ),
    GoRoute(
      path: '/auth',
      name: 'auth',
      builder: (context, state) {
        Log.d("[Main][RouteBuilder]: Building auth screen");
        return const AuthScreen();
      },
    ),
    GoRoute(
      path: '/email-verification',
      name: 'email-verification',
      builder: (context, state) {
        final email = state.uri.queryParameters['email'] ?? '';
        final isFromLogin = state.uri.queryParameters['isFromLogin'] == 'true';
        Log.d("[Main][RouteBuilder]: Building email verification screen for email: $email");
        return EmailVerificationScreen(
          email: email,
          isFromLogin: isFromLogin,
        );
      },
    ),
    GoRoute(
      path: '/contactUs',
      name: 'contactUs',
      builder: (context, state) {
        Log.d("[Main][RouteBuilder]: Building contact us screen");
        return const ContactUsScreen();
      },
    ),
    GoRoute(
      path: '/aboutUs',
      name: 'aboutUs',
      builder: (context, state) {
        Log.d("[Main][RouteBuilder]: Building about us screen");
        return const AboutUsScreen();
      },
    ),
    GoRoute(
      path: '/intro',
      name: 'intro',
      builder: (context, state) {
        Log.d("[Main][RouteBuilder]: Building introduction screen");
        return const IntroductionScreen();
      },
    ),
    GoRoute(
      path: '/sidepage',
      name: 'sidepage',
      pageBuilder: (context, state) {
        Log.d("[Main][RouteBuilder]: Building side page with slide transition");
        return CustomTransitionPage(
          key: state.pageKey,
          child: const SidePage(),
          transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
              ) {
            const begin = Offset(-1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            return SlideTransition(
              position: Tween(
                begin: begin,
                end: end,
              ).chain(CurveTween(curve: curve)).animate(animation),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 225),
        );
      },
      routes: [
        GoRoute(
          path: '/bookmark',
          name: 'bookmark',
          pageBuilder: (context, state) {
            Log.d("[Main][RouteBuilder]: Building bookmark screen with scale/fade transition");
            return CustomTransitionPage(
              key: state.pageKey,
              child: const BookmarkScreen(),
              transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                  ) {
                // Combine scale and fade animations
                return Align(
                  alignment: Alignment.center,
                  child: FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: animation.drive(
                        Tween<double>(
                          begin: 0.0,
                          end: 1.0,
                        ).chain(CurveTween(curve: Curves.easeInOutQuad)),
                      ),
                      child: child,
                    ),
                  ),
                );
              },
              transitionDuration: const Duration(milliseconds: 225),
            );
          },
        ),
        GoRoute(
          path: 'settings', // CORRECTED: Removed leading '/'
          name: 'settings',
          pageBuilder: (context, state) {
            Log.d("[Main][RouteBuilder]: Building settings screen with scale/fade transition");
            return CustomTransitionPage(
              key: state.pageKey,
              child: const SettingsScreen(),
              transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                  ) {
                return Align(
                  alignment: Alignment.center,
                  child: FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: animation.drive(
                        Tween<double>(
                          begin: 0.0,
                          end: 1.0,
                        ).chain(CurveTween(curve: Curves.easeInOutQuad)),
                      ),
                      child: child,
                    ),
                  ),
                );
              },
              transitionDuration: const Duration(milliseconds: 225),
            );
          },
        ),
        GoRoute(
          path: 'profile', // CORRECTED: Removed leading '/'
          name: 'profile',
          pageBuilder: (context, state) {
            Log.d("[Main][RouteBuilder]: Building profile screen with scale/fade transition");
            return CustomTransitionPage(
              key: state.pageKey,
              child: const ProfileScreen(),
              transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                  ) {
                return Align(
                  alignment: Alignment.center,
                  child: FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: animation.drive(
                        Tween<double>(
                          begin: 0.0,
                          end: 1.0,
                        ).chain(CurveTween(curve: Curves.easeInOutQuad)),
                      ),
                      child: child,
                    ),
                  ),
                );
              },
              transitionDuration: const Duration(milliseconds: 225),
            );
          },
        ),
        GoRoute(
          path: 'searchResults', // CORRECTED: Removed leading '/'
          name: 'searchResults',
          pageBuilder: (context, state) {
            final query = state.uri.queryParameters['query'] ?? '';
            Log.d("[Main][RouteBuilder]: Building search results screen for query: $query");
            return CustomTransitionPage(
              key: state.pageKey,
              child: SearchResultsScreen(
                query: state.uri.queryParameters['query']!, // Only query parameter
              ),
              transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                  ) {
                // Combine scale and fade animations
                return Align(
                  alignment: Alignment.center,
                  child: FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: animation.drive(
                        Tween<double>(
                          begin: 0.0,
                          end: 1.0,
                        ).chain(CurveTween(curve: Curves.easeInOutQuad)),
                      ),
                      child: child,
                    ),
                  ),
                );
              },
              transitionDuration: const Duration(milliseconds: 225),
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/home/:category',
      name: 'home',
      pageBuilder: (context, state) {
        final categoryIndex = int.parse(state.pathParameters['category'] ?? '0');
        final category = NewsCategory.fromIndex(categoryIndex);
        Log.d("[Main][RouteBuilder]: Building home screen for category: ${category.name} (index: $categoryIndex)");
        return CustomTransitionPage(
          key: state.pageKey,
          child: HomeScreen(category: category),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            return SlideTransition(
              position: Tween(
                begin: begin,
                end: end,
              ).chain(CurveTween(curve: curve)).animate(animation),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 225),
        );
      },
    ),
    GoRoute(
      path: '/chat',
      name: 'chat',
      pageBuilder: (context, state) {
        final article = state.extra as Article?;
        Log.d("[Main][RouteBuilder]: Building chat screen for article: ${article?.title ?? 'unknown'}");
        return CustomTransitionPage(
          key: state.pageKey,
          child: ChatScreen(article: article!),
          transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
              ) {
            // Combine scale and fade animations
            return Align(
              alignment: Alignment.center,
              child: FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: animation.drive(
                    Tween<double>(
                      begin: 0.0,
                      end: 1.0,
                    ).chain(CurveTween(curve: Curves.easeInOutQuad)),
                  ),
                  child: child,
                ),
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 225),
        );
      },
    ),
    GoRoute(
      path: '/share',
      name: 'share',
      builder: (context, state) {
        final id = state.uri.queryParameters['id'];
        Log.d("[Main][RouteBuilder]: Building shared news screen for id: $id");
        return SharedNewsScreen(newsId: id!);
      },
    ),
  ],
  // Add redirect logic to handle authentication state
  redirect: (context, state) {
    Log.d("[Main][Router]: Handling redirect for route: ${state.matchedLocation}");

    // Allow access to splash screen
    if (state.matchedLocation == '/splash') {
      Log.d("[Main][Router]: Allowing access to splash screen");
      return null;
    }

    // Check for routes that should be accessible without authentication
    final allowedPaths = ['/auth', '/intro', '/email-verification'];
    if (allowedPaths.contains(state.matchedLocation)) {
      Log.d("[Main][Router]: Allowing access to unauthenticated route: ${state.matchedLocation}");
      return null;
    }

    // Get the AuthService instance
    final authService = AuthService();

    // If user is not signed in, redirect to auth
    if (!authService.isAuthenticated) {
      Log.w("[Main][Router]: User not authenticated, redirecting to /auth");
      return '/auth';
    }

    // If user is authenticated but email is not verified, redirect to email verification
    if (authService.isAuthenticated && !authService.isEmailVerified) {
      final currentUser = authService.currentUser;
      if (currentUser != null) {
        Log.w("[Main][Router]: User authenticated but email not verified, redirecting to email verification");
        return '/email-verification?email=${Uri.encodeComponent(currentUser.email)}&isFromLogin=true';
      }
    }

    // Allow access to authenticated routes
    Log.d("[Main][Router]: User authenticated and verified, allowing access to: ${state.matchedLocation}");
    return null;
  },
);

void main() async {
  try {
    Log.i("[Main][main]: App initialization started");

    Log.d("[Main][main]: Ensuring widgets binding initialization");
    WidgetsFlutterBinding.ensureInitialized();
    Log.d("[Main][main]: Widgets binding initialization completed");

    Log.d("[Main][main]: Initializing Firebase");
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    Log.i("[Main][main]: Firebase initialization completed");

    Log.d("[Main][main]: Setting system UI mode to immersive sticky");
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    Log.d("[Main][main]: System UI mode set successfully");

    Log.d("[Main][main]: Initializing timezone data");
    tz.initializeTimeZones();
    Log.d("[Main][main]: Timezone data initialization completed");

    Log.d("[Main][main]: Initializing AuthService");
    await AuthService().initializeAuth();
    Log.i("[Main][main]: AuthService initialization completed");

    Log.d("[Main][main]: Initializing ApiService");
    await backend.ApiService().initializeTokens();
    Log.i("[Main][main]: ApiService initialization completed");

    Log.d("[Main][main]: Initializing notification service");
    final notificationService = NotificationService();
    await notificationService.initialize();
    Log.i("[Main][main]: Notification service initialization completed");

    Log.d("[Main][main]: Loading environment variables");
    await dotenv.load(fileName: ".env");
    Log.d("[Main][main]: Environment variables loaded successfully");

    Log.d("[Main][main]: Creating service instances");
    final bookmarkRepository = BookmarkServices();
    final newsService = NewsService();
    Log.d("[Main][main]: Service instances created successfully");

    Log.d("[Main][main]: Setting preferred device orientations");
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    Log.d("[Main][main]: Device orientations set to portrait only");

    Log.i("[Main][main]: All initialization completed successfully, starting app");
    Log.d("[Main][main]: Setting up deep linking");

    // Initialize deep linking
    final appLinks = AppLinks();
    String? initialLink;

    // Handle initial link
    try {
      initialLink = await appLinks.getInitialLinkString();
      if (initialLink != null) {
        Log.d("[Main][DeepLink]: Initial link received: $initialLink");
      }
    } catch (e) {
      Log.e("[Main][DeepLink]: Error getting initial link", e);
    }

    Log.d("[Main][main]: Setting up widget tree with providers and blocs");

    runApp(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: newsService),
          RepositoryProvider.value(value: bookmarkRepository),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) {
              Log.d("[Main][BlocProvider]: Creating NewsBloc");
              return NewsBloc(newsService: newsService);
            }),
            BlocProvider(create: (context) {
              Log.d("[Main][BlocProvider]: Creating BookmarkBloc");
              return BookmarkBloc(bookmarkRepository);
            }),
            BlocProvider(create: (context) {
              Log.d("[Main][BlocProvider]: Creating UserProfileCubit");
              return UserProfileCubit();
            }),
            BlocProvider(create: (context) {
              Log.d("[Main][BlocProvider]: Creating ThemeCubit and initializing theme");
              return ThemeCubit()..initializeTheme();
            }),
          ],
          child: DeepLinkHandler(
            appLinks: appLinks,
            initialLink: initialLink,
            child: const MyApp(),
          ),
        ),
      ),
    );

    Log.i("[Main][main]: App started successfully, runApp() executed");

  } catch (error, stackTrace) {
    Log.e("[Main][main]: Critical error during app initialization", error, stackTrace);
    // You might want to show an error screen or handle this gracefully
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Log.d("[Main][MyApp]: Building app widget tree");

    // UPDATED: Wrap with BlocBuilder to react to theme changes
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        Log.d("[Main][MyApp]: Building MaterialApp with theme: ${state.currentTheme.name}");
        return MaterialApp.router(
          title: 'Brevity',
          debugShowCheckedModeBanner: false,
          routerConfig: _routes,
          theme: createAppTheme(state.currentTheme),
        );
      },
    );
  }
}

class DeepLinkHandler extends StatefulWidget {
  final AppLinks appLinks;
  final String? initialLink;
  final Widget child;

  const DeepLinkHandler({
    super.key,
    required this.appLinks,
    this.initialLink,
    required this.child,
  });

  @override
  State<DeepLinkHandler> createState() => _DeepLinkHandlerState();
}

class _DeepLinkHandlerState extends State<DeepLinkHandler> {
  @override
  void initState() {
    super.initState();
    _handleInitialLink();
    _listenForLinks();
  }

  void _handleInitialLink() {
    if (widget.initialLink != null) {
      _handleDeepLink(widget.initialLink!);
    }
  }

  void _listenForLinks() {
    widget.appLinks.uriLinkStream.listen((uri) {
      Log.d("[DeepLink]: Received link: $uri");
      _handleDeepLink(uri.toString());
    }, onError: (err) {
      Log.e("[DeepLink]: Error receiving link", err);
    });
  }

  void _handleDeepLink(String link) {
    try {
      final uri = Uri.parse(link);
      Log.d("[DeepLink]: Parsed URI: $uri");

      if (uri.scheme == 'brevity' && uri.host == 'share') {
        final id = uri.queryParameters['id'];
        if (id != null && id.isNotEmpty) {
          Log.d("[DeepLink]: Navigating to shared news with id: $id");
          // Use a post-frame callback to ensure the widget tree is built
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              try {
                _routes.go('/share?id=$id');
              } catch (e, st) {
                Log.e('[DeepLink]: Failed to navigate via _routes.go', e, st);
              }
            }
          });
        } else {
          Log.w("[DeepLink]: No id parameter found in share link");
        }
      } else {
        Log.d("[DeepLink]: Ignoring non-share link: $link");
      }
    } catch (e) {
      Log.e("[DeepLink]: Error handling deep link: $link", e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
