import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/utils/app_constants.dart';

class PostDetailsPage extends StatefulWidget {
  const PostDetailsPage({super.key});

  @override
  State<PostDetailsPage> createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  final Map<String, dynamic> postData = Get.arguments;
  int likes = 0;
  int dislikes = 0;
  final TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    likes = postData['likes'] ?? 0;
    dislikes = postData['dislikes'] ?? 0;
  }

  void addComment(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      postData['comments'].add({
        'author': 'You',
        'text': text,
        'timestamp': DateTime.now().toString(),
      });
    });
    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final post = postData;
    final system = post['system'];

    return Scaffold(
      appBar: AppBar(
        title: Text(post['title'] ?? 'Post'),
        actions: [
          if (post['type'] != 'post')
            Icon(
              FontAwesome.triangle_exclamation_solid,
              color: Colors.red,
            ),
          horSpace()
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(post['title'],
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text("By ${post['user']} • on ${post['date']}"),
                const SizedBox(height: 12),
                Text(post['content']),
                const SizedBox(height: 20),

                // المنظومة المرتبطة
                if (system != null) _linkedSystemCard(system),

                // تفاعلات

                Row(
                  children: [
                    Expanded(child: const Divider(height: 32)),
                    const SizedBox(width: 4),
                    Icon(
                      FontAwesome.comment,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text('${post['comments'].length} comments',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 18,
                          color: Theme.of(context).primaryColor,
                        )),
                    const SizedBox(height: 8),
                  ],
                ),
                const SizedBox(height: 20),

                const Text("Comments",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 8),

                ...post['comments']
                    .map<Widget>((comment) => _commentItem(comment))
                    .toList(),
              ],
            ),
          ),

          // إضافة تعليق
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
              color: Colors.grey.shade100,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    decoration: const InputDecoration(
                      hintText: "Add a comment...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => addComment(commentController.text),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _linkedSystemCard(Map<String, dynamic> system) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("🔗 Linked System",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            _info("Panel",
                "${system['panelCount']} x ${system['panelPower']} ${system['panelBrand']}"),
            _info("Battery",
                "${system['batteryCount']} x ${system['batteryAh']}Ah ${system['batteryBrand']}"),
            _info("Inverter",
                "${system['inverterSize']} ${system['inverterBrand']}"),
            if (system['installer'] != null)
              _info("Installed by", system['installer']),
          ],
        ),
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _commentItem(Map<String, dynamic> comment) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 0, right: 0, bottom: 8),
      leading: const CircleAvatar(child: Icon(Icons.person)),
      title: Text(comment['author']),
      subtitle: Text(comment['text']),
      trailing: Text(comment['timestamp'].toString().substring(0, 10)),
    );
  }
}
