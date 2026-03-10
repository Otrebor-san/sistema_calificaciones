import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/calificacion_provider.dart';
import 'screens/lista_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CalificacionProvider(),
      child: MaterialApp(
        title: 'Sistema de Calificaciones',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1565C0),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        home: const ListaScreen(),
      ),
    );
  }
}