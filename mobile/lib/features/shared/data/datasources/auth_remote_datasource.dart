import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../../../../core/config/supabase_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../employee/data/models/employee_profile_model.dart';

/// Remote data source for authentication using the backend API.
abstract class AuthRemoteDataSource {
  /// Login with email and password using the backend API.
  Future<AuthResponse> login({required String email, required String password});

  /// Logout from Supabase.
  Future<void> logout();

  /// Get current user from Supabase session.
  Future<AuthResponse?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client httpClient;

  // Backend API URL
  // Use your computer's IP address when testing on physical device
  static const String baseUrl = 'http://10.36.245.125:8000';

  AuthRemoteDataSourceImpl({http.Client? httpClient})
    : httpClient = httpClient ?? http.Client();

  @override
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🔵 LOGIN: Starting login request');
      print('🔵 LOGIN: URL = $baseUrl/auth/login');
      print('🔵 LOGIN: Email = $email');

      // Step 1: Authenticate with backend API
      final response = await httpClient
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('❌ LOGIN: Request timed out after 10 seconds');
              throw Exception('Connection timeout - backend not reachable');
            },
          );

      print('🟢 LOGIN: Got response, status = ${response.statusCode}');
      print('🟢 LOGIN: Response body = ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final backendToken = data['access_token'] as String;
        final user = data['user'] as Map<String, dynamic>;
        final role = user['role'] as String;
        final userId = user['id'] as String;
        final name = user['name'] as String;

        // Step 2: Sign in with Supabase to establish session
        final supabaseResponse = await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (supabaseResponse.user == null) {
          throw AuthException('Supabase authentication failed');
        }

        return AuthResponse(
          userId: userId,
          email: email,
          name: name,
          role: role,
          backendToken: backendToken,
          supabaseToken: supabaseResponse.session?.accessToken ?? '',
        );
      } else if (response.statusCode == 401) {
        print('❌ LOGIN: Authentication failed');
        throw AuthException('Email ou mot de passe incorrect');
      } else {
        print('❌ LOGIN: Server error ${response.statusCode}');
        print('❌ LOGIN: Error body = ${response.body}');
        try {
          final error = jsonDecode(response.body);
          throw AuthException(error['detail'] ?? 'Login failed');
        } catch (e) {
          // If response is not JSON (like HTML error page)
          throw AuthException(
            'Erreur serveur (${response.statusCode}). Vérifiez que le backend fonctionne.',
          );
        }
      }
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Erreur de connexion: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await supabase.auth.signOut();
    } catch (e) {
      throw AuthException('Erreur de déconnexion: ${e.toString()}');
    }
  }

  @override
  Future<AuthResponse?> getCurrentUser() async {
    try {
      final session = supabase.auth.currentSession;
      if (session == null) {
        return null;
      }

      final user = supabase.auth.currentUser;
      if (user == null) {
        return null;
      }

      // Get user profile from backend
      final response = await httpClient.get(
        Uri.parse('$baseUrl/employee/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${session.accessToken}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final profile = EmployeeProfileModel.fromJson(data);

        return AuthResponse(
          userId: profile.id,
          email: profile.email,
          name: profile.name,
          role: profile.role,
          backendToken: session.accessToken,
          supabaseToken: session.accessToken,
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}

/// Response from authentication containing user data and tokens.
class AuthResponse {
  final String userId;
  final String email;
  final String name;
  final String role;
  final String backendToken;
  final String supabaseToken;

  AuthResponse({
    required this.userId,
    required this.email,
    required this.name,
    required this.role,
    required this.backendToken,
    required this.supabaseToken,
  });
}
