import 'package:flutter/material.dart';

class ProfilePostGrid extends StatelessWidget {
  final List<String> postImages;

  const ProfilePostGrid({super.key, required this.postImages});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.only(top: 2),
      itemCount: postImages.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemBuilder: (context, index) {
        return Image.network(postImages[index], fit: BoxFit.cover);
      },
    );
  }
}
