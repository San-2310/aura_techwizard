import 'package:aura_techwizard/components/utils.dart';
import 'package:aura_techwizard/resources/firestore_methods.dart';
import 'package:aura_techwizard/resources/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool isLoading = false;

  void postContent(String uid, String username, String profImage) async {
    setState(() {
      isLoading = true;
    });
    try {
      String res = await FireStoreMethods().uploadPost(
        _descriptionController.text,
        uid,
        username,
        profImage,
        _titleController.text,
      );
      if (res == "success") {
        setState(() {
          isLoading = false;
        });
        if (context.mounted) {
          showSnackBar(
            'Posted!',
            context,
          );
        }
        clearPost();
      } else {
        if (context.mounted) {
          showSnackBar(res,context);
        }
      }
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      showSnackBar(
        err.toString(),
        context,
        
      );
    }
  }

  void clearPost() {
    setState(() {
      _titleController.clear();
      _descriptionController.clear();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: clearPost,
        ),
        title: const Text('Create a Post'),
        centerTitle: false,
        actions: <Widget>[
          TextButton(
            onPressed: () => postContent(
              userProvider.getUser!.uid,
              userProvider.getUser!.username,
              userProvider.getUser!.photoUrl,
            ),
            child: const Text(
              "Post",
              style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0),
            ),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          isLoading
              ? const LinearProgressIndicator()
              : const Padding(padding: EdgeInsets.only(top: 0.0)),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: "Enter post title...",
                border: InputBorder.none,
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  hintText: "Write your post...",
                  border: InputBorder.none,
                ),
                maxLines: null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}