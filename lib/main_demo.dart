import 'package:flutter/material.dart';
import 'appointmentDemoPage.dart';
import 'constants/app_colors.dart';

void main() {
  runApp(const AppointmentDemoApp());
}

class AppointmentDemoApp extends StatelessWidget {
  const AppointmentDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Appointment Booking Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary).copyWith(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
        ),
      ),
      home: const AppointmentDemoPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
