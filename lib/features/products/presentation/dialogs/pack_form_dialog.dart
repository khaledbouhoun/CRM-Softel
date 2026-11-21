import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/l10n/l10n.dart';
import '../../../../app/services/lookup_service.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/form_widgets.dart';
import '../../data/models/pack.dart';

Future<Pack?> showPackFormDialog({BuildContext? context}) =>
    Get.dialog<Pack>(const _PackFormDialog());

class _PackFormDialog extends StatefulWidget {
  const _PackFormDialog();

  @override
  State<_PackFormDialog> createState() => _PackFormDialogState();
}

class _PackFormDialogState extends State<_PackFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isSubmitting = false;
  String? _errorMessage;
  final Map<String, String> _serverErrors = {};

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onNameChanged(String val) {
    _serverErrors.remove('name');
    // If code is untouched or auto-generated, suggest code from name
    if (_codeController.text.isEmpty ||
        _codeController.text == _slugify(_nameController.text.substring(0, _nameController.text.length > 1 ? _nameController.text.length - 1 : 0))) {
      _codeController.text = _slugify(val);
    }
  }

  String _slugify(String text) => text
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9_]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');

  Future<void> _submit() async {
    if (_isSubmitting) return;
    _serverErrors.clear();
    setState(() => _errorMessage = null);

    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);
    try {
      final lookups = Get.find<LookupService>();
      final payload = PackPayload(
        name: _nameController.text,
        code: _codeController.text,
        description: _descriptionController.text,
      );
      final created = await lookups.addPack(payload);
      AppFeedback.success('${tr.productPack}: ${created.name}');
      Get.back(result: created);
    } on ValidationException catch (e) {
      setState(() {
        e.fieldErrors.forEach((k, m) {
          if (m.isNotEmpty) _serverErrors[k] = m.first;
        });
        _errorMessage = e.describeFor(const {'name', 'code', 'description'});
      });
      _formKey.currentState?.validate();
    } catch (e) {
      setState(() {
        _errorMessage = ApiException.from(e).message;
      });
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormDialog(
      title: tr.productNewPack,
      icon: Icons.layers_outlined,
      width: 480,
      busy: _isSubmitting,
      errorMessage: _errorMessage,
      onCancel: () => Get.back(),
      onSubmit: _submit,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: '${tr.productPackName} *',
                hintText: 'ex: GestCom Editions',
              ),
              validator: (v) =>
                  _serverErrors['name'] ??
                  Validators.combine([
                    () => Validators.required(v, field: tr.productPackName),
                    () => Validators.maxLength(v, 150),
                  ]),
              onChanged: _onNameChanged,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: '${tr.productPackCode} *',
                hintText: 'ex: gestcom_editions',
                helperText: 'Identifiant unique en minuscules (a-z, 0-9, _)',
              ),
              validator: (v) =>
                  _serverErrors['code'] ??
                  Validators.combine([
                    () => Validators.required(v, field: tr.productPackCode),
                    () => Validators.maxLength(v, 50),
                    () {
                      final val = (v ?? '').trim();
                      if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(val)) {
                        return 'Le code doit commencer par une lettre minuscule et contenir uniquement a-z, 0-9, _';
                      }
                      return null;
                    },
                  ]),
              onChanged: (_) => _serverErrors.remove('code'),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _descriptionController,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: tr.fieldDescription,
                alignLabelWithHint: true,
              ),
              validator: (v) =>
                  _serverErrors['description'] ??
                  Validators.maxLength(v, 2000),
            ),
          ],
        ),
      ),
    );
  }
}
