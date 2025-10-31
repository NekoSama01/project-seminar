import 'package:fishing_guide_app/screens/social_screens/commentsheet.dart';
import 'package:fishing_guide_app/screens/social_screens/upload_post_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, String> userCache =
      {}; // เก็บ uid -> username เพื่อลดการ query บ่อย

  String? currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
  }

  Future<String> getUsername(String uid) async {
    // ถ้ามีใน cache แล้วก็ใช้เลย
    if (userCache.containsKey(uid)) return userCache[uid]!;

    try {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists && userDoc.data()!.containsKey('username')) {
        String username = userDoc['username'];
        userCache[uid] = username; // เก็บลง cache
        return username;
      }
    } catch (e) {
      print('Error getting username: $e');
    }
    return 'Unknown User';
  }

  Future<void> toggleLike(String postId, String userId) async {
    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);

    final snapshot = await postRef.get();
    final data = snapshot.data();

    if (data != null) {
      List likedBy = data['likedBy'] ?? [];

      if (likedBy.contains(userId)) {
        // ถ้ามีอยู่แล้ว → กำลังจะ "unlike"
        await postRef.update({
          'likedBy': FieldValue.arrayRemove([userId]),
          'likesCount': FieldValue.increment(-1),
        });
      } else {
        // ถ้ายังไม่มี → กดไลก์
        await postRef.update({
          'likedBy': FieldValue.arrayUnion([userId]),
          'likesCount': FieldValue.increment(1),
        });
      }
    } else {
      // post ยังไม่มี field likedBy หรือ likesCount
      await postRef.set({
        'likedBy': [userId],
        'likesCount': 1,
      }, SetOptions(merge: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: RefreshIndicator(
        color: Colors.blue,
        onRefresh: () async {
          // หน่วงเวลานิดหน่อยให้รู้สึกว่ารีเฟรช
          await Future.delayed(Duration(seconds: 1));
          setState(() {}); // รีเฟรชหน้าใหม่
        },
        child: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('posts')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('ยังไม่มีโพสต์'));
            }

            final posts = snapshot.data!.docs;

            return ListView.builder(
              physics:
                  const AlwaysScrollableScrollPhysics(), // สำคัญ! ให้เลื่อนลงรีเฟรชได้แม้ไม่มีโพสต์
              padding: EdgeInsets.all(10),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index].data() as Map<String, dynamic>;
                final userId = post['userId'] ?? '';

                return FutureBuilder<String>(
                  future: getUsername(userId),
                  builder: (context, usernameSnapshot) {
                    String username = usernameSnapshot.data ?? 'Unknown User';

                    return Container(
                      margin: EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue[200],
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            title: Text(
                              username,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle:
                                post['createdAt'] != null
                                    ? Text(
                                      timeago.format(
                                        (post['createdAt'] as Timestamp)
                                            .toDate(),
                                      ),
                                      style: TextStyle(fontSize: 12),
                                    )
                                    : Text(''),
                            trailing:
                                (userId == currentUserId)
                                    ? PopupMenuButton<String>(
                                      onSelected: (value) async {
                                        if (value == 'delete') {
                                          bool? confirm = await showDialog(
                                            context: context,
                                            builder:
                                                (context) => AlertDialog(
                                                  title: Text('ลบโพสต์'),
                                                  content: Text(
                                                    'คุณแน่ใจหรือไม่ว่าต้องการลบโพสต์นี้?',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed:
                                                          () => Navigator.pop(
                                                            context,
                                                            false,
                                                          ),
                                                      child: Text('ยกเลิก'),
                                                    ),
                                                    TextButton(
                                                      onPressed:
                                                          () => Navigator.pop(
                                                            context,
                                                            true,
                                                          ),
                                                      child: Text(
                                                        'ลบ',
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                          );

                                          if (confirm == true) {
                                            await FirebaseFirestore.instance
                                                .collection('posts')
                                                .doc(posts[index].id)
                                                .delete();
                                          }
                                        }
                                      },
                                      itemBuilder:
                                          (context) => [
                                            PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text('ลบโพสต์'),
                                                ],
                                              ),
                                            ),
                                          ],
                                    )
                                    : null,
                          ),
                          if (post['imageUrl'] != null)
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  barrierColor: Colors.black87,
                                  builder: (context) {
                                    return Dialog(
                                      backgroundColor: Colors.transparent,
                                      insetPadding: EdgeInsets.all(10),
                                      child: Hero(
                                        tag: post['imageUrl'],
                                        child: InteractiveViewer(
                                          child: CachedNetworkImage(
                                            imageUrl: post['imageUrl'],
                                            fit: BoxFit.contain,
                                            errorWidget:
                                                (context, url, error) => Icon(
                                                  Icons.error,
                                                  color: Colors.white,
                                                ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Hero(
                                tag: post['imageUrl'],
                                child: ClipRRect(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(15),
                                  ),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 250,
                                    child: CachedNetworkImage(
                                      imageUrl: post['imageUrl'],
                                      placeholder:
                                          (context, url) => Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                      errorWidget:
                                          (context, url, error) =>
                                              Icon(Icons.error),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (post['text'] != null &&
                              post['text'].toString().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                post['text'],
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    (post['likedBy'] != null &&
                                            (post['likedBy'] as List).contains(
                                              currentUserId,
                                            ))
                                        ? Icons.thumb_up
                                        : Icons.thumb_up_alt_outlined,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () {
                                    if (currentUserId != null) {
                                      toggleLike(
                                        posts[index].id,
                                        currentUserId!,
                                      );
                                    }
                                  },
                                ),
                                Text('${post['likesCount'] ?? 0}'),
                                SizedBox(width: 10),
                                IconButton(
                                  icon: Icon(Icons.comment_outlined),
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20),
                                        ),
                                      ),
                                      builder:
                                          (context) => CommentSheet(
                                            postId: posts[index].id,
                                          ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[600],
        child: Icon(Icons.add_a_photo, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UploadPostPage()),
          );
        },
      ),
    );
  }
}
