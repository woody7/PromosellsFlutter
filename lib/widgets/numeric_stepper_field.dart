import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Port of the React app's NumericCheckbox.js — a small numeric text field
/// used for picking stock quantities. Clamps to [0, max] the same way the
/// React version rejects out-of-range typed values, and selects all text on
/// focus so re-entering a value doesn't require manually clearing it first.
class NumericStepperField extends StatefulWidget {
  const NumericStepperField({
    super.key,
    required this.value,
    required this.onValueChange,
    this.max,
  });

  final int value;
  final ValueChanged<int> onValueChange;
  final int? max;

  @override
  State<NumericStepperField> createState() => _NumericStepperFieldState();
}

class _NumericStepperFieldState extends State<NumericStepperField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value == 0 ? '' : widget.value.toString());
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _controller.selection = TextSelection(baseOffset: 0, extentOffset: _controller.text.length);
      }
    });
  }

  @override
  void didUpdateWidget(covariant NumericStepperField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final text = widget.value == 0 ? '' : widget.value.toString();
    if (text != _controller.text && !_focusNode.hasFocus) {
      _controller.text = text;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleChange(String text) {
    final newValue = int.tryParse(text);
    if (newValue == null || newValue < 0) return;
    if (widget.max != null && newValue > widget.max!) return;
    widget.onValueChange(newValue);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textAlign: TextAlign.center,
        decoration: const InputDecoration(
          isDense: true,
          hintText: '0',
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          border: OutlineInputBorder(),
        ),
        onChanged: _handleChange,
      ),
    );
  }
}
