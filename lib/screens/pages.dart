import 'package:flutter/material.dart';
import 'avaliarpage.dart';
import 'listpage.dart';
import 'dashboard.dart';
import 'mapa.dart';

final pages = [
  (title: 'Dashboard', icon: Icons.home, widget:Dashboard(), key: Key('dashboard-bottom-bar-item')),
  (title: 'Lista', icon: Icons.list, widget:Lista(), key: Key('lista-bottom-bar-item')),
  (title: 'Mapa', icon: Icons.map, widget:Mapa(), key: Key('mapa-bottom-bar-item')),
  (title: 'Avaliar', icon: Icons.star, widget:Avaliar(), key: Key('avaliacoes-bottom-bar-item')),
];
