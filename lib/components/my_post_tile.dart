// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone/components/my_textfiled.dart';
import 'package:twitter_clone/components/services/auth/auth_service.dart';
import 'package:twitter_clone/models/post.dart';

import 'services/database/database_provider.dart';

class MyPostTile extends StatefulWidget {
  const MyPostTile(
      {super.key, required this.post, this.onUserTap, this.onPostTap});

  final Post post;
  final void Function()? onUserTap;
  final void Function()? onPostTap;

  @override
  State<MyPostTile> createState() => _MyPostTileState();
}

class _MyPostTileState extends State<MyPostTile> {
  //providers
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _toggleLikePost() async {
    try {
      await databaseProvider.toggleLike(widget.post.id);
    } catch (e) {
      print(e);
    }
  }

  void showOptions() {
    //check if this post is owned by user or not

    String currentUserId = AuthService().getCurrentUid();
    final bool isOwnPost = widget.post.uid == currentUserId;

    //show options
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            child: Wrap(
              children: [
                //this post belongs to USer

                if (isOwnPost)
                  //delete meesage button
                  ListTile(
                    leading: const Icon(Icons.delete),
                    title: const Text("Delete"),
                    onTap: () async {
                      Navigator.pop(context);

                      //hanlde delete
                      await databaseProvider.deletePost(widget.post.id);
                    },
                  )

                //this post does not belong to user
                else ...[
                  //report buttton
                  ListTile(
                    leading: const Icon(Icons.flag),
                    title: const Text("Report"),
                    onTap: () {
                      Navigator.pop(context);

                      //handle report action
                      _reportPostConfirmationBox();
                    },
                  ),

                  //block user button
                  ListTile(
                    leading: const Icon(Icons.block),
                    title: const Text("Block User"),
                    onTap: () {
                      Navigator.pop(context);

                      //handle block user action
                      _blockUserConfirmation();
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

//report post confam
  void _reportPostConfirmationBox() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("Report Post"),
        content: const Text("Are you sure you want to report this post?"),
        actions: <Widget>[
          TextButton(
            child: const Text("Cancel"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),

          //report button
          TextButton(
            child: const Text("Report"),
            onPressed: () async {
              //handle report action
              await databaseProvider.reportUser(
                  widget.post.id, widget.post.uid);

              Navigator.pop(context);

              //ley user know...
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Message reported!")));
            },
          ),
        ],
      ),
    );
  }

  //block user
  void _blockUserConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("Block User"),
        content: const Text("Are you sure you want to block this user?"),
        actions: <Widget>[
          TextButton(
            child: const Text("Cancel"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),

          //Block button
          TextButton(
            child: const Text("Block"),
            onPressed: () async {
              //handle Block action
              await databaseProvider.blockUser(widget.post.uid);

              Navigator.pop(context);

              //ley user know...
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text("User Blocked!")));
            },
          ),
        ],
      ),
    );
  }

  //comments
  void openCommentBox() {
    showDialog(
        context: context,
        builder: (context) {
          return MyInputAlertBox(
              hintText: "Type a comment..",
              onPressedText: "Post",
              onPressed: () async {
                await _addComment();
              },
              textController: _commentController);
        });
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    try {
      await databaseProvider.addComment(
          widget.post.id, _commentController.text.trim());
      _commentController.clear();
    } catch (e) {
      print(e);
    }
  }

  //load comments
  Future<void> _loadComments() async {
    try {
      await databaseProvider.loadComments(widget.post.id);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    //does curretn user like the post
    bool likedByCurrentUser =
        listeningProvider.isPostByCurrentUser(widget.post.id);

    //listen to like count
    int likeCount = listeningProvider.getLikeCount(widget.post.id);
    //listen to comment count
    int commentCount = listeningProvider.getComments(widget.post.id).length;

    return GestureDetector(
      onTap: widget.onPostTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: widget.onUserTap,
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
                    widget.post.name,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    width: 5,
                  ),

                  //username
                  Text(
                    "@${widget.post.username}",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      // fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Spacer(),

                  //delete icon -> ore options
                  GestureDetector(
                      onTap: showOptions,
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
              widget.post.message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
                // fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            //buttons - like and comment

            Row(
              children: [
//

                //like seections
                SizedBox(
                  width: 60,
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: _toggleLikePost,
                        child: likedByCurrentUser
                            ? const Icon(
                                Icons.favorite,
                                color: Colors.red,
                              )
                            : Icon(
                                Icons.favorite_border_rounded,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        likeCount != 0 ? likeCount.toString() : '',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                // comments section
                Row(
                  children: [
                    //comment button
                    GestureDetector(
                      onTap: openCommentBox,
                      child: Icon(
                        Icons.chat,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),

                    //comment count
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      commentCount != 0 ? commentCount.toString() : '',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
