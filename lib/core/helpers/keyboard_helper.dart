import 'package:flutter/material.dart';

abstract final class KeyboardHelper {
  static void hide(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  static void show(BuildContext context, FocusNode focusNode) {
    FocusScope.of(context).requestFocus(focusNode);
  }
}
