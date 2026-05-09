import 'package:feyam/core/widgets/adaptive/adaptive_platform.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AdaptiveAppTextField extends StatelessWidget {
  const AdaptiveAppTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.label,
    this.placeholder,
    this.helperText,
    this.errorText,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.prefixIcon,
    this.suffixIcon,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.inputFormatters,
    this.autofillHints,
  }) : assert(
         controller == null || initialValue == null,
         'controller and initialValue cannot both be provided.',
       );

  final TextEditingController? controller;
  final String? initialValue;
  final String? label;
  final String? placeholder;
  final String? helperText;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Color? backgroundColor;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    if (AdaptivePlatform.isCupertino(context)) {
      return _CupertinoAdaptiveTextField(
        controller: controller,
        initialValue: initialValue,
        label: label,
        placeholder: placeholder,
        helperText: helperText,
        errorText: errorText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        obscureText: obscureText,
        enabled: enabled,
        readOnly: readOnly,
        maxLines: maxLines,
        minLines: minLines,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        backgroundColor: backgroundColor,
        borderColor: borderColor,
        borderRadius: borderRadius,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        validator: validator,
        inputFormatters: inputFormatters,
        autofillHints: autofillHints,
      );
    }

    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: obscureText ? 1 : maxLines,
      minLines: minLines,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      inputFormatters: inputFormatters,
      autofillHints: autofillHints,
      decoration: InputDecoration(
        labelText: label,
        hintText: placeholder,
        helperText: helperText,
        errorText: errorText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: backgroundColor != null,
        fillColor: backgroundColor,
        enabledBorder: _materialBorder(borderColor, borderRadius),
        focusedBorder: _materialBorder(borderColor, borderRadius),
        errorBorder: _materialBorder(null, borderRadius, isError: true),
        focusedErrorBorder: _materialBorder(null, borderRadius, isError: true),
      ),
    );
  }

  OutlineInputBorder? _materialBorder(
    Color? color,
    BorderRadius? radius, {
    bool isError = false,
  }) {
    if (color == null && radius == null && !isError) {
      return null;
    }

    return OutlineInputBorder(
      borderRadius: radius ?? BorderRadius.circular(12),
      borderSide: BorderSide(
        color: isError ? Colors.red : color ?? Colors.transparent,
      ),
    );
  }
}

class _CupertinoAdaptiveTextField extends StatefulWidget {
  const _CupertinoAdaptiveTextField({
    required this.controller,
    required this.initialValue,
    required this.label,
    required this.placeholder,
    required this.helperText,
    required this.errorText,
    required this.keyboardType,
    required this.textInputAction,
    required this.obscureText,
    required this.enabled,
    required this.readOnly,
    required this.maxLines,
    required this.minLines,
    required this.prefixIcon,
    required this.suffixIcon,
    required this.backgroundColor,
    required this.borderColor,
    required this.borderRadius,
    required this.onChanged,
    required this.onSubmitted,
    required this.validator,
    required this.inputFormatters,
    required this.autofillHints,
  });

  final TextEditingController? controller;
  final String? initialValue;
  final String? label;
  final String? placeholder;
  final String? helperText;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Color? backgroundColor;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;

  @override
  State<_CupertinoAdaptiveTextField> createState() =>
      _CupertinoAdaptiveTextFieldState();
}

class _CupertinoAdaptiveTextFieldState
    extends State<_CupertinoAdaptiveTextField> {
  late TextEditingController _controller;

  bool get _usesExternalController => widget.controller != null;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ?? TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(_CupertinoAdaptiveTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      if (!_usesExternalController) {
        _controller.dispose();
      }

      _controller =
          widget.controller ?? TextEditingController(text: widget.initialValue);
    }
  }

  @override
  void dispose() {
    if (!_usesExternalController) {
      _controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: _controller.text,
      enabled: widget.enabled,
      validator: widget.validator,
      builder: (field) {
        final theme = CupertinoTheme.of(context);
        final effectiveErrorText = widget.errorText ?? field.errorText;
        final helperOrError = effectiveErrorText ?? widget.helperText;
        final helperColor = effectiveErrorText == null
            ? CupertinoColors.secondaryLabel.resolveFrom(context)
            : CupertinoColors.systemRed.resolveFrom(context);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (widget.label != null) ...<Widget>[
              Text(
                widget.label!,
                style: theme.textTheme.textStyle.copyWith(
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
            ],
            CupertinoTextField(
              controller: _controller,
              placeholder: widget.placeholder,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              obscureText: widget.obscureText,
              enabled: widget.enabled,
              readOnly: widget.readOnly,
              maxLines: widget.obscureText ? 1 : widget.maxLines,
              minLines: widget.minLines,
              prefix: widget.prefixIcon == null
                  ? null
                  : Padding(
                      padding: const EdgeInsetsDirectional.only(start: 12),
                      child: IconTheme.merge(
                        data: IconThemeData(
                          color: CupertinoColors.secondaryLabel.resolveFrom(
                            context,
                          ),
                        ),
                        child: widget.prefixIcon!,
                      ),
                    ),
              suffix: widget.suffixIcon == null
                  ? null
                  : Padding(
                      padding: const EdgeInsetsDirectional.only(end: 12),
                      child: IconTheme.merge(
                        data: IconThemeData(
                          color: CupertinoColors.secondaryLabel.resolveFrom(
                            context,
                          ),
                        ),
                        child: widget.suffixIcon!,
                      ),
                    ),
              onChanged: (value) {
                field.didChange(value);
                widget.onChanged?.call(value);
              },
              onSubmitted: widget.onSubmitted,
              inputFormatters: widget.inputFormatters,
              autofillHints: widget.autofillHints,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color:
                    widget.backgroundColor ??
                    CupertinoColors.secondarySystemBackground.resolveFrom(
                      context,
                    ),
                borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
                border: Border.all(
                  color: effectiveErrorText == null
                      ? widget.borderColor ??
                            CupertinoColors.separator.resolveFrom(context)
                      : CupertinoColors.systemRed.resolveFrom(context),
                ),
              ),
            ),
            if (helperOrError != null) ...<Widget>[
              const SizedBox(height: 6),
              Text(
                helperOrError,
                style: theme.textTheme.textStyle.copyWith(
                  color: helperColor,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
