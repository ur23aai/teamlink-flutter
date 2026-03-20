import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/task.dart';
import '../../models/team.dart';
import '../../providers/task_provider.dart';
import '../../services/team_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class EditTaskScreen extends StatefulWidget {
  final Task task;

  const EditTaskScreen({Key? key, required this.task}) : super(key: key);

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  late String _selectedPriority;
  late DateTime? _dueDate;
  List<TeamMember> _teamMembers = [];
  List<TeamMember> _selectedAssignees = [];
  bool _loadingMembers = true;

  final List<String> _priorities = ['Low', 'Medium', 'High'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController =
        TextEditingController(text: widget.task.description ?? '');
    _selectedPriority = widget.task.priority;
    _dueDate = widget.task.dueDate;
    _loadTeamMembers();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadTeamMembers() async {
    setState(() => _loadingMembers = true);
    final members = await TeamService().getTeamMembers(widget.task.teamId);
    setState(() {
      _teamMembers = members;
      // Pre-select current assignees
      _selectedAssignees = members
          .where((m) =>
              widget.task.assignedTo.any((a) => a.userId == m.userId))
          .toList();
      _loadingMembers = false;
    });
  }

  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  void _showAssigneePicker() {
    if (_teamMembers.isEmpty) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Column(
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
        ),
      ),
    );
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    final success = await taskProvider.updateTask(
      taskId: widget.task.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      priority: _selectedPriority,
      assignedTo: _selectedAssignees.map((m) => m.userId).toList(),
      dueDate: _dueDate,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(taskProvider.errorMessage ?? 'Failed to update task'),
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
        title: const Text('Edit Task'),
      ),
      body: _loadingMembers
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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

                    // Team (read-only)
                    const Text(
                      'Team',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.groups, color: Colors.grey),
                          const SizedBox(width: 12),
                          Text(
                            widget.task.teamName,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Assign To
                    const Text(
                      'Assign To (Optional)',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _showAssigneePicker,
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
                              child: _selectedAssignees.isEmpty
                                  ? const Text('Tap to select members',
                                      style:
                                          TextStyle(color: Colors.grey))
                                  : Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      children: _selectedAssignees
                                          .map((m) => Chip(
                                                label: Text(m.name,
                                                    style: const TextStyle(
                                                        fontSize: 12)),
                                                backgroundColor:
                                                    const Color(0xFF8B5CF6)
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
                            const Icon(Icons.arrow_drop_down,
                                color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Priority
                    const Text(
                      'Priority',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500),
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
                      items: _priorities.map((p) {
                        return DropdownMenuItem(
                            value: p, child: Text(p));
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedPriority = value);
                        }
                      },
                    ),
                    const SizedBox(height: 20),

                    // Due Date
                    const Text(
                      'Due Date (Optional)',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500),
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
                                  : DateFormat('MMM dd, yyyy')
                                      .format(_dueDate!),
                              style: TextStyle(
                                fontSize: 16,
                                color: _dueDate == null
                                    ? Colors.grey[600]
                                    : Colors.black,
                              ),
                            ),
                            const Spacer(),
                            if (_dueDate != null)
                              IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () =>
                                    setState(() => _dueDate = null),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    Consumer<TaskProvider>(
                      builder: (context, taskProvider, _) {
                        return CustomButton(
                          text: 'Save Changes',
                          onPressed: _saveTask,
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
