import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/l10n/l10n.dart';
import '../data/employee_options.dart';
import '../data/models/employee_session.dart';
import 'employees_controller.dart';
import '../../../core/widgets/animated_entrance.dart';

/// Edits the friendly name and department of a workstation.
Future<void> showWorkstationDialog(
  EmployeesController controller,
  EmployeeSession employee,
) => showAppDialog<void>(
  _WorkstationDialog(controller: controller, employee: employee),
);

class _WorkstationDialog extends StatefulWidget {
  const _WorkstationDialog({required this.controller, required this.employee});

  final EmployeesController controller;
  final EmployeeSession employee;

  @override
  State<_WorkstationDialog> createState() => _WorkstationDialogState();
}

class _WorkstationDialogState extends State<_WorkstationDialog> {
  late final _name = TextEditingController(text: widget.employee.customName);
  late EmployeeRole _role = EmployeeRole.parse(widget.employee.role);
  bool _failed = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final ok = await widget.controller.saveWorkstation(
      widget.employee,
      customName: _name.text,
      role: _role,
    );
    if (!mounted) return;
    if (ok) {
      Get.back<void>();
    } else {
      setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(tr.empEditWorkstation),
    content: SizedBox(
      width: 380,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _name,
            maxLength: 120,
            autofocus: true,
            decoration: InputDecoration(
              labelText: tr.empWorkstationName,
              hintText: widget.employee.username,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<EmployeeRole>(
            initialValue: _role,
            decoration: InputDecoration(labelText: tr.empRole),
            items: [
              for (final r in EmployeeRole.values)
                DropdownMenuItem(value: r, child: Text(r.label)),
            ],
            onChanged: (r) => setState(() => _role = r ?? _role),
          ),
          if (_failed)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                tr.empSaveFailed,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
        ],
      ),
    ),
    actions: [
      TextButton(onPressed: Get.back, child: Text(tr.actionCancel)),
      Obx(
        () => FilledButton(
          onPressed: widget.controller.saving.value ? null : _save,
          child: Text(tr.actionSave),
        ),
      ),
    ],
  );
}
