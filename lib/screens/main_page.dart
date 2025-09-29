import 'package:flutter/material.dart';
import 'package:prjectcm/screens/pages.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_selectedIndex].widget,
      bottomNavigationBar: NavigationBar(
        indicatorColor: Colors.black,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: List.generate(pages.length, (index) {
          final page = pages[index];
          return NavigationDestination(
            icon: Icon(
              page.icon,
              color: Colors.white,
            ),
            label: page.title,
            key: page.key,
          );
        }),
      ),
    );
  }
}
