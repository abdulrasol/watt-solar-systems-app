import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watt/src/core/theme/app_colors.dart';
import 'package:watt/src/utils/app_theme.dart';

/// A reusable text field widget used for all text inputs in the app.
///
/// Supports single-line, multi-line, password, read-only, validation,
/// prefix/suffix icons, and input formatters.
class AppTextField extends ConsumerStatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final IconData? prefixIcon;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final bool expands;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final TextDirection? textDirection;
  final TextAlign textAlign;

  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffix,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.expands = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.textDirection,
    this.textAlign = TextAlign.start,
  }) : assert(!expands || maxLines == null, 'expands requires maxLines to be null');

  @override
  ConsumerState<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends ConsumerState<AppTextField> {
  late final TextEditingController _controller;
  bool _obscure = false;

  TextEditingController get _effectiveController => widget.controller ?? _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _obscure = widget.obscureText;
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(appColorsProvider);
    final isMultiline = widget.expands || (widget.maxLines ?? 1) > 1;

    return TextFormField(
      controller: _effectiveController,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      obscureText: _obscure,
      keyboardType: isMultiline ? TextInputType.multiline : widget.keyboardType,
      textInputAction: isMultiline ? TextInputAction.newline : widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      textDirection: widget.textDirection,
      textAlign: widget.textAlign,
      minLines: widget.expands ? null : widget.minLines,
      maxLines: widget.expands ? null : widget.maxLines,
      maxLength: widget.maxLength,
      expands: widget.expands,
      inputFormatters: widget.inputFormatters,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      onTap: widget.onTap,
      style: TextStyle(
        fontFamily: AppTheme.fontFamily,
        fontSize: 14,
        color: widget.enabled ? colors.textPrimary : colors.textTertiary,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        helperText: widget.helperText,
        errorText: widget.errorText,
        hintStyle: TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 14,
          color: colors.textTertiary,
        ),
        labelStyle: TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 14,
          color: colors.textSecondary,
        ),
        helperStyle: TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 12,
          color: colors.textTertiary,
        ),
        errorStyle: TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 12,
          color: colors.error,
        ),
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, color: colors.textTertiary, size: 20)
            : null,
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: colors.textTertiary,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : widget.suffix,
        filled: true,
        fillColor: widget.enabled ? colors.surface : colors.background,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: isMultiline ? 16 : 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.error, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.border),
        ),
      ),
    );
  }
}
