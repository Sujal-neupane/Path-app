import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Editorial typography roles for the "Editorial Alpine" redesign.
///
/// Philosophy: ONE apex headline per screen, everything else quiet.
/// - Display roles → big, tight, heavy. Used sparingly (hero / page title).
/// - Eyebrow → small, wide-tracked, uppercase. Labels above headlines.
/// - Title / body / caption → calm supporting hierarchy.
///
/// Keep using these instead of hardcoded `TextStyle(fontSize: …)` so the
/// hierarchy stays consistent across every screen.
class AppType {
  AppType._();

  // ── Display (hero / page apex — use ONE per screen) ──────────────
  static TextStyle get displayXL => GoogleFonts.plusJakartaSans(
    fontSize: 40,
    height: 1.02,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.0,
  );

  static TextStyle get display => GoogleFonts.plusJakartaSans(
    fontSize: 32,
    height: 1.05,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.6,
  );

  // ── Headlines / titles ───────────────────────────────────────────
  static TextStyle get title => GoogleFonts.plusJakartaSans(
    fontSize: 22,
    height: 1.15,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
  );

  static TextStyle get titleSm => GoogleFonts.plusJakartaSans(
    fontSize: 17,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
  );

  // ── Eyebrow (label above a headline) ─────────────────────────────
  static TextStyle get eyebrow => GoogleFonts.spaceGrotesk(
    fontSize: 11.5,
    height: 1.1,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.6,
  );

  // ── Body ─────────────────────────────────────────────────────────
  static TextStyle get body => GoogleFonts.inter(
    fontSize: 15,
    height: 1.5,
    fontWeight: FontWeight.w400,
  );

  static TextStyle get bodySm => GoogleFonts.inter(
    fontSize: 13,
    height: 1.45,
    fontWeight: FontWeight.w400,
  );

  static TextStyle get caption => GoogleFonts.inter(
    fontSize: 11.5,
    height: 1.3,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
  );

  // ── Numeric / stat emphasis ──────────────────────────────────────
  static TextStyle get stat => GoogleFonts.spaceGrotesk(
    fontSize: 20,
    height: 1.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  // ── Button ───────────────────────────────────────────────────────
  static TextStyle get button => GoogleFonts.spaceGrotesk(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );
}

/// Editorial radius + elevation scale (single source of truth).
class AppRadii {
  AppRadii._();
  static const double chip = 12.0;
  static const double card = 20.0;
  static const double sheet = 28.0;
  static const double hero = 28.0;
  static const double pill = 999.0;
}
