import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/service_provider.dart';
import 'providers/booking_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/owner/owner_dashboard.dart';
import 'screens/customer/customer_home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BikeServiceApp());
}

class BikeServiceApp extends StatelessWidget {
  const BikeServiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProvider(create: (_) => ServiceProvider()),
        ChangeNotifierProxyProvider<AuthProvider, BookingProvider>(
          create: (_) => BookingProvider(),
          update: (_, auth, booking) {
            booking?.setAuthProvider(auth);
            return booking ?? BookingProvider()..setAuthProvider(auth);
          },
        ),
      ],
      child: MaterialApp(
        title: 'Bike Service Station',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.light,
        home: const AuthWrapper(),
      ),
    );
  }
}

/// Wrapper that handles authentication routing
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Show loading while checking auth state
    if (authProvider.isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppTheme.primary,
                strokeWidth: 2,
              ),
              const SizedBox(height: 24),
              Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Route based on auth state and role
    if (authProvider.isAuthenticated) {
      if (authProvider.isOwner) {
        return const OwnerDashboard();
      } else {
        return const CustomerHome();
      }
    }

    return const LoginScreen();
  }
}
