import 'package:flutter/material.dart';

void showLoadingCircle(context) {
  showDialog(
      context: context,
      builder: (context) => const AlertDialog(
            backgroundColor: Colors.transparent,
            elevation: 1,
            content: Center(
              child: CircularProgressIndicator.adaptive(),
            ),
          ));
}

void hideLoading(context) {
  Navigator.pop(context);
}
