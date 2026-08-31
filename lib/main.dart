import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/app_constants.dart';
import 'core/services/widget_service.dart';
import 'core/theme/app_theme.dart';
import 'features/converter/domain/repositories/converter_repository.dart';
import 'features/converter/presentation/cubit/convert_cubit.dart';
import 'features/converter/presentation/screens/splash_screen.dart';
import 'features/favorites/domain/repositories/favorites_repository.dart';
import 'features/favorites/presentation/cubit/favorites_cubit.dart';
import 'features/history/domain/repositories/history_repository.dart';
import 'features/settings/domain/repositories/settings_repository.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';
import 'features/settings/presentation/cubit/settings_state.dart';
import 'injection_container.dart' as di;
import 'routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetService.initialize();
  await di.initServiceLocator();
  runApp(const CurrencySnapApp());
}

class CurrencySnapApp extends StatelessWidget {
  const CurrencySnapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ConverterRepository>.value(
          value: di.sl<ConverterRepository>(),
        ),
        RepositoryProvider<FavoritesRepository>.value(
          value: di.sl<FavoritesRepository>(),
        ),
        RepositoryProvider<HistoryRepository>.value(
          value: di.sl<HistoryRepository>(),
        ),
        RepositoryProvider<SettingsRepository>.value(
          value: di.sl<SettingsRepository>(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<SettingsCubit>(
            create: (_) => di.sl<SettingsCubit>(),
          ),
          BlocProvider<ConvertCubit>(
            create: (_) => di.sl<ConvertCubit>(),
          ),
          BlocProvider<FavoritesCubit>(
            create: (_) => di.sl<FavoritesCubit>(),
          ),
        ],
        child: BlocBuilder<SettingsCubit, SettingsState>(
          buildWhen: (previous, current) =>
              previous.themeMode != current.themeMode,
          builder: (context, settingsState) {
            return MaterialApp(
              title: AppConstants.appName,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: settingsState.flutterThemeMode,
              onGenerateRoute: AppRouter.onGenerateRoute,
              home: const SplashScreen(),
            );
          },
        ),
      ),
    );
  }
}
