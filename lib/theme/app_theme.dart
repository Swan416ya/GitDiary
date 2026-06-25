import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // 基底色 — 暖灰白，不是纯白
  static const Color surfaceColor = Color(0xFFF7F6F3);
  static const Color surfaceAltColor = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFFFFFFF);

  // 主色 — 深墨绿，沉稳有质感
  static const Color primaryColor = Color(0xFF2D3B36);
  static const Color primaryLightColor = Color(0xFF3D5048);

  // 强调色 — 低饱和琥珀
  static const Color accentColor = Color(0xFFB8895A);

  // 文字
  static const Color onSurfaceColor = Color(0xFF1A1A1A);
  static const Color onSurfaceMutedColor = Color(0xFF6B6B6B);
  static const Color onSurfaceFaintColor = Color(0xFF9A9A9A);

  // 分割线/边框
  static const Color dividerColor = Color(0xFFE8E6E1);
  static const Color borderColor = Color(0xFFDAD7D0);

  // 兼容旧引用
  static const Color secondaryColor = accentColor;
  static const Color tertiaryColor = Color(0xFF6B8E7F);
  static const Color mutedTextColor = onSurfaceMutedColor;

  // 间距系统
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;
  static const double spaceXxl = 48;

  // 圆角
  static const double radiusSm = 6;
  static const double radiusMd = 10;
  static const double radiusLg = 14;
  static const double radiusXl = 20;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: primaryColor,
        onPrimary: Colors.white,
        primaryContainer: primaryColor.withOpacity(0.08),
        onPrimaryContainer: primaryColor,
        secondary: accentColor,
        onSecondary: Colors.white,
        tertiary: tertiaryColor,
        onTertiary: Colors.white,
        surface: surfaceColor,
        onSurface: onSurfaceColor,
        surfaceContainerHighest: surfaceAltColor,
        onSurfaceVariant: onSurfaceMutedColor,
        outline: borderColor,
        outlineVariant: dividerColor,
        error: const Color(0xFFC53030),
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: surfaceColor,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,

      // 卡片
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: BorderSide(color: dividerColor, width: 0.5),
        ),
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: onSurfaceColor,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: onSurfaceColor, size: 22),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),

      // 底部导航
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceAltColor,
        elevation: 0,
        height: 64,
        indicatorColor: primaryColor.withOpacity(0.08),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? primaryColor : onSurfaceFaintColor,
            letterSpacing: 0.2,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 22,
            color: selected ? primaryColor : onSurfaceFaintColor,
          );
        }),
      ),

      // FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),

      // 按钮
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: onSurfaceColor,
          side: BorderSide(color: borderColor, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
        ),
      ),

      // 输入框
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceAltColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(color: onSurfaceFaintColor, fontSize: 15),
        labelStyle: TextStyle(color: onSurfaceMutedColor, fontSize: 14),
      ),

      // 分割线
      dividerTheme: DividerThemeData(
        color: dividerColor,
        thickness: 0.5,
        space: 0,
      ),

      // 文字
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w700,
          color: onSurfaceColor,
          letterSpacing: -1.2,
          height: 1.1,
        ),
        displayMedium: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: onSurfaceColor,
          letterSpacing: -0.8,
          height: 1.15,
        ),
        headlineLarge: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w600,
          color: onSurfaceColor,
          letterSpacing: -0.5,
          height: 1.25,
        ),
        headlineMedium: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w600,
          color: onSurfaceColor,
          letterSpacing: -0.3,
          height: 1.3,
        ),
        titleLarge: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: onSurfaceColor,
          letterSpacing: -0.2,
          height: 1.4,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: onSurfaceColor,
          height: 1.4,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          color: onSurfaceColor,
          height: 1.6,
          letterSpacing: -0.1,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: onSurfaceMutedColor,
          height: 1.55,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: onSurfaceFaintColor,
          height: 1.4,
          letterSpacing: 0.1,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: onSurfaceFaintColor,
          letterSpacing: 0.8,
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: onSurfaceColor,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),

      dialogTheme: DialogTheme(
        backgroundColor: surfaceAltColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
      ),
    );
  }
}
