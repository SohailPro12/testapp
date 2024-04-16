import 'package:flutter/material.dart';
import 'package:testapp/services/crud2/firestore.dart';
import 'package:testapp/models/post.dart';
import 'package:testapp/views/normal/hub_search/post_desc.dart';

class YourPostsView extends StatefulWidget {
  const YourPostsView({Key? key}) : super(key: key);

  @override
  _YourPostsViewState createState() => _YourPostsViewState();
}

class _YourPostsViewState extends State<YourPostsView> {
  final FireStoreService _fireStoreService = FireStoreService();
  List<Post> _allPosts = [];
  List<Post> _filteredPosts = [];
  bool _isSearchVisible = false;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _getAllPosts();
    _searchController = TextEditingController();
  }

  String _username = '';
  void _fetchUsername() async {
    try {
      String username = await _fireStoreService.getUserField('username');
      setState(() {
        _username = username;
      });
    } catch (e) {
      print('Error fetching username: $e');
    }
  }

  void _getAllPosts() async {
    String username = await _fireStoreService.getUserField('username');
    List<Post> posts = await _fireStoreService.getAllPosts(username);
    setState(() {
      _allPosts = posts;
      _filteredPosts = posts;
    });
  }

  void _toggleSearchVisibility() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (!_isSearchVisible) {
        _searchController.clear();
        _filterPosts('');
      }
    });
  }

  void _filterPosts(String query) {
    List<Post> filteredList = _allPosts.where((post) {
      return post.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
    setState(() {
      _filteredPosts = filteredList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Posts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _toggleSearchVisibility,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isSearchVisible) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterPosts,
              decoration: const InputDecoration(
                hintText: 'Search posts...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _buildPostList(_filteredPosts),
          ),
        ],
      );
    } else {
      return _buildPostList(_allPosts);
    }
  }

  Widget _buildPostList(List<Post> posts) {
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        Post post = posts[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostInfoView(post: post),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                post.datatype == 'video'
                    ? AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(
                          "https://i.pinimg.com/564x/e0/a2/00/e0a200b80d2aa7282c3987991aaf328b.jpg",
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.network(
                        post.postUrl,
                        fit: BoxFit.cover,
                      ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    post.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
