import 'package:bamscan/theme/app_color.dart';
import 'package:bamscan/utils/color.dart';
import 'package:flutter/material.dart';

class AppTheme {
  ThemeData get dark => _base(DarkColor());
  ThemeData get light => _base(LightColor());

  ThemeData _base(AppColor color) {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: color.base1,
      extensions: [color],
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
        },
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(backgroundColor: color.primary, foregroundColor: color.base3),
      ),
      appBarTheme: AppBarTheme(backgroundColor: color.base1, foregroundColor: color.primaryText, shadowColor: Color(0x00000000), surfaceTintColor: Colors.transparent),
      cardTheme: CardThemeData(
        color: color.base2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      listTileTheme: ListTileThemeData(textColor: color.primaryText, iconColor: color.primaryText),
      iconTheme: IconThemeData(color: color.primaryText),
      textTheme: TextTheme(
        displayLarge: TextStyle(color: color.primaryText),
        displayMedium: TextStyle(color: color.primaryText),
        displaySmall: TextStyle(color: color.primaryText),
        headlineLarge: TextStyle(color: color.primaryText),
        headlineMedium: TextStyle(color: color.primaryText),
        headlineSmall: TextStyle(color: color.primaryText),
        titleLarge: TextStyle(color: color.primaryText),
        titleMedium: TextStyle(color: color.primaryText),
        titleSmall: TextStyle(color: color.primaryText),
        bodyLarge: TextStyle(color: color.primaryText),
        bodyMedium: TextStyle(color: color.primaryText),
        bodySmall: TextStyle(color: color.primaryText),
        labelLarge: TextStyle(color: color.primaryText),
        labelMedium: TextStyle(color: color.primaryText),
        labelSmall: TextStyle(color: color.primaryText),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: color.base2,
        indicatorColor: color.primary.withValues(alpha: 0.5),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(color: color.primaryText);
          }
          return TextStyle(color: color.primaryText);
        }),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: color.primaryText);
          }
          return IconThemeData(color: color.primaryText);
        }),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: color.primary, circularTrackColor: color.base1, strokeCap: StrokeCap.round),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(20)),
      ),
      dialogTheme: DialogThemeData(backgroundColor: color.popup, insetPadding: EdgeInsets.all(20)),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: color.primary)),
      floatingActionButtonTheme: FloatingActionButtonThemeData(shape: CircleBorder(), backgroundColor: color.base3, foregroundColor: color.primary),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return color.primary;
          }
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return getContrastColor(color.primary);
          }
          return null;
        }),
      ),
    );
  }
}

extension AppColorBuildContext on BuildContext {
  AppColor get appColor => Theme.of(this).extension<AppColor>()!;
}
