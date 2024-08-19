import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone/components/my_comments_tile.dart';
import 'package:twitter_clone/components/my_post_tile.dart';
import 'package:twitter_clone/components/services/database/database_provider.dart';
import 'package:twitter_clone/models/post.dart';

import '../helper/navigate_pages.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key, required this.post});

  final Post post;

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  //provider
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);

  //build UI
  @override
  Widget build(BuildContext context) {
    //listen to all comments for this post
    final allcomments = listeningProvider.getComments(widget.post.id);

    //scaffold
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        // centerTitle: true,
        // title: Text(widget.post.message),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: ListView(shrinkWrap: true, children: [
        //Post
        MyPostTile(
          post: widget.post,
          onPostTap: () => goPostPage(context, widget.post),
          onUserTap: () => goUserPage(context, widget.post.uid),
        ),

        //comment on this post
        allcomments.isEmpty
            ?
            //no comments yet
            const Center(
                child: Text("No comments yet.."),
              )
            :

            //comments exist
            ListView.builder(
                itemCount: allcomments.length,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final comment = allcomments[index];
                  // return CommentTile(comment: comment);
                  return MyCommentTile(
                    comment: comment,
                    onUserTap: () => goUserPage(context, comment.uid),
                  );
                },
              ),
      ]

          //comments on this post
          ),
    );
  }
}
