import 'package:flutter/material.dart';
import 'package:fluter/api/api.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants/app_colors.dart';
import 'models/doctorModel.dart';
import 'models/specialtyModel.dart';
import 'services/doctorService.dart';
import 'services/specialtyService.dart';
import 'adminDoctorForm.dart';

class AdminDoctorManagementPage extends StatefulWidget {
  const AdminDoctorManagementPage({super.key});

  @override
  State<AdminDoctorManagementPage> createState() => _AdminDoctorManagementPageState();
}

class _AdminDoctorManagementPageState extends State<AdminDoctorManagementPage> {
  List<Doctor> doctors = [];
  List<Specialty> specialties = [];
  List<Doctor> filteredDoctors = [];
  bool isLoading = true;
  String? error;
  String searchQuery = '';
  String? selectedSpecialtyId;

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

      final [doctorsList, specialtiesList] = await Future.wait([
        DoctorService.getAllDoctors(),
        SpecialtyService.getAllSpecialties(),
      ]);

      setState(() {
        doctors = doctorsList.cast<Doctor>();
        filteredDoctors = doctorsList.cast<Doctor>();
        specialties = specialtiesList.cast<Specialty>();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void _filterDoctors() {
    setState(() {
      filteredDoctors = doctors.where((doctor) {
        final matchesSearch = doctor.fullName.toLowerCase().contains(searchQuery.toLowerCase()) ||
            doctor.email.toLowerCase().contains(searchQuery.toLowerCase());
        final matchesSpecialty = selectedSpecialtyId == null || doctor.sp_no == selectedSpecialtyId;
        return matchesSearch && matchesSpecialty;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Doctor Management',
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _loadData,
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
              : Column(
                  children: [
                    _searchAndFilterSection(),
                    const SizedBox(height: 16),
                    Expanded(
                      child: filteredDoctors.isEmpty
                          ? _buildEmptyState()
                          : _buildDoctorsList(),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AdminDoctorFormPage(specialties: specialties)),
          );
          if (result == true) {
            _loadData();
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
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
              hintText: 'Search doctors by name or email...',
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
              _filterDoctors();
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Filter by Specialty',
              prefixIcon: const Icon(Icons.medical_services),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            value: selectedSpecialtyId,
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('All Specialties'),
              ),
              ...specialties.map((specialty) => DropdownMenuItem<String>(
                value: specialty.id,
                child: Text(specialty.name),
              )),
            ],
            onChanged: (value) {
              selectedSpecialtyId = value;
              _filterDoctors();
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
          Icon(Icons.person_off, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No doctors found',
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

  Widget _buildDoctorsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredDoctors.length,
      itemBuilder: (context, index) {
        final doctor = filteredDoctors[index];
        return _DoctorCard(
          doctor: doctor,
          specialty: specialties.firstWhere(
            (spec) => spec.id == doctor.sp_no,
            orElse: () => Specialty(name: 'Unknown'),
          ),
          onEdit: () => _editDoctor(doctor),
          onDelete: () => _deleteDoctor(doctor),
          onToggleStatus: () => _toggleDoctorStatus(doctor),
        );
      },
    );
  }

  Future<void> _editDoctor(Doctor doctor) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminDoctorFormPage(
          doctor: doctor,
          specialties: specialties,
        ),
      ),
    );
    if (result == true) {
      _loadData();
    }
  }

  Future<void> _deleteDoctor(Doctor doctor) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Doctor'),
        content: Text('Are you sure you want to delete Dr. ${doctor.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await DoctorService.deleteDoctor(doctor.id!);
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Doctor deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting doctor: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _toggleDoctorStatus(Doctor doctor) async {
    try {
      final newStatus = doctor.status == 'active' ? 'inactive' : 'active';
      await DoctorService.updateDoctorStatus(doctor.id!, newStatus);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Doctor ${newStatus == 'active' ? 'activated' : 'deactivated'} successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating doctor status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final Specialty specialty;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleStatus;

  const _DoctorCard({
    required this.doctor,
    required this.specialty,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
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
                  backgroundImage: ApiClient.resolveImageUrl(doctor.image).isNotEmpty
                      ? NetworkImage(ApiClient.resolveImageUrl(doctor.image))
                      : null,
                  child: ApiClient.resolveImageUrl(doctor.image).isEmpty
                      ? Text(
                          doctor.fullName.substring(0, 2).toUpperCase(),
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${doctor.fullName}',
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        specialty.name,
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
                    color: doctor.status == 'active' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    doctor.status.toUpperCase(),
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: doctor.status == 'active' ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.email_outlined, size: 16, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    doctor.email,
                    style: GoogleFonts.manrope(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.phone_outlined, size: 16, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  doctor.tell,
                  style: GoogleFonts.manrope(fontSize: 12, color: Colors.grey.shade600),
                ),
                const Spacer(),
                Text(
                  '${doctor.experienceYears} years exp.',
                  style: GoogleFonts.manrope(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // TextButton.icon(
                //   onPressed: onToggleStatus,
                //   icon: Icon(
                //     doctor.status == 'active' ? Icons.block : Icons.check_circle,
                //     size: 16,
                //   ),
                //   label: Text(doctor.status == 'active' ? 'Deactivate' : 'Activate'),
                //   style: TextButton.styleFrom(
                //     foregroundColor: doctor.status == 'active' ? Colors.orange : Colors.green,
                //   ),
                // ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
