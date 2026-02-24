import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/controllers/chat_controller.dart';
import 'package:solar_hub/utils/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatPage extends StatefulWidget {
  final String entityId;
  final String entityType; // 'offer', 'order', 'system'
  final String title;

  const ChatPage({super.key, required this.entityId, required this.entityType, required this.title});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatController controller = Get.put(ChatController());
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late String currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = Supabase.instance.client.auth.currentUser?.id ?? '';
    controller.openChat(widget.entityId, widget.entityType);
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent + 100, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          // Context Card
          Obx(() {
            if (controller.isContextLoading.value) {
              return const LinearProgressIndicator(minHeight: 2);
            }
            if (controller.contextData.isNotEmpty) {
              return Container(
                padding: const EdgeInsets.all(12),
                color: Colors.blue.withValues(alpha: 0.05),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.entityType == 'offer') ...[
                            Text(
                              "Offer for: ${controller.contextData['offer_requests']?['title'] ?? 'Request'}",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text("Price: \$${controller.contextData['price'] ?? 0} | Status: ${controller.contextData['status']}"),
                          ] else ...[
                            Text("Context: ${widget.entityType.capitalizeFirst}", style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.messages.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.messages.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text("start_conversation".tr, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }

              // Scroll to bottom on new messages
              WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

              return RefreshIndicator(
                onRefresh: () async => controller.refreshMessages(widget.entityId, widget.entityType),
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  physics: const AlwaysScrollableScrollPhysics(), // Ensure scrollable even if few items
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final msg = controller.messages[index];
                    final isMe = msg['sender_id'] == currentUserId;
                    final time = DateTime.tryParse(msg['created_at']);
                    final isRead = msg['is_read'] ?? false;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        decoration: BoxDecoration(
                          color: isMe ? AppTheme.primaryColor : Colors.grey[200],
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(msg['content'] ?? '', style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 15)),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  time != null ? timeago.format(time, locale: 'en_short') : '',
                                  style: TextStyle(color: isMe ? Colors.white70 : Colors.black54, fontSize: 10),
                                ),
                                if (isMe) ...[
                                  const SizedBox(width: 4),
                                  Icon(isRead ? Icons.done_all : Icons.done, size: 14, color: isRead ? Colors.blueAccent : Colors.white70),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),

          // Input Area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), offset: const Offset(0, -2), blurRadius: 10)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: InputDecoration(
                      hintText: "type_message".tr,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                const SizedBox(width: 8),
                Obx(
                  () => CircleAvatar(
                    backgroundColor: AppTheme.primaryColor,
                    child: IconButton(
                      icon: controller.isSending.value
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: controller.isSending.value
                          ? null
                          : () async {
                              if (_msgController.text.trim().isEmpty) return;
                              await controller.sendMessage(_msgController.text);
                              _msgController.clear();
                            },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
