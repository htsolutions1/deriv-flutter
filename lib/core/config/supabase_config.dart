import 'package:flutter/foundation.dart' show kIsWeb;

/// Supabase configuration
class SupabaseConfig {
  // Supabase URL
  static const String supabaseUrl = 'https://llyjlhzyajoghrouysos.supabase.co';
  
  // Supabase Anon Key
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxseWpsaHp5YWpvZ2hyb3V5c29zIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQ1NTM1NTEsImV4cCI6MjEwMDEyOTU1MX0.iAPywJQDF6wKxzgfxOVAMM1glj8U8bSrnsrQsqNxDGI';
  
  // Deriv OAuth Configuration
  static const String derivClientId = '33x4yt1oLTBWGsLUTHRWo';
  
  // Platform-specific redirect URIs
  // IMPORTANT: Must match what's registered in Deriv app settings
  // Using Railway for deployment
  static const String _webRedirectUri = 'https://deriv-flutter-production.up.railway.app/callback';
  static const String _mobileRedirectUri = 'htbot://callback';
  
  /// Get redirect URI based on current platform
  static String get derivRedirectUri => kIsWeb ? _webRedirectUri : _mobileRedirectUri;
  
  // For development/testing
  static const bool isDevelopment = true;
}
