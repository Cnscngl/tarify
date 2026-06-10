import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'viewmodels/recipe_vm.dart';
import 'views/home_page.dart';

void main() {
  runApp(const TarifyApp());
}

class TarifyApp extends StatelessWidget {
  const TarifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RecipeViewModel()..loadRecipes(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Tarify',
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFFFF8F2),
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFF29B7E),
            secondary: Color(0xFFF7D9A7),
            surface: Color(0xFFFFFDFB),
            background: Color(0xFFFFF8F2),
            error: Color(0xFFD56A6A),
            onPrimary: Colors.white,
            onSecondary: Color(0xFF4A3B34),
            onSurface: Color(0xFF4A3B34),
            onBackground: Color(0xFF4A3B34),
            onError: Colors.white,
          ),

          appBarTheme: const AppBarTheme(
            centerTitle: true,
            backgroundColor: Color(0xFFFFF1E8),
            foregroundColor: Color(0xFF4A3B34),
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            titleTextStyle: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF4A3B34),
            ),
          ),

          cardTheme: CardThemeData(
            color: const Color(0xFFFFFDFC),
            elevation: 3,
            shadowColor: const Color(0x1A9C6A4A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
              side: const BorderSide(
                color: Color(0xFFF2E3D6),
                width: 1,
              ),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),

          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xFFEEDCCD),
                width: 1.2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xFFEEDCCD),
                width: 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xFFF29B7E),
                width: 1.8,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xFFD56A6A),
                width: 1.2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xFFD56A6A),
                width: 1.8,
              ),
            ),
            labelStyle: const TextStyle(
              color: Color(0xFF75665D),
              fontWeight: FontWeight.w500,
            ),
            hintStyle: const TextStyle(
              color: Color(0xFFA09188),
            ),
          ),

          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF29B7E),
              foregroundColor: Colors.white,
              elevation: 2,
              shadowColor: const Color(0x338C5B45),
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 15,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),

          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF5E4C44),
              backgroundColor: const Color(0xFFFFFDFC),
              side: const BorderSide(
                color: Color(0xFFE9D9CC),
                width: 1.1,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 15,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),

          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFFF29B7E),
            foregroundColor: Colors.white,
            elevation: 4,
          ),

          chipTheme: ChipThemeData(
            backgroundColor: const Color(0xFFFFEBDC),
            selectedColor: const Color(0xFFF7D9A7),
            disabledColor: const Color(0xFFF2E7DD),
            labelStyle: const TextStyle(
              color: Color(0xFF4F4038),
              fontWeight: FontWeight.w600,
            ),
            secondaryLabelStyle: const TextStyle(
              color: Color(0xFF4F4038),
              fontWeight: FontWeight.w600,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),

          dividerColor: const Color(0xFFF2E3D6),

          textTheme: const TextTheme(
            headlineSmall: TextStyle(
              color: Color(0xFF4A3B34),
              fontWeight: FontWeight.w800,
            ),
            titleLarge: TextStyle(
              color: Color(0xFF4A3B34),
              fontWeight: FontWeight.w800,
            ),
            titleMedium: TextStyle(
              color: Color(0xFF4A3B34),
              fontWeight: FontWeight.w700,
            ),
            bodyLarge: TextStyle(
              color: Color(0xFF5B4B44),
            ),
            bodyMedium: TextStyle(
              color: Color(0xFF75665D),
            ),
          ),
        ),
        home: const HomePage(),
      ),
    );
  }
}