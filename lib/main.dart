import 'dart:convert';
import 'package:fluter/loginPage.dart';
import 'package:fluter/adminDashboard.dart';
import 'package:fluter/patientDashboard.dart';
import 'package:fluter/doctorDashboard.dart';
import 'package:fluter/models/userModel.dart';
import 'package:fluter/models/peopleModel.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget? _defaultHome;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      final String? role = prefs.getString('userRole');
      final String? userDataString = prefs.getString('userData');

      if (role != null && userDataString != null) {
        final Map<String, dynamic> userData = jsonDecode(userDataString);

        setState(() {
          if (role == 'admin') {
            _defaultHome = const AdminDashboardPage();
          } else if (role == 'patient') {
            final patient = PeopleModel.fromJson(userData);
            _defaultHome = PatientHomePage(patient: patient);
          } else if (role == 'doctor') {
            final doctor = UserModel.fromJson(userData);
            _defaultHome = DoctorDashboard(doctor: doctor);
          } else {
            _defaultHome = const LoginPage();
          }
        });
      } else {
        setState(() {
          _defaultHome = const LoginPage();
        });
      }
    } else {
      setState(() {
        _defaultHome = const LoginPage();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_defaultHome == null) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      title: 'Hospital Management System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary).copyWith(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
        ),
      ),
      home: _defaultHome,
    );
  }
}



