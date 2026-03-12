import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/team_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class CreateTeamScreen extends StatefulWidget {
  const CreateTeamScreen({Key? key}) : super(key: key);

  @override
  State<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends State<CreateTeamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createTeam() async {
    if (!_formKey.currentState!.validate()) return;

    final teamProvider = Provider.of<TeamProvider>(context, listen: false);

    final success = await teamProvider.createTeam(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
    );

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Team created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(teamProvider.errorMessage ?? 'Failed to create team'),
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
        title: const Text('Create Team'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.groups,
                size: 64,
                color: Color(0xFF8B5CF6),
              ),
              const SizedBox(height: 16),
              const Text(
                'Create a New Team',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Build your team and start collaborating',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              CustomTextField(
                label: 'Team Name',
                hintText: 'e.g., Development Team',
                controller: _nameController,
                prefixIcon: const Icon(Icons.people),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a team name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Description (Optional)',
                hintText: 'What is this team about?',
                controller: _descriptionController,
                prefixIcon: const Icon(Icons.description),
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 32),
              Consumer<TeamProvider>(
                builder: (context, teamProvider, _) {
                  return CustomButton(
                    text: 'Create Team',
                    onPressed: _createTeam,
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