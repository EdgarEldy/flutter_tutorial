// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Row of 6 individual digit boxes for OTP / activation-code entry.
///
/// Author: edgar.muhamyangabo
/// Date: 2026-11-25
/// Project: flutter_tutorial
class OtpInputField extends StatefulWidget {
  const OtpInputField({
    super.key,
    required this.onCompleted,
    this.length = 6,
  });

  final ValueChanged<String> onCompleted;
  final int length;

  @override
  State<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputField> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length == widget.length) {
      widget.onCompleted(otp);
    }
  }

  void _onKeyEvent(KeyEvent event, int index) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.length, (i) {
        return Padding(
          padding: EdgeInsets.only(right: i < widget.length - 1 ? 10 : 0),
          child: KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (e) => _onKeyEvent(e, i),
            child: SizedBox(
              width: 48,
              height: 60,
              child: TextField(
                controller: _controllers[i],
                focusNode: _focusNodes[i],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(1),
                ],
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
                onChanged: (v) => _onChanged(v, i),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: _controllers[i].text.isNotEmpty
                      ? const Color(0xFFEDE7FF)
                      : const Color(0xFFF4EFF4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: colorScheme.outlineVariant,
                      style: _controllers[i].text.isEmpty
                          ? BorderStyle.none
                          : BorderStyle.solid,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: _controllers[i].text.isEmpty
                        ? const BorderSide(
                            color: Color(0xFFCAC4D0),
                            width: 1.5,
                            style: BorderStyle.solid,
                          )
                        : BorderSide(
                            color: colorScheme.primary,
                            width: 2,
                          ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
