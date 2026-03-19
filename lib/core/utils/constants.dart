import 'dart:ui';

//Color Palette
const kPrimaryColor = Color(0xFF03457F);

const kSecondaryColor = Color(0xFF009BDD);

const kSecondaryColorAlt = Color.fromRGBO(0, 155, 221, 0.5);

const kAccentColor = Color(0xFF6FC5C8);

const kForegroundColor = Color(0xFF05121D);

const kBackgroundColor = Color(0xFFFFFFFF);

const kSecondaryTextColor = Color(0xFF606060);

const kPrimaryStrokeColor = Color(0xFFB5B5B5);

const kSecondaryStrokeColor = Color(0xFFCFCFCF);

// API Configuration
// Network targets
// - Production (Railway): set FISHCAST_BASE_URL to your deployed URL
// - Local: pass USE_LOCAL_BACKEND=true and optional FISHCAST_BASE_URL
const bool kUseLocalBackend = bool.fromEnvironment(
  'USE_LOCAL_BACKEND',
  defaultValue: false,
);

const String kBaseUrl = String.fromEnvironment(
  'FISHCAST_BASE_URL',
  defaultValue: kUseLocalBackend
      ? 'http://10.0.2.2:8000'
      : 'https://unenveloped-perishably-valerie.ngrok-free.dev', //ok na to
);
