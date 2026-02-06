import 'package:fluter/loginPage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants/app_colors.dart';
import 'models/appointmentModel.dart';
import 'services/appointmentService.dart';
import 'adminDoctorManagement.dart';
import 'appointmentListPage.dart';
import 'scheduleManagementPage.dart';
import 'specialtyManagementPage.dart';
import 'usersManagementPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  List<AppointmentModel> appointments = [];
  List<AppointmentModel> todayAppointments = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final [allAppointments, todayAppts] = await Future.wait([
        AppointmentService.getAllAppointments(),
        AppointmentService.getTodayAppointments(),
      ]);

      setState(() {
        appointments = allAppointments;
        todayAppointments = todayAppts;
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
    return _buildDashboardTab();
  }

  void _openPage(Widget page) {
    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            DrawerHeader(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.primary,
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDalfb1byufNYVi8eM9M6fzIiHcJcQiqwPsW9d8JotYAblUcJoEsyR_sNX7E7JQINGZHgQt4kjgrhQYaMeD_oJ2w3qOnhub3WQnSp1uXM5Dnk613Y5tx0kOvx7sOxtnx1NvejK9S3Zj6UPOHOlupOXFQGg9d5EunOmkAihqWufskzKcICH_HB1znmMO7l72g19cmmSq_Osbo-fxmGGGtvZRpn3-gPpZ97UzUKp75W1cokdEaB_Fnb9YfRgAigvQa-NJmC5GMKLK7Ms',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Admin Portal',
                          style: GoogleFonts.manrope(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Management',
                          style: GoogleFonts.manrope(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.grid_view),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.medical_services),
              title: const Text('Doctors'),
              onTap: () => _openPage(const AdminDoctorManagementPage()),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('Appointments'),
              onTap: () => _openPage(const AppointmentListPage()),
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Schedules'),
              onTap: () => _openPage(const ScheduleManagementPage()),
            ),
            //const Divider(),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Specialties'),
              onTap: () => _openPage(const SpecialtyManagementPage()),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Users'),
              onTap: () => _openPage(const UsersManagementPage()),
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout'),
              onTap: () {
                Navigator.of(context).pop();
                _showLogoutDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardTab() {
    final pendingCount = appointments.where((a) => a.status == 'pending').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      drawer: _buildDrawer(),

      // ---------------- TOP APP BAR ----------------
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 12),
            const CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuDalfb1byufNYVi8eM9M6fzIiHcJcQiqwPsW9d8JotYAblUcJoEsyR_sNX7E7JQINGZHgQt4kjgrhQYaMeD_oJ2w3qOnhub3WQnSp1uXM5Dnk613Y5tx0kOvx7sOxtnx1NvejK9S3Zj6UPOHOlupOXFQGg9d5EunOmkAihqWufskzKcICH_HB1znmMO7l72g19cmmSq_Osbo-fxmGGGtvZRpn3-gPpZ97UzUKp75W1cokdEaB_Fnb9YfRgAigvQa-NJmC5GMKLK7Ms',
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome back,",
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  "Admin Portal",
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.black),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AppointmentsManagementPage(
                        initialStatus: 'pending',
                      ),
                    ),
                  );
                },
              ),
              if (pendingCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$pendingCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          
        ],
      ),

      // ---------------- BODY ----------------
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error loading data', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(error!, style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _statsGrid(),
                        const SizedBox(height: 20),
                        _chartCard(),
                        const SizedBox(height: 24),
                        _recentActivity(),
                      ],
                    ),
                  ),
                ),


    );
  }

  // ================= STATS =================
  Widget _statsGrid() {
    final totalAppointments = appointments.length;
    final pendingCount = appointments.where((a) => a.status == 'pending').length;
    final confirmedCount = appointments.where((a) => a.status == 'confirmed').length;
    final patientsToday = todayAppointments.length;
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _StatCard(title: "Total Appointments", value: totalAppointments.toString()),
        _StatCard(title: "Confirmed Today", value: confirmedCount.toString()),
        _StatCard(title: "Patients Today", value: patientsToday.toString()),
        _StatCard(
          title: "Pending Requests",
          value: pendingCount.toString(),
          danger: pendingCount > 0,
        ),
      ],
    );
  }

  // ================= CHART =================
  Widget _chartCard() {
    final todayCount = todayAppointments.length;
    final totalCount = appointments.length;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Appointment Volume",
            style: GoogleFonts.manrope(color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                todayCount.toString(),
                style: GoogleFonts.manrope(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Today",
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Total: $totalCount appointments",
            style: GoogleFonts.manrope(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 120,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bar_chart, size: 32, color: AppColors.primary),
                const SizedBox(height: 8),
                Text("Appointment Statistics", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }


  // ================= ACTIVITY =================
  Widget _recentActivity() {
    final recentAppointments = todayAppointments.take(5).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Today's Appointments",
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AppointmentsManagementPage()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "View All",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (recentAppointments.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: _cardDecoration(),
            child: Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(Icons.event_available, size: 32, color: Colors.grey.shade400),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "No appointments today", 
                    style: GoogleFonts.manrope(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Check back later for new appointments",
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Column(
            children: recentAppointments.asMap().entries.map((entry) {
              final index = entry.key;
              final appointment = entry.value;
              return _EnhancedActivityItem(
                appointment: appointment,
                index: index + 1,
                onStatusUpdate: () => _showStatusUpdateDialog(appointment),
              );
            }).toList(),
          ),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.shade200),
    );
  }

  void _showLogoutDialog() {
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

  Future<void> _showStatusUpdateDialog(AppointmentModel appointment) async {
    String selectedStatus = appointment.status;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Update Appointment Status'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appointment ID: ${appointment.id?.substring(0, 8) ?? 'Unknown'}...',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Current Status: ${appointment.status.toUpperCase()}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text('Select New Status:'),
                  SizedBox(height: 8),
                  ...AppointmentModel.statusValues.map((status) => RadioListTile<String>(
                    title: Text(status.toUpperCase()),
                    value: status,
                    groupValue: selectedStatus,
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value!;
                      });
                    },
                  )).toList(),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: selectedStatus != appointment.status
                      ? () async {
                          try {
                            await AppointmentService.updateAppointmentStatus(
                              appointment.id!,
                              selectedStatus,
                            );
                            Navigator.of(context).pop();
                            _loadData();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Status updated to $selectedStatus'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error updating status: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      : null,
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ================= COMPONENTS =================
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  //final String change;
  final bool danger;

  const _StatCard({
    required this.title,
    required this.value,
    //required this.change,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: danger
                      ? Colors.red.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                // child: Text(
                //   change,
                //   style: TextStyle(
                //     fontSize: 12,
                //     fontWeight: FontWeight.bold,
                //     color: danger ? Colors.red : Colors.green,
                //   ),
                // ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EnhancedActivityItem extends StatelessWidget {
  final AppointmentModel appointment;
  final int index;
  final VoidCallback onStatusUpdate;

  const _EnhancedActivityItem({
    required this.appointment,
    required this.index,
    required this.onStatusUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Number Badge
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  index.toString(),
                  style: GoogleFonts.manrope(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Main Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Patient Name
                  Text(
                    'Patient: ${appointment.patientName ?? appointment.pNo}',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // Doctor Name
                  Text(
                    'Dr. ${appointment.doctorName ?? appointment.docNo}',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                ],
              ),
            ),
            
            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _getStatusColor(appointment.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getStatusColor(appointment.status).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getStatusIcon(appointment.status),
                    size: 14,
                    color: _getStatusColor(appointment.status),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    appointment.status.toUpperCase(),
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(appointment.status),
                    ),
                  ),
                ],
              ),
            ),
            
            // Update Status Button (only for pending)
            if (appointment.status == 'pending') ...[
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: onStatusUpdate,
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.pending_outlined;
      case 'confirmed':
        return Icons.event_available_outlined;
      case 'completed':
        return Icons.check_circle_outline;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.event_outlined;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return AppColors.primary;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

}

class AppointmentsManagementPage extends StatefulWidget {
  final String? initialStatus;
  const AppointmentsManagementPage({super.key, this.initialStatus});

  @override
  State<AppointmentsManagementPage> createState() => _AppointmentsManagementPageState();
}

class _AppointmentsManagementPageState extends State<AppointmentsManagementPage> {
  List<AppointmentModel> allAppointments = [];
  List<AppointmentModel> filteredAppointments = [];
  bool isLoading = true;
  String? error;
  String searchQuery = '';
  String? selectedStatus;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.initialStatus;
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final appointments = await AppointmentService.getAllAppointments();
      
      setState(() {
        allAppointments = appointments;
        filteredAppointments = appointments.where((appointment) {
          final matchesSearch = appointment.pNo.toLowerCase().contains(searchQuery.toLowerCase()) ||
              appointment.docNo.toLowerCase().contains(searchQuery.toLowerCase());
          final matchesStatus = selectedStatus == null || appointment.status == selectedStatus;
          return matchesSearch && matchesStatus;
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void _filterAppointments() {
    setState(() {
      filteredAppointments = allAppointments.where((appointment) {
        final matchesSearch = appointment.pNo.toLowerCase().contains(searchQuery.toLowerCase()) ||
            appointment.docNo.toLowerCase().contains(searchQuery.toLowerCase());
        final matchesStatus = selectedStatus == null || appointment.status == selectedStatus;
        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  Future<void> _updateAppointmentStatus(AppointmentModel appointment, String newStatus) async {
    try {
      await AppointmentService.updateAppointmentStatus(appointment.id!, newStatus);
      _loadAppointments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to $newStatus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Appointments Management',
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _loadAppointments,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error loading appointments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(error!, style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadAppointments,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    _searchAndFilterSection(),
                    const SizedBox(height: 16),
                    Expanded(
                      child: filteredAppointments.isEmpty
                          ? _buildEmptyState()
                          : _buildAppointmentsList(),
                    ),
                  ],
                ),
    );
  }

  Widget _searchAndFilterSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search by patient ID or doctor ID...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            onChanged: (value) {
              searchQuery = value;
              _filterAppointments();
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Filter by Status',
              prefixIcon: const Icon(Icons.filter_list),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            value: selectedStatus,
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('All Status'),
              ),
              ...AppointmentModel.statusValues.map((status) => DropdownMenuItem<String>(
                value: status,
                child: Text(status.toUpperCase()),
              )),
            ],
            onChanged: (value) {
              selectedStatus = value;
              _filterAppointments();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No appointments found',
            style: GoogleFonts.manrope(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: GoogleFonts.manrope(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredAppointments.length,
      itemBuilder: (context, index) {
        final appointment = filteredAppointments[index];
        return _AppointmentCard(
          appointment: appointment,
          onStatusUpdate: () => _showStatusUpdateDialog(appointment),
        );
      },
    );
  }

  Future<void> _showStatusUpdateDialog(AppointmentModel appointment) async {
    String selectedStatus = appointment.status;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Update Appointment Status'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appointment ID: ${appointment.id?.substring(0, 8) ?? 'Unknown'}...',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Patient ID: ${appointment.pNo}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Doctor ID: ${appointment.docNo}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Current Status: ${appointment.status.toUpperCase()}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text('Select New Status:'),
                  SizedBox(height: 8),
                  ...AppointmentModel.statusValues.map((status) => RadioListTile<String>(
                    title: Text(status.toUpperCase()),
                    value: status,
                    groupValue: selectedStatus,
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value!;
                      });
                    },
                  )).toList(),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: selectedStatus != appointment.status
                      ? () {
                          Navigator.of(context).pop();
                          _updateAppointmentStatus(appointment, selectedStatus);
                        }
                      : null,
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback onStatusUpdate;

  const _AppointmentCard({
    required this.appointment,
    required this.onStatusUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Icon(
                    _getStatusIcon(appointment.status),
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.patientName ?? appointment.pNo,
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Dr. ${appointment.doctorName ?? appointment.docNo}',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(appointment.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    appointment.status.toUpperCase(),
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(appointment.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  '${appointment.date.day}/${appointment.date.month}/${appointment.date.year}',
                  style: GoogleFonts.manrope(fontSize: 12, color: Colors.grey.shade600),
                ),
                const Spacer(),
                Text(
                  '\$${appointment.fee.toStringAsFixed(2)}',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onStatusUpdate,
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Update Status'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.pending;
      case 'confirmed':
        return Icons.event_available;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.event;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return AppColors.primary;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
