import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/task.dart';
import '../../providers/task_provider.dart';
import '../../services/storage_service.dart';

class TaskDetailsScreen extends StatefulWidget {
  final Task task;
  final bool isAdmin;

  const TaskDetailsScreen({
    Key? key,
    required this.task,
    this.isAdmin = false,
  }) : super(key: key);

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  late Task _task;
  late String _currentStatus;
  bool _isCreator = false;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    _currentStatus = _task.status;
    final currentUserId = StorageService().getUserId();
    _isCreator = currentUserId != null &&
        currentUserId == _task.createdBy.userId;
  }

  bool get _canModify => _isCreator || widget.isAdmin;

  Color _getPriorityColor() {
    switch (_task.priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    final success = await taskProvider.updateTaskStatus(
      taskId: _task.id,
      status: newStatus,
    );

    if (success) {
      setState(() => _currentStatus = newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to $newStatus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(taskProvider.errorMessage ?? 'Failed to update status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteTask() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final success = await taskProvider.deleteTask(_task.id);

      if (success) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }

  Future<void> _removeAssignee(AssignedUser user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Assignee'),
        content: Text('Remove ${user.name} from this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final updatedAssignees = _task.assignedTo
        .where((u) => u.userId != user.userId)
        .map((u) => u.userId)
        .toList();

    final success = await taskProvider.updateTask(
      taskId: _task.id,
      assignedTo: updatedAssignees,
    );

    if (mounted) {
      if (success) {
        final refreshed = taskProvider.tasks.firstWhere(
          (t) => t.id == _task.id,
          orElse: () => _task,
        );
        setState(() => _task = refreshed);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${user.name} removed from task'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(taskProvider.errorMessage ?? 'Failed to remove assignee'),
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
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
            ),
          ),
        ),
        title: const Text(
          'Task Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_canModify) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                final updated = await Navigator.pushNamed(
                  context,
                  '/edit-task',
                  arguments: _task,
                );
                if (updated == true && mounted) {
                  final taskProvider =
                      Provider.of<TaskProvider>(context, listen: false);
                  final refreshed = taskProvider.tasks.firstWhere(
                    (t) => t.id == _task.id,
                    orElse: () => _task,
                  );
                  setState(() {
                    _task = refreshed;
                    _currentStatus = refreshed.status;
                  });
                }
              },
              tooltip: 'Edit Task',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteTask,
              tooltip: 'Delete Task',
            ),
          ],
        ],
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                _task.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 20),

              // Status Buttons
              const Text(
                'Status',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _StatusChip(
                    label: 'To Do',
                    isSelected: _currentStatus == 'To Do',
                    color: Colors.grey,
                    onTap: () => _updateStatus('To Do'),
                  ),
                  const SizedBox(width: 8),
                  _StatusChip(
                    label: 'In Progress',
                    isSelected: _currentStatus == 'In Progress',
                    color: Colors.blue,
                    onTap: () => _updateStatus('In Progress'),
                  ),
                  const SizedBox(width: 8),
                  _StatusChip(
                    label: 'Completed',
                    isSelected: _currentStatus == 'Completed',
                    color: Colors.green,
                    onTap: () => _updateStatus('Completed'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Priority Badge
              Row(
                children: [
                  const Text(
                    'Priority: ',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getPriorityColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _task.priority,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _getPriorityColor(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Description
              if (_task.description != null &&
                  _task.description!.isNotEmpty) ...[
                const Text(
                  'Description',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _task.description!,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Team
              _InfoRow(
                icon: Icons.groups,
                label: 'Team',
                value: _task.teamName,
              ),
              const SizedBox(height: 16),

              // Assigned To (list)
              if (_task.assignedTo.isNotEmpty || _canModify) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.people, color: Color(0xFF8B5CF6)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Assigned To',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[600]),
                                ),
                                if (_canModify) ...[
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () async {
                                      final updated =
                                          await Navigator.pushNamed(
                                        context,
                                        '/edit-task',
                                        arguments: _task,
                                      );
                                      if (updated == true && mounted) {
                                        final taskProvider =
                                            Provider.of<TaskProvider>(context,
                                                listen: false);
                                        final refreshed =
                                            taskProvider.tasks.firstWhere(
                                          (t) => t.id == _task.id,
                                          orElse: () => _task,
                                        );
                                        setState(() {
                                          _task = refreshed;
                                          _currentStatus = refreshed.status;
                                        });
                                      }
                                    },
                                    child: const Text(
                                      'Edit assignees',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF8B5CF6),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 6),
                            if (_task.assignedTo.isEmpty)
                              Text(
                                'No one assigned yet',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                  fontStyle: FontStyle.italic,
                                ),
                              )
                            else
                              ..._task.assignedTo.map(
                                (user) => Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${user.name} (${user.email})',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    if (_canModify)
                                      IconButton(
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        tooltip: 'Remove assignee',
                                        onPressed: () => _removeAssignee(user),
                                      ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Created By
              _InfoRow(
                icon: Icons.person_outline,
                label: 'Created By',
                value: _task.createdBy.name,
                subtitle: _task.createdBy.email,
              ),
              const SizedBox(height: 16),

              // Due Date
              if (_task.dueDate != null) ...[
                _InfoRow(
                  icon: Icons.calendar_today,
                  label: 'Due Date',
                  value: DateFormat('MMM dd, yyyy').format(_task.dueDate!),
                ),
                const SizedBox(height: 16),
              ],

              // Created At
              _InfoRow(
                icon: Icons.access_time,
                label: 'Created',
                value: DateFormat('MMM dd, yyyy - hh:mm a')
                    .format(_task.createdAt),
              ),

              // Non-modifier notice
              if (!_canModify) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: Colors.orange, size: 18),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Only the task creator or a team admin can delete this task.',
                          style:
                              TextStyle(fontSize: 12, color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? color : Colors.grey[300]!,
              width: 2,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF8B5CF6)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
