import 'package:flutter/material.dart';

class SourceEditorResult {
  const SourceEditorResult({
    required this.name,
    required this.url,
    required this.currentChapter,
  });

  final String name;
  final String url;
  final String currentChapter;
}

class SourceEditorDialog extends StatefulWidget {
  const SourceEditorDialog({
    super.key,
    this.initialName = '',
    this.initialUrl = '',
    this.initialChapter = '',
    required this.title,
    required this.confirmLabel,
    this.editName = true,
    this.editUrl = true,
    this.editChapter = true,
  });

  final String initialName;
  final String initialUrl;
  final String initialChapter;
  final String title;
  final String confirmLabel;
  final bool editName;
  final bool editUrl;
  final bool editChapter;

  @override
  State<SourceEditorDialog> createState() => _SourceEditorDialogState();
}

class _SourceEditorDialogState extends State<SourceEditorDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _urlController;
  late final TextEditingController _chapterController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _urlController = TextEditingController(text: widget.initialUrl);
    _chapterController = TextEditingController(text: widget.initialChapter);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _chapterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (widget.editName)
                TextFormField(
                  controller: _nameController,
                  decoration:
                      const InputDecoration(labelText: 'Publication name'),
                  textInputAction: TextInputAction.next,
                  validator: _requiredValidator,
                ),
              if (widget.editUrl)
                TextFormField(
                  controller: _urlController,
                  decoration: const InputDecoration(labelText: 'URL'),
                  keyboardType: TextInputType.url,
                  textInputAction: widget.editChapter
                      ? TextInputAction.next
                      : TextInputAction.done,
                  validator: _urlValidator,
                ),
              if (widget.editChapter)
                TextFormField(
                  controller: _chapterController,
                  decoration:
                      const InputDecoration(labelText: 'Current chapter'),
                  textInputAction: TextInputAction.done,
                  validator: _requiredValidator,
                ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  String? _urlValidator(String? value) {
    final String? requiredError = _requiredValidator(value);
    if (requiredError != null) {
      return requiredError;
    }

    final Uri? uri = Uri.tryParse(value!.trim());
    if (uri == null || !(uri.hasScheme && uri.hasAuthority)) {
      return 'Enter a valid URL';
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(
      SourceEditorResult(
        name: _nameController.text.trim(),
        url: _urlController.text.trim(),
        currentChapter: _chapterController.text.trim(),
      ),
    );
  }
}
