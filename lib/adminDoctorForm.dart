import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants/app_colors.dart';
import 'models/doctorModel.dart';
import 'models/specialtyModel.dart';
import 'services/doctorService.dart';

class AdminDoctorFormPage extends StatefulWidget {
  final Doctor? doctor;
  final List<Specialty> specialties;

  const AdminDoctorFormPage({
    super.key,
    this.doctor,
    required this.specialties,
  });

  @override
  State<AdminDoctorFormPage> createState() => _AdminDoctorFormPageState();
}

class _AdminDoctorFormPageState extends State<AdminDoctorFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String? error;

  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _qualificationController;
  late TextEditingController _bioController;
  late TextEditingController _experienceController;

  String? _selectedSpecialtyId;
  String _selectedSex = 'male';
  String _selectedStatus = 'active';

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _fullNameController = TextEditingController(text: widget.doctor?.fullName ?? '');
    _emailController = TextEditingController(text: widget.doctor?.email ?? '');
    _phoneController = TextEditingController(text: widget.doctor?.tell ?? '');
    _qualificationController = TextEditingController(text: widget.doctor?.qualification ?? '');
    _bioController = TextEditingController(text: widget.doctor?.bio ?? '');
    _experienceController = TextEditingController(text: widget.doctor?.experienceYears.toString() ?? '0');
    
    _selectedSpecialtyId = widget.doctor?.sp_no;
    _selectedSex = widget.doctor?.sex ?? 'male';
    _selectedStatus = widget.doctor?.status ?? 'active';
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _qualificationController.dispose();
    _bioController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _saveDoctor() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // Create doctor first without image to get ID
      final doctor = Doctor(
        id: widget.doctor?.id,
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        tell: _phoneController.text.trim(),
        qualification: _qualificationController.text.trim().isEmpty ? null : _qualificationController.text.trim(),
        bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
        experienceYears: int.tryParse(_experienceController.text) ?? 0,
        image: null, // Don't set image yet
        sex: _selectedSex,
        status: _selectedStatus,
        sp_no: _selectedSpecialtyId!,
      );

      if (widget.doctor == null) {
        await DoctorService.createDoctor(doctor);
      } else {
        await DoctorService.updateDoctor(widget.doctor!.id!, doctor);
      }

      // Do not upload/save doctor images anymore.

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.doctor == null ? 'Doctor created successfully' : 'Doctor updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.doctor != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          isEditing ? 'Edit Doctor' : 'Add New Doctor',
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // TextButton(
          //   onPressed: isLoading ? null : _saveDoctor,
          //   child: Text(
          //     'Save',
          //     style: GoogleFonts.manrope(
          //       fontWeight: FontWeight.bold,
          //       color: isLoading ? Colors.grey : const Color(0xFF135BEC),
          //     ),
          //   ),
          // ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (error != null) _buildErrorCard(),
              _buildPersonalInfoSection(),
              const SizedBox(height: 24),
              _buildProfessionalInfoSection(),
              const SizedBox(height: 24),
              _buildAdditionalInfoSection(),
              const SizedBox(height: 32),
              _buildSaveButton(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error!,
              style: GoogleFonts.manrope(
                fontSize: 14,
                color: Colors.red.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return _buildSection(
      title: 'Personal Information',
      children: [
        TextFormField(
          controller: _fullNameController,
          decoration: _buildInputDecoration('Full Name', Icons.person),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter full name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          decoration: _buildInputDecoration('Email Address', Icons.email),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter email address';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email address';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          decoration: _buildInputDecoration('Phone Number', Icons.phone),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter phone number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          decoration: _buildInputDecoration('Gender', Icons.person_outline),
          value: _selectedSex,
          items: const [
            DropdownMenuItem(value: 'male', child: Text('Male')),
            DropdownMenuItem(value: 'female', child: Text('Female')),
          ],
          onChanged: (value) {
            setState(() {
              _selectedSex = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildProfessionalInfoSection() {
    return _buildSection(
      title: 'Professional Information',
      children: [
        DropdownButtonFormField<String>(
          decoration: _buildInputDecoration('Specialty', Icons.medical_services),
          value: _selectedSpecialtyId,
          items: widget.specialties.map((specialty) => DropdownMenuItem<String>(
            value: specialty.id,
            child: Text(specialty.name),
          )).toList(),
          validator: (value) {
            if (value == null) {
              return 'Please select a specialty';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {
              _selectedSpecialtyId = value;
            });
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _qualificationController,
          decoration: _buildInputDecoration('Qualification', Icons.school),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _experienceController,
          decoration: _buildInputDecoration('Years of Experience', Icons.work),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter years of experience';
            }
            final years = int.tryParse(value);
            if (years == null || years < 0) {
              return 'Please enter a valid number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          decoration: _buildInputDecoration('Status', Icons.toggle_on),
          value: _selectedStatus,
          items: const [
            DropdownMenuItem(value: 'active', child: Text('Active')),
            DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
          ],
          onChanged: (value) {
            setState(() {
              _selectedStatus = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Column(
      children: [
        _buildSection(
          title: 'Additional Information',
          children: [
            TextFormField(
              controller: _bioController,
              decoration: _buildInputDecoration('Bio', Icons.info),
              maxLines: 3,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey.shade600),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.primary),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : _saveDoctor,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                widget.doctor == null ? 'Create Doctor' : 'Update Doctor',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
