import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:solar_hub/utils/toast_service.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();
  final _supabase = Supabase.instance.client;
  final Rx<User?> user = Rx<User?>(null);

  bool get isSignedIn => user.value != null;

  @override
  void onInit() {
    super.onInit();
    // Listen to auth state changes
    _supabase.auth.onAuthStateChange.listen((data) {
      user.value = data.session?.user;
      if (user.value != null) {
        fetchUserRole();
      } else {
        role.value = 'user';
      }
    });

    // Auto-redirect for admins
    // ever(role, (String r) {
    //   if (r == 'admin') {
    //     // Use a slight delay to ensure context is ready or navigation stack is stable
    //     Future.delayed(const Duration(milliseconds: 300), () {
    //       // Check if we are already there to avoid loop? Get.currentRoute might help but using class-based routing makes it harder.
    //       // We'll trust Get.offAll to handle the transition.
    //       Get.offAll(() => const AdminDashboardLayout());
    //     });
    //   }
    // });
  }

  @override
  void onReady() {
    super.onReady();
    // Ensure we capture the current session on startup
    user.value = _supabase.auth.currentUser;
    if (user.value != null) {
      fetchUserRole();
    }
  }

  final role = 'user'.obs;

  Future<void> fetchUserRole() async {
    try {
      if (user.value == null) return;
      final data = await _supabase.from('profiles').select('role').eq('id', user.value!.id).single();
      role.value = data['role'] ?? 'user';
    } catch (e) {
      // print("Error fetching role: $e");
    }
  }

  Future<AuthResponse> signUp(String email, String password, Map<String, dynamic> data) async {
    return await _supabase.auth.signUp(email: email, password: password, data: data);
  }

  Future<AuthResponse> signIn(String email, String password) async {
    return await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  Future<void> logOut() async {
    await _supabase.auth.signOut();
  }

  Future<bool> signInWithGoogle() async {
    // Note: Use correct redirectTo URL for your app (deep link)
    // e.g. io.supabase.flutter://login-callback
    final res = await _supabase.auth.signInWithOAuth(OAuthProvider.google, redirectTo: 'io.supabase.flutter://login-callback');
    return res;
  }

  Future<bool> signInWithApple() async {
    final res = await _supabase.auth.signInWithOAuth(OAuthProvider.apple, redirectTo: 'io.supabase.flutter://login-callback');
    return res;
  }

  /// Executes [action] only if the user is logged in.
  /// Otherwise, redirects to the Auth page.
  void ensureLoggedIn(Function action) {
    if (isSignedIn) {
      action();
    } else {
      Get.toNamed('/auth');
      ToastService.warning('Authentication Required', 'Please login to perform this action');
    }
  }

  Future<bool> checkProfileExists(String id) async {
    try {
      final res = await _supabase.from('profiles').select('id').eq('id', id).maybeSingle();
      return res != null;
    } catch (e) {
      return false;
    }
  }
}
