import 'package:flutter/material.dart';
import '../services/google_auth_service.dart';
import '../services/supabase_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GoogleAuthService _authService = GoogleAuthService();
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkExistingSignIn();
  }

  /// Check if user is already signed in
  Future<void> _checkExistingSignIn() async {
    try {
      final account = await _authService.signInSilently();
      if (account != null && mounted) {
        setState(() {
          _isLoading = true;
        });
        await _completeFrontendSignIn();
      }
    } catch (error) {
      print('Silent sign-in error: $error');
      // Don't show error on silent sign-in failure - just skip it
    }
  }

  /// Handle Google Sign-In button press
  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final account = await _authService.signIn();

      if (account == null) {
        setState(() {
          _errorMessage = 'Sign-in was cancelled';
          _isLoading = false;
        });
        return;
      }

      await _completeFrontendSignIn();
    } catch (error) {
      setState(() {
        _errorMessage = 'Sign-in failed: $error';
        _isLoading = false;
      });
    }
  }

  /// Complete sign-in on frontend only (no backend verification)
  Future<void> _completeFrontendSignIn() async {
    try {
      final account = _authService.currentUser;
      if (account == null) {
        setState(() {
          _errorMessage = 'No signed-in account found';
          _isLoading = false;
        });
        return;
      }
      // Check if student exists, create if not
      final studentId = SupabaseService.getStudentIdFromEmail(account.email);
      var student = await _supabaseService.getStudentProfile(studentId);

      if (student == null) {
        // Create new student profile
        try {
          student = await _supabaseService.createStudentProfile(
            email: account.email,
            name: account.displayName ?? account.email.split('@')[0],
            phone: 'Not Provided',
          );
        } catch (e) {
          setState(() {
            _errorMessage = 'Failed to create student profile: $e';
            _isLoading = false;
          });
          await _authService.signOut();
          return;
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Navigate to home screen, using student_id extracted from email
        Navigator.of(context).pushReplacementNamed(
          '/home',
          arguments: {
            'email': studentId,
            'user': {
              'email': account.email,
              'name': account.displayName ?? '',
              'picture': account.photoUrl ?? '',
              'user_id': account.id,
              'email_verified': true,
            },
          },
        );
      }
    } catch (error) {
      print('Frontend sign-in error: $error');
      setState(() {
        _errorMessage = 'Network error: $error';
        _isLoading = false;
      });
      await _authService.signOut();
    }
  }

  /// Handle sign out
  Future<void> _handleSignOut() async {
    await _authService.signOut();
    setState(() {
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student App Login'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo or Title
              Icon(
                Icons.school,
                size: 100,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              const Text(
                'Mess Leave Management',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Student Portal',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 48),

              // Error message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),

              // Loading indicator or Sign-In button
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton.icon(
                  onPressed: _handleGoogleSignIn,
                  icon: Image.network(
                    'https://www.google.com/favicon.ico',
                    height: 24,
                    width: 24,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.login),
                  ),
                  label: const Text('Sign in with Google'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),

              const SizedBox(height: 16),

              // Info text
              const Text(
                'Use your institutional Google account',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
