import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/snack_provider.dart';
import 'screen/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar el idioma español para fechas
  await initializeDateFormatting('es', null);

  // Inicializar Supabase (Credenciales de Alexandra)
  await Supabase.initialize(
    url: 'https://nqvmabwwaslhfdfpiayx.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5xdm1hYnd3YXNsaGZkZnBpYXl4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzAzNDk1MzcsImV4cCI6MjA4NTkyNTUzN30.J1mvry81OmYy6DiFYCg5RQt1cSBqCvWXVInqP_2N9yc',
  );

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => SnackProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Snack Point POS',
      // Cambiamos a Brightness.light para que los textos sean negros por defecto
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF24BF5B),
          brightness: Brightness.light, 
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const HomeScreen(),
    );
  }
}