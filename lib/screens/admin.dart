import 'package:blog_test/screens/update.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'Add_blog.dart';
import 'home/components/blog_post.dart';

class Admin extends StatefulWidget {
  const Admin({Key? key}) : super(key: key);

  @override
  _AdminState createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  final bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> studentsStream =
        FirebaseFirestore.instance.collection('blog').snapshots();
    CollectionReference students =
        FirebaseFirestore.instance.collection('blog');

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddBlog(),
            ),
          );
        },
      ),
      appBar: AppBar(
        title: const Text('Admin Panel'),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: studentsStream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Something Went Wrong.'),
                ),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final List storedocs = [];
            snapshot.data!.docs.map((DocumentSnapshot document) {
              Map a = document.data() as Map<String, dynamic>;
              storedocs.add(a);
              a['id'] = document.id;
            }).toList();

            if (isLoading) {
              return const Center(
                child: Text('Loading'),
              );

            } else {
              return SizedBox(
                height: 1500,
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    for (var index = 0; index < storedocs.length; index++) ...[
                      BlogPostCardAdmin(
                        image: storedocs[index]['image'],
                        date: storedocs[index]['date'],
                        title: storedocs[index]['title'],
                        description: storedocs[index]['description'],
                        delete: () async {
                          for (int i = 0; i < storedocs[index]['image'].length; i++) {
                            await FirebaseStorage.instance.refFromURL(storedocs[index]['image'][i]).delete();
                          }
                          students.doc(storedocs[index]['id']).delete();
                        },
                        update: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UpdateStudentPage(
                              id: storedocs[index]['id'],
                            ),
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
              );
            }
          }),
    );
  }
}
