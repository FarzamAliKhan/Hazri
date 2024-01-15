// @dart=2.9

import 'dart:ui';

import 'package:flutter/src/painting/text_style.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyle {
  static TextStyle ubuntuStyle(Color color, double size) {
    return GoogleFonts.ubuntu(
        fontSize: size, fontWeight: FontWeight.w900, color: color);
  }
}
