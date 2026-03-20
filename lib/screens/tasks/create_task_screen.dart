import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/team.dart';
import '../../providers/task_provider.dart';
import '../../providers/team_provider.dart';
import '../../services/team_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({Key? key}) : super(key: key);

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  Team? _selectedTeam;
  String _selectedPriority = 'Medium';
  String _selectedStatus = 'To Do';
  DateTime? _dueDate;
  List<TeamMember> _teamMembers = [];
  List<TeamMember> _selectedAssignees = [];
  bool _loadingMembers = false;

  final List<String> _priorities = ['Low', 'Medium', 'High'];
  final List<String> _statuses = ['To Do', 'In Progress', 'Completed'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TeamProvider>(context, listen: false).loadTeams();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadTeamMembers(String teamId) async {
    setState(() {
      _loadingMembers = true;
      _selectedAssignees = [];
    });
    final members = await TeamService().getTeamMembers(teamId);
    setState(() {
      _teamMembers = members;
      _loadingMembers = false;
    });
  }

  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  void _showAssigneePicker() {
    if (_teamMembers.isEmpty) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Assignees',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                Expanded(
                  child: ListView(
                    children: _teamMembers.map((member) {
                      final isSelected = _selectedAssignees
                          .any((s) => s.userId == member.userId);
                      return CheckboxListTile(
                        value: isSelected,
                        onChanged: (checked) {
                          setModalState(() {
                            if (checked == true) {
                              _selectedAssignees.add(member);
                            } else {
                              _selectedAssignees.removeWhere(
                                  (s) => s.userId == member.userId);
                            }
                          });
                          setState(() {});
                        },
                        title: Text(member.name),
                        subtitle: Text(member.email),
                        secondary: CircleAvatar(
                          backgroundColor: const Color(0xFF8B5CF6),
                          child: Text(
                            member.name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        activeColor: const Color(0xFF8B5CF6),
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Done',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _createTask() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedTeam == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a team'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    final success = await taskProvider.createTask(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      teamId: _selectedTeam!.teamId,
      assignedTo: _selectedAssignees.map((m) => m.userId).toList(),
      priority: _selectedPriority,
      status: _selectedStatus,
      dueDate: _dueDate,
    );

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(taskProvider.errorMessage ?? 'Failed to create task'),
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
        title: const Text('Create Task'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.task_alt, size: 64, color: Color(0xFF8B5CF6)),
              const SizedBox(height: 16),
              const Text(
                'Create New Task',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),

              // Title
              CustomTextField(
                label: 'Task Title',
                hintText: 'Enter task title',
                controller: _titleController,
                prefixIcon: const Icon(Icons.title),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a task title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Description
              CustomTextField(
                label: 'Description (Optional)',
                hintText: 'Enter task description',
                controller: _descriptionController,
                prefixIcon: const Icon(Icons.description),
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 20),

              // Team Selection
              const Text(
                'Team',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Consumer<TeamProvider>(
                builder: (context, teamProvider, _) {
                  if (teamProvider.isLoading) {
                    return const CircularProgressIndicator();
                  }
                  if (teamProvider.teams.isEmpty) {
                    return const Text('No teams available');
                  }
                  return DropdownButtonFormField<Team>(
                    value: _selectedTeam,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.groups),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    hint: const Text('Select team'),
                    items: teamProvider.teams.map((team) {
                      return DropdownMenuItem(
                        value: team,
                        child: Text(team.name),
                      );
                    }).toList(),
                    onChanged: (team) {
                      setState(() => _selectedTeam = team);
                      if (team != null) {
                        _loadTeamMembers(team.id);
                      }
                    },
                    validator: (value) {
                      if (value == null) return 'Please select a team';
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 20),

              // Assign To (multi-select)
              const Text(
                'Assign To (Optional)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _loadingMembers || _selectedTeam == null
                    ? null
                    : _showAssigneePicker,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.people, color: Colors.grey),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _loadingMembers
                            ? const Text('Loading members...',
                                style: TextStyle(color: Colors.grey))
                            : _selectedTeam == null
                                ? const Text('Select a team first',
                                    style: TextStyle(color: Colors.grey))
                                : _selectedAssignees.isEmpty
                                    ? const Text('Tap to select members',
                                        style: TextStyle(color: Colors.grey))
                                    : Wrap(
                                        spacing: 6,
                                        runSpacing: 4,
                                        children: _selectedAssignees
                                            .map((m) => Chip(
                                                  label: Text(m.name,
                                                      style: const TextStyle(
                                                          fontSize: 12)),
                                                  backgroundColor: const Color(
                                                          0xFF8B5CF6)
                                                      .withOpacity(0.1),
                                                  deleteIcon: const Icon(
                                                      Icons.close,
                                                      size: 14),
                                                  onDeleted: () {
                                                    setState(() {
                                                      _selectedAssignees
                                                          .removeWhere((s) =>
                                                              s.userId ==
                                                              m.userId);
                                                    });
                                                  },
                                                ))
                                            .toList(),
                                      ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Priority
              const Text(
                'Priority',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedPriority,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.priority_high),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: _priorities.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(priority),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedPriority = value);
                },
              ),
              const SizedBox(height: 20),

              // Status
              const Text(
                'Status',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.checklist),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: _statuses.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedStatus = value);
                },
              ),
              const SizedBox(height: 20),

              // Due Date
              const Text(
                'Due Date (Optional)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectDueDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 12),
                      Text(
                        _dueDate == null
                            ? 'Select due date'
                            : DateFormat('MMM dd, yyyy').format(_dueDate!),
                        style: TextStyle(
                          fontSize: 16,
                          color:
                              _dueDate == null ? Colors.grey[600] : Colors.black,
                        ),
                      ),
                      const Spacer(),
                      if (_dueDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => _dueDate = null),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Create Button
              Consumer<TaskProvider>(
                builder: (context, taskProvider, _) {
                  return CustomButton(
                    text: 'Create Task',
                    onPressed: _createTask,
                    isLoading: taskProvider.isLoading,
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
