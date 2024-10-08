import 'package:flutter/material.dart';

class MyFollowButton extends StatelessWidget {
  const MyFollowButton(
      {super.key, required this.onPressed, required this.isFollowing});
  final void Function()? onPressed;
  final bool isFollowing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: MaterialButton(
          color:
              isFollowing ? Theme.of(context).colorScheme.primary : Colors.blue,
          padding: const EdgeInsets.all(25.0),
          onPressed: onPressed,
          child: Text(
            isFollowing ? "Unfollow" : "Follow",
            style: TextStyle(
              color: Theme.of(context).colorScheme.tertiary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
