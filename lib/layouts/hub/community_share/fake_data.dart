// lib/data/fake_data.dart

// Needed for some widget imports if they were directly in these maps, though not strictly for maps themselves.

// Fake System Data
// List of all fake systems

final List<Map<String, dynamic>> fakeSystems = [
  {
    'id': 'system_123',
    'user_name': 'Rasool Al-Engineer',
    'user_id': 'rasol',
    'type': 'Hybrid',
    'panelPower': 610,
    'panelCount': 6,
    'panelBrand': 'LONGi',
    'panelNotes': 'Mounted at 25° tilt',
    'batteryVoltage': 51.2,
    'batteryAh': 200,
    'batteryCount': 1,
    'batteryBrand': 'SVolt',
    'batteryNotes': 'Lithium, safe under high temp',
    'inverterSize': '6',
    'inverterType': 'Hybrid',
    'inverterBrand': 'Deye',
    'inverterNotes': 'WiFi monitoring enabled',
    'installDate': '2024-11-10',
    'installer': 'SolarTech Iraq',
    'relatedPosts': ['post_a1b2', 'post_c3d4'],
  },
  {
    'id': 'system_123',
    'user_name': 'Ali',
    'user_id': 'ali',
    'type': 'Hybrid',
    'panelPower': 570,
    'panelCount': 8,
    'panelBrand': 'Jinko',
    'panelNotes': '',
    'batteryVoltage': 51.2,
    'batteryAh': 280,
    'batteryCount': 1,
    'batteryBrand': 'Deye',
    'batteryNotes': 'Lithium, safe under high temp',
    'inverterSize': '6',
    'inverterType': 'Hybrid',
    'inverterBrand': 'Deye',
    'inverterNotes': 'WiFi monitoring enabled',
    'installDate': '2024-12-10',
    'installer': 'SolarTech Iraq',
    'relatedPosts': [],
  },
];

// Fake Post Data (post 1)
final Map<String, dynamic> post = {
  'id': 'post_a1b2',
  'system_id': 'system_123', // Link to the system
  'title': 'Battery Drain Problem',
  'user': 'Ahmed Zain',
  'user_id': 'ahmed_zain',
  "type": "post",
  'date': '2025-04-15',
  'content': 'The battery drains quickly after sunset.',
  'likes': 5,
  'dislikes': 2,
  'comments': [
    {
      'author': 'Engineer Noor',
      'user_id': 'noor',
      'text': 'Check your charge controller!',
      'timestamp': '2025-04-16',
    },
    {
      'author': 'Ali H.',
      'user_id': 'ali',
      'text': 'Had same issue with old inverter',
      'timestamp': '2025-04-17',
    },
  ],
};

// Fake Post Data (post 2 - an issue)
final Map<String, dynamic> post2 = {
  'id': 'post_c3d4',
  'system_id': 'system_123', // Link to the system
  'title': 'شحن غير كافي',
  'user_id': 'alhilo',
  'user': 'الحلو',
  "type": "issue",
  'date': '2025-04-15',
  'content': 'في الليل يكون التشغيل اقل من المعتاد على البطارية',
  'likes': 5,
  'dislikes': 2,
  'comments': [
    {
      'author': 'Engineer Noor',
      'user_id': 'noor',
      'text': 'Check your charge controller!',
      'timestamp': '2025-04-16',
    },
    {
      'author': 'Ali H.',
      'user_id': 'ali',
      'text': 'Had same issue with old inverter',
      'timestamp': '2025-04-17',
    },
  ],
};

// List of all fake posts
final List<Map<String, dynamic>> fakePosts = [post, post2];

// --- Fake Notifications Data ---
// In a real app, this would come from an API or a local database
final List<Map<String, dynamic>> fakeNotifications = const [
  {
    'id': 'notif_001',
    'type': 'comment_on_system',
    'message': 'تم التعليق على النظام الخاص بك من قبل علي',
    'timestamp': '2025-07-12T10:30:00Z',
    'relatedId': 'system_123', // ID of the system
    'isRead': false,
  },
  {
    'id': 'notif_002',
    'type': 'reply_on_post',
    'message': 'تم الرد على منشورك من قبل حسن',
    'timestamp': '2025-07-12T11:00:00Z',
    'relatedId': 'post_a1b2', // ID of the post
    'isRead': false,
  },
  {
    'id': 'notif_003',
    'type': 'problem_answered',
    'message': 'تمت الاجابة على مشكلتك من قبل مهندس جاسم',
    'timestamp': '2025-07-12T11:30:00Z',
    'relatedId': 'post_c3d4', // ID of the problem post
    'isRead': false,
  },
  {
    'id': 'notif_004',
    'type': 'general_update',
    'message': 'مرحباً بك في مجتمع سولار هاب! استكشف الميزات الجديدة.',
    'timestamp': '2025-07-11T09:00:00Z',
    'isRead': true, // Example of a read notification
  },
];
