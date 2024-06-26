import 'package:flutter/material.dart';
import 'package:testapp/utilities/dialogs/generic_dialog.dart';

Future<void> showErrorDialog(BuildContext context, String text) {
  return showGenericDialog<void>(
    context: context,
    title: 'An error occurred',
    content: text,
    optionsBuilder: () => {
      'OK': null,
    },
  );
}

Future<void> showSuccessDialog(BuildContext context, String text) {
  return showGenericDialog<void>(
    context: context,
    title: 'Success!',
    content: text,
    optionsBuilder: () => {
      'OK': null,
    },
  );
}
