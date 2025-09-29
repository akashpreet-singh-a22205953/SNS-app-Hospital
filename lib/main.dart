import 'package:flutter/material.dart';
import 'package:prjectcm/screens/main_page.dart';
import 'package:prjectcm/data/http_sns_datasource.dart';
import 'package:prjectcm/data/sqflite_sns_datasource.dart';
import 'package:provider/provider.dart';

import 'connectivity_module.dart';
import 'location_module.dart';



import 'dart:io' as io;

class _HttpOverrides extends io.HttpOverrides {
  @override
  io.HttpClient createHttpClient(io.SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (io.X509Certificate cert, String host, int port) => true;
  }
}
void main() {
  io.HttpOverrides.global = _HttpOverrides();

  final httpDataSource = HttpSnsDataSource();
  final sqfliteDataSource = SqfliteSnsDataSource();
  final locationModule = LocationModule();
  final connectivityModule = ConnectivityModule();


  runApp(
    MultiProvider(
      providers: [
        Provider<HttpSnsDataSource>.value(value: httpDataSource),
        Provider<SqfliteSnsDataSource>.value(value: sqfliteDataSource),
        Provider<LocationModule>.value(value: locationModule),
        Provider<ConnectivityModule>.value(value: connectivityModule),


      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {





  @override
  Widget build(BuildContext context) {
    final iniciaDB = context.read<SqfliteSnsDataSource>().init();

    var colorScheme = ColorScheme.fromSeed(seedColor: Colors.white);

    return MaterialApp(
      title: 'App',
      theme: ThemeData(
        useMaterial3: true,
        appBarTheme: ThemeData.from(colorScheme: colorScheme).appBarTheme.copyWith(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.background,
        ),
        navigationBarTheme: ThemeData.from(colorScheme: colorScheme).navigationBarTheme.copyWith(
          backgroundColor: colorScheme.primary,
          labelTextStyle: MaterialStateProperty.all(const TextStyle(color: Colors.white)),
        ),
      ),
      home: FutureBuilder<void>(
        future: iniciaDB,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('Error: ${snapshot.error}')),
            );
          } else {
            return const MainPage();
          }
        },
      ),
    );
  }
}
