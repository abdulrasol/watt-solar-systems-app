/* ==========================================================================
   ملف إنشاء قاعدة بيانات تطبيق الطاقة الشمسية الشامل (Solar Ecosystem DB)
   المنصة: Supabase (PostgreSQL)
   المميزات: دعم الأوفلاين، تعدد الصلاحيات، الحسابات، والمخزون
  ==========================================================================
*/

-- 1. تنظيف البيئة (اختياري: لحذف الأنواع السابقة إذا كنت تعيد البناء)
-- DROP TYPE IF EXISTS user_role, company_tier, order_type, order_status, product_status, system_status CASCADE;

-----------------------------------------------------------------------------
-- القسم الأول: التعريفات والأنواع (ENUMS)
-- نستخدمها لتقييد القيم المسموح بها في الحقول لضمان جودة البيانات
-----------------------------------------------------------------------------

-- أدوار الموظفين داخل الشركة
CREATE TYPE user_role AS ENUM ('owner', 'manager', 'accountant', 'sales', 'installer', 'staff');

-- تصنيف الشركات (تجار جملة، وسطاء/مكاتب)
CREATE TYPE company_tier AS ENUM ('wholesaler', 'intermediary', 'retailer');

-- أنواع الانفرترات (للمواصفات الفنية)
CREATE TYPE inverter_type AS ENUM ('hybrid', 'on_grid', 'off_grid', 'vfd');

-- حالة توثيق المنظومة (هل وافقت الشركة على أن هذا النظام من تركيبها؟)
CREATE TYPE system_status AS ENUM ('pending_verification', 'verified', 'rejected');

-- حالة المنتج في المخزن
CREATE TYPE product_status AS ENUM ('active', 'archived', 'out_of_stock');

-- أنواع الطلبات (بيع مباشر، أونلاين، جملة بين شركات)
CREATE TYPE order_type AS ENUM ('pos_sale', 'online_order', 'b2b_supply');

-- حالة الطلب
CREATE TYPE order_status AS ENUM ('pending', 'processing', 'completed', 'cancelled', 'returned');

-- حالة الدفع
CREATE TYPE payment_status AS ENUM ('paid', 'unpaid', 'partial', 'refunded');


-----------------------------------------------------------------------------
-- القسم الثاني: المستخدمين والشركات (Core Entities)
-----------------------------------------------------------------------------

-- جدول الملفات الشخصية (Profiles)
-- يربط مع جدول المصادقة الخاص بـ Supabase
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY, -- نفس ID المستخدم في Supabase Auth
  full_name TEXT,
  phone_number TEXT UNIQUE, -- المعرف الأساسي للبحث والربط
  avatar_url TEXT,
  is_verified BOOLEAN DEFAULT FALSE, -- للتوثيق الرسمي
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- جدول الشركات (Companies)
-- الكيان الاعتباري الذي يمتلك المخزون والفواتير
CREATE TABLE companies (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY, -- نستخدم UUID لدعم الأوفلاين والمزامنة
  name TEXT NOT NULL,
  tier company_tier NOT NULL DEFAULT 'intermediary', -- مستوى الشركة
  description TEXT,
  logo_url TEXT,
  address TEXT,
  contact_phone TEXT,
  balance DECIMAL DEFAULT 0, -- رصيد الشركة (لعمولة التطبيق أو الدفعات)
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- جدول أعضاء الشركة (Company Members)
-- يربط الأشخاص بالشركات ويحدد صلاحياتهم
CREATE TABLE company_members (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  
  role user_role DEFAULT 'staff', -- الدور (محاسب، مدير، الخ)
  permissions JSONB DEFAULT '[]', -- مصفوفة صلاحيات دقيقة e.g. ["view_reports", "edit_stock"]
  
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- قيد: يمنع تكرار نفس الموظف في نفس الشركة مرتين
  UNIQUE(company_id, user_id)
);


-----------------------------------------------------------------------------
-- القسم الثالث: معرض أعمال الطاقة الشمسية (Portfolio)
-- الأنظمة التي يمتلكها المستخدمون ويركبها الشركات
-----------------------------------------------------------------------------

CREATE TABLE solar_systems (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  owner_id UUID REFERENCES profiles(id) ON DELETE CASCADE, -- المستخدم صاحب البيت
  
  -- الشركة المنفذة (يمكن أن تكون فارغة اذا ركبها بنفسه)
  installed_by_company_id UUID REFERENCES companies(id) ON DELETE SET NULL, 
  
  -- حالة "الهاند شيك": الشركة يجب أن توافق لتظهر في بروفايلها
  verification_status system_status DEFAULT 'pending_verification',
  
  system_name TEXT, -- مثلا: "منظومة المزرعة"
  location_coordinates POINT, -- خط الطول والعرض للخريطة
  total_capacity_kw NUMERIC, -- سعة النظام بالكيلوواط
  image_url TEXT,
  
  -- *مهم*: المواصفات الفنية مخزنة بمرونة تامة
  -- مثال: { "panels": [{"brand": "Jinko", "count": 10}], "batteries": [...] }
  specs JSONB DEFAULT '{}', 
  
  notes TEXT,
  installation_date DATE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);


-----------------------------------------------------------------------------
-- القسم الرابع: التجارة والمخزون (Commerce & Inventory)
-----------------------------------------------------------------------------

-- جدول المنتجات (Products)
CREATE TABLE products (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  company_id UUID REFERENCES companies(id) ON DELETE CASCADE, -- من يملك هذا المنتج؟
  
  name TEXT NOT NULL,
  sku TEXT, -- الباركود (يستخدم للبحث السريع بالكاميرا)
  category TEXT, -- (الواح، انفرترات، اسلاك...)
  description TEXT,
  image_url TEXT,
  
  -- استراتيجية التسعير المتعدد
  cost_price DECIMAL DEFAULT 0, -- التكلفة (سري لا يظهر للعملاء)
  retail_price DECIMAL DEFAULT 0, -- سعر البيع للمستخدم العادي
  wholesale_price DECIMAL DEFAULT 0, -- سعر البيع للشركات والوسطاء
  
  -- إدارة المخزون
  stock_quantity INT DEFAULT 0,
  min_stock_alert INT DEFAULT 5, -- اشعار عند وصول العدد لهذا الرقم
  
  -- مواصفات المنتج الدقيقة (نفس فكرة المنظومة)
  specs JSONB DEFAULT '{}',
  
  status product_status DEFAULT 'active',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- قيد: لا يتكرر الباركود داخل مخزن نفس الشركة
  UNIQUE(company_id, sku)
);

-- جدول الطلبات/الفواتير (Orders)
-- يدعم الأوفلاين والمزامنة
CREATE TABLE orders (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY, -- يتم توليده في الموبايل عند الأوفلاين
  
  seller_company_id UUID REFERENCES companies(id), -- الشركة البائعة
  
  -- تحديد المشتري (واحد منهم سيكون له قيمة)
  buyer_user_id UUID REFERENCES profiles(id) ON DELETE SET NULL, -- مستخدم تطبيق
  buyer_company_id UUID REFERENCES companies(id) ON DELETE SET NULL, -- شركة أخرى (B2B)
  guest_customer_name TEXT, -- زبون "طياري" (دخل المحل واشترى نقدا)
  
  order_type order_type NOT NULL,
  status order_status DEFAULT 'completed', -- في البيع المباشر تكون completed فورا
  payment_status payment_status DEFAULT 'paid',
  
  -- الحسابات المالية
  total_amount DECIMAL NOT NULL,
  discount_amount DECIMAL DEFAULT 0,
  tax_amount DECIMAL DEFAULT 0,
  
  -- حقول المزامنة (Sync Fields) - عصب الأوفلاين
  created_offline BOOLEAN DEFAULT FALSE, -- هل انشئت والنت مقطوع؟
  synced_at TIMESTAMP WITH TIME ZONE, -- متى وصلت للسيرفر؟
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- تفاصيل الفاتورة (Order Items)
CREATE TABLE order_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id) ON DELETE SET NULL,
  
  quantity INT NOT NULL,
  
  -- نخزن السعر واسم المنتج "لحظة البيع"
  -- لضمان أن الفاتورة لا تتغير قيمتها اذا غير التاجر سعر المنتج لاحقاً
  unit_price DECIMAL NOT NULL, 
  total_line_price DECIMAL NOT NULL, -- (quantity * unit_price)
  product_name_snapshot TEXT
);


-----------------------------------------------------------------------------
-- القسم الخامس: التواصل الاجتماعي (Social)
-----------------------------------------------------------------------------

CREATE TABLE posts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  author_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  system_id UUID REFERENCES solar_systems(id) ON DELETE SET NULL,
  content TEXT,
  image_urls TEXT[], -- مصفوفة نصوص للصور
  post_type TEXT DEFAULT 'general', -- (استفسار، عرض، نقاش)
  
  likes_count INT DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE comments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
  author_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);


-----------------------------------------------------------------------------
-- تابع: القسم الخامس
-- الإشعارات (Notifications)
CREATE TABLE notifications (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE, -- من سيتلقى الإشعار
  
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  type TEXT DEFAULT 'info', -- info, success, warning, error
  
  is_read BOOLEAN DEFAULT FALSE,
  
  -- للربط مع الكيانات الأخرى (اختياري)
  related_entity_type TEXT, -- 'post', 'order', 'system'
  related_entity_id UUID,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- القسم السادس: الأمان (Security & RLS)
-- ... (existing RLS lines)
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- القسم السابع: المشغلات التلقائية (Triggers)
-- ... (existing triggers)

-- 1. إنشاء الدالة التي ستقوم بعملية النسخ
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, phone_number, avatar_url)
  values (
    new.id, -- نأخذ الـ ID من جدول المصادقة
    new.raw_user_meta_data ->> 'full_name', -- نأخذ الاسم من البيانات المرفقة
    COALESCE(new.phone, new.raw_user_meta_data ->> 'phone_number'), -- نأخذ الهاتف من المصادقة أو البيانات المرفقة
    new.raw_user_meta_data ->> 'avatar_url' -- الصورة إن وجدت
  );
  return new;
end;
$$;

-- 2. إنشاء الـ Trigger الذي يشغل الدالة عند كل تسجيل جديد
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();