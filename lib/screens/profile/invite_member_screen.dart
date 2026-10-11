import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class InviteMemberScreen extends StatefulWidget {
  final String inviteCode;

  const InviteMemberScreen({
    super.key,
    required this.inviteCode,
  });

  @override
  State<InviteMemberScreen> createState() =>
      _InviteMemberScreenState();
}

class _InviteMemberScreenState
    extends State<InviteMemberScreen> {
  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _emailController =
      TextEditingController();

  String _selectedPermission = 'member';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _copyCode() {
    Clipboard.setData(
      ClipboardData(text: widget.inviteCode),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Household join code copied!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Open WhatsApp and prepare the household invitation message.
  Future<void> _shareWhatsApp() async {
    final message =
        'Hi! Join my Family Budget App household.\n\n'
        'Household Join Code: ${widget.inviteCode}\n\n'
        'Enter this code in the app to join my household.';

    final whatsappUrl = Uri.https(
      'wa.me',
      '/',
      {'text': message},
    );

    try {
      final opened = await launchUrl(
        whatsappUrl,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not open WhatsApp. Please check if it is installed.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open WhatsApp.'),
          ),
        );
      }
    }
  }

  Future<void> _sendInvitation() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the member full name.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (email.isEmpty || !RegExp(r'^[\w\.\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z0-9\-\.]+$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address (e.g. member@example.com).'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final roleTitle = _selectedPermission == 'admin' ? 'Admin / Co-Owner (Full Access)' : 'Member';
    final subject = 'Invitation to join our Family Budget (Code: ${widget.inviteCode})';
    final body = 'Hi $name,\n\n'
        'You have been invited to join our household budget on the Smart Family Budget App!\n\n'
        '• Role: $roleTitle\n'
        '• Household Join Code: ${widget.inviteCode}\n\n'
        'How to join:\n'
        '1. Open the Smart Family Budget app on your device.\n'
        '2. Choose "Join an Existing Family".\n'
        '3. Enter the code "${widget.inviteCode}" to start budgeting together!\n\n'
        'Best regards,\nYour Family';

    final emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );

    try {
      final opened = await launchUrl(
        emailUri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open default email app.'),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email invitation prepared for $email!'),
            backgroundColor: const Color(0xFF087F70),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open email client: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F8FC),
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFF172033),
            ),
          ),
        ),
        title: const Text(
          'INVITE MEMBER',
          style: TextStyle(
            color: Color(0xFF172033),
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFF087F70),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            4,
            20,
            24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Description
              const Text(
                'Add a new member to share household budgets and '
                'track expenses together.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: Color(0xFF697386),
                ),
              ),

              const SizedBox(height: 16),

              // Instant Invitation Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFC8F5E7),
                      Color(0xFFDDF8F2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '⚡ Instant Invitation',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF087F70),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Row(
                          children: [
                            Icon(
                              Icons.circle,
                              size: 7,
                              color: Color(0xFF087F70),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Active for 48h',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF5F706C),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Join Code
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'HOUSEHOLD JOIN CODE',
                            style: TextStyle(
                              fontSize: 9,
                              letterSpacing: 1,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6D7775),
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            widget.inviteCode,
                            style: const TextStyle(
                              fontSize: 22,
                              letterSpacing: 5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF087F70),
                            ),
                          ),

                          const SizedBox(height: 5),

                          const Text(
                            'The member can enter this code in their app '
                            'during setup to join immediately.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 9,
                              color: Color(0xFF7A8582),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _copyCode,
                            icon: const Icon(
                              Icons.copy_outlined,
                              size: 16,
                            ),
                            label: const Text('Copy Code'),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor:
                                  const Color(0xFF172033),
                              side: BorderSide.none,
                              minimumSize: const Size(0, 42),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(22),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _shareWhatsApp,
                            icon: const Icon(
                              Icons.chat_outlined,
                              size: 16,
                            ),
                            label: const Text('WhatsApp'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFF20C76A),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              minimumSize: const Size(0, 42),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(22),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Divider
              Row(
                children: [
                  const Expanded(
                    child: Divider(
                      color: Color(0xFFD9DDE5),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    child: Text(
                      'OR INVITE VIA EMAIL',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey.shade600,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Divider(
                      color: Color(0xFFD9DDE5),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Member Information
              _sectionCard(
                title: 'Member Information',
                icon: Icons.person_add_alt_1_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Member Full Name',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF4D5968),
                      ),
                    ),

                    const SizedBox(height: 6),

                    _inputField(
                      controller: _nameController,
                      hint: 'e.g. Brother, Mom, Dinusha',
                      icon: Icons.badge_outlined,
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'Member Email Address',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF4D5968),
                      ),
                    ),

                    const SizedBox(height: 6),

                    _inputField(
                      controller: _emailController,
                      hint: 'name@example.com',
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Permission Level
              _sectionCard(
                title: 'Assign Permission Level',
                icon: Icons.admin_panel_settings_outlined,
                trailing: const Text(
                  '2 Roles Available',
                  style: TextStyle(
                    fontSize: 9,
                    color: Color(0xFF707A78),
                  ),
                ),
                child: Column(
                  children: [
                    _permissionTile(
                      value: 'admin',
                      title: 'Full Access',
                      badge: 'Admin / Co-Owner',
                      description:
                          'Can view, add, and edit all budgets, goals, and transactions.',
                    ),

                    const SizedBox(height: 8),

                    _permissionTile(
                      value: 'member',
                      title: 'Member',
                      badge: 'Recommended',
                      description:
                          'Can add personal expenses and view shared household limits.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Send Invitation
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: _sendInvitation,
                  icon: const Icon(
                    Icons.mark_email_read_outlined,
                    size: 17,
                  ),
                  label: const Text(
                    'SEND INVITATION',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF087F70),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: const Color(0xFF087F70),
              ),
              const SizedBox(width: 5),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF172033),
                ),
              ),
              const Spacer(),
              if (trailing != null) trailing,
            ],
          ),

          const SizedBox(height: 12),

          child,
        ],
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontSize: 12,
        color: Color(0xFF172033),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontSize: 11,
          color: Color(0xFF9BA4B0),
        ),
        prefixIcon: Icon(
          icon,
          size: 16,
          color: const Color(0xFF7D878C),
        ),
        filled: true,
        fillColor: const Color(0xFFF0F1FB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _permissionTile({
    required String value,
    required String title,
    required String badge,
    required String description,
  }) {
    final bool selected = _selectedPermission == value;

    return InkWell(
      borderRadius: BorderRadius.circular(7),
      onTap: () {
        setState(() {
          _selectedPermission = value;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFE0FAF0)
              : const Color(0xFFF5F5FC),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: selected
                ? const Color(0xFFB8EFD8)
                : Colors.transparent,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Radio<String>(
              value: value,
              groupValue: _selectedPermission,
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedPermission = newValue;
                  });
                }
              },
              activeColor: const Color(0xFF087F70),
              materialTapTargetSize:
                  MaterialTapTargetSize.shrinkWrap,
            ),

            const SizedBox(width: 2),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF172033),
                        ),
                      ),

                      const SizedBox(width: 6),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFFD5E9F7)
                              : const Color(0xFFE7EAF0),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(
                            fontSize: 7,
                            color: Color(0xFF4F5C68),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 3),

                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 9,
                      height: 1.25,
                      color: Color(0xFF66717B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

