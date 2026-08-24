import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'data/datasources/remote/currency_remote_datasource.dart';
import 'data/datasources/local/currency_cache_datasource.dart';
import 'data/datasources/local/favorites_local_datasource.dart';
import 'data/repositories/currency_repository.dart';
import 'bloc/convert/convert_cubit.dart';
import 'bloc/favorites/favorites_cubit.dart';
import 'presentation/screens/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(CurrencySnapApp(prefs: prefs));
}

class CurrencySnapApp extends StatelessWidget {
  final SharedPreferences prefs;

  const CurrencySnapApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    final repository = CurrencyRepository(
      CurrencyRemoteDataSource(),
      CurrencyCacheDataSource(prefs),
      FavoritesLocalDataSource(prefs),
    );

    return RepositoryProvider.value(
      value: repository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ConvertCubit(repository)),
          BlocProvider(create: (_) => FavoritesCubit(repository)),
        ],
        child: MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
