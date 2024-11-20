import 'package:flutter/material.dart';


class CustomProductField extends StatelessWidget {

  final bool isTopField;
  final bool isBottomField;
  final String? label;
  final String? hint;
  final String? errorMessage;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int maxLines;
  final String initialValue;
  final Function(String)? onChanged;
  final Function(String)? onFieldSubmitted;
  final String? Function(String?)? validator;
  final bool enabled;

  const CustomProductField({
    super.key, 
    this.isTopField = false, 
    this.isBottomField = false, 
    this.label, 
    this.hint, 
    this.errorMessage, 
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.initialValue = '',
    this.onChanged, 
    this.onFieldSubmitted, 
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {

    final colors = Theme.of(context).colorScheme;

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
      child: TextFormField(
        onChanged: onChanged,
        onFieldSubmitted: onFieldSubmitted,
        validator: validator,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle( fontSize: 15, color: Colors.black87 ),
        maxLines: maxLines,
        initialValue: initialValue,
        decoration: InputDecoration(
          floatingLabelBehavior: maxLines > 1 ? FloatingLabelBehavior.always : FloatingLabelBehavior.auto,
          floatingLabelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
          enabledBorder: border,
          focusedBorder: border,
          errorBorder: border.copyWith( borderSide: const BorderSide( color: Colors.transparent )),
          focusedErrorBorder: border.copyWith( borderSide: const BorderSide( color: Colors.transparent )),
          isDense: true,
          label: label != null ? Text(label!) : null,
          hintText: hint,
          errorText: errorMessage,
          focusColor: colors.primary,
          // icon: Icon( Icons.supervised_user_circle_outlined, color: colors.primary, )
        ),
      ),
    );
  }
}