# دليلك الكامل للانتقال من Django إلى Go

> **هدف هذا الدليل:** تعليمك قراءة Backend المكتوب بلغة Go والموجود في المشروع، وتعديله، وإضافة ميزات جديدة إليه، حتى تصل في النهاية إلى نقل كل المنصة من Django إلى Go.
>
> **الجمهور:** مطوّر يجيد Java أو Dart أو Python/Django، ولا يعرف شيئًا عن Go.
>
> **سياق المشروع:**
> - جذر المشروع: `/Users/rasol/DevsTools/codes/python/watt`
> - Backend Go: `/Users/rasol/DevsTools/codes/python/watt/go_backend`
> - تقرير المقارنة: `/Users/rasol/DevsTools/codes/python/watt/api_migration_comparison.md`
> - مسار Go API الأساسي: `/api/v1`
> - Swagger: `/api/v1/docs`
> - GoAdmin Dashboard: `/dashboard`
> - Stack: Go 1.25, Gin, GORM, golang-jwt, swaggo/gin-swagger, GoAdmin, SQLite/MySQL

---

## 1. مقدمة

### 1.1 لماذا Go؟

Go (تُنطق **Go**، وليس Golang رسميًا) هي لغة برمجة صُمّمت في Google عام 2009 على يد Robert Griesemer وRob Pike وKen Thompson. ظهرت كرد فعل على تعقيد لغات أخرى مثل C++ وJava في المشاريع الضخمة، مع الحفاظ على الأداء العالي. منذ ذلك الحين، أصبحت Go واحدة من أكثر اللغات استخدامًا في الخوادم، وخدمات السحابة، وأدوات سطر الأوامر. شركات كبيرة مثل Google وUber وDropbox وCloudflare تعتمد عليها في أنظمةها الحرجة.

تتميز Go بأربعة أمور تجعلها مثالية لكتابة الخوادم (Backend):

1. **سرعة الترجمة والتنفيذ:** يترجم Go إلى ملف تنفيذي أصلي (native binary)، لذلك يبدأ الخادم خلال جزء من الثانية ويستهلك ذاكرة أقل بكثير من Python أو Java. هذا مهم جدًا عند نشر التطبيقات في الحاويات (containers) حيث كل ميجابايت يهم.
2. **تزامن بسيط (Concurrency):** توفر goroutines و channels لمعالجة آلاف الطلبات في وقت واحد بأقل تعقيد من Java threads، وبدون الحاجة لـ async/await كما في Python. Goroutine خفيفة جدًا: يمكن تشغيل مئات الآلاف منها في نفس الوقت.
3. **بنية بسيطة ومكتبة قياسية ضخمة:** لا توجد طبقات من التعقيد الاصطلاحي (boilerplate) كما في Java Spring، ولا توجد نسخ متعددة من الـ runtime كما قد يحدث في Python. القواعد قليلة وواضحة.
4. **توزيع سهل:** ملف تنفيذي واحد يحتوي على كل شيء (بدون تبعيات خارجية في الغالب)، مما يسهل النشر على الخوادم أو الحاويات. لا حاجة لـ virtualenv أو متطلبات طويلة.

بالنسبة لهذا المشروع، تم اختيار **Go 1.25 + Gin + GORM** لإعادة كتابة الـ Backend بدل Django Ninja لأسباب عملية:

- **أداء أفضل** عند عدد كبير من الطلبات المتزامنة.
- **ملف تنفيذي واحد** يمكن نشره بسهولة.
- **توافق كامل تقريبًا** مع التطبيق المكتوب بلغة Dart/Flutter لأن كلاهما يتحدث JSON عبر HTTP.
- **GORM** يجعل التعامل مع قاعدة البيانة قريبًا جدًا من Django ORM.
- **GoAdmin** يوفر لوحة تحكم شبيهة بـ Django Admin دون الحاجة لكتابة واجهة من الصفر.
- **golang-jwt** يوفر توافقًا مع توكنات Django JWT.
- **swaggo/gin-swagger** يولّد توثيق Swagger من التعليقات في الكود.

### 1.2 ما تحتاجه قبل البدء

قبل أن تبدأ، تأكد من توفر ما يلي:

- **Go 1.25** مثبتًا على جهازك. افتح الطرفية واكتب:
  ```bash
  go version
  ```
  يجب أن ترى شيئًا مثل `go version go1.25.0 darwin/arm64`.
- **VS Code** مع الإضافتين:
  - Go (من Google)
  - Error Lens (اختياري)
- **Postman** أو **Bruno** لاختبار الـ endpoints.
- **Git** للتحكم بالإصدارات.
- **معرفة عملية** بـ HTTP/REST و JSON و SQL.
- **فهم جيد** لـ Django Ninja و Django ORM.

### 1.3 كيف تقرأ هذا الدليل

هذا الدليل مُصمم ليقرأ من البداية إلى النهاية في المرة الأولى. الأقسام الأولى تعلمك لغة Go، والأقسام الوسطى تشرح هندسة المشروع، والأقسام الأخيرة تركز على العمل العملي وحل المشكلات. في نهاية كل قسم تجد **"ملخص سريع"** يلخّص النقاط الأساسية.

<p dir="rtl">
<b>ملخص سريع:</b> Go لغة حديثة وسريعة لكتابة الخوادم. في هذا المشروع، تعمل مع Gin (للـ HTTP) و GORM (لقواعد البيانات). لا حاجة لخبرة سابقة في Go؛ سنبدأ من الصفر.
</p>

---

## 2. أول يوم في Go

### 2.1 تثبيت Go و VS Code

تثبيت Go بسيط جدًا. على macOS يمكنك استخدام Homebrew:

```bash
brew install go
```

على Linux:

```bash
sudo apt update
sudo apt install golang-go
```

بعد التثبيت، تأكد من متغيرات البيئة:

```bash
go env GOPATH
go env GOROOT
```

- `GOROOT`: مكان تثبيت Go.
- `GOPATH`: مجلد العمل الافتراضي للمشاريع والحزم.
- `go.mod`: يحل محل `GOPATH` في إدارة المشاريع الحديثة.

في VS Code، شغّل `Ctrl+Shift+P` ثم `Go: Install/Update Tools` وثبّت جميع الأدوات المقترحة. هذه الأدوات تساعد في التنسيق التلقائي، والاستيراد التلقائي، والتنقل في الكود.

### 2.2 Hello World

في أي مجلد فارغ، أنشئ ملفًا باسم `main.go`:

```go
package main

import "fmt"

func main() {
    fmt.Println("مرحبًا بك في Go!")
}
```

> ملاحظة: في Go يجب أن يبدأ اسم البرنامج التنفيذي من حزمة `package main` ودالة `main()`.

شغّل الكود:

```bash
go run main.go
```

### 2.3 go run / go build / go test

| الأمر | الوظيفة | مثال |
|-------|---------|------|
| `go run .` | يترجم ويشغل مباشرة | `go run main.go` |
| `go build .` | ينتج ملف تنفيذي | `go build -o app` |
| `go test ./...` | يشغل اختبارات الحزم | `go test ./internal/handlers/...` |
| `go fmt ./...` | ينسّق الشيفرة | `go fmt ./...` |
| `go mod tidy` | ينظف الاعتماديات | `go mod tidy` |
| `go get` | يضيف حزمة جديدة | `go get github.com/gin-gonic/gin` |

### 2.4 go.mod وإدارة الاعتماديات

افتح `/Users/rasol/DevsTools/codes/python/watt/go_backend/go.mod`:

```go
module watt

go 1.25.0

require (
    github.com/GoAdminGroup/go-admin v1.2.26
    github.com/GoAdminGroup/themes v0.0.48
    github.com/gin-gonic/gin v1.12.0
    github.com/golang-jwt/jwt/v5 v5.3.1
    github.com/google/uuid v1.6.0
    github.com/joho/godotenv v1.5.1
    github.com/swaggo/files v1.0.1
    github.com/swaggo/gin-swagger v1.6.1
    github.com/swaggo/swag v1.16.6
    golang.org/x/crypto v0.53.0
    gorm.io/datatypes v1.2.7
    gorm.io/driver/mysql v1.6.0
    gorm.io/driver/sqlite v1.6.0
    gorm.io/gorm v1.31.2
)
```

- `module watt`: اسم الوحدة. كل استيراد داخلي يبدأ بـ `watt/...`.
- `go 1.25.0`: إصدار Go المطلوب.
- `require`: قائمة الحزم الخارجية، مثل `requirements.txt` في Python.
- `go.sum`: يحتوي على hashes للحزم لضمان تطابق الإصدارات.

### 2.5 إنشاء مشروع Go جديد

لإنشاء مشروع جديد:

```bash
mkdir myapp
cd myapp
go mod init myapp
```

ثم أنشئ `main.go` وشغّله.

<p dir="rtl">
<b>ملخص سريع:</b> كل برنامج Go يبدأ بـ <code>package main</code> ودالة <code>main()</code>. <code>go.mod</code> يدير الاعتماديات مثل <code>requirements.txt</code> أو <code>pubspec.yaml</code>.
</p>

---

## 3. من Java/Dart/Python إلى Go

### 3.1 المتغيرات والأنواع

في Go الأنواع ثابتة (statically typed)، مثل Java، ولكنها مختصرة.

| Java | Dart | Python | Go |
|------|------|--------|----|
| `int x = 10;` | `int x = 10;` | `x = 10` | `var x int = 10` |
| `String name = "Ali";` | `String name = "Ali";` | `name = "Ali"` | `var name string = "Ali"` |
| `boolean ok = true;` | `bool ok = true;` | `ok = True` | `var ok bool = true` |
| `double price = 9.99;` | `double price = 9.99;` | `price = 9.99` | `var price float64 = 9.99` |

Go يدعم الاستنتاج (type inference) بـ `:=`:

```go
name := "Ali"   // string
age := 30       // int
price := 9.99   // float64
active := true  // bool
```

يساوي:

```go
var name string = "Ali"
var age int = 30
var price float64 = 9.99
var active bool = true
```

الثوابت:

```go
const Pi = 3.14159
const AppName = "Watt"
```

**القيم الافتراضية (Zero Values):**

في Go، كل نوع له قيمة افتراضية:

```go
var i int     // 0
var s string  // ""
var b bool    // false
var p *int    // nil
```

### 3.2 if / for / switch

**if:**

```go
score := 85
if score >= 90 {
    fmt.Println("ممتاز")
} else if score >= 75 {
    fmt.Println("جيد جدًا")
} else {
    fmt.Println("يحتاج تحسين")
}
```

يمكن تعريف متغير داخل if:

```go
if x := 10; x > 5 {
    fmt.Println("أكبر من 5")
}
```

**for:**

```go
// for عادي
for i := 0; i < 5; i++ {
    fmt.Println(i)
}

// while-style
n := 0
for n < 5 {
    fmt.Println(n)
    n++
}

// for each على slice
names := []string{"أحمد", "سارة", "محمد"}
for index, name := range names {
    fmt.Println(index, name)
}
```

**switch:**

```go
lang := "ar"
switch lang {
case "ar":
    fmt.Println("العربية")
case "en":
    fmt.Println("English")
default:
    fmt.Println("غير معروف")
}
```

### 3.3 الدوال والقيم المرجعة المتعددة

في Java/Dart تُرجع الدالة قيمة واحدة (أو Future). في Go يمكن إرجاع أكثر من قيمة. هذا أساسي لمعالجة الأخطاء.

```go
func add(a int, b int) int {
    return a + b
}

// قيمتان مرجعتان
func divide(a, b float64) (float64, error) {
    if b == 0 {
        return 0, fmt.Errorf("لا يمكن القسمة على صفر")
    }
    return a / b, nil
}
```

استخدامها:

```go
result, err := divide(10, 2)
if err != nil {
    fmt.Println("خطأ:", err)
} else {
    fmt.Println("النتيجة:", result)
}
```

### 3.4 Structs بدل Classes

Go لا يحتوي على classes. بدلًا منها نستخدم `struct`:

```go
type User struct {
    ID       uint
    Username string
    Email    string
}

func main() {
    u := User{
        ID:       1,
        Username: "ali",
        Email:    "ali@example.com",
    }
    fmt.Println(u.Username)
}
```

هذا يكافئ في Python:

```python
@dataclass
class User:
    id: int
    username: str
    email: str
```

### 3.5 Methods و Interfaces

**Methods:** دوال مرتبطة بنوع ما.

```go
func (u User) FullName() string {
    return u.Username + "@app"
}
```

**Interfaces:** مجموعة من الـ methods التي يجب أن ينفذها النوع.

```go
type Greeter interface {
    Greet() string
}

type Person struct{ Name string }

func (p Person) Greet() string {
    return "مرحبًا " + p.Name
}
```

في Go، يتحقق التنفيذ تلقائيًا (implicit interface)؛ لا حاجة لكتابة `implements`.

### 3.6 Pointers بأبسط صورة

Pointer هو عنوان المتغير في الذاكرة. في Go نستخدم `&` للحصول على العنوان و `*` للوصول للقيمة.

```go
func main() {
    x := 10
    p := &x   // p هو *int (pointer to int)
    *p = 20   // عدّلنا x عبر p
    fmt.Println(x) // 20
}
```

تُستخدم الـ pointers كثيرًا مع GORM لتمرير النماذج والـ structs.

```go
var user models.User
database.DB.First(&user, 1) // نمرر pointer ليملأه GORM
```

### 3.7 Slices و Maps و Arrays

**Array:** طول ثابت.

```go
var arr [3]int = [3]int{1, 2, 3}
```

**Slice:** قائمة ديناميكية، تشبه `List` في Dart/Java.

```go
numbers := []int{1, 2, 3}
numbers = append(numbers, 4)
fmt.Println(numbers[0]) // 1
```

**Map:** قاموس، يكافئ `Map` في Dart/Java أو `dict` في Python.

```go
ages := map[string]int{
    "أحمد": 25,
    "سارة": 30,
}
ages["علي"] = 22
fmt.Println(ages["أحمد"])
```

### 3.8 Goroutines و Channels (مفهوم)

**Goroutine:** دالة تعمل بشكل متزامن بسيط جدًا.

```go
func sayHello() {
    fmt.Println("Hello")
}

func main() {
    go sayHello() // تشغيل متزامن
    time.Sleep(time.Second)
}
```

**Channel:** قناة للتواصل بين goroutines.

```go
ch := make(chan string)
go func() {
    ch <- "تم"
}()
msg := <-ch
fmt.Println(msg)
```

في هذا المشروع لا تحتاج لاستخدام goroutines بشكل مباشر في أغلب الـ handlers، لكن من الجيد معرفة المفهوم.

### 3.9 إدارة الأخطاء (لا يوجد try-catch)

Go لا يحتوي على `try/catch`. كل دالة قد تفشل تُرجع `error` كقيمة ثانية.

```go
file, err := os.Open("data.txt")
if err != nil {
    log.Fatal(err)
}
defer file.Close()
```

في Django/Python:

```python
try:
    file = open("data.txt")
except Exception as e:
    print(e)
```

في Go:

```go
if err := doSomething(); err != nil {
    return err
}
```

هذا النمط يظهر في كل handler في المشروع.

### 3.10 Packages والاستيراد

كل مجلد في Go هو package. اسم الحزمة يُكتب أول سطر في كل ملف.

```go
package handlers

import (
    "net/http"
    "github.com/gin-gonic/gin"
    "watt/internal/models"
)
```

- `net/http`: مكتبة قياسية.
- `github.com/gin-gonic/gin`: حزمة خارجية.
- `watt/internal/models`: حزمة داخلية من المشروع.

**الرؤية (Visibility):** في Go، الاسم الذي يبدأ بحرف كبير يكون "مُصدَّر" (exported) أي عام، والاسم الذي يبدأ بحرف صغير يكون خاصًا للحزمة.

```go
type User struct { }   // عام
func getUser() { }     // خاص
```

### 3.11 defer

`defer` يؤجل تنفيذ دالة حتى نهاية الدالة الحالية. يُستخدم غالبًا لإغلاق الموارد.

```go
file, err := os.Open("data.txt")
if err != nil {
    return err
}
defer file.Close()
// ... استخدم file
```

<p dir="rtl">
<b>ملخص سريع:</b> Go تستخدم structs بدل classes، و pointers للمرجعيات، و slices/maps للمجموعات، و لا يوجد try-catch بل نتحقق من <code>error</code> يدويًا. الأسماء التي تبدأ بحرف كبير تكون عامة.
</p>

---

## 4. هندسة مشروع Go

### 4.1 شرح المجلدات

```text
go_backend/
├── cmd/
│   └── server/
│       └── main.go          ← نقطة الدخول
├── internal/
│   ├── config/              ← إعدادات التطبيق
│   ├── database/            ← اتصال GORM + AutoMigrate
│   ├── handlers/            ← منطق استقبال HTTP
│   ├── middleware/          ← Auth, Superuser, CompanyMember
│   ├── models/              ← نماذج GORM + Schemas
│   ├── response/            ← تنسيق الردود الموحّد
│   ├── routes/              ← تسجيل المسارات
│   ├── services/            ← JWT + Django password
│   └── utils/               ← مساعدات عامة
├── docs/                    ← ملفات Swagger المولدة
├── go.mod / go.sum          ← الاعتماديات
└── uploads/                 ← الملفات المرفوعة
```

### 4.2 cmd/server/main.go

هذا الملف هو قلب التطبيق. يبدأ الخادم ويُعدّ الـ router ويُفعّل GoAdmin.

```go
func main() {
    cfg := config.LoadConfig()
    database.Connect(cfg)

    router := gin.Default()
    router.RedirectTrailingSlash = false
    router.RedirectFixedPath = false

    // Initialize GoAdmin
    eng := engine.Default()
    adminPlugin := admin.NewAdmin(admin_tables.Generators)
    // ...

    apiGroup := router.Group("/api")
    v1Group := apiGroup.Group("/v1")
    v1Group.Use(trailingSlashMiddleware())

    v1Group.GET("", root.Welcome)
    v1Group.GET("/docs/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

    routes.SetupUserRoutes(v1Group, cfg)
    routes.SetupCompanyRoutes(v1Group, cfg)
    // ...

    router.Run(":" + cfg.Port)
}
```

> ملاحظة: `trailingSlashMiddleware()` تزيل `/` الزائد من نهاية المسارات حتى يعمل التطبيق مثل Django.

### 4.3 Routes: تسجيل المسارات

افتح `internal/routes/users.go`:

```go
func SetupUserRoutes(rg *gin.RouterGroup, cfg *config.Config) {
    usersGroup := rg.Group("/users")
    h := handlers.NewUserHandler(cfg)

    usersGroup.POST("/login", h.Login)
    usersGroup.POST("/register", h.Register)

    authGroup := usersGroup.Group("")
    authGroup.Use(middleware.AuthMiddleware(cfg))
    {
        authGroup.GET("/profile", h.GetProfile)
    }
}
```

الـ `RouterGroup` يسمح بتجميع المسارات وتطبيق middleware عليها دفعة واحدة.

### 4.4 Handlers: استقبال HTTP

Handlers هي "Views" في Django. مثال من `internal/handlers/users.go`:

```go
func (h *UserHandler) Login(c *gin.Context) {
    var req models.LoginRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        msgUser := "بيانات غير صالحة"
        response.Error(c, http.StatusBadRequest, "Invalid request body", &msgUser)
        return
    }

    var user models.User
    result := database.DB.Where("username = ? OR email = ?", req.Username, req.Username).First(&user)
    if result.Error != nil {
        msgUser := "اسم المستخدم أو كلمة المرور غير صحيحة"
        response.Error(c, http.StatusUnauthorized, "User not found", &msgUser)
        return
    }

    // ... verify password & return token
}
```

- `c *gin.Context`: يحمل الطلب والاستجابة.
- `c.ShouldBindJSON(&req)`: يحول JSON body إلى struct.
- `response.Error/response.Success`: يرسل ردًا موحد الشكل.

### 4.5 Middleware

Middleware هو "طبقة" تعمل قبل الـ handler. ثلاثة أنواع رئيسية في المشروع:

1. **AuthMiddleware:** يتحقق من JWT.
2. **SuperuserMiddleware:** يتحقق أن المستخدم `is_superuser = true`.
3. **CompanyMemberMiddleware:** يتحقق أن المستخدم عضو في الشركة المحددة في `company_id`.

مثال من `internal/middleware/auth.go`:

```go
func AuthMiddleware(cfg *config.Config) gin.HandlerFunc {
    return func(c *gin.Context) {
        authHeader := c.GetHeader("Authorization")
        if authHeader == "" {
            response.Error(c, http.StatusUnauthorized, "Missing Authorization Header", &msgUser)
            c.Abort()
            return
        }
        // ... parse JWT ...
        c.Set("user_id", userID)
        c.Next()
    }
}
```

- `c.Abort()` يوقف سلسلة المعالجة.
- `c.Next()` يسمح للـ handler بالاستمرار.

### 4.6 Models و Schemas

**Models:** تمثل جداول قاعدة البيانات. مثال `internal/models/user.go`:

```go
type User struct {
    ID        uint      `gorm:"primaryKey;column:id"`
    Username  string    `gorm:"column:username;unique;not null"`
    Password  string    `gorm:"column:password;not null"`
    Email     string    `gorm:"column:email;unique;not null"`
    FirstName string    `gorm:"column:first_name"`
    LastName  string    `gorm:"column:last_name"`
    Phone     string    `gorm:"column:phone"`
    CityID    *uint     `gorm:"column:city_id"`
    Image     *string   `gorm:"column:image"`
    IsActive  bool      `gorm:"column:is_active;default:true"`
    IsStaff   bool      `gorm:"column:is_staff;default:false"`
    IsSuperuser bool    `gorm:"column:is_superuser;default:false"`
    LastLogin *time.Time
    DateJoined time.Time
}

func (User) TableName() string {
    return "users"
}
```

> ملاحظة مهمة: تم دمج جدولي `auth_user` و `users_profile` من Django في جدول واحد `users`.

**Schemas:** structs تُستخدم لاستقبال JSON أو إرساله. مثال `internal/models/users_schemas.go`:

```go
type LoginRequest struct {
    Username string `json:"username" binding:"required"`
    Password string `json:"password" binding:"required"`
}

type ProfileOut struct {
    ID       uint    `json:"id"`
    Username string  `json:"username"`
    Email    *string `json:"email"`
}
```

### 4.7 response: تنسيق الردود

`internal/response/response.go` يضمن أن كل رد يتبع الشكل:

```json
{
  "status": 200,
  "message": "Login successful",
  "body": { ... },
  "error": false,
  "message_user": null
}
```

الملف:

```go
type APIResponse struct {
    Status      int         `json:"status"`
    Message     string      `json:"message"`
    Body        interface{} `json:"body"`
    Error       bool        `json:"error"`
    MessageUser *string     `json:"message_user"`
}

func Success(c *gin.Context, status int, message string, body interface{}) {
    c.JSON(status, APIResponse{...})
}

func Error(c *gin.Context, status int, message string, messageUser *string) {
    c.JSON(status, APIResponse{...})
}
```

### 4.8 database و AutoMigrate

`internal/database/db.go` يُنشئ اتصال GORM ويُشغّل `AutoMigrate`:

```go
var DB *gorm.DB

func Connect(cfg *config.Config) {
    if strings.HasSuffix(cfg.DatabaseURL, ".sqlite3") {
        DB, _ = gorm.Open(sqlite.Open(cfg.DatabaseURL), &gorm.Config{})
    } else {
        DB, _ = gorm.Open(mysql.Open(cfg.DatabaseURL), &gorm.Config{})
    }

    DB.AutoMigrate(
        &models.User{},
        &models.Company{},
        &models.Product{},
        // ...
    )
}
```

> ملاحظة: `AutoMigrate` لا يحذف أعمدة؛ يضيف فقط ما ينقص. إذا أردت تعديل عمود موجود، استخدم migrations يدوية.

### 4.9 services/auth

`internal/services/auth.go` يتضمن:

- `VerifyDjangoPassword`: للتحقق من كلمات مرور Django (`pbkdf2_sha256$...`).
- `GenerateDjangoPassword`: لإنشاء هاش متوافق مع Django.
- `GenerateJWT`: لتوليد access/refresh tokens.

```go
func VerifyDjangoPassword(plainPassword, djangoHash string) bool {
    if strings.HasPrefix(djangoHash, "$2a$") {
        err := bcrypt.CompareHashAndPassword([]byte(djangoHash), []byte(plainPassword))
        return err == nil
    }
    // ... pbkdf2_sha256 logic ...
}
```

> ملاحظة: سر JWT الافتراضي مطابق لـ `SECRET_KEY` الافتراضي في Django لضمان توافق التوكنات في بيئة التطوير.

### 4.10 علاقات GORM

GORM يدعم أنواع العلاقات نفسها التي يدعمها Django ORM:

**One-to-One:**

```go
type User struct {
    ID      uint
    Profile Profile `gorm:"foreignKey:UserID"`
}

type Profile struct {
    ID     uint
    UserID uint
}
```

**One-to-Many:**

```go
type Company struct {
    ID      uint
    Members []CompanyMember `gorm:"foreignKey:CompanyID"`
}
```

**Many-to-Many:**

```go
type Product struct {
    ID         uint
    Categories []CompanyCategory `gorm:"many2many:product_company_categories;"`
}
```

**Preload:**

```go
database.DB.Preload("Members").Preload("Members.User").First(&company, id)
```

<p dir="rtl">
<b>ملخص سريع:</b> المشروع مقسّم لحزم واضحة: <code>main.go</code> للتشغيل، <code>routes</code> للمسارات، <code>handlers</code> للمنطق، <code>models</code> للبيانات، <code>middleware</code> للصلاحيات، و <code>response</code> للردود الموحدة. GORM يدعم One-to-One و One-to-Many و Many-to-Many.
</p>

---

## 5. Django Ninja مقابل Go Gin

### 5.1 Router

**Django Ninja:**

```python
from ninja import NinjaAPI
api = NinjaAPI(urls_namespace="api", version="1.0")

@api.get("/users")
def list_users(request):
    return User.objects.all()
```

**Go Gin:**

```go
router := gin.Default()
users := router.Group("/users")
users.GET("", handlers.GetUsers)
```

### 5.2 دورة حياة الطلب

عندما يصل طلب إلى الخادم، يحدث التالي:

1. Gin يستقبل الطلب ويُنشئ `gin.Context`.
2. يمر الطلب عبر الـ middleware المسجلة (مثل AuthMiddleware).
3. يُطابق Router المسار المناسب.
4. ينفذ الـ handler.
5. يرسل الـ handler الرد عبر `response.Success` أو `response.Error`.
6. يمكن للـ middleware ما بعد التنفيذ (post-middleware) أن تُجري عمليات إضافية.

في Django Ninja، تُشبه العملية: middleware → view → response، لكن Gin يفصل Router و Handler بشكل أوضح.

### 5.3 Views ↔ Handlers

**Django:**

```python
def login(request, payload: LoginSchema):
    user = authenticate(...)
    return {"token": token, "user": user}
```

**Go:**

```go
func (h *UserHandler) Login(c *gin.Context) {
    var req models.LoginRequest
    c.ShouldBindJSON(&req)
    // ...
    response.Success(c, http.StatusOK, "Login successful", gin.H{
        "token": access,
        "user": buildProfileOut(&user),
    })
}
```

### 5.4 Models

**Django:**

```python
class User(AbstractUser):
    phone = models.CharField(max_length=20)
```

**Go/GORM:**

```go
type User struct {
    ID       uint   `gorm:"primaryKey"`
    Username string `gorm:"unique;not null"`
    Phone    string
}
```

### 5.5 Serializers ↔ Structs

**Django Ninja Schema:**

```python
class UserOut(Schema):
    id: int
    username: str
```

**Go Struct:**

```go
type UserOut struct {
    ID       uint   `json:"id"`
    Username string `json:"username"`
}
```

### 5.6 Middleware & Permissions

**Django:**

```python
@api.get("/admin/users", auth=AuthBearer(), permissions=[IsSuperuser])
```

**Go:**

```go
adminGroup := router.Group("/admin")
adminGroup.Use(middleware.AuthMiddleware(cfg))
adminGroup.Use(middleware.SuperuserMiddleware())
adminGroup.GET("/users", handlers.GetUsers)
```

### 5.7 Migrations

**Django:**

```bash
python manage.py makemigrations
python manage.py migrate
```

**Go/GORM:**

لا يوجد `makemigrations`. نستخدم `AutoMigrate` عند بدء التشغيل:

```go
DB.AutoMigrate(&models.User{}, &models.Company{})
```

للتعديلات المعقدة، يمكن استخدام ملفات migration بأداة مثل `golang-migrate/migrate`.

<p dir="rtl">
<b>ملخص سريع:</b> Django Ninja يستخدم decorators و ORM خاصًا، بينما Gin يستخدم groups و middleware chains. الـ structs في Go تلعب دور الـ serializers.
</p>

---

## 6. جولة عملية على أقسام المشروع

### 6.1 المصادقة

مسارات المصادقة في `internal/routes/users.go`:

```go
usersGroup.POST("/login", h.Login)
usersGroup.POST("/register", h.Register)
usersGroup.GET("/:username", h.GetUser)
```

والمسارات المحمية:

```go
authGroup := usersGroup.Group("")
authGroup.Use(middleware.AuthMiddleware(cfg))
{
    authGroup.GET("/profile", h.GetProfile)
    authGroup.PUT("/profile", h.UpdateProfile)

    adminGroup := authGroup.Group("")
    adminGroup.Use(middleware.SuperuserMiddleware())
    {
        adminGroup.GET("", h.GetUsers)
    }
}
```

في `Login`، بعد التحقق من كلمة المرور بـ `VerifyDjangoPassword`، يُولّد `GenerateJWT` التوكن:

```go
access, _, err := services.GenerateJWT(&user, h.cfg)
response.Success(c, http.StatusOK, "Login successful", gin.H{
    "token": access,
    "user":  buildProfileOut(&user),
})
```

### 6.2 الشركات والأعضاء

نموذج `Company` يحتوي على علاقات كثيرة. انظر `internal/models/company.go`.

تسجيل شركة جديدة في `internal/handlers/companies/public.go`:

```go
func RegisterCompany(c *gin.Context) {
    userID, exists := c.Get("user_id")
    // ...
    tx := database.DB.Begin()
    tx.Create(&company)
    tx.Create(&models.CompanyMember{
        CompanyID: company.ID,
        UserID:    userID.(uint),
        Role:      "admin",
    })
    tx.Commit()
}
```

> ملاحظة: يستخدم الكود `transaction` لضمان إنشاء الشركة والعضو معًا أو الرجوع عنهما معًا.

CompanyMemberMiddleware يتحقق من صلاحية المستخدم:

```go
err := database.DB.Where("company_id = ? AND user_id = ?", companyID, userID).First(&member).Error
if err != nil {
    response.Error(c, http.StatusForbidden, "Forbidden", &msgUser)
    c.Abort()
    return
}
```

### 6.3 المتجر والطلبات

ملف `internal/models/shop.go` يحتوي على `Product` و `Order` و `OrderItem` و `Customer` و `Supplier`.

مثال على علاقة One-to-Many:

```go
type Order struct {
    ID      uint        `gorm:"primaryKey"`
    Items   []OrderItem `gorm:"foreignKey:OrderID"`
}
```

عند جلب طلب مع عناصره:

```go
database.DB.Preload("Items").First(&order, orderID)
```

### 6.4 العروض والأنظمة

- **Offers:** `internal/models/offers.go` و `internal/handlers/offers/`
- **Systems:** `internal/models/system.go` و `internal/handlers/systems/`

تستخدم هذه الأقسام نفس النمط: Models → Schemas → Handlers → Routes.

### 6.5 المحاسبة

ملفات المحاسبة في `internal/handlers/accounting/` و `internal/models/accounting.go`:

- `Account` (الحسابات)
- `JournalEntry` و `JournalEntryLine` (القيود اليومية)
- `Invoice` و `Bill` و `Payment`

### 6.6 المجتمع والإشعارات

**Community:** `internal/handlers/community/posts.go` يتعامل مع المنشورات والتعليقات.

```go
func ListPosts(c *gin.Context) {
    page, pageSize := parsePagination(c)
    query := database.DB.Model(&models.Post{}).Preload("Author").Preload("Company")
    // ... filter + pagination
}
```

**Notifications:** `internal/handlers/notifications/` يتعامل مع تسجيل أجهزة FCM والسجل.

> ملاحظة: التوصيل الفعلي لـ FCM غير مربوط في Go حاليًا؛ يتم فقط تخزين السجلات.

<p dir="rtl">
<b>ملخص سريع:</b> كل قسم يتبع النمط نفسه: Models → Schemas → Handlers → Routes. الصلاحيات تُدار عبر Middleware. العلاقات بين الجداول تُعرّف بـ tags في GORM.
</p>

---

## 7. دليل عملي: أضف feature جديدة

لنفترض أننا نريد إضافة **ميزة "الأخبار" (News)** التي تحتوي على عنوان ومحتوى وتاريخ نشر.

### 7.1 تعريف Model

أنشئ أو أضف إلى `internal/models/news.go`:

```go
package models

import "time"

type News struct {
    ID        uint      `gorm:"primaryKey;autoIncrement" json:"id"`
    Title     string    `gorm:"type:varchar(255);not null" json:"title"`
    Content   string    `gorm:"type:text;not null" json:"content"`
    IsActive  bool      `gorm:"default:true" json:"is_active"`
    CreatedAt time.Time `gorm:"autoCreateTime" json:"created_at"`
    UpdatedAt time.Time `gorm:"autoUpdateTime" json:"updated_at"`
}
```

### 7.2 تعريف Schema

في `internal/models/news_schemas.go`:

```go
package models

type NewsCreateSchema struct {
    Title    string `json:"title" binding:"required"`
    Content  string `json:"content" binding:"required"`
    IsActive *bool  `json:"is_active"`
}

type NewsOut struct {
    ID        uint      `json:"id"`
    Title     string    `json:"title"`
    Content   string    `json:"content"`
    IsActive  bool      `json:"is_active"`
    CreatedAt time.Time `json:"created_at"`
}
```

### 7.3 كتابة Handler

أنشئ `internal/handlers/news/news.go`:

```go
package news

import (
    "net/http"
    "github.com/gin-gonic/gin"
    "watt/internal/database"
    "watt/internal/models"
    "watt/internal/response"
)

func ListNews(c *gin.Context) {
    var items []models.News
    database.DB.Where("is_active = ?", true).Order("created_at desc").Find(&items)
    response.Success(c, http.StatusOK, "News retrieved", items)
}

func CreateNews(c *gin.Context) {
    var req models.NewsCreateSchema
    if err := c.ShouldBindJSON(&req); err != nil {
        msgUser := "بيانات غير صالحة"
        response.Error(c, http.StatusBadRequest, err.Error(), &msgUser)
        return
    }

    news := models.News{
        Title:    req.Title,
        Content:  req.Content,
        IsActive: req.IsActive == nil || *req.IsActive,
    }
    database.DB.Create(&news)
    response.Success(c, http.StatusCreated, "News created", news)
}

func UpdateNews(c *gin.Context) {
    id, _ := strconv.Atoi(c.Param("id"))
    var req models.NewsCreateSchema
    if err := c.ShouldBindJSON(&req); err != nil {
        msgUser := "بيانات غير صالحة"
        response.Error(c, http.StatusBadRequest, err.Error(), &msgUser)
        return
    }

    var news models.News
    if err := database.DB.First(&news, id).Error; err != nil {
        response.Error(c, http.StatusNotFound, "News not found", nil)
        return
    }

    news.Title = req.Title
    news.Content = req.Content
    if req.IsActive != nil {
        news.IsActive = *req.IsActive
    }
    database.DB.Save(&news)
    response.Success(c, http.StatusOK, "News updated", news)
}

func DeleteNews(c *gin.Context) {
    id, _ := strconv.Atoi(c.Param("id"))
    if err := database.DB.Delete(&models.News{}, id).Error; err != nil {
        response.Error(c, http.StatusInternalServerError, "Failed to delete", nil)
        return
    }
    response.Success(c, http.StatusOK, "News deleted", nil)
}
```

### 7.4 تسجيل Route

أنشئ `internal/routes/news.go`:

```go
package routes

import (
    "github.com/gin-gonic/gin"
    "watt/internal/config"
    "watt/internal/handlers/news"
    "watt/internal/middleware"
)

func SetupNewsRoutes(router *gin.RouterGroup, cfg *config.Config) {
    router.GET("/news", news.ListNews)

    admin := router.Group("/admin/news")
    admin.Use(middleware.AuthMiddleware(cfg))
    admin.Use(middleware.SuperuserMiddleware())
    {
        admin.POST("", news.CreateNews)
        admin.PUT("/:id", news.UpdateNews)
        admin.DELETE("/:id", news.DeleteNews)
    }
}
```

ثم سجّلها في `cmd/server/main.go`:

```go
routes.SetupNewsRoutes(v1Group, cfg)
```

### 7.5 AutoMigrate

أضف `&models.News{}` إلى `database.DB.AutoMigrate(...)` في `internal/database/db.go`.

### 7.6 Swagger

أضف تعليقات Swagger فوق الـ handler:

```go
// ListNews handles GET /api/v1/news
// @Summary List active news
// @Tags News
// @Produce json
// @Success 200 {object} response.APIResponse
// @Router /news [get]
func ListNews(c *gin.Context) { ... }
```

ثم شغّل:

```bash
swag init -g cmd/server/main.go
```

### 7.7 اختبار الـ Endpoint

```bash
curl http://localhost:8080/api/v1/news
```

<p dir="rtl">
<b>ملخص سريع:</b> لإضافة feature جديد: أنشئ Model، ثم Schema، ثم Handler، ثم Route، ثم أضفه إلى AutoMigrate و main.go، وأخيرًا شغّل <code>swag init</code>.
</p>

---

## 8. الأخطاء الشائعة والـ Debugging

### 8.1 401/403 وصلاحيات الشركة

- **401 Unauthorized:** غالبًا لأن التوكن منتهي أو غير موجود. تأكد من إرسال `Authorization: Bearer <token>`.
- **403 Forbidden:** المستخدم مسجّل الدخول لكنه ليس عضوًا في الشركة. تأكد من تسجيل الشركة أو ضم المستخدم إليها.

### 8.2 nil pointer dereference

يحدث عند محاولة الوصول لـ pointer غير مهيأ:

```go
var user *models.User
fmt.Println(user.Username) // runtime error
```

الحل:

```go
if user != nil {
    fmt.Println(user.Username)
}
```

### 8.3 GORM preload

إذا كانت العلاقة فارغة في JSON، تأكد من استخدام `Preload`:

```go
database.DB.Preload("Items").Preload("Customer").First(&order, id)
```

### 8.4 Trailing slash

Django يقبل `/users/` و `/users` كمسار واحد. في Gin هذا يختلف. المشروع يحل المشكلة عبر `trailingSlashMiddleware()` و `RedirectTrailingSlash = false`.

### 8.5 Swagger لا يتحدث

بعد أي تعديل على التعليقات، شغّل:

```bash
swag init -g cmd/server/main.go
```

ثم أعد تشغيل الخادم.

### 8.6 type assertion غير آمن

عند استخراج قيمة من `gin.Context` بـ `c.Get("user_id")`، يجب التأكد من نوعها:

```go
userID, exists := c.Get("user_id")
if !exists {
    return
}
id, ok := userID.(uint)
if !ok {
    return
}
```

### 8.7 import cycle

إذا حاولت استيراد حزمة تستيرد الحزمة الحالية، تحصل على خطأ "import cycle not allowed". الحل: نقل الكود المشترك إلى حزمة ثالثة.

### 8.8 JSON marshaling

إذا كان `Body` في الرد يحتوي على channel أو function، سيفشل JSON encoding. تأكد من أن كل القيم قابلة للتحويل إلى JSON.

<p dir="rtl">
<b>ملخص سريع:</b> تحقق دائمًا من التوكن للـ 401، ومن عضوية الشركة للـ 403، ومن الـ pointers قبل استخدامها، ومن <code>Preload</code> للعلاقات، ولا تنس <code>swag init</code> بعد تعديل Swagger.
</p>

---

## 9. تمارين

1. اكتب دالة Go ترجع مجموع عددين صحيحين.
2. اكتب struct باسم `Book` يحتوي على `Title` و `Author` و `Pages`.
3. اشرح الفرق بين `var x int` و `x := 10`.
4. حوّل هذا الكود من Python إلى Go:
   ```python
   for i in range(5):
       print(i)
   ```
5. اكتب دالة Go تستقبل slice من الأعداد وتُرجع أكبر قيمة وخطأ إذا كان فارغًا.
6. أي package يمثل نقطة دخول التطبيق في Go؟
7. ما الفرق بين Model و Schema في المشروع؟
8. كيف تتحقق مما إذا كان المستخدم يحمل توكن صالحًا في Gin؟
9. ما وظيفة `c.ShouldBindJSON(&req)`؟
10. اكتب كودًا لإنشاء شركة جديدة مع عضو admin في transaction واحدة.
11. لماذا نستخدم `Preload` في GORM؟
12. ما هي المشكلة في الكود التالي وكيف تُصلحه؟
    ```go
    var user *models.User
    fmt.Println(user.Email)
    ```
13. كيف تُعيد توليد Swagger بعد تعديل handler؟
14. ما الفرق بين `c.Abort()` و `c.Next()` في middleware؟
15. اكتب route group محمي بـ AuthMiddleware و SuperuserMiddleware.

---

## 10. إجابات التمارين

<details>
<summary>إجابة السؤال 1</summary>

```go
func sum(a, b int) int {
    return a + b
}
```

</details>

<details>
<summary>إجابة السؤال 2</summary>

```go
type Book struct {
    Title  string
    Author string
    Pages  int
}
```

</details>

<details>
<summary>إجابة السؤال 3</summary>

- `var x int`: يُعلن عن متغير من نوع int بدون قيمة أولية (افتراضيًا 0).
- `x := 10`: يُعلن عن متغير ويستنتج نوعه من القيمة (int هنا). لا يمكن استخدامه خارج دالة.

</details>

<details>
<summary>إجابة السؤال 4</summary>

```go
for i := 0; i < 5; i++ {
    fmt.Println(i)
}
```

</details>

<details>
<summary>إجابة السؤال 5</summary>

```go
func maxValue(nums []int) (int, error) {
    if len(nums) == 0 {
        return 0, fmt.Errorf("empty slice")
    }
    max := nums[0]
    for _, n := range nums {
        if n > max {
            max = n
        }
    }
    return max, nil
}
```

</details>

<details>
<summary>إجابة السؤال 6</summary>

`package main` في `cmd/server/main.go`.

</details>

<details>
<summary>إجابة السؤال 7</summary>

- **Model:** يمثل جدول قاعدة البيانات ويحتوي على tags لـ GORM.
- **Schema:** يمثل شكل JSON المُستلم أو المُرسل، ويحتوي على tags لـ `json` و `binding`.

</details>

<details>
<summary>إجابة السؤال 8</summary>

عبر `middleware.AuthMiddleware(cfg)` الذي يفك تشفير JWT ويضع `user_id` في context.

</details>

<details>
<summary>إجابة السؤال 9</summary>

تقرأ body الطلب كـ JSON وتحاول تعبئته في الـ struct المُمرر. إذا فشلت، تُرجع error.

</details>

<details>
<summary>إجابة السؤال 10</summary>

```go
tx := database.DB.Begin()
if err := tx.Create(&company).Error; err != nil {
    tx.Rollback()
    return
}
member := models.CompanyMember{
    CompanyID: company.ID,
    UserID:    userID.(uint),
    Role:      "admin",
}
if err := tx.Create(&member).Error; err != nil {
    tx.Rollback()
    return
}
tx.Commit()
```

</details>

<details>
<summary>إجابة السؤال 11</summary>

لتحميل العلاقات (relations) مع السجل الرئيسي في استعلام واحد بدلًا من إجراء استعلامات متعددة.

</details>

<details>
<summary>إجابة السؤال 12</summary>

`user` هو `nil` pointer. الحل:

```go
if user != nil {
    fmt.Println(user.Email)
}
```

</details>

<details>
<summary>إجابة السؤال 13</summary>

```bash
swag init -g cmd/server/main.go
```

</details>

<details>
<summary>إجابة السؤال 14</summary>

- `c.Next()`: يكمل إلى الـ handler أو الـ middleware التالي.
- `c.Abort()`: يوقف السلسلة ولا يدع الـ handler ينفذ.

</details>

<details>
<summary>إجابة السؤال 15</summary>

```go
admin := router.Group("/admin")
admin.Use(middleware.AuthMiddleware(cfg))
admin.Use(middleware.SuperuserMiddleware())
{
    admin.GET("/users", handlers.GetUsers)
}
```

</details>

---

## 11. ملحقات

### 11.1 قائمة أهم الـ endpoints

بناءً على تقرير `api_migration_comparison.md`، تم نقل 227 endpoint من Django Ninja إلى Go/Gin.

| القسم | المسار الأساسي | أمثلة |
|-------|----------------|-------|
| Users | `/api/v1/users/*` | `/login`, `/register`, `/profile` |
| Companies | `/api/v1/companies/*` | `/register`, `/:company_id/summary` |
| Public | `/api/v1/public/companies/*` | `/`, `/:company_id` |
| Admin | `/api/v1/admin/*` | `/companies`, `/config`, `/currencies` |
| Shop | `/api/v1/shop/*` | `/products`, `/orders` |
| Accounting | `/api/v1/accounting/*` | `/accounts`, `/invoices`, `/payments` |
| Offers | `/api/v1/offers/*` | `/`, `/:offer_id/requests` |
| Systems | `/api/v1/systems/*` | `/`, `/:system_id` |
| Community | `/api/v1/community/*` | `/posts/`, `/comments` |
| Notifications | `/api/v1/notification/*` | `/subscribe`, `/history` |

### 11.2 مصادر للتعمق

- [A Tour of Go](https://go.dev/tour/) — دورة Go الرسمية.
- [Effective Go](https://go.dev/doc/effective_go) — أفضل الممارسات.
- [Gin Documentation](https://gin-gonic.com/docs/) — توثيق إطار Gin.
- [GORM Guides](https://gorm.io/docs/) — توثيق ORM.
- [go by example](https://gobyexample.com/) — أمثلة عملية.

### 11.3 قاموس المصطلحات

| المصطلح | الشرح |
|---------|-------|
| Handler | دالة تستقبل طلب HTTP وتُرجع ردًا. |
| Middleware | طبقة تُنفذ قبل/بعد الـ handler. |
| Router | يحدد أي handler يُنفذ لكل مسار. |
| Model | struct يمثل جدول قاعدة البيانات. |
| Schema | struct يحدد شكل JSON المُستلم أو المُرسل. |
| GORM | ORM لـ Go يُدار قواعد البيانات. |
| Gin | إطار HTTP لـ Go. |
| JWT | توكن للمصادقة. |
| AutoMigrate | ميزة GORM لإنشاء/تحديث الجداول تلقائيًا. |
| Goroutine | دالة تعمل بشكل متزامن في Go. |

---

<p dir="rtl">
<b>ختامًا:</b> Go لغة بسيطة وقوية. بفهمك للبنية العامة في هذا المشروع—Models و Schemas و Handlers و Routes و Middleware و Response—يمكنك الآن قراءة أي جزء من الكود، وتعديله، وإضافة ميزات جديدة، والمساهمة في إتمام الهجرة الكاملة من Django إلى Go.
</p>

## 12. نشر المشروع باستخدام Docker

في هذا القسم سنوضح كيفية تشغيل مشروع **Watt** على جهازك أو على سيرفر محلي باستخدام Docker. التشكيلة تحتوي على ثلاث خدمات:

- **MariaDB**: قاعدة البيانات.
- **Backend (Go)**: السيرفر المكتوب بـ Go.
- **Caddy**: البروكسي العكسي (Reverse Proxy) الذي يوفر HTTPS محليًا.

### 12.1 ما هو Docker؟

Docker أداة تسمح لك بتشغيل برامجك داخل "حاويات" (Containers) معزولة. بدل ما تنصب Go وMariaDB وCaddy يدويًا على جهازك، نكتب ملفات توصيف وDocker ينصب ويشغل كل شيء بنقرة واحدة.

> **الفائدة:** نفس البيئة تعمل على جهازك وعلى السيرفر بدون اختلاف في الإعدادات.

### 12.2 متطلبات قبل النشر

1. تثبيت [Docker Desktop](https://docs.docker.com/get-docker/) (Windows/Mac) أو Docker Engine (Linux).
2. تثبيت [Docker Compose](https://docs.docker.com/compose/install/) (يأتي مدمجًا مع Docker Desktop).
3. معرفة IP الجهاز على الشبكة المحلية (مثال: `192.168.1.107`).
4. نسخ المشروع على الجهاز:
   ```bash
   cd /Users/rasol/DevsTools/codes/watt
   ```

### 12.3 تحضير ملف البيئة .env

في جذر المشروع يوجد ملف `.env.example`. انسخه إلى ملف جديد باسم `.env` وعدل القيم الحساسة:

```bash
cp .env.example .env
```

أهم المتغيرات التي يجب تغييرها:

| المتغير | الوصف | مثال |
|---------|-------|------|
| `LOCAL_IP` | IP الجهاز على الشبكة المحلية | `192.168.1.107` |
| `JWT_SECRET` | مفتاح سري لتوقيع توكن JWT (32 حرف على الأقل) | `change-me-to-long-random-string` |
| `ADMIN_COOKIE_SECRET` | مفتاح سري لجلسات الأدمن | `change-me-to-another-long-random-string` |
| `MARIADB_ROOT_PASSWORD` | كلمة سر root لـ MariaDB | `watt_root_password` |
| `MARIADB_PASSWORD` | كلمة سر مستخدم قاعدة البيانات | `watt_password` |
| `EMAIL_HOST_PASSWORD` | كلمة سر بريد التطبيق | `your-google-app-password` |
| `FCM_SERVICE_ACCOUNT_FILE` | مسار ملف حساب Firebase | `/app/config/fcm-service-account.json` |

> **تنبيه:** ضع ملف `fcm-service-account.json` داخل مجلد `config/` في جذر المشروع. Docker يربط هذا المجلد مع الحاوية للقراءة فقط.

### 12.4 شرح ملفات Docker

| الملف | الوظيفة |
|-------|---------|
| `go_backend/Dockerfile` | يصف كيفية بناء صورة Backend Go: يثبت الاعتماديات، يبني البرنامج، وينسخ الملفات الثابتة. |
| `docker-compose.yml` | يربط الخدمات الثلاث معًا: MariaDB وBackend وCaddy. |
| `Caddyfile` | إعداد Caddy: يحول HTTP إلى HTTPS ويضيف Headers أمنية ويوجه الطلبات إلى Backend. |
| `scripts/deploy.sh` | سكربت واحد يشغل كل شيء. |
| `scripts/backup-db.sh` | يأخذ نسخة احتياطية من MariaDB. |

### 12.5 خطوات التشغيل أول مرة

**الخطوة 1:** تأكد من وجود ملف `.env`:

```bash
cd /Users/rasol/DevsTools/codes/watt
ls -la .env
```

**الخطوة 2:** شغّل سكربت النشر:

```bash
./scripts/deploy.sh
```

السكربت سيقوم بما يلي:

1. يحمل آخر إصدار من صور MariaDB وCaddy.
2. يبني صورة Backend من الكود الحالي.
3. ينشئ المجلدات `uploads/`, `data/`, `config/`.
4. يشغل الخدمات في الخلفية.
5. يعرض حالة الحاويات.

**الخطوة 3:** انتظر 10-20 ثانية ثم افتح المتصفح:

```
https://192.168.1.107
```

> **تنبيه المتصفح:** بما أن الشهادة موقعة ذاتيًا (Self-signed)، سيطلب المتصفح تأكيدك. اضغط على "Advanced" ثم "Proceed" أو "Accept the Risk and Continue".

**الخطوة 4:** تحقق من صحة الخدمات:

```bash
docker compose ps
```

يجب أن ترى ثلاث حاويات بحالة `Up (healthy)` أو `Up`.

### 12.6 الأوامر المفيدة بعد التشغيل

| الأمر | الوظيفة |
|-------|---------|
| `docker compose logs -f` | مشاهدة السجلات (Logs) لكل الخدمات. |
| `docker compose logs -f backend` | مشاهدة سجلات Backend فقط. |
| `docker compose down` | إيقاف وحذف الحاويات (البيانات تبقى محفوظة). |
| `docker compose up -d` | تشغيل الحاويات من دون بناء. |
| `docker compose up -d --build` | إعادة بناء Backend وتشغيله (بعد تعديل الكود). |
| `docker compose exec mariadb mariadb -u root -p` | الدخول إلى قاعدة البيانات يدويًا. |
| `docker compose exec backend /bin/sh` | فتح طرفية داخل حاوية Backend. |

### 12.7 نسخ احتياطي لقاعدة البيانات

لأخذ نسخة احتياطية من MariaDB:

```bash
./scripts/backup-db.sh
```

سيُنشأ ملف داخل مجلد `backups/` بصيغة:

```bash
backups/watt_db_20250716_120000.sql
```

لاستعادة نسخة احتياطية:

```bash
docker compose exec -i mariadb mariadb -u root -p'watt_root_password' watt < backups/watt_db_20250716_120000.sql
```

### 12.8 مشاكل شائعة وحلولها

| المشكلة | الحل |
|---------|------|
| `Error: .env file not found` | تأكد من نسخ `.env.example` إلى `.env`. |
| `Connection refused` على `/api/v1/health` | انتظر قليلًا ثم أعد التشغيل: `docker compose restart backend`. |
| MariaDB لا تبدأ | تأكد من عدم وجود خدمة MariaDB أخرى تشغل المنفذ 3306 على الجهاز. |
| لا يمكن الوصول من جهاز آخر على الشبكة | تأكد من أن جدار الحماية (Firewall) يسمح بالمنفذين 80 و 443. |
| شهادة HTTPS غير موثوقة | طبيعي للـ IP المحلي؛ اضغط "Proceed" في المتصفح. |
| تعديل الكود لم ينعكس | يجب إعادة البناء: `docker compose up -d --build`. |

### 12.9 وضع التطوير HTTP فقط

في بيئة التطوير قد تواجه مشكلة مع شهادة HTTPS الموقعة ذاتيًا (Self-signed) خاصةً عند الاختبار من المتصفح أو من أجهزة أخرى على الشبكة. لذلك وفرنا وضع تطوير يعمل بـ HTTP فقط ويفتح منفذ Backend مباشرة على الجهاز.

**ملفات الوضع التطويري:**

| الملف | الوظيفة |
|-------|---------|
| `docker-compose.dev.yml` | يفتح المنفذ `8080:8080` للـ Backend ويستخدم `Caddyfile.dev`. |
| `Caddyfile.dev` | يخدم المشروع عبر HTTP فقط بدون إعادة توجيه إلى HTTPS. |
| `scripts/deploy-dev.sh` | سكربت تشغيل وضع التطوير. |

**تشغيل وضع التطوير:**

```bash
./scripts/deploy-dev.sh
```

أو يدويًا:

```bash
docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d --build
```

**روابط الاختبار في وضع التطوير:**

| الرابط | الوصف |
|--------|-------|
| `http://192.168.1.100:8080/api/v1/health` | فحص صحة Backend مباشرة. |
| `http://192.168.1.100:8080/admin/login` | صفحة تسجيل دخول الأدمن. |
| `http://192.168.1.100/admin/login` | نفس الصفحة عبر Caddy HTTP. |

> **تنبيه:** لا تستخدم وضع HTTP إلا في الشبكة المحلية أثناء التطوير. في الإنتاج استخدم `./scripts/deploy.sh` مع HTTPS.

**التبديل إلى الإنتاج (HTTPS):**

```bash
docker compose -f docker-compose.yml -f docker-compose.dev.yml down
./scripts/deploy.sh
```

**عند شراء دومين لاحقًا:**

1. حدّث متغير `LOCAL_IP` أو أضف `DOMAIN=example.com` في ملف `.env`.
2. عدّل `Caddyfile` ليستخدم الدومين بدل IP:
   ```text
   example.com:443 {
       tls your-email@example.com
       reverse_proxy backend:8080
   }
   ```
3. أعد تشغيل: `./scripts/deploy.sh`.

