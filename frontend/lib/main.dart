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
        ChangeNotifierProvider(create: (_) => BookingProvider()),
      ],
      child: MaterialApp(
        title: 'Bike Service Station',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
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
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppTheme.primaryColor),
              SizedBox(height: 24),
              Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
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
