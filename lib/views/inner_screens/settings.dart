import 'dart:math';
import 'dart:ui';

import 'package:blyft/controller/cubit/user_profile/user_profile_cubit.dart';
import 'package:blyft/controller/cubit/user_profile/user_profile_state.dart';
import 'package:blyft/controller/services/auth_service.dart';
import 'package:blyft/l10n/app_localizations.dart';
import 'package:blyft/views/common_widgets/common_appbar.dart';
import 'package:blyft/views/inner_screens/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../controller/cubit/theme/theme_cubit.dart';
import '../../controller/cubit/theme/theme_state.dart';
import '../../controller/cubit/locale/locale_cubit.dart';
import '../../controller/cubit/locale/locale_state.dart';
import '../../controller/services/notification_service.dart';
import '../../models/theme_model.dart';

class CircularTimePicker extends StatefulWidget {
  final String initialTime;
  final Color themeColor;
  final Function(String) onTimeChanged;

  const CircularTimePicker({
    super.key,
    required this.initialTime,
    required this.themeColor,
    required this.onTimeChanged,
  });

  @override
  State<CircularTimePicker> createState() => _CircularTimePickerState();
}

class _CircularTimePickerState extends State<CircularTimePicker> {
  late int _selectedHour;
  late int _selectedMinute;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    final timeParts = widget.initialTime.split(':');
    _selectedHour = int.parse(timeParts[0]);
    _selectedMinute = int.parse(timeParts[1]);
    _updateAngleFromTime();
  }

  void _updateAngleFromTime() {
    // Convert time to angle (24-hour format, 15 degrees per hour, 0.25 degrees per minute)
  }

  void _updateTimeFromAngle(double angle) {
    // Convert angle back to time
    double degrees = angle * 180 / pi;
    double totalMinutes = degrees / 0.25; // 0.25 degrees per minute (360/1440)
    int hour = (totalMinutes / 60).floor() % 24;
    int minute = (totalMinutes % 60).round();

    // Round minute to nearest 5 minutes
    minute = ((minute / 5).round() * 5) % 60;

    if (hour != _selectedHour || minute != _selectedMinute) {
      setState(() {
        _selectedHour = hour;
        _selectedMinute = minute;
      });
      final timeString = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      widget.onTimeChanged(timeString);
      HapticFeedback.lightImpact(); // Haptic feedback
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onPanStart: (details) {
        setState(() => _isDragging = true);
        _handleDrag(details.localPosition, Size(200, 200));
      },
      onPanUpdate: (details) {
        _handleDrag(details.localPosition, Size(200, 200));
      },
      onPanEnd: (details) {
        setState(() => _isDragging = false);
      },
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.cardColor,
          boxShadow: [
            BoxShadow(
              color: widget.themeColor.withAlpha(50),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: CustomPaint(
          painter: _ClockPainter(
            selectedHour: _selectedHour,
            selectedMinute: _selectedMinute,
            themeColor: widget.themeColor,
            isDragging: _isDragging,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: _isDragging ? widget.themeColor : theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _selectedHour < 12 ? 'AM' : 'PM',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(150),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleDrag(Offset position, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final angle = (position - center).direction;
    _updateTimeFromAngle(angle);
  }
}

class _ClockPainter extends CustomPainter {
  final int selectedHour;
  final int selectedMinute;
  final Color themeColor;
  final bool isDragging;

  _ClockPainter({
    required this.selectedHour,
    required this.selectedMinute,
    required this.themeColor,
    required this.isDragging,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw hour markers
    for (int i = 0; i < 24; i++) {
      final angle = (i * 15) * (pi / 180); // 15 degrees per hour
      final markerLength = i % 6 == 0 ? 15.0 : 8.0; // Longer markers every 6 hours
      final startPoint = center + Offset(cos(angle) * (radius - markerLength), sin(angle) * (radius - markerLength));
      final endPoint = center + Offset(cos(angle) * radius, sin(angle) * radius);

      paint.color = i == selectedHour ? themeColor : Colors.grey.withAlpha(100);
      paint.strokeWidth = i == selectedHour ? 3 : 2;
      canvas.drawLine(startPoint, endPoint, paint);
    }

    // Draw minute markers (every 5 minutes)
    paint.strokeWidth = 1;
    for (int i = 0; i < 60; i += 5) {
      final angle = i * 6 * (pi / 180); // 6 degrees per 5 minutes
      final startPoint = center + Offset(cos(angle) * (radius - 5), sin(angle) * (radius - 5));
      final endPoint = center + Offset(cos(angle) * radius, sin(angle) * radius);

      final isSelectedMinute = i == selectedMinute;
      paint.color = isSelectedMinute ? themeColor : Colors.grey.withAlpha(50);
      canvas.drawLine(startPoint, endPoint, paint);
    }

    // Draw selection indicator
    final selectedAngle = (selectedHour % 24) * 15 * (pi / 180) + selectedMinute * 0.25 * (pi / 180);
    final indicatorPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = themeColor;

    final indicatorPosition = center + Offset(
      cos(selectedAngle) * (radius - 25),
      sin(selectedAngle) * (radius - 25),
    );

    canvas.drawCircle(indicatorPosition, isDragging ? 8 : 6, indicatorPaint);
  }

  @override
  bool shouldRepaint(_ClockPainter oldDelegate) {
    return oldDelegate.selectedHour != selectedHour ||
           oldDelegate.selectedMinute != selectedMinute ||
           oldDelegate.isDragging != isDragging;
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'English';
  late AnimationController _animationController;
  late Animation<double> _animation;
  late AnimationController _particleAnimationController;
  bool _reminderEnabled = false;
  String _reminderTime = '09:00';
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();

    context.read<UserProfileCubit>().loadUserProfile();

    // Load current language from LocaleCubit
    final localeCubit = context.read<LocaleCubit>();
    _selectedLanguage = localeCubit.getCurrentLanguageName();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    _particleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _particleAnimationController.addListener(() {
      setState(() {});
    });

    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
    final enabled = await _notificationService.isReminderEnabled();
    final time = await _notificationService.getReminderTime();
    setState(() {
      _reminderEnabled = enabled;
      _reminderTime = time;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _particleAnimationController.dispose();
    super.dispose();
  }

  void _showLanguageDialog() {
    final themeCubit = context.read<ThemeCubit>();
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder:
          (context) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: themeCubit.currentTheme.primaryColor.withAlpha(50),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 5,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(AppLocalizations.of(context)!.selectLanguage, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 15),
                    Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.4,
                      ),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildLanguageOption('English'),
                            _buildLanguageOption('Spanish'),
                            _buildLanguageOption('French'),
                            _buildLanguageOption('German'),
                            _buildLanguageOption('Hindi'),
                            _buildLanguageOption('Chinese'),
                            _buildLanguageOption('Japanese'),
                            _buildLanguageOption('Russian'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildLanguageOption(String language) {
    final isSelected = _selectedLanguage == language;
    final theme = Theme.of(context);
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? themeState.currentTheme.primaryColor.withAlpha(
                      (0.1 * 255).toInt(),
                    )
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text(
              language,
              style: TextStyle(
                color:
                    isSelected
                        ? themeState.currentTheme.primaryColor
                        : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            trailing:
                isSelected
                    ? Icon(
                      Icons.check_circle,
                      color: themeState.currentTheme.primaryColor,
                    )
                    : null,
            onTap: () {
              setState(() => _selectedLanguage = language);
              // Update the app's locale using LocaleCubit
              context.read<LocaleCubit>().changeLocale(language);
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  void _showThemeColorPicker() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder:
          (context) => BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, themeState) {
              return BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Dialog(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: themeState.currentTheme.primaryColor.withAlpha(
                            50,
                          ),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.selectTheme,
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 15,
                          runSpacing: 15,
                          alignment: WrapAlignment.center,
                          children:
                              AppTheme.availableThemes.map((appTheme) {
                                final isSelected =
                                    themeState.currentTheme.name ==
                                    appTheme.name;
                                return GestureDetector(
                                  onTap: () {
                                    context.read<ThemeCubit>().changeTheme(
                                      appTheme.copyWith(
                                        isDarkMode:
                                            themeState.currentTheme.isDarkMode,
                                      ),
                                    );
                                    Navigator.pop(context);
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      color: appTheme.primaryColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color:
                                            isSelected
                                                ? theme.colorScheme.onSurface
                                                : Colors.transparent,
                                        width: 3,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: appTheme.primaryColor
                                              .withAlpha(100),
                                          blurRadius: isSelected ? 12 : 5,
                                          spreadRadius: isSelected ? 2 : 0,
                                        ),
                                      ],
                                    ),
                                    child:
                                        isSelected
                                            ? Icon(
                                              Icons.check,
                                              color:
                                                  theme.colorScheme.onPrimary,
                                            )
                                            : null,
                                  ),
                                );
                              }).toList(),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Close',
                            style: TextStyle(
                              color: themeState.currentTheme.primaryColor,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
    );
  }

  void _confirmDeleteProfile() {
    final theme = Theme.of(context);
    final TextEditingController passwordController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Dialog(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withAlpha(50),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Color.fromARGB(255, 198, 48, 37),
                            size: 60,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppLocalizations.of(context)!.deleteAccount,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 198, 48, 37),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppLocalizations.of(context)!.deleteAccountWarning,
                            style: theme.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),

                          // Password input field (shown for all users, but server will determine if needed)
                          TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Enter your password to confirm',
                              hintText: 'Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.lock),
                            ),
                          ),

                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed:
                                    isLoading
                                        ? null
                                        : () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.shade700,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(AppLocalizations.of(context)!.cancel),
                              ),
                              ElevatedButton(
                                onPressed:
                                    isLoading
                                        ? null
                                        : () async {
                                          final password =
                                              passwordController.text.trim();

                                          setState(() {
                                            isLoading = true;
                                          });

                                          try {
                                            await AuthService().deleteAccount(
                                              password:
                                                  password.isEmpty
                                                      ? null
                                                      : password,
                                              context: context,
                                            );

                                            // If we reach here, deletion was successful
                                            // The AuthService will handle navigation
                                            if (context.mounted) {
                                              Navigator.pop(context);
                                            }
                                          } catch (e) {
                                            setState(() {
                                              isLoading = false;
                                            });

                                            if (context.mounted) {
                                              String errorMessage =
                                                  e.toString();
                                              // Remove "Exception: " prefix if present
                                              if (errorMessage.startsWith(
                                                'Exception: ',
                                              )) {
                                                errorMessage = errorMessage
                                                    .substring(11);
                                              }

                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(errorMessage),
                                                  backgroundColor: Colors.red,
                                                  duration: const Duration(
                                                    seconds: 3,
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    198,
                                    48,
                                    37,
                                  ),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child:
                                    isLoading
                                        ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                        : Text(AppLocalizations.of(context)!.deleteAccount),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          ),
    );
  }

  bool _hasProfileImage(UserProfileState state, user) {
    return state.localProfileImage != null ||
        (user?.profileImageUrl != null && user!.profileImageUrl!.isNotEmpty);
  }

  ImageProvider? _getProfileImage(UserProfileState state, user) {
    if (state.localProfileImage != null) {
      return FileImage(state.localProfileImage!);
    }
    if (user?.profileImageUrl != null && user!.profileImageUrl!.isNotEmpty) {
      return NetworkImage(user.profileImageUrl!);
    }
    return null;
  }

  void _showTimePickerDialog() {
    final theme = Theme.of(context);
    final themeCubit = context.read<ThemeCubit>();

    showDialog(
      context: context,
      builder:
          (context) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: themeCubit.currentTheme.primaryColor.withAlpha(50),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.setReminderTime,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 20),
                    CircularTimePicker(
                      initialTime: _reminderTime,
                      themeColor: themeCubit.currentTheme.primaryColor,
                      onTimeChanged: (time) {
                        setState(() {
                          _reminderTime = time;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(AppLocalizations.of(context)!.cancel),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await _notificationService.setReminderTime(
                              _reminderTime,
                            );
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Reminder time set to $_reminderTime',
                                  ),
                                  backgroundColor:
                                      themeCubit.currentTheme.primaryColor,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                themeCubit.currentTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(AppLocalizations.of(context)!.save),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Future<void> _toggleReminderEnabled(bool enabled) async {
    if (enabled) {
      // Request permissions first
      final hasPermission = await _notificationService.requestPermissions();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.notificationPermissionRequired,
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }

    await _notificationService.setReminderEnabled(enabled);
    setState(() {
      _reminderEnabled = enabled;
    });

    if (mounted) {
      final message =
          enabled
              ? AppLocalizations.of(context)!.dailyRemindersEnabled(_reminderTime)
              : AppLocalizations.of(context)!.dailyRemindersDisabled;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: enabled ? Colors.green : Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return BlocBuilder<UserProfileCubit, UserProfileState>(
            builder: (context, state) {
              if (state.status == UserProfileStatus.error) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error: ${state.errorMessage}',
                        style: theme.textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    backgroundColor: theme.colorScheme.surface.withAlpha(
                      (0.85 * 255).toInt(),
                    ),
                    expandedHeight: 220,
                    pinned: true,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                      color: theme.colorScheme.onSurface.withAlpha(
                        (0.7 * 255).toInt(),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: ParticlesHeader(
                        title: "",
                        themeColor: themeState.currentTheme.primaryColor,
                        particleAnimation: _particleAnimationController,
                        child:
                            state.status == UserProfileStatus.loading
                                ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: themeState
                                            .currentTheme
                                            .primaryColor
                                            .withAlpha(50),
                                      ),
                                      child: CircleAvatar(
                                        radius: 40,
                                        backgroundColor: themeState
                                            .currentTheme
                                            .primaryColor
                                            .withAlpha((0.2 * 255).toInt()),
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  theme.brightness ==
                                                          Brightness.light
                                                      ? Colors.black54
                                                      : Colors.white70,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      height: 20,
                                      width: 120,
                                      decoration: BoxDecoration(
                                        color:
                                            theme
                                                .colorScheme
                                                .surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      height: 16,
                                      width: 180,
                                      decoration: BoxDecoration(
                                        color:
                                            theme
                                                .colorScheme
                                                .surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ],
                                )
                                : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            themeState
                                                .currentTheme
                                                .primaryColor,
                                            themeState.currentTheme.primaryColor
                                                .withAlpha(200),
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: themeState
                                                .currentTheme
                                                .primaryColor
                                                .withAlpha(125),
                                            blurRadius: 20,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: CircleAvatar(
                                        radius: 40,
                                        backgroundColor:
                                            _hasProfileImage(state, state.user)
                                                ? Colors.transparent
                                                : themeState
                                                    .currentTheme
                                                    .primaryColor
                                                    .withAlpha(
                                                      (0.2 * 255).toInt(),
                                                    ),
                                        backgroundImage: _getProfileImage(
                                          state,
                                          state.user,
                                        ),
                                        child:
                                            !_hasProfileImage(state, state.user)
                                                ? Icon(
                                                  Icons.person,
                                                  size: 48,
                                                  color: Colors.white,
                                                )
                                                : null,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      state.user?.displayName ?? 'User',
                                      style: theme.textTheme.headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            shadows: const [
                                              Shadow(
                                                color: Colors.black45,
                                                blurRadius: 5,
                                              ),
                                            ],
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      state.user?.email ?? '',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: theme.colorScheme.onSurface
                                                .withAlpha((0.8 * 255).toInt()),
                                            shadows: const [
                                              Shadow(
                                                color: Colors.black45,
                                                blurRadius: 5,
                                              ),
                                            ],
                                          ),
                                    ),
                                  ],
                                ),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate([
                      FadeTransition(
                        opacity: _animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.1),
                            end: Offset.zero,
                          ).animate(_animation),
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    8,
                                    0,
                                    8,
                                  ),
                                  child: Text(
                                    AppLocalizations.of(context)!.settings,
                                    style: theme.textTheme.headlineMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.2,
                                        ),
                                  ),
                                ),
                              ),
                              _buildSectionHeader(
                                AppLocalizations.of(context)!.profile,
                                themeState.currentTheme.primaryColor,
                              ),
                              _buildAnimatedCard(
                                child: _buildListTile(
                                  icon: Icons.person,
                                  title: AppLocalizations.of(context)!.editProfile,
                                  subtitle: AppLocalizations.of(context)!.updatePersonalInfo,
                                  themeColor:
                                      themeState.currentTheme.primaryColor,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => const ProfileScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              _buildSectionHeader(
                                AppLocalizations.of(context)!.appearance,
                                themeState.currentTheme.primaryColor,
                              ),
                              _buildAnimatedCard(
                                child: _buildSwitchTile(
                                  icon: Icons.dark_mode,
                                  title: AppLocalizations.of(context)!.darkMode,
                                  value: themeState.currentTheme.isDarkMode,
                                  themeColor:
                                      themeState.currentTheme.primaryColor,
                                  onChanged:
                                      (val) => context
                                          .read<ThemeCubit>()
                                          .toggleDarkMode(val),
                                ),
                              ),
                              _buildAnimatedCard(
                                child: _buildListTile(
                                  icon: Icons.color_lens,
                                  title: AppLocalizations.of(context)!.appTheme,
                                  subtitle: AppLocalizations.of(context)!.changeAppAccentColor,
                                  themeColor:
                                      themeState.currentTheme.primaryColor,
                                  trailingWidget: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color:
                                          themeState.currentTheme.primaryColor,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: themeState
                                              .currentTheme
                                              .primaryColor
                                              .withAlpha((0.4 * 255).toInt()),
                                          blurRadius: 5,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                  onTap: _showThemeColorPicker,
                                ),
                              ),
                              _buildSectionHeader(
                                AppLocalizations.of(context)!.preferences,
                                themeState.currentTheme.primaryColor,
                              ),
                              _buildAnimatedCard(
                                child: _buildSwitchTile(
                                  icon: Icons.notifications_active,
                                  title: AppLocalizations.of(context)!.pushNotifications,
                                  themeColor:
                                      themeState.currentTheme.primaryColor,
                                  value: _notificationsEnabled,
                                  onChanged:
                                      (val) => setState(
                                        () => _notificationsEnabled = val,
                                      ),
                                ),
                              ),
                              _buildAnimatedCard(
                                child: _buildSwitchTile(
                                  icon: Icons.bookmark_add_outlined,
                                  title: AppLocalizations.of(context)!.dailyBookmarkReminder,
                                  themeColor:
                                      themeState.currentTheme.primaryColor,
                                  value: _reminderEnabled,
                                  onChanged: _toggleReminderEnabled,
                                ),
                              ),
                              _buildAnimatedCard(
                                child: _buildListTile(
                                  icon: Icons.schedule,
                                  title: AppLocalizations.of(context)!.reminderTime,
                                  subtitle: _reminderTime,
                                  themeColor:
                                      _reminderEnabled
                                          ? themeState.currentTheme.primaryColor
                                          : theme.colorScheme.onSurface
                                              .withAlpha((0.3 * 255).toInt()),
                                  titleColor:
                                      _reminderEnabled
                                          ? null
                                          : theme.colorScheme.onSurface
                                              .withAlpha((0.5 * 255).toInt()),
                                  iconColor:
                                      _reminderEnabled
                                          ? null
                                          : theme.colorScheme.onSurface
                                              .withAlpha((0.3 * 255).toInt()),
                                  onTap:
                                      _reminderEnabled
                                          ? _showTimePickerDialog
                                          : null,
                                ),
                              ),
                              _buildAnimatedCard(
                                child: BlocBuilder<LocaleCubit, LocaleState>(
                                  builder: (context, localeState) {
                                    // Update selected language when locale changes
                                    if (localeState is LocaleLoaded) {
                                      final currentLanguage = context.read<LocaleCubit>().getCurrentLanguageName();
                                      if (_selectedLanguage != currentLanguage) {
                                        WidgetsBinding.instance.addPostFrameCallback((_) {
                                          setState(() {
                                            _selectedLanguage = currentLanguage;
                                          });
                                        });
                                      }
                                    }
                                    return _buildListTile(
                                      icon: Icons.language,
                                      title: AppLocalizations.of(context)!.language,
                                      subtitle: _selectedLanguage,
                                      themeColor:
                                          themeState.currentTheme.primaryColor,
                                      onTap: _showLanguageDialog,
                                    );
                                  },
                                ),
                              ),
                              _buildSectionHeader(
                                AppLocalizations.of(context)!.app,
                                themeState.currentTheme.primaryColor,
                              ),
                              _buildAnimatedCard(
                                child: _buildListTile(
                                  icon: Icons.share,
                                  title: AppLocalizations.of(context)!.shareApp,
                                  subtitle: AppLocalizations.of(context)!.tellYourFriends,
                                  themeColor:
                                      themeState.currentTheme.primaryColor,
                                  onTap:
                                      () => Share.share(
                                        AppLocalizations.of(context)!.shareAppMessage,
                                      ),
                                ),
                              ),
                              _buildAnimatedCard(
                                child: _buildListTile(
                                  icon: Icons.star_rate,
                                  title: AppLocalizations.of(context)!.rateApp,
                                  subtitle: AppLocalizations.of(context)!.leaveFeedback,
                                  themeColor:
                                      themeState.currentTheme.primaryColor,
                                  onTap: () {},
                                ),
                              ),
                              _buildSectionHeader(
                                AppLocalizations.of(context)!.contact,
                                themeState.currentTheme.primaryColor,
                              ),
                              _buildAnimatedCard(
                                child: _buildListTile(
                                  icon: Icons.contact_mail,
                                  title: AppLocalizations.of(context)!.contactUs,
                                  subtitle: AppLocalizations.of(context)!.getInTouch,
                                  themeColor:
                                      themeState.currentTheme.primaryColor,
                                  onTap: () => context.push('/contactUs'),
                                ),
                              ),
                              _buildAnimatedCard(
                                child: _buildListTile(
                                  icon: Icons.info,
                                  title: AppLocalizations.of(context)!.aboutUs,
                                  subtitle: AppLocalizations.of(context)!.learnMoreAboutUs,
                                  themeColor:
                                      themeState.currentTheme.primaryColor,
                                  onTap: () {
                                    context.push('/aboutUs');
                                  },
                                ),
                              ),
                              _buildSectionHeader(
                                AppLocalizations.of(context)!.account,
                                themeState.currentTheme.primaryColor,
                              ),
                              _buildAnimatedCard(
                                child: _buildListTile(
                                  icon: Icons.logout,
                                  title: AppLocalizations.of(context)!.logOut,
                                  subtitle: AppLocalizations.of(context)!.seeYouAgainSoon,
                                  themeColor:
                                      themeState.currentTheme.primaryColor,
                                  titleColor:
                                      themeState.currentTheme.primaryColor,
                                  onTap: () {
                                    // first navigate to splash then log out
                                    // splash screen checkts the auth state
                                    if (context.mounted) {
                                      context.go('/splash');
                                    }
                                    AuthService().signOut();
                                  },
                                ),
                              ),
                              _buildAnimatedCard(
                                color: Colors.red.withAlpha(
                                  (0.1 * 255).toInt(),
                                ),
                                child: _buildListTile(
                                  icon: Icons.delete_forever,
                                  iconColor: Colors.red,
                                  title: AppLocalizations.of(context)!.deleteAccount,
                                  titleColor: Colors.red,
                                  subtitle: AppLocalizations.of(context)!.permanentlyEraseData,
                                  themeColor: Colors.red,
                                  onTap: _confirmDeleteProfile,
                                ),
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
                    ]),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAnimatedCard({required Widget child, Color? color}) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color ?? theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).toInt()),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionHeader(String title, Color themeColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: themeColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    themeColor.withAlpha((0.5 * 255).toInt()),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required Color themeColor,
    required bool value,
    required Function(bool) onChanged,
  }) {
    final theme = Theme.of(context);
    return SwitchListTile.adaptive(
      secondary: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: themeColor.withAlpha((0.1 * 255).toInt()),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: themeColor, size: 24),
      ),
      title: Text(title, style: theme.textTheme.titleMedium),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required Color themeColor,
    String? subtitle,
    Color? titleColor,
    Color? iconColor,
    Widget? trailingWidget,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: (iconColor ?? themeColor).withAlpha((0.1 * 255).toInt()),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor ?? themeColor, size: 24),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(color: titleColor),
      ),
      subtitle:
          subtitle != null
              ? Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(
                    (0.7 * 255).toInt(),
                  ),
                ),
              )
              : null,
      trailing:
          trailingWidget ??
          Icon(
            Icons.arrow_forward_ios,
            color: theme.colorScheme.onSurface.withAlpha((0.4 * 255).toInt()),
            size: 16,
          ),
      onTap: onTap,
    );
  }
}

