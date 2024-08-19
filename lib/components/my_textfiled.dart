import 'package:flutter/material.dart';

class MyTextfield extends StatelessWidget {
  const MyTextfield(
      {super.key,
      required this.controller,
      required this.hintText,
      required this.obScureText,
      required this.keyboardType,
      this.suffixIcon});

  final TextEditingController controller;
  final String hintText;
  final bool obScureText;
  final Widget? suffixIcon;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obScureText,
      keyboardType: keyboardType,
      onTapOutside: (event) {
        FocusScope.of(context).unfocus();
      },
      decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.primary,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.tertiary),
            borderRadius: BorderRadius.circular(12),
          ),

          //border when selected
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.primary),
            borderRadius: BorderRadius.circular(12),
          ),

          //color
          fillColor: Theme.of(context).colorScheme.secondary,
          filled: true,
          suffixIcon: suffixIcon),
    );
  }
}

class MyInputAlertBox extends StatelessWidget {
  const MyInputAlertBox(
      {super.key,
      required this.hintText,
      required this.onPressedText,
      this.onPressed,
      required this.textController});

  final String hintText, onPressedText;

  final void Function()? onPressed;
  final TextEditingController textController;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(8),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      content: TextField(
        controller: textController,
        maxLength: 140,
        maxLines: 3,
        style: TextStyle(
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
        decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.tertiary),
              borderRadius: BorderRadius.circular(12),
            ),

            //border when selected
            focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.primary),
              borderRadius: BorderRadius.circular(12),
            ),

            //color
            fillColor: Theme.of(context).colorScheme.secondary,
            filled: true,
            counterStyle: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            )),
      ),
      actions: [
        //cancel button
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            textController.clear();
          },
          child: Text(
            'Cancel',
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
        ),

        //yes button
        TextButton(
          onPressed: () {
            Navigator.pop(context);

            //
            onPressed!();

            textController.clear();
          },
          child: Text(
            onPressedText,
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
        ),
      ],
    );
  }
}
