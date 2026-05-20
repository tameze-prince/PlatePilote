import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_typography.dart';
import 'app_elevation.dart';
import 'app_animations.dart';

ThemeData buildDarkTheme() {
  final textTheme = AppTypography.createTextTheme(
    primary: AppColors.darkOnBackground,
    secondary: AppColors.darkOnSurfaceVariant,
  );
  
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    
    // Color scheme
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primaryLight,
      onPrimary: AppColors.darkBackground,
      primaryContainer: AppColors.primary.withOpacity(0.2),
      onPrimaryContainer: AppColors.primaryLight,
      secondary: AppColors.secondaryLight,
      onSecondary: AppColors.darkBackground,
      secondaryContainer: AppColors.secondary.withOpacity(0.2),
      onSecondaryContainer: AppColors.secondaryLight,
      tertiary: AppColors.tertiary,
      onTertiary: AppColors.darkBackground,
      tertiaryContainer: AppColors.tertiary.withOpacity(0.2),
      onTertiaryContainer: AppColors.tertiary,
      error: AppColors.error,
      onError: AppColors.darkBackground,
      errorContainer: AppColors.error.withOpacity(0.2),
      onErrorContainer: AppColors.error,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkOnSurface,
      surfaceContainerHighest: AppColors.darkSurfaceContainerHighest,
      onSurfaceVariant: AppColors.darkOnSurfaceVariant,
      outline: AppColors.darkOutline,
      outlineVariant: AppColors.darkOutlineVariant,
      shadow: AppColors.shadow,
      scrim: AppColors.scrim,
      inverseSurface: AppColors.darkInverseSurface,
      onInverseSurface: AppColors.darkOnInverseSurface,
      inversePrimary: AppColors.primary,
      surfaceTint: AppColors.primaryLight,
    ),
    
    // Text theme
    textTheme: textTheme,
    primaryTextTheme: textTheme.copyWith(
      bodyLarge: textTheme.bodyLarge?.copyWith(color: AppColors.darkBackground),
      bodyMedium: textTheme.bodyMedium?.copyWith(color: AppColors.darkBackground),
      bodySmall: textTheme.bodySmall?.copyWith(color: AppColors.darkOnInverseSurface.withOpacity(0.7)),
    ),
    
    // Scaffold
    scaffoldBackgroundColor: AppColors.darkBackground,
    
    // App bar
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkSurface.withOpacity(0.95),
      foregroundColor: AppColors.darkOnSurface,
      elevation: AppElevation.appBar,
      centerTitle: false,
      scrolledUnderElevation: AppElevation.appBar,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: AppColors.primaryLight,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: IconThemeData(
        color: AppColors.darkOnSurface,
        size: 24,
      ),
      actionsIconTheme: IconThemeData(
        color: AppColors.darkOnSurfaceVariant,
        size: 24,
      ),
    ),
    
    // Bottom navigation
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedItemColor: AppColors.primaryLight,
      unselectedItemColor: AppColors.darkOnSurfaceVariant,
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
      backgroundColor: AppColors.darkSurface,
      indicatorColor: AppColors.primaryContainer,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return textTheme.labelMedium?.copyWith(
            color: AppColors.primaryLight,
            fontWeight: FontWeight.w600,
          );
        }
        return textTheme.labelMedium?.copyWith(
          color: AppColors.darkOnSurfaceVariant,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(
            color: AppColors.primaryLight,
            size: 24,
          );
        }
        return IconThemeData(
          color: AppColors.darkOnSurfaceVariant,
          size: 24,
        );
      }),
      elevation: AppElevation.navigationBar,
      height: 80,
    ),
    
    // Cards
    cardTheme: CardThemeData(
      color: AppColors.darkSurface,
      elevation: AppElevation.card,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(
          color: AppColors.darkOutline.withOpacity(0.5),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    
    // Chips
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.darkSurfaceContainerLow,
      selectedColor: AppColors.primaryContainer,
      labelStyle: textTheme.labelMedium?.copyWith(
        color: AppColors.darkOnSurface,
      ),
      side: BorderSide(
        color: AppColors.darkOutline.withOpacity(0.5),
        width: 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      checkmarkColor: AppColors.primaryLight,
    ),
    
    // Switches
    switchTheme: SwitchThemeData(
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryLight;
        }
        return AppColors.darkOutline;
      }),
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.darkBackground;
        }
        return AppColors.darkOnSurfaceVariant;
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryLight;
        }
        return AppColors.darkOutline;
      }),
    ),
    
    // Checkboxes
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryLight;
        }
        return AppColors.darkSurface;
      }),
      checkColor: WidgetStateProperty.all(AppColors.darkBackground),
      side: BorderSide(
        color: AppColors.darkOutline,
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
          return AppColors.primaryLight;
        }
        return AppColors.darkOnSurfaceVariant;
      }),
    ),
    
    // Dividers
    dividerTheme: DividerThemeData(
      color: AppColors.darkOutline,
      thickness: 1,
      space: 1,
    ),
    
    // Dialogs
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.modal),
      ),
      titleTextStyle: textTheme.headlineSmall?.copyWith(
        color: AppColors.darkOnSurface,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: AppColors.darkOnSurfaceVariant,
      ),
      elevation: AppElevation.dialog,
    ),
    
    // Bottom sheets
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.modal),
        ),
      ),
      elevation: AppElevation.bottomSheet,
      modalBackgroundColor: AppColors.darkSurface,
      modalElevation: AppElevation.bottomSheet,
    ),
    
    // Snackbars
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.darkInverseSurface,
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: AppColors.darkOnInverseSurface,
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
      backgroundColor: AppColors.primaryLight,
      foregroundColor: AppColors.darkBackground,
      elevation: AppElevation.fab,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      extendedTextStyle: textTheme.labelLarge?.copyWith(
        color: AppColors.darkBackground,
        fontWeight: FontWeight.w600,
      ),
    ),
    
    // Input decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: BorderSide(
          color: AppColors.darkOutline,
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: BorderSide(
          color: AppColors.darkOutline,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: BorderSide(
          color: AppColors.primaryLight,
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
          color: AppColors.darkOutline.withOpacity(0.5),
          width: 1,
        ),
      ),
      labelStyle: textTheme.bodyMedium?.copyWith(
        color: AppColors.darkOnSurfaceVariant,
      ),
      hintStyle: textTheme.bodyMedium?.copyWith(
        color: AppColors.darkOnSurfaceVariant.withOpacity(0.6),
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
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.darkBackground,
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
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.darkBackground,
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
        foregroundColor: AppColors.primaryLight,
        side: BorderSide(
          color: AppColors.primaryLight,
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
        foregroundColor: AppColors.primaryLight,
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
        foregroundColor: AppColors.darkOnSurfaceVariant,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    ),
    
    // Progress indicators
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: AppColors.primaryLight,
      linearTrackColor: AppColors.darkSurfaceContainerHigh,
      circularTrackColor: AppColors.darkSurfaceContainerHigh,
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
        color: AppColors.darkOnSurface,
        fontWeight: FontWeight.w500,
      ),
      subtitleTextStyle: textTheme.bodyMedium?.copyWith(
        color: AppColors.darkOnSurfaceVariant,
      ),
      leadingAndTrailingTextStyle: textTheme.bodyMedium?.copyWith(
        color: AppColors.darkOnSurfaceVariant,
      ),
    ),
    
    // Tooltip
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: AppColors.darkInverseSurface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      textStyle: textTheme.bodySmall?.copyWith(
        color: AppColors.darkOnInverseSurface,
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
      textColor: AppColors.darkBackground,
      textStyle: textTheme.labelSmall?.copyWith(
        color: AppColors.darkBackground,
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
      activeTrackColor: AppColors.primaryLight,
      inactiveTrackColor: AppColors.darkSurfaceContainerHigh,
      thumbColor: AppColors.primaryLight,
      overlayColor: AppColors.primaryLight.withOpacity(0.1),
      valueIndicatorColor: AppColors.primaryLight,
      valueIndicatorTextStyle: textTheme.bodySmall?.copyWith(
        color: AppColors.darkBackground,
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
        color: AppColors.darkOnSurface,
      ),
      menuStyle: MenuStyle(
        backgroundColor: WidgetStateProperty.all(AppColors.darkSurface),
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
        backgroundColor: WidgetStateProperty.all(AppColors.darkSurface),
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
      color: AppColors.darkSurface,
      elevation: AppElevation.dialog,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      textStyle: textTheme.bodyMedium?.copyWith(
        color: AppColors.darkOnSurface,
      ),
    ),
    
    // Tab bar
    tabBarTheme: TabBarThemeData(
      indicatorColor: AppColors.primaryLight,
      labelColor: AppColors.primaryLight,
      unselectedLabelColor: AppColors.darkOnSurfaceVariant,
      labelStyle: textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: textTheme.labelLarge,
      indicator: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.primaryLight,
            width: 2,
          ),
        ),
      ),
      dividerColor: AppColors.darkOutline,
    ),
    
    // Expansion tile
    expansionTileTheme: ExpansionTileThemeData(
      backgroundColor: AppColors.darkSurface,
      collapsedBackgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      iconColor: AppColors.darkOnSurfaceVariant,
      collapsedIconColor: AppColors.darkOnSurfaceVariant,
      textColor: AppColors.darkOnSurface,
      collapsedTextColor: AppColors.darkOnSurface,
    ),
    
    // Date picker
    datePickerTheme: DatePickerThemeData(
      backgroundColor: AppColors.darkSurface,
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
        color: AppColors.darkOnSurface,
      ),
      todayForegroundColor: WidgetStateProperty.all(AppColors.primaryLight),
      todayBackgroundColor: WidgetStateProperty.all(
        AppColors.primaryContainer,
      ),
      dayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryLight;
        }
        return AppColors.darkOnSurface;
      }),
      yearStyle: textTheme.bodyMedium?.copyWith(
        color: AppColors.darkOnSurface,
      ),
    ),
    
    // Time picker
    timePickerTheme: TimePickerThemeData(
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.modal),
      ),
      elevation: AppElevation.dialog,
      hourMinuteTextColor: AppColors.darkOnSurface,
      hourMinuteColor: AppColors.darkSurfaceContainerLow,
      dayPeriodTextColor: AppColors.darkOnSurface,
      dayPeriodColor: AppColors.darkSurfaceContainerLow,
      dialTextColor: AppColors.darkOnSurface,
      dialBackgroundColor: AppColors.darkSurfaceContainerLow,
      hourMinuteTextStyle: textTheme.headlineMedium?.copyWith(
        color: AppColors.darkOnSurface,
        fontWeight: FontWeight.w600,
      ),
      dayPeriodTextStyle: textTheme.bodyMedium?.copyWith(
        color: AppColors.darkOnSurface,
      ),
      helpTextStyle: textTheme.bodySmall?.copyWith(
        color: AppColors.darkOnSurfaceVariant,
      ),
      dialHandColor: AppColors.primaryLight,
      entryModeIconColor: AppColors.darkOnSurfaceVariant,
    ),
    
    // Search bar
    searchBarTheme: SearchBarThemeData(
      backgroundColor: WidgetStateProperty.all(AppColors.darkSurfaceContainerLow),
      elevation: WidgetStateProperty.all(AppElevation.card),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
      ),
      textStyle: WidgetStateProperty.all(
        textTheme.bodyLarge?.copyWith(
          color: AppColors.darkOnSurface,
        ),
      ),
      hintStyle: WidgetStateProperty.all(
        textTheme.bodyLarge?.copyWith(
          color: AppColors.darkOnSurfaceVariant,
        ),
      ),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 16),
      ),
    ),
    
    // Search view
    searchViewTheme: SearchViewThemeData(
      backgroundColor: AppColors.darkSurface,
      elevation: AppElevation.dialog,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.modal),
      ),
      headerTextStyle: textTheme.bodyMedium?.copyWith(
        color: AppColors.darkOnSurfaceVariant,
      ),
      dividerColor: AppColors.darkOutline,
    ),
  );
}
