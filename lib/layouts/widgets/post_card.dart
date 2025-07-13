import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

Widget postCard(Map<String, dynamic> post) {
  return InkWell(
    onTap: () {
      Get.toNamed('/community/post', arguments: post);
    },
    child: Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
          post["title"],
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(post["content"]),
        leading: CircleAvatar(child: Text(post["user"][0])),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text("💬 ${post["comments"].length}")],
        ),
      ),
    ),
  );
}

final shimmerPostCard = Shimmer.fromColors(
  baseColor: Colors.grey[300]!,
  highlightColor: Colors.grey[100]!,
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: SizedBox(
      height: 100,
      child: Card(
        child: ListTile(
          title: Container(
            color: Colors.white,
            height: 20,
            width: double.infinity,
          ),
          subtitle: Container(
            color: Colors.white,
            height: 40,
            width: double.infinity,
          ),
        ),
      ),
    ),
  ),
);
