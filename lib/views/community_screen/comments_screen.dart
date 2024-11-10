// // import 'package:aura_techwizard/components/utils.dart';
// // import 'package:aura_techwizard/models/user.dart';
// // import 'package:aura_techwizard/resources/firestore_methods.dart';
// // import 'package:aura_techwizard/resources/user_provider.dart';
// // import 'package:aura_techwizard/views/community_screen/comment_card.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';

// // class CommentsScreen extends StatefulWidget {
// //   final postId;
// //   const CommentsScreen({Key? key, required this.postId}) : super(key: key);

// //   @override
// //   _CommentsScreenState createState() => _CommentsScreenState();
// // }

// // class _CommentsScreenState extends State<CommentsScreen> {
// //   final TextEditingController commentEditingController =
// //       TextEditingController();

// //   void postComment(String uid, String name, String profilePic) async {
// //     try {
// //       String res = await FireStoreMethods().postComment(
// //         widget.postId,
// //         commentEditingController.text,
// //         uid,
// //         name,
// //         profilePic,
// //       );

// //       if (res != 'success') {
// //         if (context.mounted) showSnackBar(res, context);
// //       }
// //       setState(() {
// //         commentEditingController.text = "";
// //       });
// //     } catch (err) {
// //       showSnackBar(
// //         err.toString(),
// //         context,
// //       );
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final User? user = Provider.of<UserProvider>(context).getUser;

// //     return Scaffold(
// //       appBar: AppBar(
// //         backgroundColor: Colors.white,
// //         title: const Text('Comments'),
// //         centerTitle: false,
// //       ),
// //       body: StreamBuilder(
// //         stream: FirebaseFirestore.instance
// //             .collection('posts')
// //             .doc(widget.postId)
// //             .collection('comments')
// //             .snapshots(),
// //         builder: (context,
// //             AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
// //           if (snapshot.connectionState == ConnectionState.waiting) {
// //             return const Center(
// //               child: CircularProgressIndicator(),
// //             );
// //           }

// //           return ListView.builder(
// //             itemCount: snapshot.data!.docs.length,
// //             itemBuilder: (ctx, index) => CommentCard(
// //               snap: snapshot.data!.docs[index],
// //             ),
// //           );
// //         },
// //       ),
// //       bottomNavigationBar: SafeArea(
// //         child: Container(
// //           height: kToolbarHeight,
// //           margin:
// //               EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
// //           padding: const EdgeInsets.only(left: 16, right: 8),
// //           child: Row(
// //             children: [
// //               Hero(
// //                 tag: 'profile_${widget.postId}',
// //                 child: CircleAvatar(
// //                   backgroundImage: NetworkImage(user!.photoUrl),
// //                   radius: 18,
// //                 ),
// //               ),
// //               Expanded(
// //                 child: Padding(
// //                   padding: const EdgeInsets.only(left: 16, right: 8),
// //                   child: TextField(
// //                     controller: commentEditingController,
// //                     decoration: InputDecoration(
// //                       hintText: 'Comment as ${user.username}',
// //                       border: InputBorder.none,
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //               InkWell(
// //                 onTap: () => postComment(
// //                   user.uid,
// //                   user.username,
// //                   user.photoUrl,
// //                 ),
// //                 child: Container(
// //                   padding:
// //                       const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
// //                   child: const Text(
// //                     'Post',
// //                     style: TextStyle(color: Colors.blue),
// //                   ),
// //                 ),
// //               )
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'package:aura_techwizard/components/utils.dart';
// import 'package:aura_techwizard/models/user.dart';
// import 'package:aura_techwizard/resources/firestore_methods.dart';
// import 'package:aura_techwizard/resources/user_provider.dart';
// import 'package:aura_techwizard/views/community_screen/comment_card.dart';
// import 'package:aura_techwizard/views/community_screen/toxicity_detection/toxicity_service.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:provider/provider.dart';

// class CommentsScreen extends StatefulWidget {
//   final String postId;
//   const CommentsScreen({Key? key, required this.postId}) : super(key: key);

//   @override
//   _CommentsScreenState createState() => _CommentsScreenState();
// }

// class _CommentsScreenState extends State<CommentsScreen> {
//   final TextEditingController commentEditingController = TextEditingController();
//   final ToxicityDetectionService _toxicityService = ToxicityDetectionService();
//   bool _isPosting = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializeToxicityService();
//   }

//   Future<void> _initializeToxicityService() async {
//     try {
//       await _toxicityService.initialize();
//     } catch (e) {
//       print('Error initializing toxicity service: $e');
//     }
//   }

//   @override
//   void dispose() {
//     _toxicityService.dispose();
//     commentEditingController.dispose();
//     super.dispose();
//   }

//   Future<void> postComment(String uid, String name, String profilePic) async {
//     if (_isPosting || commentEditingController.text.trim().isEmpty) return;

//     setState(() {
//       _isPosting = true;
//     });

//     try {
//       // Show loading indicator
//       if (context.mounted) {
//         showDialog(
//           context: context,
//           barrierDismissible: false,
//           builder: (context) => const Center(
//             child: CircularProgressIndicator(),
//           ),
//         );
//       }

//       // Check for toxicity
//       bool isToxic = await _toxicityService.isToxic(commentEditingController.text);
      
//       // Hide loading indicator
//       if (context.mounted) {
//         Navigator.of(context).pop();
//       }

//       if (isToxic) {
//         if (context.mounted) {
//           showDialog(
//             context: context,
//             builder: (context) => AlertDialog(
//               title: const Text('Content Warning'),
//               content: const Text(
//                 'Your comment appears to contain inappropriate content. '
//                 'Please revise it to maintain a respectful discussion.',
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text('OK'),
//                 ),
//               ],
//             ),
//           );
//         }
//       } else {
//         String res = await FireStoreMethods().postComment(
//           widget.postId,
//           commentEditingController.text,
//           uid,
//           name,
//           profilePic,
//         );

//         if (res != 'success') {
//           if (context.mounted) showSnackBar(res, context);
//         } else {
//           setState(() {
//             commentEditingController.text = "";
//           });
//         }
//       }
//     } catch (err) {
//       if (context.mounted) {
//         showSnackBar(
//           'Error posting comment: ${err.toString()}',
//           context,
//         );
//       }
//     } finally {
//       setState(() {
//         _isPosting = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final User? user = Provider.of<UserProvider>(context).getUser;

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         title: const Text('Comments'),
//         centerTitle: false,
//       ),
//       body: StreamBuilder(
//         stream: FirebaseFirestore.instance
//             .collection('posts')
//             .doc(widget.postId)
//             .collection('comments')
//             .orderBy('datePublished', descending: true)
//             .snapshots(),
//         builder: (context,
//             AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(
//               child: CircularProgressIndicator(),
//             );
//           }

//           return ListView.builder(
//             itemCount: snapshot.data!.docs.length,
//             itemBuilder: (ctx, index) => CommentCard(
//               snap: snapshot.data!.docs[index],
//             ),
//           );
//         },
//       ),
//       bottomNavigationBar: SafeArea(
//         child: Container(
//           height: kToolbarHeight,
//           margin:
//               EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
//           padding: const EdgeInsets.only(left: 16, right: 8),
//           child: Row(
//             children: [
//               CircleAvatar(
//                 backgroundImage: NetworkImage(user?.photoUrl ?? ''),
//                 radius: 18,
//               ),
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.only(left: 16, right: 8),
//                   child: TextField(
//                     controller: commentEditingController,
//                     decoration: InputDecoration(
//                       hintText: 'Comment as ${user?.username ?? ""}',
//                       border: InputBorder.none,
//                     ),
//                   ),
//                 ),
//               ),
//               InkWell(
//                 onTap: _isPosting
//                     ? null
//                     : () => postComment(
//                           user?.uid ?? '',
//                           user?.username ?? '',
//                           user?.photoUrl ?? '',
//                         ),
//                 child: Container(
//                   padding:
//                       const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
//                   child: Text(
//                     'Post',
//                     style: TextStyle(
//                       color: _isPosting ? Colors.grey : Colors.blue,
//                     ),
//                   ),
//                 ),
//               ),
//               ElevatedButton(
//   onPressed: () async {
//     bool result = await _toxicityService.isToxic("I will kill you you bastard you useless piece if shit you have no balls");
//     print("Test toxicity result: $result");
//   },
//   child: Text('Test Model'),
// ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:aura_techwizard/resources/firestore_methods.dart';
import 'package:aura_techwizard/resources/user_provider.dart';
import 'package:aura_techwizard/views/community_screen/comment_card.dart';
import 'package:aura_techwizard/views/community_screen/toxicity_detection/toxicity_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class CommentsScreen extends StatefulWidget {
  final String postId;
  const CommentsScreen({Key? key, required this.postId}) : super(key: key);

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController commentEditingController = TextEditingController();
  final ToxicityDetectionService _toxicityService = ToxicityDetectionService();
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    _initializeToxicityService();
  }

  Future<void> _initializeToxicityService() async {
    try {
      await _toxicityService.initialize();
    } catch (e) {
      print('Error initializing toxicity service: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing toxicity detection')),
        );
      }
    }
  }

  @override
  void dispose() {
    _toxicityService.dispose();
    commentEditingController.dispose();
    super.dispose();
  }

  Future<void> postComment(String uid, String name, String profilePic) async {
    if (_isPosting || commentEditingController.text.trim().isEmpty) return;

    setState(() {
      _isPosting = true;
    });

    try {
      // Show loading indicator
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      // Check for toxicity
      bool isToxic = await _toxicityService.isToxic(commentEditingController.text);
      
      // Hide loading indicator
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (isToxic) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Content Warning'),
              content: const Text(
                'Your comment appears to contain inappropriate content. '
                'Please revise it to maintain a respectful discussion.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        String res = await FireStoreMethods().postComment(
          widget.postId,
          commentEditingController.text,
          uid,
          name,
          profilePic,
        );

        if (res != 'success') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(res)),
            );
          }
        } else {
          setState(() {
            commentEditingController.text = "";
          });
        }
      }
    } catch (err) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error posting comment: ${err.toString()}')),
        );
      }
    } finally {
      setState(() {
        _isPosting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).getUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Comments'),
        centerTitle: false,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.postId)
            .collection('comments')
            .orderBy('datePublished', descending: true)
            .snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (ctx, index) => CommentCard(
              snap: snapshot.data!.docs[index],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: kToolbarHeight,
          margin:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(user?.photoUrl ?? ''),
                radius: 18,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8),
                  child: TextField(
                    controller: commentEditingController,
                    decoration: InputDecoration(
                      hintText: 'Comment as ${user?.username ?? ""}',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: _isPosting
                    ? null
                    : () => postComment(
                          user?.uid ?? '',
                          user?.username ?? '',
                          user?.photoUrl ?? '',
                        ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: Text(
                    'Post',
                    style: TextStyle(
                      color: _isPosting ? Colors.grey : Colors.blue,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}