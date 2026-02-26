import 'package:mobile/core/constants/app_constants.dart';
import 'package:mobile/features/auth/login_screen.dart';
import 'package:mobile/features/auth/role_selection_screen.dart';
import 'package:mobile/features/auth/signup_screen.dart';
import 'package:mobile/features/dashboard/dashboard_screen.dart';
import 'package:mobile/features/classroom/classroom_screen.dart';
import 'features/auth/doctor_login_screen.dart';
import 'features/auth/doctor_signup_screen.dart';
import 'features/dashboard/doctor_dashboard_screen.dart';
import 'features/dashboard/doctor_patient_vitals_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SYNAPSE',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF2D004D),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF2D004D),
          secondary: Color(0xFF00E5FF),
        ),
      ),
      initialRoute: AppConstants.dashboardRoute,
      routes: {
        AppConstants.roleSelectionRoute: (context) =>
            const RoleSelectionScreen(),
        AppConstants.loginRoute: (context) => const LoginScreen(),
        AppConstants.signupRoute: (context) => const SignupScreen(),
        '/doctor_login': (context) => const DoctorLoginScreen(),
        '/doctor_signup': (context) => const DoctorSignupScreen(),
        '/doctor_dashboard': (context) => const DoctorDashboardScreen(),
        '/doctor_patient_vitals': (context) =>
            const DoctorPatientVitalsScreen(),
        AppConstants.dashboardRoute: (context) => const DashboardScreen(),
        '/classroom': (context) => const ClassroomScreen(),
      },
    );
  }
}
