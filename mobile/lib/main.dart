import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://xvyapxfvdfogbzjtvvhs.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh2eWFweGZ2ZGZvZ2J6anR2dmhzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA5MzQ3ODQsImV4cCI6MjA4NjUxMDc4NH0._pl9Tq9M2khGAGhNQKw2BczUwC4_1pgzJhdr4JV6Uow', // Replace with your Supabase anon key
  );

  runApp(const App());
}

// Global Supabase client
final supabase = Supabase.instance.client;
