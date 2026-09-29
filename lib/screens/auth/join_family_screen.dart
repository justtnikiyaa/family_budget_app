import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class JoinFamilyScreen extends StatefulWidget {
  final UserModel currentUser;

  const JoinFamilyScreen({super.key, required this.currentUser});

  @override
  State<JoinFamilyScreen> createState() => _JoinFamilyScreenState();
}

class _JoinFamilyScreenState extends State<JoinFamilyScreen> {
  final _codeController = TextEditingController();
  final _firestoreService = FirestoreService();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleJoin() async {
    final code = _codeController.text.trim();
    if (code.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid invitation code')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _firestoreService.joinFamily(
        inviteCode: code,
        currentUser: widget.currentUser,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully joined family group!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join Family')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.accent.withValues(alpha: 0.15),
                child: const Icon(Icons.group_add_rounded, size: 40, color: AppColors.accent),
              ),
              const SizedBox(height: 24),
              Text(
                'Enter Invitation Code',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ask your family administrator for the 6-character invite code to link your budget.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 32),
              CustomTextField(
                controller: _codeController,
                label: 'Family Code (e.g., A7X9P2)',
                prefixIcon: Icons.key_outlined,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Join Family Group',
                isLoading: _isLoading,
                onPressed: _handleJoin,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
