import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:solar_hub/models/post_model.dart';
import 'package:solar_hub/models/system_model.dart';
import 'package:solar_hub/services/supabase_service.dart';
import 'package:solar_hub/utils/toast_service.dart';

class DataController extends GetxController {
  static DataController get to => Get.find();
  final _dbService = SupabaseService();

  User? get currentUser => _dbService.currentUser;

  // Observables for UI
  final RxList<PostModel> posts = <PostModel>[].obs;
  final RxList<SystemModel> systems = <SystemModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isMorePostsAvailable = true.obs;

  // Pagination State
  int _postsPage = 1;
  final int _pageSize = 10;

  // User System Data (local for now, or fetched)
  final userSystem = <String, dynamic>{
    'username': '',
    'address': {'address': '', 'lan': '', 'lag': ''},
    'panel': {'count': 0, 'power': 0, 'brand': '', 'details': ''},
    'inverter': {'power': 0, 'brand': '', 'type': 'On-Grid', 'details': ''},
    'battery': {'power': 0, 'count': 0, 'brand': '', 'type': 'Lithium', 'details': ''},
  }.obs;

  void updateUserSystem(Map<String, dynamic> data) {
    userSystem.value = data;
    ToastService.success('Success', 'User system updated locally');
  }

  @override
  void onInit() {
    super.onInit();
    // Listen for Auth Changes
    _dbService.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        // Refresh private data
        fetchSystems();
      } else if (event == AuthChangeEvent.signedOut) {
        // Clear private data
        systems.clear(); // If systems are private to the user
      }
    });
  }

  @override
  void onReady() {
    super.onReady();
    // Initial fetch - delayed until UI is ready
    _fetchData();
  }

  void _fetchData() {
    fetchPosts();
    // fetchSystems(); // fetched via auth listener or if public? Assuming systems are private:
    if (_dbService.currentUser != null) {
      fetchSystems();
    }
  }

  // void _loadDemoData() {
  //   // Demo Posts matching new structure
  //   posts.addAll([
  //     PostModel(
  //       id: '1',
  //       title: 'Amazing 5kW Solar System Performance',
  //       content: 'Just installed my new 5kW Hybrid system with 10kWh battery. Generating over 25kWh per day in Baghdad! Highly recommend Jinko panels.',
  //       userId: 'user1',
  //       userName: 'Ahmed Solar',
  //       type: 'post',
  //       date: DateTime.now().subtract(const Duration(hours: 2)),
  //       likes: 15,
  //       comments: [
  //         {'author': 'Sarah', 'text': 'Great numbers! What inverter are you using?'},
  //       ],
  //     ),
  //     // ... more demo data could be added here
  //   ]);

  //   // Demo Systems matching new structure
  //   systems.addAll([
  //     SystemModel(
  //       id: 's1',
  //       ownerId: 'user1',
  //       userName: 'Ahmed Solar',
  //       systemName: 'Home Hybrid',
  //       totalCapacityKw: 5.5,
  //       installDate: DateTime(2023, 11, 15),
  //       specs: {
  //         'panel': {'brand': 'Jinko', 'count': 10, 'power': 550},
  //         'inverter': {'brand': 'Deye', 'power': '5kW'},
  //         'battery': {'brand': 'Pylontech', 'count': 1, 'ah': 200},
  //       },
  //     ),
  //   ]);
  // }

  // --- Posts ---

  Future<void> fetchPosts({bool refresh = false}) async {
    if (refresh) {
      _postsPage = 1;
      isMorePostsAvailable.value = true;
    }

    if (!isMorePostsAvailable.value && !refresh) return;

    try {
      if (refresh) isLoading.value = true;

      final newPostsData = await _dbService.fetchPosts(_postsPage, _pageSize);
      final newPosts = newPostsData.map((json) => PostModel.fromJson(json)).toList();

      if (newPosts.length < _pageSize) {
        isMorePostsAvailable.value = false;
      }

      if (refresh) {
        posts.assignAll(newPosts);
      } else {
        posts.addAll(newPosts);
      }

      _postsPage++;
    } catch (e) {
      // Silent error or retry logic usually, avoiding snackbar spam on load more
      debugPrint('Error fetching posts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>?> addComment(String postId, String content) async {
    try {
      final user = _dbService.currentUser;
      if (user == null) {
        ToastService.error("Auth", "Please login to comment");
        return null;
      }

      final data = {'post_id': postId, 'author_id': user.id, 'content': content};

      final newComment = await _dbService.createComment(data);
      // Optional: Update local post comment count if needed
      return newComment;
    } catch (e) {
      // print('Add Comment Error: $e');
      ToastService.error("Error", "Failed to add comment");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> loadComments(String postId) async {
    try {
      return await _dbService.fetchComments(postId);
    } catch (e) {
      // print('Load Comments Error: $e');
      return [];
    }
  }

  Future<void> createPost(String content, String postType, String? systemId) async {
    try {
      isLoading.value = true;
      final user = _dbService.currentUser;
      if (user == null) {
        // Demo fallback
        final newPost = PostModel(
          id: 'demo_${DateTime.now().millisecondsSinceEpoch}',
          content: content,
          postType: postType,
          userId: 'demo_user',
          userName: 'You (Demo)',
          createdAt: DateTime.now(),
        );
        posts.insert(0, newPost);
        Get.back();
        ToastService.warning('Demo Mode', 'Post created locally (Not logged in)');
        return;
      }

      final newPostModel = PostModel(
        content: content,
        postType: postType,
        systemId: systemId,
        userId: user.id,
        userName: user.email, // Optimistic, usually fetch profile
        createdAt: DateTime.now(),
      );

      await _dbService.createPost(newPostModel.toJson());

      await fetchPosts(refresh: true);
      Get.back();
      ToastService.success('Success', 'Post created successfully');
    } catch (e) {
      // print(e);
      ToastService.error('Error', 'Failed to create post: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // --- Systems ---

  Future<void> fetchSystems() async {
    try {
      // Similarly implement pagination for systems if list grows long
      final data = await _dbService.fetchSystems(1, 20);
      systems.assignAll(data.map((json) => SystemModel.fromJson(json)).toList());
    } catch (e) {
      // print('Error fetching systems: $e');
    }
  }

  // --- User Requests ---
  final RxList<Map<String, dynamic>> myRequests = <Map<String, dynamic>>[].obs;

  Future<void> fetchMyRequests() async {
    try {
      final user = _dbService.currentUser;
      if (user == null) return;

      final response = await _dbService.client.from('offer_requests').select().eq('user_id', user.id).order('created_at', ascending: false);

      myRequests.assignAll(List<Map<String, dynamic>>.from(response));
    } catch (e) {
      // print('Error fetching my requests: $e');
    }
  }
}
