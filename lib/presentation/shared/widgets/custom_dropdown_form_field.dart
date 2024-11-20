import 'package:flutter/material.dart';

class CustomDropdownFormField extends StatelessWidget {
  final bool isTopField;
  final bool isBottomField;
  final String? label;
  final List<DropdownMenuItem<String>> items;
  final String? value;
  final Function(String?)? onChanged;
  final String? Function(String?)? validator;
  final String? errorMessage;
  final int? maxTextLength;
  final bool required;
  final bool enabled;

  const CustomDropdownFormField({
    super.key,
    this.label,
    this.isTopField = false,
    this.isBottomField = false,
    required this.items,
    this.value,
    this.onChanged,
    this.validator,
    this.errorMessage,
    this.maxTextLength,
    this.required = false,
    this.enabled = true,
  });


  @override
  Widget build(BuildContext context) {

    const borderRadius = Radius.circular(10);
    final border = OutlineInputBorder(
      borderSide: BorderSide(color: enabled ? Colors.transparent : Colors.grey.shade300 ),
      borderRadius: const BorderRadius.only(topLeft: borderRadius, bottomLeft: borderRadius, bottomRight: borderRadius ),
    );

    return Container(
      decoration: BoxDecoration(
        color: enabled ? Colors.white : Colors.grey[200],
        borderRadius: const BorderRadius.only(topLeft: borderRadius, bottomLeft: borderRadius, bottomRight: borderRadius),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0,5)
            )
          ]
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: enabled ? onChanged : null,
        validator: enabled ? validator : null,
        decoration: InputDecoration(
          floatingLabelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 17),
          enabledBorder: border,
          focusedBorder: border,
          errorBorder: border.copyWith(borderSide: const BorderSide(color: Colors.transparent)),
          focusedErrorBorder: border.copyWith(borderSide: const BorderSide(color: Colors.transparent)),
          isDense: true,
          errorText: errorMessage,
          label: label != null ? Row(
            children: [
              Text(label!),
              if(required == true)
                const Text("*", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13.5)),
            ],
          ) : null,
        ),
        items: items,
        selectedItemBuilder: (BuildContext context) {
          return items.map<Widget>((DropdownMenuItem<String> item) {
            return Text(
              item.child is Text ? _truncateText((item.child as Text).data!, maxTextLength) : '',
              overflow: TextOverflow.ellipsis,
              style: (item.child as Text).style,
            );
          }).toList();
        },
        disabledHint: enabled ? null : Text(value ?? ''), // Mostrar el valor seleccionado si está deshabilitado
      ),
    );
  }

  String _truncateText(String text, int? maxLength) {
    if(maxLength != null){
      return text.length > maxLength ? '${text.substring(0, maxLength)}...' : text;
    }
    else{
      return text;
    }
  }
}

