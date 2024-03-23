import 'package:flutter/material.dart';
import 'package:testapp/utilities/dialogs/generic_dialog.dart';

Future<void> showCannotShareEmptyNoteDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'Sharing',
    content: 'You cannot share empty notes',
    optionsBuilder: () => {
      'OK': null,
    },
  );
}
