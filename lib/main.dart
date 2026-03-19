import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/theme_cubit/theme_cubit.dart';
import 'theme/design_system.dart';
import 'router/app_router.dart';
import 'bloc/product_bloc/product_bloc.dart';
import 'data/repositories/product_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ProductRepository>(
          create: (context) => ProductRepository(prefs: prefs),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),
          BlocProvider<ProductBloc>(
            create: (context) => ProductBloc(
              repository: context.read<ProductRepository>(),
            )..add(FetchProducts()),
          ),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp.router(
              title: 'TechGadol Catalog',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              routerConfig: appRouter,
              debugShowCheckedModeBanner: false,
            );
          },
        ),
      ),
    );
  }
}