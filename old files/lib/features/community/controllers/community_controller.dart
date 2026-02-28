import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/controllers/company_controller.dart';
import 'package:solar_hub/features/community/models/community_post_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:solar_hub/utils/toast_service.dart';
import 'package:solar_hub/features/systems/controllers/systems_controller.dart';

class CommunityController extends GetxController {
  final _db = Supabase.instance.client;

  // State
  final posts = <CommunityPostModel>[].obs;
  final isLoading = false.obs;
  final isMoreLoading = false.obs;

  // Systems State for Hub
  final publicSystems = <dynamic>[].obs; // Using dynamic for now to match fetch logic or import SystemModel
  final isLoadingSystems = false.obs;
  final isMoreSystemsLoading = false.obs;

  // Search Toggle
  final isSearching = false.obs;
  final searchController = TextEditingController();

  // For Create Post
  final isPosting = false.obs;
  final postAsCompany = false.obs;
  final selectedImages = <XFile>[].obs;

  // Pagination
  int _page = 0;
  final int _limit = 10;
  bool _hasMore = true;

  // Systems for Dropdown
  final mySystems = <Map<String, dynamic>>[].obs;

  // Internal full list for local filtering
  final List<CommunityPostModel> _allPosts = [];

  @override
  void onInit() {
    super.onInit();
    fetchPosts();
    fetchPublicSystems(refresh: true);
    fetchMySystems();
  }

  Future<void> fetchPublicSystems({bool refresh = false}) async {
    // This will delegate to SystemsController but keep state here for unified Hub access
    final systemsController = Get.isRegistered<SystemsController>() ? Get.find<SystemsController>() : Get.put(SystemsController());
    if (refresh) {
      isLoadingSystems.value = true;
    } else {
      isMoreSystemsLoading.value = true;
    }

    try {
      await systemsController.fetchPublicSystems(refresh: refresh);
      publicSystems.assignAll(systemsController.publicSystems);
    } finally {
      isLoadingSystems.value = false;
      isMoreSystemsLoading.value = false;
    }
  }

  void searchPosts(String query) {
    if (query.isEmpty) {
      posts.assignAll(_allPosts);
    } else {
      final filtered = _allPosts.where((p) {
        final content = p.content?.toLowerCase() ?? '';
        final name = p.userName?.toLowerCase() ?? '';
        final q = query.toLowerCase();
        return content.contains(q) || name.contains(q);
      }).toList();
      posts.assignAll(filtered);
    }
  }

  Future<void> fetchMySystems() async {
    try {
      final userId = _db.auth.currentUser?.id;
      if (userId == null) return;

      final data = await _db.from('systems').select('id, notes, pv').eq('user_id', userId);
      mySystems.assignAll(List<Map<String, dynamic>>.from(data));
    } catch (e) {
      debugPrint('Error fetching user systems: $e');
    }
  }

  Future<void> fetchPosts({bool refresh = false}) async {
    if (refresh) {
      _page = 0;
      _hasMore = true;
      posts.clear();
      isLoading.value = true;
    } else {
      if (!_hasMore || isMoreLoading.value) return;
      isMoreLoading.value = true;
    }

    try {
      final from = _page * _limit;
      final to = from + _limit - 1;

      // Select with joins for Author, Company, and linked System
      final data = await _db.from('posts').select('*, author:profiles(*), companies(name, logo_url)').order('created_at', ascending: false).range(from, to);

      final List<CommunityPostModel> newPosts = (data as List).map((json) => CommunityPostModel.fromJson(json)).toList();

      if (refresh) {
        _allPosts.assignAll(newPosts);
        posts.assignAll(newPosts);
      } else {
        _allPosts.addAll(newPosts);
        posts.addAll(newPosts);
      }

      if (newPosts.length < _limit) {
        _hasMore = false;
      } else {
        _page++;
      }
    } catch (e) {
      debugPrint('Error fetching posts: $e');
      ToastService.error('Error', 'Failed to load posts');
    } finally {
      isLoading.value = false;
      isMoreLoading.value = false;
    }
  }

  Future<void> createPost(String content, {String postType = 'general', String? systemId}) async {
    if (content.trim().isEmpty && selectedImages.isEmpty) return;

    isPosting.value = true;
    try {
      final userId = _db.auth.currentUser!.id;
      final imageUrls = <String>[];

      // Upload Images
      for (var img in selectedImages) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${img.name}';
        final path = 'posts/$fileName';
        await _db.storage.from('products').uploadBinary(path, await img.readAsBytes()); // Reusing products/posts bucket if possible or create new one?
        // NOTE: Ideally create 'posts' bucket, but for now assuming we reuse or user creates it.
        // Let's assume 'products' bucket is public read for simplicity or use 'profiles'.
        // Best practice: separate bucket.
        // User didn't create 'posts' bucket yet. I will use 'products' as a fallback or assume it works if policy allows authenticated uploads.
        // Actually, let's just stick to 'products' bucket logic or 'profiles' bucket logic we fixed earlier.
        // Or assume user will fix storage.

        // Let's try 'products' bucket since we fixed it earlier.
        final url = _db.storage.from('products').getPublicUrl(path);
        imageUrls.add(url);
      }

      final postData = {
        'author_id': userId,
        'content': content,
        'image_urls': imageUrls,
        'created_at': DateTime.now().toIso8601String(),
        'post_type': postType,
        'system_id': systemId,
      };

      // Handle Company Post
      if (postAsCompany.value) {
        final companyController = Get.find<CompanyController>();
        // Fix: Use 'company' observable instead of 'myCompany'
        if (companyController.company.value != null) {
          postData['company_id'] = companyController.company.value!.id;
        }
      }

      final res = await _db.from('posts').insert(postData).select('*, author:profiles(*), companies(name, logo_url)').single();
      final newPost = CommunityPostModel.fromJson(res);

      posts.insert(0, newPost);

      selectedImages.clear();
      Navigator.of(Get.context!).pop(); // Close create page/modal safely
      ToastService.success('Success', 'post_created'.tr);
    } catch (e) {
      debugPrint('Error creating post: $e');
      ToastService.error('Error', '${'failed_to_create_post'.tr}: $e');
    } finally {
      isPosting.value = false;
    }
  }

  Future<List<CommunityPostModel>> fetchPostsBySystem(String systemId) async {
    try {
      final data = await _db
          .from('posts')
          .select('*, author:profiles(*), companies(name, logo_url)')
          .eq('system_id', systemId)
          .order('created_at', ascending: false);

      return (data as List).map((json) => CommunityPostModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching system posts: $e');
      return [];
    }
  }

  Future<List<CommunityPostModel>> fetchPostsByUser(String userId) async {
    try {
      final data = await _db
          .from('posts')
          .select('*, author:profiles(*), companies(name, logo_url)')
          .eq('author_id', userId)
          .order('created_at', ascending: false);

      return (data as List).map((json) => CommunityPostModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching user posts: $e');
      return [];
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _db.from('posts').delete().eq('id', postId);
      posts.removeWhere((p) => p.id == postId);
    } catch (e) {
      ToastService.error('Error', 'Failed to delete post');
    }
  }

  Future<List<Map<String, dynamic>>> fetchComments(String postId) async {
    try {
      final data = await _db.from('comments').select('*, author:profiles(*)').eq('post_id', postId).order('created_at', ascending: true);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('Error fetching comments: $e');
      return [];
    }
  }

  Future<bool> addComment(String postId, String content) async {
    try {
      final userId = _db.auth.currentUser?.id;
      if (userId == null) {
        ToastService.warning('Error', 'Please login to comment');
        return false;
      }

      await _db.from('comments').insert({'post_id': postId, 'author_id': userId, 'content': content, 'created_at': DateTime.now().toIso8601String()});

      // Optionally update local comment count if it was tracked
      return true;
    } catch (e) {
      debugPrint('Error adding comment: $e');
      ToastService.error('Error', 'Failed to add comment');
      return false;
    }
  }

  void pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    if (picked.isNotEmpty) {
      selectedImages.addAll(picked);
    }
  }
}
