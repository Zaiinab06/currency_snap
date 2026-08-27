import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'data/datasources/remote/currency_remote_datasource.dart';
import 'data/datasources/local/currency_cache_datasource.dart';
import 'data/datasources/local/favorites_local_datasource.dart';
import 'data/datasources/local/history_local_datasource.dart';
import 'data/repositories/currency_repository.dart';
import 'bloc/convert/convert_cubit.dart';
import 'bloc/favorites/favorites_cubit.dart';
import 'bloc/settings/settings_cubit.dart';
import 'bloc/settings/settings_state.dart';
import 'presentation/screens/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(CurrencySnapApp(prefs: prefs));
}

class CurrencySnapApp extends StatefulWidget {
  final SharedPreferences prefs;

  const CurrencySnapApp({super.key, required this.prefs});

  @override
  State<CurrencySnapApp> createState() => _CurrencySnapAppState();
}

class _CurrencySnapAppState extends State<CurrencySnapApp> {
  late final CurrencyRepository _repository;
  late final SettingsCubit _settingsCubit;
  late final ConvertCubit _convertCubit;
  late final FavoritesCubit _favoritesCubit;

  @override
  void initState() {
    super.initState();
    _repository = CurrencyRepository(
      CurrencyRemoteDataSource(),
      CurrencyCacheDataSource(widget.prefs),
      FavoritesLocalDataSource(widget.prefs),
      HistoryLocalDataSource(widget.prefs),
    );
    _settingsCubit = SettingsCubit(widget.prefs);
    _convertCubit = ConvertCubit(_repository);
    _favoritesCubit = FavoritesCubit(_repository);
  }

  @override
  void dispose() {
    _settingsCubit.close();
    _convertCubit.close();
    _favoritesCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: _repository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _settingsCubit),
          BlocProvider.value(value: _convertCubit),
          BlocProvider.value(value: _favoritesCubit),
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
              home: const SplashScreen(),
            );
          },
        ),
      ),
    );
  }
}
