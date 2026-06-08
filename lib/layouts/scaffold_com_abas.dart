import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScaffoldComAbas extends StatelessWidget {
  const ScaffoldComAbas({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: _onTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.precision_manufacturing),
            label: 'Produção',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Receitas',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.egg), label: 'Ingredientes'),
          BottomNavigationBarItem(
            icon: Icon(Icons.link),
            label: 'Ficha Técnica',
          ),
        ],
      ),
    );
  }
}
