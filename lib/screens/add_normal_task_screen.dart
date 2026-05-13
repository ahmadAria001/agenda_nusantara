import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/task_controller.dart';
import '../models/task.dart';

class AddNormalTaskScreen extends StatefulWidget {
  const AddNormalTaskScreen({super.key});

  @override
  State<AddNormalTaskScreen> createState() => _AddNormalTaskScreenState();
}

class _AddNormalTaskScreenState extends State<AddNormalTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(ThemeData theme) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.colorScheme.tertiary, // Green color for Normal
              onPrimary: theme.colorScheme.onTertiary,
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

  Future<void> _saveTask(ThemeData theme) async {
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

    final task = Task(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      dueDate: _selectedDate!.toIso8601String().split('T').first,
      category: 'biasa',
    );

    final taskController = context.read<TaskController>();
    final success = await taskController.addTask(task);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Tugas biasa berhasil ditambahkan'),
          backgroundColor: theme.colorScheme.tertiary,
        ),
      );
      Navigator.of(context).pop(); // Back to Home
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Tugas Biasa'),
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
                    borderSide: BorderSide(color: theme.colorScheme.tertiary, width: 1.5),
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
                    borderSide: BorderSide(color: theme.colorScheme.tertiary, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Date Picker ──────────────────────────────────────────
              GestureDetector(
                onTap: () => _selectDate(theme),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedDate == null
                          ? theme.colorScheme.outline
                          : theme.colorScheme.tertiary,
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
                            color: theme.colorScheme.tertiary, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // ── Buttons ──────────────────────────────────────────────
              Consumer<TaskController>(
                builder: (context, controller, child) {
                  return ElevatedButton(
                    onPressed: controller.isLoading ? null : () => _saveTask(theme),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.tertiary,
                      foregroundColor: theme.colorScheme.onTertiary,
                    ),
                    child: controller.isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.onTertiary,
                            ),
                          )
                        : const Text(
                            'Simpan',
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
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
