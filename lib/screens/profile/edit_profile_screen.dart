import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel currentUser;

  const EditProfileScreen({
    super.key,
    required this.currentUser,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  final AuthService _authService = AuthService();

  bool _isLoading = false;

  String _selectedRole = 'Primary Contributor / Admin';

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.currentUser.displayName,
    );

    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your full name'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Existing Firebase profile update logic
      await _authService.updateProfile(
        displayName: name,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
          ),
        );

        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _changePhoto() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Change Profile Photo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: const Text('Take a photo'),
                  onTap: () {
                    Navigator.pop(context);

                    ScaffoldMessenger.of(this.context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Camera feature will be connected next.',
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Choose from gallery'),
                  onTap: () {
                    Navigator.pop(context);

                    ScaffoldMessenger.of(this.context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Gallery feature will be connected next.',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF087F6B);
    const backgroundColor = Color(0xFFF7F8FC);
    const fieldColor = Color(0xFFF0F1FF);
    const textColor = Color(0xFF27303F);
    const secondaryTextColor = Color(0xFF6F7785);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // -----------------------------------------------------------
            // TOP BAR
            // -----------------------------------------------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 21,
                    ),
                    color: textColor,
                  ),
                  const Expanded(
                    child: Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: Colors.white,
                      size: 21,
                    ),
                  ),
                ],
              ),
            ),

            // -----------------------------------------------------------
            // CONTENT
            // -----------------------------------------------------------
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // -----------------------------------------------------
                    // PROFILE PHOTO
                    // -----------------------------------------------------
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFE9ECFF),
                                  border: Border.all(
                                    color: primaryColor,
                                    width: 4,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  _getInitials(
                                    widget.currentUser.displayName,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 42,
                                    fontWeight: FontWeight.w700,
                                    color: primaryColor,
                                  ),
                                ),
                              ),

                              Positioned(
                                right: -2,
                                bottom: -2,
                                child: GestureDetector(
                                  onTap: _changePhoto,
                                  child: Container(
                                    width: 38,
                                    height: 38,
                                    decoration: const BoxDecoration(
                                      color: primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_outlined,
                                      color: Colors.white,
                                      size: 19,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          GestureDetector(
                            onTap: _changePhoto,
                            child: const Text(
                              'Change Photo',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // -----------------------------------------------------
                    // FULL NAME
                    // -----------------------------------------------------
                    _sectionLabel('FULL NAME'),

                    const SizedBox(height: 7),

                    TextField(
                      controller: _nameController,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                      decoration: _inputDecoration(
                        icon: Icons.badge_outlined,
                        hint: 'Enter your full name',
                        fillColor: fieldColor,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // -----------------------------------------------------
                    // EMAIL
                    // -----------------------------------------------------
                    Row(
                      children: [
                        _sectionLabel('EMAIL ADDRESS'),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFB9F7D7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 12,
                                color: Color(0xFF087F6B),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Verified',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF087F6B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 7),

                    TextFormField(
                      initialValue: widget.currentUser.email,
                      enabled: false,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                      decoration: _inputDecoration(
                        icon: Icons.email_outlined,
                        hint: 'Email address',
                        fillColor: fieldColor,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // -----------------------------------------------------
                    // PHONE NUMBER
                    // -----------------------------------------------------
                    _sectionLabel('PHONE NUMBER'),

                    const SizedBox(height: 7),

                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: fieldColor,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 14),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'LK  +94',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: secondaryTextColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                            ],
                          ),
                        ),
                        suffixIcon: const Icon(
                          Icons.phone_outlined,
                          size: 20,
                          color: secondaryTextColor,
                        ),
                        hintText: '77 123 4567',
                        hintStyle: const TextStyle(
                          color: secondaryTextColor,
                          fontSize: 15,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(9),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 16,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // -----------------------------------------------------
                    // ROLE IN HOUSEHOLD
                    // -----------------------------------------------------
                    _sectionLabel('ROLE IN HOUSEHOLD'),

                    const SizedBox(height: 7),

                    Container(
                      decoration: BoxDecoration(
                        color: fieldColor,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.admin_panel_settings_outlined,
                            color: secondaryTextColor,
                            size: 21,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Primary Contributor / Admin',
                            child: Text(
                              'Primary Contributor / Admin',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Contributor',
                            child: Text(
                              'Contributor',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Viewer',
                            child: Text(
                              'Viewer',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedRole = value;
                            });
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 22),

                    // -----------------------------------------------------
                    // HOUSEHOLD DETAILS
                    // -----------------------------------------------------
                    Row(
                      children: [
                        const Text(
                          'HOUSEHOLD DETAILS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: secondaryTextColor,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          '(READ-ONLY)',
                          style: TextStyle(
                            fontSize: 10,
                            color: secondaryTextColor,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.lock_outline,
                          size: 15,
                          color: Colors.grey.shade500,
                        ),
                      ],
                    ),

                    const SizedBox(height: 7),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                          color: const Color(0xFFE7E8EF),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Household Name',
                            style: TextStyle(
                              fontSize: 10,
                              color: secondaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'My Household',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: textColor,
                                  ),
                                ),
                              ),
                              Container(
                                width: 34,
                                height: 34,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE9ECFF),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.groups_outlined,
                                  color: primaryColor,
                                  size: 19,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: fieldColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'FAMILY REFERENCE CODE',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: secondaryTextColor,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Expanded(
                                      child: Text(
                                        'AX-992-B',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.2,
                                          color: primaryColor,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFB9F7D7),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.sync,
                                            size: 11,
                                            color: primaryColor,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'SYNCED',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              color: primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // -----------------------------------------------------
                    // SAVE BUTTON
                    // -----------------------------------------------------
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.save_outlined,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'SAVE CHANGES',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: Color(0xFF69717F),
        letterSpacing: 0.3,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required IconData icon,
    required String hint,
    required Color fillColor,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: fillColor,
      prefixIcon: Icon(
        icon,
        color: const Color(0xFF737B88),
        size: 20,
      ),
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF737B88),
        fontSize: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 16,
      ),
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'U';
    }

    final parts = name.trim().split(' ');

    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}