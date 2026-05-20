import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_typography.dart';
import 'app_elevation.dart';
import 'app_animations.dart';

ThemeData buildLightTheme() {
  final textTheme = AppTypography.createTextTheme(
    primary: AppColors.onBackground,
    secondary: AppColors.onSurfaceVariant,
  );
  
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    // Color scheme
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryLight.withOpacity(0.1),
      onPrimaryContainer: AppColors.primary,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.secondaryLight.withOpacity(0.1),
      onSecondaryContainer: AppColors.secondary,
      tertiary: AppColors.tertiary,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.tertiary.withOpacity(0.1),
      onTertiaryContainer: AppColors.tertiary,
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: AppColors.error.withOpacity(0.1),
      onErrorContainer: AppColors.error,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      surfaceContainerHighest: AppColors.surfaceContainerHighest,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      shadow: AppColors.shadow,
      scrim: AppColors.scrim,
      inverseSurface: AppColors.inverseSurface,
      onInverseSurface: AppColors.onInverseSurface,
      inversePrimary: AppColors.primaryLight,
      surfaceTint: AppColors.primary,
    ),
    
    // Text theme
    textTheme: textTheme,
    primaryTextTheme: textTheme.copyWith(
      bodyLarge: textTheme.bodyLarge?.copyWith(color: Colors.white),
      bodyMedium: textTheme.bodyMedium?.copyWith(color: Colors.white),
      bodySmall: textTheme.bodySmall?.copyWith(color: Colors.white70),
    ),
    
    // Scaffold
    scaffoldBackgroundColor: AppColors.background,
    
    // App bar
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surface.withOpacity(0.95),
      foregroundColor: AppColors.onSurface,
      elevation: AppElevation.appBar,
      centerTitle: false,
      scrolledUnderElevation: AppElevation.appBar,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: IconThemeData(
        color: AppColors.onSurface,
        size: 24,
      ),
      actionsIconTheme: IconThemeData(
        color: AppColors.onSurfaceVariant,
        size: 24,
      ),
    ),
    
    // Bottom navigation
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.onSurfaceVariant,
      type: BottomNavigationBarType.fixed,
      elevation: AppElevation.navigationBar,
      selectedLabelStyle: textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: textTheme.labelMedium,
      showUnselectedLabels: true,
    ),
    
    // Navigation bar (Material 3)
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.primaryContainer,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return textTheme.labelMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          );
        }
        return textTheme.labelMedium?.copyWith(
          color: AppColors.onSurfaceVariant,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(
            color: AppColors.primary,
            size: 24,
          );
        }
        return IconThemeData(
          color: AppColors.onSurfaceVariant,
          size: 24,
        );
      }),
      elevation: AppElevation.navigationBar,
      height: 80,
    ),
    
    // Cards
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: AppElevation.card,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(
          color: AppColors.outline.withOpacity(0.5),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    
    // Chips
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surfaceContainerLow,
      selectedColor: AppColors.primaryContainer,
      labelStyle: textTheme.labelMedium?.copyWith(
        color: AppColors.onSurface,
      ),
      side: BorderSide(
        color: AppColors.outline.withOpacity(0.5),
        width: 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      checkmarkColor: AppColors.primary,
    ),
    
    // Switches
    switchTheme: SwitchThemeData(
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.outline;
      }),
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white;
        }
        return AppColors.onSurfaceVariant;
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.outline;
      }),
    ),
    
    // Checkboxes
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.surface;
      }),
      checkColor: WidgetStateProperty.all(Colors.white),
      side: BorderSide(
        color: AppColors.outline,
        width: 2,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
    ),
    
    // Radio buttons
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.onSurfaceVariant;
      }),
    ),
    
    // Dividers
    dividerTheme: DividerThemeData(
      color: AppColors.outline,
      thickness: 1,
      space: 1,
    ),
    
    // Dialogs
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.modal),
      ),
      titleTextStyle: textTheme.headlineSmall?.copyWith(
        color: AppColors.onSurface,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: AppColors.onSurfaceVariant,
      ),
      elevation: AppElevation.dialog,
    ),
    
    // Bottom sheets
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.modal),
        ),
      ),
      elevation: AppElevation.bottomSheet,
      modalBackgroundColor: AppColors.surface,
      modalElevation: AppElevation.bottomSheet,
    ),
    
    // Snackbars
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.inverseSurface,
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: AppColors.onInverseSurface,
      ),
      actionTextColor: AppColors.primaryLight,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      elevation: AppElevation.snackbar,
    ),
    
    // Floating action buttons
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: AppElevation.fab,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      extendedTextStyle: textTheme.labelLarge?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    ),
    
    // Input decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: BorderSide(
          color: AppColors.outline,
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: BorderSide(
          color: AppColors.outline,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: BorderSide(
          color: AppColors.error,
          width: 1,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: BorderSide(
          color: AppColors.error,
          width: 2,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: BorderSide(
          color: AppColors.outline.withOpacity(0.5),
          width: 1,
        ),
      ),
      labelStyle: textTheme.bodyMedium?.copyWith(
        color: AppColors.onSurfaceVariant,
      ),
      hintStyle: textTheme.bodyMedium?.copyWith(
        color: AppColors.onSurfaceVariant.withOpacity(0.6),
      ),
      errorStyle: textTheme.bodySmall?.copyWith(
        color: AppColors.error,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
    ),
    
    // Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: AppElevation.button,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        textStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        minimumSize: const Size.fromHeight(54),
      ),
    ),
    
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        textStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        minimumSize: const Size.fromHeight(54),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: BorderSide(
          color: AppColors.primary,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        textStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        minimumSize: const Size.fromHeight(54),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        textStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    ),
    
    // Icon buttons
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: AppColors.onSurfaceVariant,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    ),
    
    // Progress indicators
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.surfaceContainerHigh,
      circularTrackColor: AppColors.surfaceContainerHigh,
      linearMinHeight: 8,
    ),
    
    // List tiles
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      titleTextStyle: textTheme.bodyLarge?.copyWith(
        color: AppColors.onSurface,
        fontWeight: FontWeight.w500,
      ),
      subtitleTextStyle: textTheme.bodyMedium?.copyWith(
        color: AppColors.onSurfaceVariant,
      ),
      leadingAndTrailingTextStyle: textTheme.bodyMedium?.copyWith(
        color: AppColors.onSurfaceVariant,
      ),
    ),
    
    // Tooltip
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: AppColors.inverseSurface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      textStyle: textTheme.bodySmall?.copyWith(
        color: AppColors.onInverseSurface,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      margin: const EdgeInsets.all(8),
      waitDuration: AppAnimations.fast,
      showDuration: AppAnimations.normal,
    ),
    
    // Badge
    badgeTheme: BadgeThemeData(
      backgroundColor: AppColors.error,
      textColor: Colors.white,
      textStyle: textTheme.labelSmall?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    ),
    
    // Segmented button
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    ),
    
    // Slider
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.primary,
      inactiveTrackColor: AppColors.surfaceContainerHigh,
      thumbColor: AppColors.primary,
      overlayColor: AppColors.primary.withOpacity(0.1),
      valueIndicatorColor: AppColors.primary,
      valueIndicatorTextStyle: textTheme.bodySmall?.copyWith(
        color: Colors.white,
      ),
      trackHeight: 4,
      thumbShape: const RoundSliderThumbShape(
        enabledThumbRadius: 10,
      ),
      overlayShape: const RoundSliderOverlayShape(
        overlayRadius: 20,
      ),
    ),
    
    // Dropdown
    dropdownMenuTheme: DropdownMenuThemeData(
      textStyle: textTheme.bodyMedium?.copyWith(
        color: AppColors.onSurface,
      ),
      menuStyle: MenuStyle(
        backgroundColor: WidgetStateProperty.all(AppColors.surface),
        elevation: WidgetStateProperty.all(AppElevation.dialog),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    ),
    
    // Menu
    menuTheme: MenuThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStateProperty.all(AppColors.surface),
        elevation: WidgetStateProperty.all(AppElevation.dialog),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    ),
    
    // Popup menu
    popupMenuTheme: PopupMenuThemeData(
      color: AppColors.surface,
      elevation: AppElevation.dialog,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      textStyle: textTheme.bodyMedium?.copyWith(
        color: AppColors.onSurface,
      ),
    ),
    
    // Tab bar
    tabBarTheme: TabBarThemeData(
      indicatorColor: AppColors.primary,
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.onSurfaceVariant,
      labelStyle: textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: textTheme.labelLarge,
      indicator: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
      ),
      dividerColor: AppColors.outline,
    ),
    
    // Expansion tile
    expansionTileTheme: ExpansionTileThemeData(
      backgroundColor: AppColors.surface,
      collapsedBackgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      iconColor: AppColors.onSurfaceVariant,
      collapsedIconColor: AppColors.onSurfaceVariant,
      textColor: AppColors.onSurface,
      collapsedTextColor: AppColors.onSurface,
    ),
    
    // Date picker
    datePickerTheme: DatePickerThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.modal),
      ),
      elevation: AppElevation.dialog,
      headerBackgroundColor: AppColors.primary,
      headerForegroundColor: Colors.white,
      headerHeadlineStyle: textTheme.headlineSmall?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      headerHelpStyle: textTheme.bodyMedium?.copyWith(
        color: Colors.white70,
      ),
      dayStyle: textTheme.bodyMedium?.copyWith(
        color: AppColors.onSurface,
      ),
      todayForegroundColor: WidgetStateProperty.all(AppColors.primary),
      todayBackgroundColor: WidgetStateProperty.all(
        AppColors.primaryContainer,
      ),
      dayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.onSurface;
      }),
      yearStyle: textTheme.bodyMedium?.copyWith(
        color: AppColors.onSurface,
      ),
    ),
    
    // Time picker
    timePickerTheme: TimePickerThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.modal),
      ),
      elevation: AppElevation.dialog,
      hourMinuteTextColor: AppColors.onSurface,
      hourMinuteColor: AppColors.surfaceContainerLow,
      dayPeriodTextColor: AppColors.onSurface,
      dayPeriodColor: AppColors.surfaceContainerLow,
      dialTextColor: AppColors.onSurface,
      dialBackgroundColor: AppColors.surfaceContainerLow,
      hourMinuteTextStyle: textTheme.headlineMedium?.copyWith(
        color: AppColors.onSurface,
        fontWeight: FontWeight.w600,
      ),
      dayPeriodTextStyle: textTheme.bodyMedium?.copyWith(
        color: AppColors.onSurface,
      ),
      helpTextStyle: textTheme.bodySmall?.copyWith(
        color: AppColors.onSurfaceVariant,
      ),
      dialHandColor: AppColors.primary,
      entryModeIconColor: AppColors.onSurfaceVariant,
    ),
    
    // Search bar
    searchBarTheme: SearchBarThemeData(
      backgroundColor: WidgetStateProperty.all(AppColors.surfaceContainerLow),
      elevation: WidgetStateProperty.all(AppElevation.card),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
      ),
      textStyle: WidgetStateProperty.all(
        textTheme.bodyLarge?.copyWith(
          color: AppColors.onSurface,
        ),
      ),
      hintStyle: WidgetStateProperty.all(
        textTheme.bodyLarge?.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
      ),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 16),
      ),
    ),
    
    // Search view
    searchViewTheme: SearchViewThemeData(
      backgroundColor: AppColors.surface,
      elevation: AppElevation.dialog,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.modal),
      ),
      headerTextStyle: textTheme.bodyMedium?.copyWith(
        color: AppColors.onSurfaceVariant,
      ),
      dividerColor: AppColors.outline,
    ),
  );
}
