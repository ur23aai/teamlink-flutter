import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/team_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class JoinTeamScreen extends StatefulWidget {
  const JoinTeamScreen({Key? key}) : super(key: key);

  @override
  State<JoinTeamScreen> createState() => _JoinTeamScreenState();
}

class _JoinTeamScreenState extends State<JoinTeamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _joinCodeController = TextEditingController();

  @override
  void dispose() {
    _joinCodeController.dispose();
    super.dispose();
  }

  Future<void> _joinTeam() async {
    if (!_formKey.currentState!.validate()) return;

    final teamProvider = Provider.of<TeamProvider>(context, listen: false);

    final success = await teamProvider.joinTeam(
      _joinCodeController.text.trim(),
    );

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully joined the team!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(teamProvider.errorMessage ?? 'Failed to join team'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Team'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.login,
                size: 64,
                color: Color(0xFF8B5CF6),
              ),
              const SizedBox(height: 16),
              const Text(
                'Join a Team',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the team code to join',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              CustomTextField(
                label: 'Join Code',
                hintText: 'Enter 8-character code',
                controller: _joinCodeController,
                prefixIcon: const Icon(Icons.vpn_key),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a join code';
                  }
                  if (value.length < 6) {
                    return 'Join code must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Ask your team admin for the join code',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Consumer<TeamProvider>(
                builder: (context, teamProvider, _) {
                  return CustomButton(
                    text: 'Join Team',
                    onPressed: _joinTeam,
                    isLoading: teamProvider.isLoading,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}