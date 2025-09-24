import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BaseDropdownButton extends StatelessWidget {
  final String label;
  final dynamic items;
  final String? value;
  final void Function(String?) onChanged;
  final bool isDisabled;

  const BaseDropdownButton({
    super.key,
    required this.label,
    required this.items,
    required this.value,
    required this.onChanged,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, String> normalizedItems = items is Map<String, String>
        ? items
        : {for (var item in (items as List<String>)) item: item};
    return DropdownButtonFormField<String>(
      menuMaxHeight: 300.w,
      value: value,
      isExpanded: true,
      padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
      decoration: InputDecoration(labelText: label),
      items: normalizedItems.entries
          .map((entry) => DropdownMenuItem(
                value: entry.key,
                child: Text(entry.value),
              ))
          .toList(),
      onChanged: isDisabled ? null : onChanged,
    );
  }
}
