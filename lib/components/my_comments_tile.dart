import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone/components/services/database/database_provider.dart';
import 'package:twitter_clone/models/comment.dart';

import 'services/auth/auth_service.dart';

class MyCommentTile extends StatelessWidget {
  const MyCommentTile({super.key, required this.comment, this.onUserTap});
  final Comment comment;
  final void Function()? onUserTap;

  void showOptions(context) {
    //check if this post is owned by user or not

    String currentUserId = AuthService().getCurrentUid();
    final bool isOwnComment = comment.uid == currentUserId;

    //show options
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            child: Wrap(
              children: [
                //this post belongs to USer

                if (isOwnComment)
                  //delete comment button
                  ListTile(
                    leading: const Icon(Icons.delete),
                    title: const Text("Delete"),
                    onTap: () async {
                      Navigator.pop(context);

                      //hanlde delete
                      await Provider.of<DatabaseProvider>(context,
                              listen: false)
                          .deleteComment(comment.id, comment.postID);
                    },
                  )

                //this comment does not belong to user
                else ...[
//report buttton
                  ListTile(
                    leading: const Icon(Icons.flag),
                    title: const Text("Report"),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),

//block user button
                  ListTile(
                    leading: const Icon(Icons.block),
                    title: const Text("Block User"),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  )
                ],

                //cancel button
                ListTile(
                  leading: const Icon(Icons.cancel),
                  title: const Text("Cancel"),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiary,
          borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onUserTap,
            child: Row(
              children: [
                Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  comment.name,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  width: 5,
                ),

                //username
                Text(
                  "@${comment.username}",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    // fontWeight: FontWeight.bold,
                  ),
                ),

                const Spacer(),

                //delete icon -> ore options
                GestureDetector(
                    onTap: () => showOptions(context),
                    child: Icon(
                      Icons.more_horiz_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    )),
              ],
            ),
          ),

          //
          const SizedBox(
            height: 20,
          ),

          //message
          Text(
            comment.message,
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
              // fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
