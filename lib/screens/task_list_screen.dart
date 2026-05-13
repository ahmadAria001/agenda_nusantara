import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/task_controller.dart';
import '../models/task.dart';
import 'edit_task_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskController>().fetchTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Tugas'),
      ),
      body: Consumer<TaskController>(
        builder: (context, controller, child) {
          if (controller.isLoading && controller.tasks.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage != null && controller.tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: theme.colorScheme.error, size: 48),
                  const SizedBox(height: 16),
                  Text(controller.errorMessage!, style: TextStyle(color: theme.colorScheme.onSurface)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.fetchTasks(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (controller.tasks.isEmpty) {
            return Center(
              child: Text(
                'Belum ada tugas.\nTambahkan tugas baru!',
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.tasks.length,
            itemBuilder: (context, index) {
              final task = controller.tasks[index];
              return _TaskListItem(task: task);
            },
          );
        },
      ),
    );
  }
}

class _TaskListItem extends StatelessWidget {
  final Task task;

  const _TaskListItem({required this.task});

  void _showTaskDetails(BuildContext context, ThemeData theme, Color categoryColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 32,
            bottom: MediaQuery.of(context).padding.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          task.category?.toUpperCase() ?? '',
                          style: TextStyle(
                            color: categoryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (task.isCompleted) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'SELESAI',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit_rounded, color: theme.colorScheme.onSurfaceVariant),
                        onPressed: () {
                          Navigator.pop(context); // Close modal
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditTaskScreen(task: task),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Hapus Tugas?'),
                              content: const Text('Apakah Anda yakin ingin menghapus tugas ini?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
                                  child: const Text('Hapus'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true && context.mounted) {
                            Navigator.pop(context); // close modal
                            final success = await context.read<TaskController>().softDeleteTask(task);
                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Tugas berhasil dihapus'),
                                  backgroundColor: theme.colorScheme.error,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                task.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              if (task.dueDate != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 16, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Text(
                      task.dueDate!,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              Text(
                'Deskripsi',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                (task.description == null || task.description!.trim().isEmpty)
                    ? 'Tidak ada deskripsi.'
                    : task.description!,
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.surface,
                    foregroundColor: theme.colorScheme.onSurface,
                    elevation: 0,
                    side: BorderSide(color: theme.colorScheme.outline),
                  ),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isImportant = task.category == 'penting';

    // Dynamic colors based on category, pulled from AppTheme
    final categoryColor =
        isImportant ? theme.colorScheme.error : theme.colorScheme.tertiary;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showTaskDetails(context, theme, categoryColor),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Checkbox / Completion status
              InkWell(
                onTap: () {
                  context.read<TaskController>().toggleTaskStatus(task);
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: task.isCompleted ? categoryColor : theme.colorScheme.outline,
                        width: 2,
                      ),
                      color: task.isCompleted ? categoryColor : Colors.transparent,
                    ),
                    child: task.isCompleted
                        ? Icon(Icons.check, size: 16, color: theme.colorScheme.onPrimary)
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Title and Due Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: task.isCompleted ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.onSurface,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    if (task.dueDate != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 14, color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            task.dueDate!,
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Dynamic Category Arrow
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isImportant
                      ? Icons.keyboard_double_arrow_up_rounded
                      : Icons.keyboard_arrow_right_rounded,
                  color: categoryColor,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
