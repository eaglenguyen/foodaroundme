import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../authentication/viewmodel/authViewModel.dart';
import '../../../model/place.dart';
import '../action_row.dart';

class SaveButton extends StatefulWidget {
  final Place place;

  const SaveButton({super.key, required this.place});

  @override
  State<SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<SaveButton> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final saved = authVm.isSaved(widget.place.id);

    return CustomActionChip(
      icon: saved ? Icons.bookmark : Icons.bookmark_border, // ✅ icon changes
      label: "Save",
      onTap: () => authVm.savePlace(widget.place),
    );
  }
}