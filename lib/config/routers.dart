import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../layouts/scaffold_com_abas.dart';
import '../screens/main_producao_screen.dart';
import '../screens/receita_screen.dart';
import '../screens/ingrediente_screen.dart';
import '../screens/receita_ingrediente_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  debugLogDiagnostics: true,

  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldComAbas(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const MainProductionScreen(),
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/receitas',
              builder: (context, state) => const ReceitaScreen(),
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/ingredientes',
              builder: (context, state) => const IngredienteScreen(),
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/receita_ingredientes',
              builder: (context, state) => const ReceitaIngredienteScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
