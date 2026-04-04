// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get app_name => 'تطبيق واط';

  @override
  String get app_slug => 'احسب منظومة الطاقة الشمسية الخاصة بك';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get my_systems => 'أنظمتي';

  @override
  String get my_requests => 'طلبات العروض';

  @override
  String get my_orders => 'طلباتي';

  @override
  String get company_dashboard => 'مساحة الشركة';

  @override
  String get admin_dashboard => 'مساحة الإدارة';

  @override
  String get register_company => 'تسجيل شركة';

  @override
  String get settings => 'الإعدادات';

  @override
  String get guest_user => 'مستخدم زائر';

  @override
  String get welcome_guest => 'مرحباً بك';

  @override
  String get hello => 'مرحباً،';

  @override
  String get dark_mode => 'الوضع الداكن';

  @override
  String get sign_out => 'تسجيل الخروج';

  @override
  String get sign_in => 'تسجيل الدخول';

  @override
  String get home => 'الرئيسية';

  @override
  String get good_morning => 'صباح الخير،';

  @override
  String get good_afternoon => 'طاب مساؤك،';

  @override
  String get good_evening => 'مساء الخير،';

  @override
  String get ready_to_manage_solar => 'جاهز لإدارة أنظمتك الشمسية؟';

  @override
  String get active_orders => 'الطلبات النشطة';

  @override
  String get quick_actions => 'إجراءات سريعة';

  @override
  String get calculator => 'الحاسبة';

  @override
  String get plan_your_system => 'خطط لنظامك';

  @override
  String get solar_tips => 'نصائح ومعلومات شمسية';

  @override
  String get store => 'المتجر';

  @override
  String get buy_components => 'شراء المكونات';

  @override
  String get b2b_storefront => 'واجهة B2B';

  @override
  String get b2c_storefront => 'واجهة B2C';

  @override
  String get storefront_b2b_subtitle => 'كتالوج مخصص للأعضاء مع أسعار الجملة وإظهار مخزون الشركة.';

  @override
  String get storefront_b2c_subtitle => 'واجهة متجر مفتوحة لجميع المستخدمين مع وصول عام للمنتجات.';

  @override
  String storefront_products_available(Object count) {
    return 'المنتجات المتاحة $count';
  }

  @override
  String get search_products => 'ابحث عن المنتجات';

  @override
  String get search_b2b_products => 'ابحث في منتجات B2B';

  @override
  String get filters => 'الفلاتر';

  @override
  String get sort_by => 'الترتيب حسب';

  @override
  String get sort_newest => 'الأحدث';

  @override
  String get sort_oldest => 'الأقدم';

  @override
  String get sort_name_asc => 'الاسم أ-ي';

  @override
  String get sort_name_desc => 'الاسم ي-أ';

  @override
  String get sort_price_asc => 'السعر من الأقل للأعلى';

  @override
  String get sort_price_desc => 'السعر من الأعلى للأقل';

  @override
  String get all => 'الكل';

  @override
  String get all_categories => 'كل التصنيفات';

  @override
  String get all_companies => 'كل الشركات';

  @override
  String get availability => 'التوفر';

  @override
  String get available => 'متوفر';

  @override
  String get unavailable => 'غير متوفر';

  @override
  String get min_price => 'أقل سعر';

  @override
  String get max_price => 'أعلى سعر';

  @override
  String get clear_filters => 'مسح';

  @override
  String get apply_filters => 'تطبيق';

  @override
  String get store_filters => 'فلاتر المتجر';

  @override
  String get no_store_products_found => 'لا توجد منتجات مطابقة للفلاتر الحالية.';

  @override
  String get load_more => 'تحميل المزيد';

  @override
  String get global_category => 'عام';

  @override
  String get internal_category => 'داخلي';

  @override
  String get company_category => 'شركة';

  @override
  String iqd_price(Object amount) {
    return '$amount د.ع';
  }

  @override
  String retail_price_label(Object amount) {
    return 'مفرد $amount';
  }

  @override
  String wholesale_price_label(Object amount) {
    return 'جملة $amount';
  }

  @override
  String stock_count(Object count) {
    return 'المخزون $count';
  }

  @override
  String get product_details => 'تفاصيل المنتج';

  @override
  String get price_overview => 'ملخص الأسعار';

  @override
  String get display_price => 'السعر المعروض';

  @override
  String get retail_price => 'سعر المفرد';

  @override
  String get wholesale_price => 'سعر الجملة';

  @override
  String get sku => 'SKU';

  @override
  String get pricing_tiers => 'شرائح التسعير';

  @override
  String pricing_tier_line(Object quantity, Object amount) {
    return '$quantity+ قطعة: $amount د.ع';
  }

  @override
  String get add_to_cart => 'أضف إلى السلة';

  @override
  String get added_to_cart => 'تمت الإضافة إلى السلة';

  @override
  String get b2b_cart => 'سلة B2B';

  @override
  String get b2c_cart => 'سلة B2C';

  @override
  String get cart_empty => 'سلتك فارغة';

  @override
  String get cart_empty_subtitle => 'أضف منتجات من المتجر لإنشاء سلة محلية مستقلة لكل شركة.';

  @override
  String get cart_summary => 'ملخص السلة';

  @override
  String get total_items => 'إجمالي العناصر';

  @override
  String get total_amount => 'الإجمالي';

  @override
  String cart_items_count(Object count) {
    return '$count عنصر';
  }

  @override
  String get clear_cart => 'مسح السلة';

  @override
  String get subtotal => 'المجموع الفرعي';

  @override
  String get join_community => 'انضم للمجتمع';

  @override
  String get share_system_feedback => 'شارك نظامك واحصل على تقييم';

  @override
  String get reset_password => 'إعادة تعيين كلمة المرور';

  @override
  String get reset_password_instructions => 'أدخل بريدك الإلكتروني وسنرسل لك رابطاً لإعادة تعيين كلمة المرور.';

  @override
  String get email_is_required => 'البريد الإلكتروني مطلوب';

  @override
  String get invalid_email => 'بريد إلكتروني غير صالح';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get success => 'نجاح';

  @override
  String get password_reset_email_sent => 'تم إرسال بريد إعادة تعيين كلمة المرور!';

  @override
  String get error => 'خطأ';

  @override
  String get send_reset_link => 'إرسال رابط إعادة التعيين';

  @override
  String get send_feedback => 'إرسال الملاحظات';

  @override
  String get feedback_info_title => 'رأيك يساعدنا على التحسين';

  @override
  String get feedback_info_description => 'شاركنا ملاحظاتك أو اقتراحاتك لنطوّر التطبيق ونحسّن تجربتك.';

  @override
  String get name => 'الاسم';

  @override
  String get name_hint => 'أدخل اسمك';

  @override
  String get name_required => 'الرجاء إدخال اسمك';

  @override
  String get phone_number => 'رقم الهاتف';

  @override
  String get phone_hint => 'رقم الهاتف (اختياري)';

  @override
  String get message => 'الرسالة';

  @override
  String get feedback_hint => 'اكتب ملاحظاتك أو اقتراحاتك هنا';

  @override
  String get feedback_required => 'الرجاء كتابة رسالة';

  @override
  String get feedback_submitted_successfully => 'تم إرسال ملاحظاتك بنجاح';

  @override
  String get user_feedbacks => 'ملاحظات المستخدمين';

  @override
  String get no_feedbacks_yet => 'لا توجد ملاحظات حتى الآن';

  @override
  String get mark_as_read => 'تحديد كمقروء';

  @override
  String get mark_as_unread => 'تحديد كغير مقروء';

  @override
  String get call => 'اتصال';

  @override
  String get whatsapp => 'واتساب';

  @override
  String get delete_feedback => 'حذف الملاحظة';

  @override
  String get delete_feedback_confirm => 'هل أنت متأكد من حذف هذه الملاحظة؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get add_screenshot => 'إضافة لقطة شاشة';

  @override
  String get tap_to_select_image => 'اضغط لاختيار صورة';

  @override
  String get remove => 'إزالة';

  @override
  String get username => 'اسم المستخدم';

  @override
  String get username_is_required => 'اسم المستخدم مطلوب';

  @override
  String get password => 'كلمة المرور';

  @override
  String get password_is_required => 'كلمة المرور مطلوبة';

  @override
  String get forgot_password => 'نسيت كلمة المرور؟';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get sign_up => 'إنشاء حساب';

  @override
  String get or_text => 'أو';

  @override
  String get first_name => 'الاسم الأول';

  @override
  String get last_name => 'الاسم الأخير';

  @override
  String get phone_required => 'رقم الهاتف مطلوب';

  @override
  String get invalid_phone_number => 'أدخل رقم هاتف صحيح';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get country => 'البلد';

  @override
  String get city => 'المدينة';

  @override
  String get city_is_required => 'المدينة مطلوبة';

  @override
  String get confirm_password => 'تأكيد كلمة المرور';

  @override
  String get confirm_password_is_required => 'تأكيد كلمة المرور مطلوب';

  @override
  String get passwords_do_not_match => 'كلمات المرور غير متطابقة';

  @override
  String get account_created => 'تم إنشاء الحساب';

  @override
  String get please_verify_email => 'يرجى التحقق من بريدك الإلكتروني.';

  @override
  String get sign_up_failed => 'فشل التسجيل';

  @override
  String get start_your_solar_business => 'ابدأ نشاطك في مجال الطاقة الشمسية';

  @override
  String get register_company_details => 'أدخل البيانات التالية لتسجيل شركتك. سيتم مراجعة طلبك من فريقنا قبل اعتماده.';

  @override
  String get company_name => 'اسم الشركة';

  @override
  String get company_name_is_required => 'اسم الشركة مطلوب';

  @override
  String get description => 'الوصف';

  @override
  String get description_is_required => 'الوصف مطلوب';

  @override
  String get b2b => 'B2B';

  @override
  String get b2c => 'B2C';

  @override
  String get address => 'العنوان';

  @override
  String get address_is_required => 'العنوان مطلوب';

  @override
  String get upload_logo => 'رفع الشعار';

  @override
  String get business_phone => 'هاتف الشركة';

  @override
  String get submit_application => 'إرسال الطلب';

  @override
  String get company_registered_success => 'تم تسجيل الشركة بنجاح';

  @override
  String get min_6_characters => '6 أحرف على الأقل';

  @override
  String get edit_profile_title => 'تعديل الملف الشخصي';

  @override
  String get edit_profile_tooltip => 'تعديل الملف الشخصي';

  @override
  String get gallery => 'المعرض';

  @override
  String get camera => 'الكاميرا';

  @override
  String failed_to_pick_image(Object error) {
    return 'تعذر اختيار الصورة: $error';
  }

  @override
  String get tap_to_change_avatar => 'اضغط لتغيير الصورة الشخصية';

  @override
  String get security_question => 'سؤال الأمان';

  @override
  String get security_answer => 'إجابة سؤال الأمان';

  @override
  String get save_changes => 'حفظ التغييرات';

  @override
  String get saving => 'جارٍ الحفظ...';

  @override
  String get my_posts => 'منشوراتي';

  @override
  String profile_id_short(Object id) {
    return 'المعرف: $id...';
  }

  @override
  String get welcome_back => 'مرحباً بعودتك';

  @override
  String get choose_how_to_continue => 'اختر الوجهة التي تريد المتابعة إليها';

  @override
  String get solar_hub => 'سولار هب';

  @override
  String continue_as(Object name) {
    return 'المتابعة باسم $name';
  }

  @override
  String get platform_management => 'إدارة المنصة';

  @override
  String get save_role_page_selection => 'تذكّر هذا الاختيار';

  @override
  String get use_the_power_of_the_sun => 'ابدأ رحلتك مع الطاقة الشمسية';

  @override
  String get default_user => 'المستخدم';

  @override
  String get calculator_tools => 'أدوات الحساب';

  @override
  String get system_wizard => 'حساب النظام الشمسي';

  @override
  String get system_wizard_desc => 'أجب عن بعض الأسئلة لتحصل على توصية لنظام شمسي متكامل';

  @override
  String get request_offer_wizard => 'طلب عرض سعر مخصص';

  @override
  String get request_offer_desc => 'أرسل متطلباتك ليصلك عرض مناسب من الشركات';

  @override
  String get quick_tools => 'أدوات سريعة';

  @override
  String get panels_calc => 'الألواح الشمسية';

  @override
  String get inverter_calc => 'العاكس';

  @override
  String get battery_calc => 'البطاريات';

  @override
  String get wires_calc => 'الكابلات';

  @override
  String get pump_calc => 'مضخة المياه';

  @override
  String get step_appliances => 'الأجهزة';

  @override
  String get step_usage => 'الاستخدام';

  @override
  String get step_results => 'النتائج';

  @override
  String get back => 'رجوع';

  @override
  String get next => 'التالي';

  @override
  String get close => 'إغلاق';

  @override
  String get calculate => 'احسب';

  @override
  String get add_appliance => 'إضافة جهاز';

  @override
  String get autonomy_hours => 'ساعات الاستقلالية';

  @override
  String get sun_hours => 'ساعات ذروة الشمس';

  @override
  String get panel_wattage => 'قدرة اللوح';

  @override
  String get single_battery_voltage => 'جهد البطارية الواحدة';

  @override
  String get battery_type_hint => 'الليثيوم عادة 12.8 فولت، 25.6 فولت، 51.2 فولت | الرصاص الحمضي عادة 12 فولت';

  @override
  String get system_voltage => 'جهد النظام';

  @override
  String get recommended_system => 'النظام الموصى به';

  @override
  String get panel_count => 'عدد الألواح';

  @override
  String get inverter_size => 'حجم العاكس';

  @override
  String get battery_bank => 'بنك البطاريات';

  @override
  String get request_this_system => 'طلب هذا النظام';

  @override
  String get request_description => 'أرسل تكوين هذا النظام للشركات المحلية للحصول على عروض';

  @override
  String get guide => 'دليل';

  @override
  String get dont_show_again => 'لا تظهر هذا مرة أخرى';

  @override
  String get capacity_kw => 'السعة';

  @override
  String get voltage_type => 'نوع الجهد';

  @override
  String get phase => 'الطور';

  @override
  String get type => 'النوع';

  @override
  String get battery_voltage => 'جهد البطارية';

  @override
  String get battery_amp => 'السعة';

  @override
  String get count => 'العدد';

  @override
  String get bank => 'مجموعة';

  @override
  String get notes_details => 'ملاحظات وتفاصيل';

  @override
  String get submit_request => 'إرسال الطلب';

  @override
  String get notes_optional => 'ملاحظات (اختياري)';

  @override
  String get notes_brand => 'ملاحظات (العلامة التجارية، نوع محدد...)';

  @override
  String get three_phase => 'ثلاثي الأطوار';

  @override
  String get voltage_110 => '110 فولت';

  @override
  String get voltage_230 => '230 فولت';

  @override
  String get voltage_380_three_phase => '380 فولت (ثلاثي الأطوار)';

  @override
  String get confirm_submit => 'تأكيد الإرسال';

  @override
  String get create_new_system => 'إنشاء نظام جديد';

  @override
  String get enter_system_name => 'أدخل اسماً لنظامك الجديد:';

  @override
  String get back_to_list => 'العودة للقائمة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get error_enter_system_name => 'مطلوب: يرجى إدخال اسم النظام';

  @override
  String get error_select_system => 'مطلوب: يرجى تحديد نظام';

  @override
  String get error_no_components => 'يرجى إضافة مكون واحد على الأقل (لوح، عاكس، أو بطارية)';

  @override
  String get appliance_name => 'اسم الجهاز';

  @override
  String get power_watts => 'القدرة';

  @override
  String get quantity => 'الكمية';

  @override
  String get hours_per_day => 'ساعة/يوم';

  @override
  String get no_company_found => 'لم يتم العثور على شركة';

  @override
  String get not_linked_company => 'أنت لست مرتبطاً بأي شركة بعد.';

  @override
  String get verification_pending => 'التحقق قيد الانتظار';

  @override
  String get verification_pending_msg => 'تسجيل شركتك قيد المراجعة. يرجى التحقق لاحقاً.';

  @override
  String get go_back => 'رجوع';

  @override
  String get balance => 'الرصيد';

  @override
  String get stock_value => 'قيمة المخزون';

  @override
  String get pending_orders => 'طلبات قيد الانتظار';

  @override
  String get open_requests => 'الطلبات المفتوحة';

  @override
  String get low_stock => 'الكمية قليلة';

  @override
  String get manage_business => 'إدارة العمل';

  @override
  String get orders => 'الطلبات';

  @override
  String get pos => 'نقطة البيع (POS)';

  @override
  String get invoices => 'الفواتير';

  @override
  String get accounting => 'المحاسبة';

  @override
  String get inventory => 'المخزون';

  @override
  String get offers => 'العروض';

  @override
  String get people => 'الأشخاص';

  @override
  String get members => 'الأعضاء';

  @override
  String get customers => 'العملاء';

  @override
  String get suppliers => 'الموردون';

  @override
  String get my_purchases => 'مشترياتي';

  @override
  String get tools => 'الأدوات';

  @override
  String get analytics => 'التحليلات';

  @override
  String get overview => 'نظرة عامة';

  @override
  String get services => 'الخدمات';

  @override
  String get contacts => 'جهات الاتصال';

  @override
  String get status_active => 'نشط';

  @override
  String get status_pending => 'قيد الانتظار';

  @override
  String get status_rejected => 'مرفوض';

  @override
  String get status_suspended => 'معلّق';

  @override
  String get status_cancelled => 'ملغي';

  @override
  String get status_accepted => 'مقبول';

  @override
  String get status_completed => 'مكتمل';

  @override
  String get status_unavailable => 'غير متاح';

  @override
  String get request_status_open => 'مفتوح';

  @override
  String get request_status_closed => 'مغلق';

  @override
  String get request_status_fulfilled => 'مكتمل التنفيذ';

  @override
  String get battery_type_gel => 'جل';

  @override
  String get battery_type_tubular => 'أنبوبي';

  @override
  String get battery_type_lithium => 'ليثيوم';

  @override
  String get inverter_type_off_grid => 'منفصل عن الشبكة';

  @override
  String get inverter_type_on_grid => 'مرتبط بالشبكة';

  @override
  String get inverter_type_hybrid => 'هجين';

  @override
  String get offers_marketplace => 'سوق العروض الشمسية';

  @override
  String get available_requests => 'الطلبات المتاحة';

  @override
  String get my_bids => 'عروضي المقدمة';

  @override
  String get no_requests_found => 'لا توجد طلبات';

  @override
  String get no_offers_found => 'لا توجد عروض';

  @override
  String get new_projects_will_appear_here => 'ستظهر هنا مشاريع الطاقة الشمسية الجديدة في منطقتك.';

  @override
  String get browse_requests_to_start_bidding => 'انتقل إلى تبويب الطلبات لبدء تقديم العروض على المشاريع.';

  @override
  String get admin_marketplace_oversight => 'لوحة متابعة سوق العروض';

  @override
  String get all_requests => 'جميع الطلبات';

  @override
  String get all_offers => 'جميع العروض';

  @override
  String get my_solar_project_inquiries => 'استفسارات مشاريعي الشمسية';

  @override
  String get add_new_request => 'إضافة طلب جديد';

  @override
  String received_offers_count(Object count) {
    return 'العروض المستلمة ($count)';
  }

  @override
  String get no_offers_received_yet => 'لم تصلك أي عروض بعد.';

  @override
  String get no_requests_posted => 'لا توجد طلبات منشورة';

  @override
  String get post_first_solar_request => 'ابدأ بتوفير الطاقة من خلال نشر أول طلب لنظام شمسي واستقبال عروض من الشركات.';

  @override
  String get create_solar_request => 'إنشاء طلب نظام شمسي';

  @override
  String get location_preferences => 'تفضيلات الموقع';

  @override
  String get broadcast_to_all_cities => 'إرسال الطلب إلى جميع المدن';

  @override
  String get broadcast_to_all_cities_desc => 'فعّل هذا الخيار للوصول إلى الشركات في مختلف المدن';

  @override
  String get solar_panel_needs => 'احتياجات الألواح الشمسية';

  @override
  String get expected_power_per_unit => 'القدرة المتوقعة للوحدة (واط)';

  @override
  String get quantity_needed => 'الكمية المطلوبة';

  @override
  String get estimated_pv_power_needed => 'إجمالي قدرة الألواح المطلوبة';

  @override
  String get storage_requirements => 'متطلبات التخزين';

  @override
  String get preferred_battery_type => 'نوع البطارية المفضل';

  @override
  String get battery_size_wh => 'سعة البطارية (واط-ساعة)';

  @override
  String get total_energy_capacity_needed => 'إجمالي سعة التخزين المطلوبة';

  @override
  String get inverter_configuration => 'إعدادات العاكس';

  @override
  String get desired_inverter_type => 'نوع العاكس المطلوب';

  @override
  String get total_inverter_power_peak => 'إجمالي قدرة العاكس المطلوبة';

  @override
  String get additional_specifications => 'مواصفات إضافية';

  @override
  String get project_description_notes => 'وصف المشروع / الملاحظات';

  @override
  String get required_field => 'هذا الحقل مطلوب';

  @override
  String get post_solar_request => 'نشر الطلب';

  @override
  String get new_offer_proposal => 'عرض سعر جديد';

  @override
  String get financial_information => 'البيانات المالية';

  @override
  String get solar_panels => 'الألواح الشمسية';

  @override
  String get power_per_unit => 'قدرة الوحدة (واط)';

  @override
  String get total_energy_capacity => 'إجمالي سعة التخزين';

  @override
  String get battery_type_label => 'نوع البطارية';

  @override
  String get inverter_type_label => 'نوع العاكس';

  @override
  String get storage_batteries => 'التخزين (البطاريات)';

  @override
  String get additional_notes => 'ملاحظات إضافية';

  @override
  String get notes_for_user => 'ملاحظات للمستخدم';

  @override
  String get enter_quotation_price => 'أدخل سعر العرض';

  @override
  String get price_required => 'السعر مطلوب';

  @override
  String get submit_quotation => 'إرسال العرض';

  @override
  String get offer_details => 'تفاصيل العرض';

  @override
  String get offering_price => 'سعر العرض';

  @override
  String get technical_specifications => 'المواصفات الفنية';

  @override
  String get included_services_items => 'الخدمات والعناصر المشمولة';

  @override
  String get notes_from_provider => 'ملاحظات الشركة';

  @override
  String submitted_on_date(Object date) {
    return 'تم الإرسال في $date';
  }

  @override
  String get quotation => 'عرض سعر';

  @override
  String get panels => 'الألواح';

  @override
  String get battery_storage => 'البطارية والتخزين';

  @override
  String get total_project_quote => 'إجمالي قيمة المشروع';

  @override
  String get chat => 'محادثة';

  @override
  String get accept_offer => 'قبول العرض';

  @override
  String get reject_offer => 'رفض العرض';

  @override
  String get solar_request_details => 'تفاصيل الطلب الشمسي';

  @override
  String get user_needs => 'احتياجات المستخدم';

  @override
  String get technical_notes => 'ملاحظات فنية';

  @override
  String get send_offer_for_request => 'إرسال عرض لهذا الطلب';

  @override
  String get panels_power => 'قدرة الألواح';

  @override
  String get battery_power => 'قدرة البطارية';

  @override
  String get battery_type_full => 'نوع البطارية';

  @override
  String get pv_power => 'قدرة الألواح';

  @override
  String get battery => 'البطارية';

  @override
  String city_label(Object city) {
    return 'المدينة: $city';
  }

  @override
  String get company_dashboard_subtitle => 'أدر عملياتك في مجال الطاقة الشمسية بكفاءة';

  @override
  String get error_loading_data => 'حدث خطأ أثناء تحميل البيانات';

  @override
  String section_label(Object name) {
    return 'القسم: $name';
  }

  @override
  String get quick_stats => 'إحصاءات سريعة';

  @override
  String get ready_to_scale_business => 'هل أنت مستعد لتوسيع أعمالك؟';

  @override
  String get monitor_growth_subscriptions => 'تابع نمو أعمالك واشتراكاتك من هنا.';

  @override
  String get solar_solutions_provider => 'مزود حلول الطاقة الشمسية';

  @override
  String get standard => 'قياسي';

  @override
  String get company => 'شركة';

  @override
  String get admin_user => 'مستخدم إداري';

  @override
  String get super_admin => 'مدير النظام';

  @override
  String get ready_to_scale_title => 'جاهز للتوسع؟';

  @override
  String service_not_requested(Object service) {
    return 'لم تطلب الوصول إلى خدمة $service بعد.';
  }

  @override
  String get service_unlock_description => 'فعّل هذه الخدمة لتطوير أعمالك في الطاقة الشمسية وأتمتة سير العمل.';

  @override
  String get access_requested_successfully => 'تم إرسال طلب الوصول بنجاح';

  @override
  String get request_access_now => 'اطلب الوصول الآن';

  @override
  String get awaiting_approval => 'بانتظار الموافقة';

  @override
  String service_under_review(Object service) {
    return 'طلبك للحصول على خدمة $service قيد المراجعة حالياً.';
  }

  @override
  String get service_pending_help => 'عادةً ما يستغرق فريقنا من 24 إلى 48 ساعة للموافقة على الخدمات الجديدة. يُرجى الانتظار أو التواصل مع الدعم عند الحاجة.';

  @override
  String get contact_support => 'التواصل مع الدعم';

  @override
  String get request_denied => 'تم رفض الطلب';

  @override
  String service_request_rejected(Object service) {
    return 'تم رفض طلبك لخدمة $service.';
  }

  @override
  String get service_rejected_help => 'قد يكون ذلك بسبب نقص في المعلومات أو عدم استيفاء الشروط. يُرجى التواصل مع فريقنا لتقديم اعتراض.';

  @override
  String get appeal_decision => 'الاعتراض على القرار';

  @override
  String get access_limited => 'الوصول محدود';

  @override
  String service_suspended_or_cancelled(Object service) {
    return 'خدمة $service الخاصة بك معلّقة أو ملغاة حالياً.';
  }

  @override
  String get service_accounts_help => 'يرجى التحقق من حالة اشتراكك أو التواصل مع فريق خدمة العملاء لحل المشكلة.';

  @override
  String get contact_accounts => 'التواصل مع الحسابات';

  @override
  String get service_maintenance => 'الخدمة تحت الصيانة';

  @override
  String service_being_updated(Object service) {
    return 'يتم حالياً تحديث خدمة $service.';
  }

  @override
  String get service_maintenance_help => 'نعمل على إضافة مزايا جديدة لتحسين تجربتك. يُرجى المحاولة مرة أخرى لاحقاً.';

  @override
  String get back_to_dashboard => 'العودة إلى لوحة التحكم';

  @override
  String get maybe_later => 'لاحقاً';

  @override
  String get email_support => 'الدعم عبر البريد';

  @override
  String get chat_on_whatsapp => 'المحادثة عبر واتساب';

  @override
  String get systems => 'الأنظمة';

  @override
  String get delivery => 'التوصيل';

  @override
  String get company_profile => 'ملف الشركة';

  @override
  String get subscription => 'الاشتراك';

  @override
  String get switch_to_user_view => 'التبديل لعرض المستخدم';

  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get app_preferences => 'تفضيلات التطبيق';

  @override
  String get push_notifications => 'الإشعارات الفورية';

  @override
  String get localization => 'اللغة والمنطقة';

  @override
  String get language => 'اللغة';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get startup_roles => 'بدء التشغيل والأدوار';

  @override
  String get startup_role_subtitle => 'افتح لوحة التحكم المفضلة لديك تلقائياً عند تشغيل التطبيق';

  @override
  String get edit_company => 'تعديل الشركة';

  @override
  String get profile_updated_success => 'تم تحديث الملف بنجاح!';

  @override
  String get subscription_required => 'الاشتراك مطلوب';

  @override
  String get subscription_required_msg => 'تحتاج إلى اشتراك نشط للوصول إلى هذه الميزة.';

  @override
  String get view_plans => 'مشاهدة الخطط';

  @override
  String get no_products_in_stock => 'لا توجد منتجات في المخزون';

  @override
  String get search => 'بحث';

  @override
  String get system_parameters => 'إعدادات النظام';

  @override
  String appliances_count_label(Object count) {
    return '$count أجهزة';
  }

  @override
  String total_load_watts_label(Object watts) {
    return 'إجمالي الحمل $watts واط';
  }

  @override
  String get total_pv_power => 'إجمالي قدرة الألواح';

  @override
  String get total_battery => 'إجمالي البطارية';

  @override
  String get charge_controller => 'منظم الشحن';

  @override
  String get peak_sun_hours => 'ساعات ذروة الشمس';

  @override
  String get autonomy => 'الاستقلالية';

  @override
  String get request_notes_hint => 'قيود التركيب، ملاحظات الموقع، أو أي طلبات إضافية...';

  @override
  String get new_system => 'نظام جديد';

  @override
  String get select_system => 'اختر نظاماً';

  @override
  String get add_calculation_to_existing_system => 'أضف هذه الحسبة إلى نظام موجود:';

  @override
  String get no_saved_systems_found => 'لم يتم العثور على أنظمة محفوظة.';

  @override
  String get system_name => 'اسم النظام';

  @override
  String get system_name_hint => 'مثال: منزلي الشمسي';

  @override
  String get select_installer_optional => 'اختر شركة التركيب (اختياري):';

  @override
  String get search_company_hint => 'ابحث عن شركة...';

  @override
  String get confirm_request_details => 'تأكيد تفاصيل الطلب';

  @override
  String get add_notes_constraints => 'أضف أي ملاحظات أو قيود خاصة...';

  @override
  String get low_voltage => 'جهد منخفض';

  @override
  String get high_voltage => 'جهد عالٍ';

  @override
  String get single_phase => 'سنكل فاز';

  @override
  String get hybrid => 'هجين';

  @override
  String get on_grid => 'مرتبط بالشبكة';

  @override
  String get off_grid => 'منفصل عن الشبكة';

  @override
  String get lithium => 'ليثيوم';

  @override
  String get gel_lead_acid_tubular => 'جل / رصاص-حامضي / تيوبولر';

  @override
  String get panel_calc_intro => 'احسب عدد الألواح الشمسية المطلوبة بناءً على استهلاكك اليومي للطاقة.';

  @override
  String get total_daily_usage => 'الاستهلاك اليومي الكلي';

  @override
  String get system_efficiency_loss_factor => 'كفاءة النظام / معامل الفاقد';

  @override
  String get required_panels => 'الألواح المطلوبة';

  @override
  String total_array_kw(Object value) {
    return 'إجمالي المصفوفة: $value كيلوواط';
  }

  @override
  String get did_you_know => 'هل تعلم؟';

  @override
  String get panel_calc_tip_text => '• الأمبير-ساعة = الواط ÷ الفولت.\n• مثال: حمل يومي 1000 واط-ساعة على نظام 12 فولت يساوي تقريباً 83.3 أمبير-ساعة.\n• نحتسب الفواقد حتى يبقى أداء النظام جيداً في الظروف الواقعية.';

  @override
  String get inverter_calc_intro => 'احسب حجم العاكس المناسب لتحمل أحمال الذروة بأمان.';

  @override
  String get total_load_amps => 'إجمالي تيار الحمل';

  @override
  String get amps => 'أمبير';

  @override
  String get ac_system_voltage => 'جهد النظام المتناوب';

  @override
  String get safety_factor_oversizing => 'معامل الأمان (زيادة الحجم)';

  @override
  String get recommended_inverter_size => 'حجم العاكس الموصى به';

  @override
  String approx_watts(Object value) {
    return '(تقريباً $value واط)';
  }

  @override
  String get inverter_calc_tip_text => '• عادةً يتم اختيار العاكس بقدرة أعلى من الحمل المستمر بنسبة 20% إلى 30%.\n• معامل الأمان يساعد على تحمل تيارات الإقلاع للأحمال مثل الثلاجات أو المضخات.';

  @override
  String get wires_calc_intro => 'اختر نوع التطبيق للحصول على مقاس سلك مقترح.';

  @override
  String get application_type => 'نوع التطبيق';

  @override
  String get dc_solar => 'تيار مستمر للألواح';

  @override
  String get dc_battery => 'تيار مستمر للبطاريات';

  @override
  String get ac_single_phase => 'تيار متناوب سنكل فاز';

  @override
  String get ac_three_phase => 'تيار متناوب ثلاثي الفاز';

  @override
  String get volts => 'فولت';

  @override
  String get current => 'التيار';

  @override
  String get distance_one_way => 'المسافة (اتجاه واحد)';

  @override
  String get metres => 'متر';

  @override
  String get allowable_voltage_drop => 'هبوط الجهد المسموح';

  @override
  String get recommended_wire_size => 'مقاس السلك الموصى به';

  @override
  String get wires_calc_tip_text => '• الحفاظ على هبوط الجهد منخفضاً مهم جداً لكفاءة النظام.\n• في كابلات البطاريات يفضّل أن يكون الهبوط أقل من 1% لتجنب فصل العاكس.\n• في خطوط الألواح الشمسية يكون 3% مقبولاً عادةً.';

  @override
  String get pump_calc_intro => 'احسب القدرة الشمسية اللازمة لنظام مضخة المياه.';

  @override
  String get daily_water_volume => 'حجم المياه اليومي';

  @override
  String get total_dynamic_head => 'الارتفاع الديناميكي الكلي (TDH)';

  @override
  String get pumping_hours => 'ساعات الضخ';

  @override
  String get location_peak_sun_hours => 'ساعات ذروة الشمس في الموقع';

  @override
  String get solar_panel_wattage => 'قدرة اللوح الشمسي';

  @override
  String get pump_efficiency => 'كفاءة المضخة';

  @override
  String get required_solar_panels => 'الألواح الشمسية المطلوبة';

  @override
  String get hydraulic_power_est => 'تقدير القدرة الهيدروليكية';

  @override
  String motor_hp_estimate(Object value) {
    return '(حوالي $value حصان) للمحرك';
  }

  @override
  String get definitions => 'تعريفات';

  @override
  String get flow_rate => 'معدل التدفق';

  @override
  String get hydraulic_power => 'القدرة الهيدروليكية';

  @override
  String get definition_tdh => 'الرفع العمودي + فاقد الاحتكاك + الضغط المطلوب.';

  @override
  String get definition_flow_rate => 'كمية المياه المطلوبة يومياً، مثل المتر المكعب.';

  @override
  String get definition_psh => 'عدد الساعات المكافئة لشدة شمس كاملة في موقعك، وغالباً تكون بين 4 و6 ساعات.';

  @override
  String get definition_hydraulic_power => 'القدرة المطلوبة لرفع الماء قبل احتساب فاقد كفاءة المحرك.';

  @override
  String get find_battery_count => 'حساب عدد البطاريات';

  @override
  String get find_backup_time => 'حساب مدة التشغيل';

  @override
  String get how_many_batteries_need => 'كم عدد البطاريات التي تحتاجها؟';

  @override
  String get how_long_batteries_last => 'كم ستدوم بطارياتك؟';

  @override
  String get required_backup_time => 'مدة التشغيل المطلوبة';

  @override
  String get hours => 'ساعات';

  @override
  String get required_batteries => 'البطاريات المطلوبة';

  @override
  String batteries_count_value(Object count) {
    return '$count بطاريات';
  }

  @override
  String battery_for_spec(Object capacity, Object voltage) {
    return 'لـ ${capacity}Ah عند ${voltage}V';
  }

  @override
  String get estimated_runtime => 'مدة التشغيل التقديرية';

  @override
  String runtime_hours_value(Object value) {
    return '$value ساعة';
  }

  @override
  String get number_of_batteries => 'عدد البطاريات';

  @override
  String get battery_capacity_ah => 'سعة البطارية (Ah)';

  @override
  String get depth_of_discharge_dod => 'عمق التفريغ (DoD)';

  @override
  String get typical_dod_hint => 'شائع: 50% لبطاريات الجل/AGM، و80% لليثيوم، و20-30% للرصاص الحمضي';

  @override
  String get battery_count_formula_hint => 'المعادلة: (الحمل × الوقت) ÷ (جهد البطارية × السعة × عمق التفريغ)';

  @override
  String get battery_runtime_formula_hint => 'تحسب هذه العملية مدة تشغيل بنك البطاريات مع الحمل قبل الوصول إلى عمق التفريغ المحدد.';

  @override
  String get battery_calculator_title => 'حاسبة البطاريات';

  @override
  String get time_calculate => 'حساب المدة';

  @override
  String get count_calculate => 'حساب العدد';

  @override
  String get your_load_ampere => 'تيار الحمل';

  @override
  String get example_10 => 'مثال: 10';

  @override
  String get numbers_only => 'أدخل أرقاماً فقط';

  @override
  String get load_ampere_helper => 'أدخل الحمل بالأمبير ثم اختر جهد النظام المتناوب. عادةً يتم حساب الحمل من: الجهد × التيار. مثال: 10 أمبير × 230 فولت = 2300 واط.';

  @override
  String get battery_amperes => 'سعة البطارية';

  @override
  String get battery_voltage_label => 'جهد البطارية';

  @override
  String get battery_count_label => 'عدد البطاريات';

  @override
  String get battery_count_hint => 'واحدة أو أكثر';

  @override
  String get runtime_question => 'كم ساعة تريد أن يعمل النظام فيها على البطاريات؟';

  @override
  String get required_runtime_hours => 'مدة التشغيل المطلوبة (بالساعات)';

  @override
  String get example_100_or_200 => 'مثال: 100 أو 200';

  @override
  String get example_12_24_48_512 => 'مثال: 12 أو 24 أو 48 أو 51.2';

  @override
  String get example_5_or_8 => 'مثال: 5 أو 8';

  @override
  String get battery_count_explanation => 'يتم حساب عدد البطاريات المطلوبة وفق المعادلة التالية:\n\n(القدرة × الوقت) ÷ (جهد البطارية × السعة × عمق التفريغ)\n\nمثال: (2300 واط × 5 ساعات) ÷ (12 فولت × 100Ah × 0.2) = حوالي 8 بطاريات.\n\nهذا يساعدك على تقدير عدد البطاريات اللازمة لحمل ومدة تشغيل محددين.';

  @override
  String depth_of_discharge_with_value(Object value) {
    return 'عمق تفريغ البطارية ($value%)';
  }

  @override
  String get dod_guidance => 'حدد نسبة عمق التفريغ (DoD).\n\nالقيم الشائعة تتراوح بين 20% و80% حسب نوع البطارية.\n\n• 20% لبطاريات الليثيوم أو التيوبولر\n• 50% لبطاريات AGM أو الجل\nراجع ورقة المواصفات للحصول على أفضل دقة.';

  @override
  String get battery_runtime_explanation => 'أدخل سعة البطارية (Ah)، الجهد (V)، وعدد البطاريات.\nيتم حساب إجمالي الطاقة المخزنة كما يلي:\nالجهد × السعة × عدد البطاريات × عمق التفريغ.\n\n• مثال: 4 بطاريات × 12 فولت × 100Ah × 0.2 = 960 واط-ساعة\nوهذا يساعد على تقدير مدة تشغيل الحمل على البطاريات.';

  @override
  String get dod_guidance_runtime => 'حدد نسبة عمق التفريغ (DoD) للبطارية.\n\nغالباً تتراوح القيم المناسبة بين 50% و80% حسب نوع البطارية ودرجة الحرارة وتعليمات الشركة المصنعة.\n\n• استخدم 20% لبطاريات الليثيوم أو التيوبولر.\n• استخدم 50% لبطاريات AGM أو الجل.\nارجع إلى ورقة المواصفات إذا لم تكن متأكداً.';

  @override
  String runtime_hours_precise(Object value) {
    return '$value ساعة';
  }

  @override
  String get save_to_system => 'حفظ في النظام';
}
