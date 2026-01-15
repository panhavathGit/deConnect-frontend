import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/feed_viewmodel.dart';
import '../../chat/views/room_list_page.dart'; // Using named routes is better, but direct import for MVP is okay

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  @override
  void initState() {
    super.initState();
    // Trigger data load when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeedViewModel>().loadPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FeedViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Feed"),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RoomListPage())),
          )
        ],
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: viewModel.posts.length,
              itemBuilder: (context, index) {
                return Card(child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(viewModel.posts[index].content),
                ));
              },
            ),
    );
  }
}