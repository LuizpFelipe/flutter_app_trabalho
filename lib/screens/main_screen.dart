import 'package:flutter/material.dart';
import 'main_producao_screen.dart';
import 'receita_screen.dart';
import 'ingrediente_screen.dart';
import 'receita_ingrediente_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _abaAtual = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> telas = [
      const MainProductionScreen(),
      const ReceitaScreen(),
      const IngredienteScreen(),
      const ReceitaIngredienteScreen(),
    ];

    final List<String> titulos = [
      'Ordem de Produção',
      'Minhas Receitas',
      'Gestão de Ingredientes',
      'Fichas Técnicas',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          titulos[_abaAtual],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
      ),

      body: IndexedStack(index: _abaAtual, children: telas),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _abaAtual,
        onDestinationSelected: (index) {
          setState(() {
            _abaAtual = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.precision_manufacturing_outlined),
            selectedIcon: Icon(Icons.precision_manufacturing),
            label: 'Produção',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: 'Receitas',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_basket_outlined),
            selectedIcon: Icon(Icons.shopping_basket),
            label: 'Ingredientes',
          ),
          NavigationDestination(
            icon: Icon(Icons.description_outlined),
            selectedIcon: Icon(Icons.description),
            label: 'Fichas',
          ),
        ],
      ),
    );
  }
}
