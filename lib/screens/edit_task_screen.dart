import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/task_controller.dart';
import '../models/task.dart';

class EditTaskScreen extends StatefulWidget {
  final Task task;

  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descController = TextEditingController(text: widget.task.description);
    if (widget.task.dueDate != null) {
      try {
        _selectedDate = DateTime.parse(widget.task.dueDate!);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(ThemeData theme, Color primaryColor) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2000), // Allow past dates if they want to keep it
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: primaryColor,
              onPrimary: theme.colorScheme.surface,
              surface: theme.colorScheme.surface,
              onSurface: theme.colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _updateTask(ThemeData theme, Color primaryColor) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Pilih tanggal tenggat waktu'),
          backgroundColor: theme.colorScheme.error,
        ),
      );
      return;
    }

    final updatedTask = widget.task.copyWith(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      dueDate: _selectedDate!.toIso8601String().split('T').first,
    );

    final taskController = context.read<TaskController>();
    final success = await taskController.updateTask(updatedTask);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Tugas berhasil diperbarui'),
          backgroundColor: primaryColor,
        ),
      );
      Navigator.of(context).pop(); // Go back
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(taskController.errorMessage ?? 'Gagal menyimpan'),
          backgroundColor: theme.colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isImportant = widget.task.category == 'penting';
    final primaryColor = isImportant ? theme.colorScheme.error : theme.colorScheme.tertiary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Tugas'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Title Field ──────────────────────────────────────────
              TextFormField(
                controller: _titleController,
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Judul Tugas',
                  prefixIcon: const Icon(Icons.title_rounded),
                  focusedBorder: theme.inputDecorationTheme.focusedBorder?.copyWith(
                    borderSide: BorderSide(color: primaryColor, width: 1.5),
                  ),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Judul tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 20),

              // ── Description Field ────────────────────────────────────
              TextFormField(
                controller: _descController,
                style: TextStyle(color: theme.colorScheme.onSurface),
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Deskripsi',
                  prefixIcon: const Icon(Icons.description_outlined),
                  focusedBorder: theme.inputDecorationTheme.focusedBorder?.copyWith(
                    borderSide: BorderSide(color: primaryColor, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Date Picker ──────────────────────────────────────────
              GestureDetector(
                onTap: () => _selectDate(theme, primaryColor),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedDate == null
                          ? theme.colorScheme.outline
                          : primaryColor,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          color: theme.colorScheme.onSurfaceVariant, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedDate == null
                              ? 'Pilih Tenggat Waktu'
                              : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                          style: TextStyle(
                            color: _selectedDate == null
                                ? theme.colorScheme.onSurfaceVariant
                                : theme.colorScheme.onSurface,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (_selectedDate != null)
                        Icon(Icons.check_circle,
                            color: primaryColor, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // ── Buttons ──────────────────────────────────────────────
              Consumer<TaskController>(
                builder: (context, controller, child) {
                  return ElevatedButton(
                    onPressed: controller.isLoading ? null : () => _updateTask(theme, primaryColor),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: theme.colorScheme.surface,
                    ),
                    child: controller.isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.surface,
                            ),
                          )
                        : const Text(
                            'Perbarui',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  );
                },
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.onSurfaceVariant,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Batal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
