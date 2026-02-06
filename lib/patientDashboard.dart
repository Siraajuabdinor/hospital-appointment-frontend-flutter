import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'package:fluter/api/api.dart';
import 'models/doctorModel.dart';
import 'models/peopleModel.dart';
import 'services/doctorService.dart';
import 'doctorDetailPage.dart';

import 'appointmentListPage.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
import 'loginPage.dart';

class PatientHomePage extends StatefulWidget {
  final PeopleModel? patient;
  
  const PatientHomePage({super.key, this.patient});

  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Define pages here to access widget.patient
    final List<Widget> pages = [
      // Home Page Content
      SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TopBar(
              patient: widget.patient,
              onLogout: () => _showLogoutDialog(context),
            ),
            const SizedBox(height: 20),
            const SearchBarWidget(),
            const SizedBox(height: 24),
            DoctorSection(patient: widget.patient),
            const SizedBox(height: 24),
            const PromoBanner(),
          ],
        ),
      ),
      // Appointments Page
      AppointmentListPage(patientId: widget.patient?.id),
      // Profile Page
      PatientProfilePage(patient: widget.patient),
    ];

    return Scaffold(
      body: SafeArea(
        child: pages[_currentIndex],
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                if (!context.mounted) return;
                Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

/// ================= TOP BAR =================
class TopBar extends StatelessWidget {
  final PeopleModel? patient;
  final VoidCallback? onLogout;
  
  const TopBar({super.key, this.patient, this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundImage:
                    NetworkImage('https://randomuser.me/api/portraits/men/32.jpg'),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Good morning',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    patient?.fullName ?? 'Guest User',
                    style:
                        const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: onLogout,
          ),
        ],
      ),
    );
  }
}

/// ================= SEARCH BAR =================
class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search doctors, specialities...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: const Icon(Icons.tune),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

/// ================= DOCTORS =================
class DoctorSection extends StatefulWidget {
  final PeopleModel? patient;
  
  const DoctorSection({super.key, this.patient});

  @override
  State<DoctorSection> createState() => _DoctorSectionState();
}

class _DoctorSectionState extends State<DoctorSection> {
  List<Doctor> doctors = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    try {
      final doctorList = await DoctorService.getActiveDoctors();
      setState(() {
        doctors = doctorList.take(3).toList(); // Show top 3 doctors
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Rated Doctors',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (error != null)
            Text(
              'Error loading doctors: $error',
              style: const TextStyle(color: Colors.red),
            )
          else if (doctors.isEmpty)
            const Text('No doctors available')
          else
            ...doctors.map((doctor) => DoctorCard(
              name: doctor.fullName,
              speciality: doctor.qualification ?? 'General Practitioner',
              imageUrl: ApiClient.resolveImageUrl(doctor.image),
              doctor: doctor,
              patient: widget.patient,
            )).toList(),
        ],
      ),
    );
  }
}

class DoctorCard extends StatelessWidget {
  final String name;
  final String speciality;
  final String imageUrl;
  final Doctor doctor;
  final PeopleModel? patient;

  const DoctorCard({
    super.key,
    required this.name,
    required this.speciality,
    required this.imageUrl,
    required this.doctor,
    this.patient,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DoctorDetailPage(
                doctor: doctor,
                patientId: patient?.id,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
            child: imageUrl.isEmpty
                ? Text(
                    name.substring(0, 2).toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )
                : null,
          ),
          title: Text(name,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(speciality),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
          ),
        ),
      ),
    );
  }
}

/// ================= PROMO =================
class PromoBanner extends StatelessWidget {
  const PromoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      // child: Container(
      //   padding: const EdgeInsets.all(20),
      //   decoration: BoxDecoration(
      //     color: const Color(0xFF2B8CEE),
      //     borderRadius: BorderRadius.circular(20),
      //   ),
      //   child: const Text(
      //     'Get up to 20% discount on your first consultation',
      //     style: TextStyle(color: Colors.white),
      //   ),
      // ),
    );
  }
}

/// ================= DOCTOR DETAILS DIALOG =================
class DoctorDetailsDialog extends StatelessWidget {
  final Doctor doctor;

  const DoctorDetailsDialog({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Doctor Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Doctor Profile
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: ApiClient.resolveImageUrl(doctor.image).isNotEmpty
                      ? NetworkImage(ApiClient.resolveImageUrl(doctor.image))
                      : null,
                  child: ApiClient.resolveImageUrl(doctor.image).isEmpty
                      ? Text(
                          doctor.fullName.substring(0, 2).toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.fullName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        doctor.qualification ?? 'General Practitioner',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: doctor.status == 'active' 
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          doctor.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            color: doctor.status == 'active' 
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Contact Information
            const Text(
              'Contact Information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.email, doctor.email),
            _buildInfoRow(Icons.phone, doctor.tell),
            
            const SizedBox(height: 16),
            
            // Professional Information
            const Text(
              'Professional Information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.person, doctor.sex),
            _buildInfoRow(Icons.work, '${doctor.experienceYears} years experience'),
            if (doctor.bio != null && doctor.bio!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                doctor.bio!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
            
            const SizedBox(height: 20),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Booking with ${doctor.fullName}')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Book Appointment'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}

/// ================= PATIENT PROFILE PAGE =================
class PatientProfilePage extends StatelessWidget {
  final PeopleModel? patient;
  
  const PatientProfilePage({super.key, this.patient});

  @override
  Widget build(BuildContext context) {
    if (patient == null) {
      return const Center(
        child: Text('No patient data available'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  backgroundImage: const NetworkImage(
                    'https://randomuser.me/api/portraits/men/32.jpg',
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  patient!.fullName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '@${patient!.username}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Personal Information Section
          _buildSection(
            title: 'Personal Information',
            children: [
              _buildInfoTile(Icons.person, 'Full Name', patient!.fullName),
              _buildInfoTile(Icons.badge, 'Username', patient!.username),
              _buildInfoTile(Icons.male, 'Gender', patient!.sex),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Contact Information Section
          _buildSection(
            title: 'Contact Information',
            children: [
              _buildInfoTile(Icons.email, 'Email', patient!.email),
              _buildInfoTile(Icons.phone, 'Phone', patient!.tell),
              _buildInfoTile(Icons.location_on, 'Address', patient!.address),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Account Actions
          // _buildSection(
          //   title: 'Account Actions',
          //   children: [
          //     ListTile(
          //       leading: const Icon(Icons.edit, color: Color(0xFF2B8CEE)),
          //       title: const Text('Edit Profile'),
          //       trailing: const Icon(Icons.arrow_forward_ios),
          //       onTap: () {
          //         ScaffoldMessenger.of(context).showSnackBar(
          //           const SnackBar(content: Text('Edit profile feature coming soon')),
          //         );
          //       },
          //     ),
          //     ListTile(
          //       leading: const Icon(Icons.lock, color: Color(0xFF2B8CEE)),
          //       title: const Text('Change Password'),
          //       trailing: const Icon(Icons.arrow_forward_ios),
          //       onTap: () {
          //         ScaffoldMessenger.of(context).showSnackBar(
          //           const SnackBar(content: Text('Change password feature coming soon')),
          //         );
          //       },
          //     ),
          //     ListTile(
          //       leading: const Icon(Icons.notifications, color: Color(0xFF2B8CEE)),
          //       title: const Text('Notification Settings'),
          //       trailing: const Icon(Icons.arrow_forward_ios),
          //       onTap: () {
          //         ScaffoldMessenger.of(context).showSnackBar(
          //           const SnackBar(content: Text('Notification settings coming soon')),
          //         );
          //       },
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.grey,
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// ================= BOTTOM NAV =================
class BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNav({
    super.key, 
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today), label: 'Appointments'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
