import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/receita_provider.dart';
import 'providers/ingrediente_provider.dart';
import 'providers/receita_ingrediente_provider.dart';
import 'providers/producao_provider.dart';
import 'providers/inteligencia_provider.dart';
import 'screens/splash_screen_animada.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProducaoProvider()),
        ChangeNotifierProvider(create: (_) => ReceitaIngredienteProvider()),
        ChangeNotifierProvider(create: (_) => ReceitaProvider()),
        ChangeNotifierProvider(create: (_) => IngredienteProvider()),
        ChangeNotifierProvider(create: (_) => InteligenciaProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestão de Produção',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D4B41),
          primary: const Color(0xFF2D4B41),
          secondary: const Color(0xFF437664),
          tertiary: const Color(0xFFE88D43),
          surface: const Color(0xFFF2F5F2),
        ),
        useMaterial3: true,
      ),
      home: const SplashScreenAnimada(),
      routes: {'/home': (context) => const MainScreen()},
    );
  }
}
