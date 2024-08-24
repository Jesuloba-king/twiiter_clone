import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone/components/services/database/database_provider.dart';

import '../components/my_drawer.dart';
import '../components/my_post_tile.dart';
import '../components/my_textfiled.dart';
import '../helper/navigate_pages.dart';
import '../models/post.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //providers
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);

  //
  TextEditingController messageController = TextEditingController();

//ona startup, looad all post
  @override
  void initState() {
    loadAllPosts();
    super.initState();
  }

  Future<void> loadAllPosts() async {
    await databaseProvider.loadAllPost();
  }

  //
  void _openPostMessageBox() {
    showDialog(
      context: context,
      builder: (context) => MyInputAlertBox(
        textController: messageController,
        hintText: "What's on your mind....",
        onPressedText: "Post",
        onPressed: () => postMessage(messageController.text),
      ),
    );

    //  CustomToast.show(
    //     backgroundColor: Colors.red.shade800,
    //     textColor: Colors.white,
    //     context: context,
    //     message: e.toString(),
    //     icon: Icons.error_outline_rounded, // Success icon
    //   );
  }

  //user wants to post message
  Future<void> postMessage(String message) async {
    await databaseProvider.postMessage(message);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        drawer: const MyDrawer(),
        appBar: AppBar(
          centerTitle: true,
          title: const Text("H O M E"),
          bottom: TabBar(
            dividerColor: Colors.transparent,
            padding: const EdgeInsets.all(4),
            labelPadding: const EdgeInsets.all(8),
            labelColor: Theme.of(context).colorScheme.inversePrimary,
            unselectedLabelColor: Theme.of(context).colorScheme.primary,
            indicatorColor: Theme.of(context).colorScheme.secondary,
            tabs: const [
              //
              Text("For you"),
              Text("Following"),
            ],
          ),
          foregroundColor: Theme.of(context).colorScheme.primary,
        ),

        body: TabBarView(
          children: [
            _buildPostList(listeningProvider.allPosts),
            _buildPostList(listeningProvider.followingPosts),
          ],
        ),

        //FAB
        floatingActionButton: FloatingActionButton(
            onPressed: _openPostMessageBox,
            child: const Icon(Icons.add_rounded)),
      ),
    );
  }

  Widget _buildPostList(List<Post> posts) {
    return posts.isEmpty
        ?
        //post list is empty
        const Center(
            child: const Text("Noting here..."),
          )
        :
        //post list is not empty
        ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              // final message = post.message;
              //get all posts
              return MyPostTile(
                post: post,
                onPostTap: () => goPostPage(context, post),
                onUserTap: () => goUserPage(context, post.uid),
              );
            });
  }
}
