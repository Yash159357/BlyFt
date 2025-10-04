import 'package:equatable/equatable.dart';
import 'package:blyft/utils/logger.dart';
import '../../../models/theme_model.dart';

enum ThemeStatus { initial, loading, loaded, error }

class ThemeState extends Equatable {
  final AppTheme currentTheme;
  final ThemeStatus status;
  final String? errorMessage;

  const ThemeState({
    required this.currentTheme,
    required this.status,
    this.errorMessage,
  });

  factory ThemeState.initial() {
    final state = ThemeState(
      currentTheme: AppTheme.defaultTheme,
      status: ThemeStatus.initial,
    );
    Log.d('<THEME_STATE> initial state: theme=${state.currentTheme.name}, status=${state.status}');
    return state;
  }

  ThemeState copyWith({
    AppTheme? currentTheme,
    ThemeStatus? status,
    String? errorMessage,
  }) {
    final newState = ThemeState(
      currentTheme: currentTheme ?? this.currentTheme,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );

    Log.d('<THEME_STATE> copyWith created: theme=${newState.currentTheme.name}, status=${newState.status}');

    return newState;
  }

  @override
  List<Object?> get props => [currentTheme, status, errorMessage];
}

