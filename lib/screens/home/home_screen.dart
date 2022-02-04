import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../responsive.dart';
import 'components/blog_post.dart';
import 'components/categories.dart';
import 'components/recent_posts.dart';
import 'components/search.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);
  final bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> studentsStream =
        FirebaseFirestore.instance.collection('blog').snapshots();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: StreamBuilder<QuerySnapshot>(
              stream: studentsStream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
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
                  return Column(
                    children: List.generate(
                      storedocs.length,
                      (i) => BlogPostCard(
                        image: storedocs[i]['image'],
                        date: storedocs[i]['date'],
                        title: storedocs[i]['title'],
                        description: storedocs[i]['description'],
                      ),
                    ),
                  );
                }
              }),
        ),
        if (!Responsive.isMobile(context))
          const SizedBox(width: kDefaultPadding),
        if (!Responsive.isMobile(context))
          Expanded(
            child: Column(
              children: const [
                Search(),
                SizedBox(height: kDefaultPadding),
                Categories(),
                SizedBox(height: kDefaultPadding),
                RecentPosts(),
              ],
            ),
          ),
      ],
    );
  }
}
