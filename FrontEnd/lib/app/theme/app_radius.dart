import 'package:flutter/material.dart';

abstract final class AppRadius {
  // None
  static const none = 0.0;
  
  // Extra small
  static const xs = 4.0;
  
  // Small
  static const sm = 8.0;
  
  // Medium
  static const md = 12.0;
  
  // Large
  static const lg = 16.0;
  
  // Extra large
  static const xl = 24.0;
  
  // Extra extra large
  static const xxl = 32.0;
  
  // Full (circle/pill)
  static const full = 9999.0;
  
  // Semantic radius values
  static const input = md;
  static const button = lg;
  static const card = xl;
  static const modal = xxl;
  static const chip = sm;
  static const badge = full;
  static const avatar = full;
  
  // Helper for consistent border radius
  static BorderRadius circular(double value) =>
      BorderRadius.circular(value);
  
  static BorderRadius get inputRadius => circular(input);
  static BorderRadius get buttonRadius => circular(button);
  static BorderRadius get cardRadius => circular(card);
  static BorderRadius get modalRadius => circular(modal);
  static BorderRadius get chipRadius => circular(chip);
  static BorderRadius get badgeRadius => circular(badge);
  static BorderRadius get avatarRadius => circular(avatar);
}
