# 📱 Flutter Responsive System - README

```markdown
# 📱 Flutter Responsive System
### نظام متكامل للتصميم المتجاوب - يدعم جميع الأجهزة

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-green.svg)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-purple.svg)](LICENSE)

---

## 📋 المحتويات

- [🎯 نظرة عامة](#-نظرة-عامة)
- [✨ المميزات](#-المميزات)
- [📁 هيكل الملفات](#-هيكل-الملفات)
- [🚀 التثبيت](#-التثبيت)
- [📱 الأجهزة المدعومة](#-الأجهزة-المدعومة)
- [📐 نقاط التحول (Breakpoints)](#-نقاط-التحول-breakpoints)
- [🔧 الاستخدام](#-الاستخدام)
  - [الاستخدام الأساسي](#1-الاستخدام-الأساسي)
  - [Extensions](#2-extensions)
  - [Responsive Widgets](#3-responsive-widgets)
  - [Responsive Utils](#4-responsive-utils)
  - [App Dimensions](#5-app-dimensions)
  - [App Typography](#6-app-typography)
- [📊 جداول المقاسات](#-جداول-المقاسات)
- [💡 أمثلة عملية](#-أمثلة-عملية)
- [✅ Best Practices](#-best-practices)
- [❓ FAQ](#-faq)

---

## 🎯 نظرة عامة

نظام Responsive متكامل ومتطور لتطبيقات Flutter، يوفر تحجيم تلقائي وذكي لجميع العناصر (نصوص، أيقونات، مسافات، أبعاد) بناءً على حجم الشاشة ونوع الجهاز.

### 🎨 المبدأ الأساسي

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│   📱 Mobile Small    →  Scale: 0.85 - 1.0                      │
│   📱 Mobile Medium   →  Scale: 0.90 - 1.05                     │
│   📱 Mobile Large    →  Scale: 0.95 - 1.10   ← Design Base     │
│   📱 Mobile XLarge   →  Scale: 1.0  - 1.15                     │
│   📱 Tablet Small    →  Scale: 1.0  - 1.20                     │
│   📱 Tablet Medium   →  Scale: 1.05 - 1.25                     │
│   📱 Tablet Large    →  Scale: 1.10 - 1.30                     │
│   📱 Tablet XLarge   →  Scale: 1.15 - 1.35                     │
│   🖥️ Desktop         →  Scale: 1.20 - 1.50                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## ✨ المميزات

| الميزة | الوصف |
|--------|-------|
| 🎯 **تحجيم ذكي** | تحجيم تلقائي بناءً على نوع الجهاز وحجم الشاشة |
| 📱 **دعم شامل** | يدعم جميع أحجام الموبايل، التابلت، الآيباد، والديسكتوب |
| 🔄 **دعم Orientation** | يتكيف مع الـ Portrait والـ Landscape |
| 📏 **حدود آمنة** | Scale factors محدودة لتجنب التشوهات |
| 🎨 **Typography موحد** | نظام خطوط متجاوب ومتناسق |
| 📦 **Widgets جاهزة** | مجموعة Widgets متجاوبة جاهزة للاستخدام |
| ⚡ **Extensions سهلة** | Extensions بسيطة للاستخدام السريع |
| 📊 **Grid System** | نظام Grid متكيف حسب حجم الشاشة |
| 🔧 **قابل للتخصيص** | يمكن تعديل جميع القيم حسب الحاجة |

---

## 📁 هيكل الملفات

```
lib/
└── core/
└── responsive/
├── responsive.dart              # ملف التصدير الرئيسي
├── responsive_config.dart       # إعدادات الأجهزة والـ Breakpoints
├── responsive_utils.dart        # الأدوات والحسابات الأساسية
├── responsive_widgets.dart      # الـ Widgets المتجاوبة
└── responsive_dimensions.dart   # المقاسات والـ Typography
```

### 📄 ملف التصدير الرئيسي (responsive.dart)

```dart
// lib/core/responsive/responsive.dart

export 'responsive_config.dart';
export 'responsive_utils.dart';
export 'responsive_widgets.dart';
export 'responsive_dimensions.dart';
```

---

## 🚀 التثبيت

### 1️⃣ إنشاء المجلد والملفات

```bash
mkdir -p lib/core/responsive
```

### 2️⃣ نسخ الملفات

انسخ الملفات الأربعة إلى المجلد:
- `responsive_config.dart`
- `responsive_utils.dart`
- `responsive_widgets.dart`
- `responsive_dimensions.dart`

### 3️⃣ إنشاء ملف التصدير

```dart
// lib/core/responsive/responsive.dart
export 'responsive_config.dart';
export 'responsive_utils.dart';
export 'responsive_widgets.dart';
export 'responsive_dimensions.dart';
```

### 4️⃣ الاستيراد في مشروعك

```dart
import 'package:your_app/core/responsive/responsive.dart';
```

---

## 📱 الأجهزة المدعومة

### 📱 الهواتف (Mobile)

| النوع | نطاق العرض | أمثلة الأجهزة |
|-------|-----------|---------------|
| `mobileSmall` | < 350px | iPhone SE, iPhone 5, Android صغير |
| `mobileMedium` | 350-395px | iPhone 8, iPhone 7, Android متوسط |
| `mobileLarge` | 395-428px | iPhone 14 Pro, Galaxy S23, Pixel 7 |
| `mobileXLarge` | 428-600px | iPhone 14 Pro Max, Galaxy Ultra |

### 📱 التابلت (Tablet)

| النوع | نطاق العرض | أمثلة الأجهزة |
|-------|-----------|---------------|
| `tabletSmall` | 600-768px | iPad Mini, Galaxy Tab A |
| `tabletMedium` | 768-834px | iPad Air, Galaxy Tab S |
| `tabletLarge` | 834-1024px | iPad Pro 11" |
| `tabletXLarge` | 1024-1280px | iPad Pro 12.9" |

### 🖥️ الديسكتوب (Desktop)

| النوع | نطاق العرض | أمثلة الأجهزة |
|-------|-----------|---------------|
| `desktop` | > 1280px | MacBook, Windows PC |

---

## 📐 نقاط التحول (Breakpoints)

```dart
class ResponsiveConfig {
  static const double mobileSmall   = 320;   // iPhone SE
  static const double mobileMedium  = 375;   // iPhone 8
  static const double mobileLarge   = 414;   // iPhone 12/13/14
  static const double mobileXLarge  = 428;   // iPhone Pro Max
  static const double tabletSmall   = 600;   // iPad Mini
  static const double tabletMedium  = 768;   // iPad
  static const double tabletLarge   = 834;   // iPad Pro 11"
  static const double tabletXLarge  = 1024;  // iPad Pro 12.9"
  static const double desktopSmall  = 1280;  // Laptop
  static const double desktopMedium = 1440;  // Desktop
  static const double desktopLarge  = 1920;  // Large Desktop
}
```

---

## 🔧 الاستخدام

### 1. الاستخدام الأساسي

```dart
import 'package:your_app/core/responsive/responsive.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      // العرض المتجاوب
      width: ResponsiveUtils.width(context, 300),
      
      // الارتفاع المتجاوب
      height: ResponsiveUtils.height(context, 200),
      
      // المسافات المتجاوبة
      padding: ResponsiveUtils.paddingAll(context, 16),
      
      // الزوايا المتجاوبة
      decoration: BoxDecoration(
        borderRadius: ResponsiveUtils.borderRadius(context, 12),
      ),
      
      child: Text(
        'مرحباً',
        style: TextStyle(
          // حجم الخط المتجاوب
          fontSize: ResponsiveUtils.font(context, 18),
        ),
      ),
    );
  }
}
```

---

### 2. Extensions

طريقة أسهل وأسرع للاستخدام:

```dart
import 'package:your_app/core/responsive/responsive.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300.w(context),      // Width
      height: 200.h(context),     // Height
      padding: EdgeInsets.all(16.s(context)),  // Spacing
      
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r(context)),  // Radius
      ),
      
      child: Column(
        children: [
          Icon(
            Icons.home,
            size: 24.ic(context),  // Icon size
          ),
          
          SizedBox(height: 8.s(context)),  // Spacing
          
          Text(
            'مرحباً',
            style: TextStyle(
              fontSize: 18.sp(context),  // Font size
            ),
          ),
        ],
      ),
    );
  }
}
```

#### 📋 جدول Extensions

| Extension | الوظيفة | مثال |
|-----------|---------|------|
| `.w(context)` | تحجيم العرض | `100.w(context)` |
| `.h(context)` | تحجيم الارتفاع | `50.h(context)` |
| `.sp(context)` | تحجيم الخط | `16.sp(context)` |
| `.s(context)` | تحجيم المسافات | `20.s(context)` |
| `.ic(context)` | تحجيم الأيقونات | `24.ic(context)` |
| `.r(context)` | تحجيم الزوايا | `12.r(context)` |
| `.sz(context)` | تحجيم مربع | `50.sz(context)` |

---

### 3. Responsive Widgets

#### 📦 ResponsiveContainer

```dart
ResponsiveContainer(
  width: 300,
  height: 200,
  padding: EdgeInsets.all(16),
  margin: EdgeInsets.symmetric(horizontal: 20),
  centerOnLargeScreens: true,  // توسيط على الشاشات الكبيرة
  maxWidth: 600,
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
  ),
  child: YourWidget(),
)
```

#### 📝 ResponsiveText

```dart
ResponsiveText(
  'مرحباً بك في التطبيق',
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: Colors.black,
  textAlign: TextAlign.center,
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
)
```

#### 🎨 ResponsiveIcon

```dart
ResponsiveIcon(
  Icons.home,
  size: 32,
  color: Colors.blue,
)
```

#### 📏 ResponsiveSizedBox

```dart
// مسافة أفقية
ResponsiveSizedBox.width(16),

// مسافة عمودية
ResponsiveSizedBox.height(24),

// مربع
ResponsiveSizedBox.square(50, child: YourWidget()),

// مخصص
ResponsiveSizedBox(width: 100, height: 50),
```

#### 🔘 ResponsiveButton

```dart
ResponsiveButton(
  text: 'تسجيل الدخول',
  onPressed: () {},
  height: 56,
  fontSize: 16,
  backgroundColor: Colors.blue,
  textColor: Colors.white,
  borderRadius: 12,
  expand: true,  // يملأ العرض المتاح
  isLoading: false,
  icon: Icon(Icons.login),
)
```

#### 📦 ResponsiveCard

```dart
ResponsiveCard(
  width: 300,
  height: 200,
  padding: EdgeInsets.all(16),
  margin: EdgeInsets.all(8),
  color: Colors.white,
  borderRadius: 16,
  elevation: 4,
  gradient: LinearGradient(
    colors: [Colors.blue, Colors.purple],
  ),
  onTap: () {},
  child: YourWidget(),
)
```

#### 📊 ResponsiveGrid

```dart
ResponsiveGrid(
  spacing: 16,
  runSpacing: 16,
  childAspectRatio: 1.0,
  crossAxisCount: null,  // تلقائي حسب حجم الشاشة
  padding: EdgeInsets.all(20),
  children: [
    GridItem1(),
    GridItem2(),
    GridItem3(),
    // ...
  ],
)
```

#### 📱 ResponsiveLayoutBuilder

```dart
ResponsiveLayoutBuilder(
  mobile: MobileLayout(),
  mobileLarge: MobileLargeLayout(),
  tablet: TabletLayout(),
  tabletLarge: TabletLargeLayout(),
  desktop: DesktopLayout(),
)
```

#### 📱 ResponsiveBuilder

```dart
ResponsiveBuilder(
  builder: (context, deviceType, orientation) {
    if (deviceType == DeviceType.tabletLarge) {
      return TabletLargeLayout();
    }
    return MobileLayout();
  },
)
```

#### 📱 ResponsiveScaffold

```dart
ResponsiveScaffold(
  appBar: AppBar(title: Text('عنوان')),
  body: YourContent(),
  floatingActionButton: FAB(),
  bottomNavigationBar: BottomNav(),
  centerContent: true,  // توسيط على الشاشات الكبيرة
  maxContentWidth: 800,
)
```

---

### 4. Responsive Utils

#### 🔍 التحقق من نوع الجهاز

```dart
// التحقق من نوع الجهاز
if (ResponsiveUtils.isMobile(context)) {
  // كود للموبايل
}

if (ResponsiveUtils.isTablet(context)) {
  // كود للتابلت
}

if (ResponsiveUtils.isDesktop(context)) {
  // كود للديسكتوب
}

// تحققات أكثر تفصيلاً
ResponsiveUtils.isSmallMobile(context);   // موبايل صغير
ResponsiveUtils.isLargeMobile(context);   // موبايل كبير
ResponsiveUtils.isSmallTablet(context);   // تابلت صغير
ResponsiveUtils.isLargeTablet(context);   // تابلت كبير

// الحصول على نوع الجهاز
DeviceType type = ResponsiveUtils.getDeviceType(context);
```

#### 📐 معلومات الشاشة

```dart
// أبعاد الشاشة
double width = ResponsiveUtils.screenWidth(context);
double height = ResponsiveUtils.screenHeight(context);
double shortestSide = ResponsiveUtils.shortestSide(context);
double longestSide = ResponsiveUtils.longestSide(context);

// الاتجاه
bool isPortrait = ResponsiveUtils.isPortrait(context);
bool isLandscape = ResponsiveUtils.isLandscape(context);
Orientation orient = ResponsiveUtils.orientation(context);

// Safe Area
EdgeInsets safeArea = ResponsiveUtils.safeAreaPadding(context);
double safeTop = ResponsiveUtils.safeAreaTop(context);
double safeBottom = ResponsiveUtils.safeAreaBottom(context);
```

#### 🎯 اختيار قيم حسب الجهاز

```dart
// قيمة مختلفة لكل حجم شاشة
double padding = ResponsiveUtils.value(
  context,
  mobile: 16.0,
  mobileLarge: 20.0,
  tablet: 24.0,
  tabletLarge: 32.0,
  desktop: 40.0,
);

// مع الاتجاه
Widget layout = ResponsiveUtils.valueWithOrientation(
  context,
  mobilePortrait: MobilePortraitLayout(),
  mobileLandscape: MobileLandscapeLayout(),
  tabletPortrait: TabletPortraitLayout(),
  tabletLandscape: TabletLandscapeLayout(),
  desktop: DesktopLayout(),
);
```

#### 📊 Grid Helpers

```dart
// عدد الأعمدة المناسب
int columns = ResponsiveUtils.gridColumns(context);

// عرض العنصر في الـ Grid
double itemWidth = ResponsiveUtils.gridItemWidth(
  context,
  spacing: 16,
  horizontalPadding: 20,
);

// نسبة العرض للارتفاع
double ratio = ResponsiveUtils.gridAspectRatio(context, baseRatio: 1.0);
```

#### 📏 الحدود القصوى

```dart
// أقصى عرض للمحتوى
double maxContent = ResponsiveUtils.maxContentWidth(context);

// أقصى عرض للـ Dialog
double maxDialog = ResponsiveUtils.maxDialogWidth(context);

// أقصى عرض للـ Card
double maxCard = ResponsiveUtils.maxCardWidth(context);
```

---

### 5. App Dimensions

مقاسات موحدة جاهزة للاستخدام:

#### 📏 المسافات (Spacing)

```dart
AppDimensions.xxs(context);    // 2px
AppDimensions.xs(context);     // 4px
AppDimensions.sm(context);     // 8px
AppDimensions.md(context);     // 12px
AppDimensions.lg(context);     // 16px
AppDimensions.xl(context);     // 20px
AppDimensions.xxl(context);    // 24px
AppDimensions.xxxl(context);   // 32px
AppDimensions.xxxxl(context);  // 40px
AppDimensions.xxxxxl(context); // 48px
```

#### 🎨 الزوايا (Border Radius)

```dart
AppDimensions.radiusXS(context);   // 4px
AppDimensions.radiusSM(context);   // 8px
AppDimensions.radiusMD(context);   // 12px
AppDimensions.radiusLG(context);   // 16px
AppDimensions.radiusXL(context);   // 20px
AppDimensions.radiusXXL(context);  // 24px
AppDimensions.radiusXXXL(context); // 28px
AppDimensions.radiusFull(context); // 32px
```

#### 🔘 ارتفاعات الأزرار

```dart
AppDimensions.buttonXS(context);  // 32px
AppDimensions.buttonSM(context);  // 40px
AppDimensions.buttonMD(context);  // 48px
AppDimensions.buttonLG(context);  // 56px
AppDimensions.buttonXL(context);  // 64px
```

#### 🎨 أحجام الأيقونات

```dart
AppDimensions.iconXXS(context);  // 12px
AppDimensions.iconXS(context);   // 16px
AppDimensions.iconSM(context);   // 20px
AppDimensions.iconMD(context);   // 24px
AppDimensions.iconLG(context);   // 28px
AppDimensions.iconXL(context);   // 32px
AppDimensions.iconXXL(context);  // 40px
AppDimensions.iconXXXL(context); // 48px
AppDimensions.iconHuge(context); // 64px
```

#### 👤 أحجام الصور الشخصية (Avatar)

```dart
AppDimensions.avatarXS(context);   // 24px
AppDimensions.avatarSM(context);   // 32px
AppDimensions.avatarMD(context);   // 40px
AppDimensions.avatarLG(context);   // 48px
AppDimensions.avatarXL(context);   // 64px
AppDimensions.avatarXXL(context);  // 80px
AppDimensions.avatarHuge(context); // 100px
```

---

### 6. App Typography

أنماط النصوص الموحدة:

```dart
// Display (عناوين كبيرة)
AppTypography.displayLarge(context);   // 36px, Bold
AppTypography.displayMedium(context);  // 30px, Bold
AppTypography.displaySmall(context);   // 26px, Bold

// Headline (عناوين)
AppTypography.headlineLarge(context);  // 24px, SemiBold
AppTypography.headlineMedium(context); // 22px, SemiBold
AppTypography.headlineSmall(context);  // 20px, SemiBold

// Title (عناوين فرعية)
AppTypography.titleLarge(context);   // 18px, SemiBold
AppTypography.titleMedium(context);  // 16px, SemiBold
AppTypography.titleSmall(context);   // 15px, SemiBold

// Body (نص عادي)
AppTypography.bodyLarge(context);   // 16px, Regular
AppTypography.bodyMedium(context);  // 14px, Regular
AppTypography.bodySmall(context);   // 13px, Regular

// Label (تسميات)
AppTypography.labelLarge(context);   // 14px, Medium
AppTypography.labelMedium(context);  // 12px, Medium
AppTypography.labelSmall(context);   // 11px, Medium

// Caption & Overline
AppTypography.caption(context);   // 12px, Regular
AppTypography.overline(context);  // 10px, Medium

// Button
AppTypography.buttonLarge(context);   // 16px, SemiBold
AppTypography.buttonMedium(context);  // 15px, SemiBold
AppTypography.buttonSmall(context);   // 14px, SemiBold
```

#### 🎨 مع تخصيص اللون

```dart
Text(
  'عنوان',
  style: AppTypography.headlineLarge(context, color: Colors.blue),
)
```

---

## 📊 جداول المقاسات

### 📏 جدول Scale Factors

```
╔════════════════════════════════════════════════════════════════════════════╗
║                           SCALE FACTORS TABLE                              ║
╠════════════════════════════════════════════════════════════════════════════╣
║ Device Type    │ Font Scale  │ Spacing Scale │ Icon Scale │ Widget Scale  ║
╠════════════════╪═════════════╪═══════════════╪════════════╪═══════════════╣
║ mobileSmall    │ 0.85 - 1.00 │ 0.80 - 1.00   │ 0.85 - 1.00│ 0.85 - 1.00   ║
║ mobileMedium   │ 0.90 - 1.05 │ 0.88 - 1.05   │ 0.90 - 1.05│ 0.90 - 1.05   ║
║ mobileLarge    │ 0.95 - 1.10 │ 0.95 - 1.10   │ 0.95 - 1.10│ 0.95 - 1.10   ║
║ mobileXLarge   │ 1.00 - 1.15 │ 1.00 - 1.15   │ 1.00 - 1.15│ 1.00 - 1.15   ║
║ tabletSmall    │ 1.00 - 1.20 │ 1.10 - 1.30   │ 1.05 - 1.25│ 1.10 - 1.30   ║
║ tabletMedium   │ 1.05 - 1.25 │ 1.15 - 1.40   │ 1.10 - 1.30│ 1.15 - 1.40   ║
║ tabletLarge    │ 1.10 - 1.30 │ 1.20 - 1.50   │ 1.15 - 1.35│ 1.20 - 1.50   ║
║ tabletXLarge   │ 1.15 - 1.35 │ 1.25 - 1.60   │ 1.20 - 1.40│ 1.25 - 1.60   ║
║ desktop        │ 1.20 - 1.50 │ 1.30 - 1.80   │ 1.25 - 1.50│ 1.30 - 1.80   ║
╚════════════════════════════════════════════════════════════════════════════╝
```

### 📊 جدول Grid Columns

```
╔═══════════════════════════════════════════════════════════════╗
║                    GRID COLUMNS TABLE                         ║
╠═══════════════════════════════════════════════════════════════╣
║ Device Type    │ Portrait Columns │ Landscape Columns         ║
╠════════════════╪══════════════════╪═══════════════════════════╣
║ mobileSmall    │        2         │          3                ║
║ mobileMedium   │        2         │          3                ║
║ mobileLarge    │        2         │          4                ║
║ mobileXLarge   │        2         │          4                ║
║ tabletSmall    │        3         │          4                ║
║ tabletMedium   │        3         │          4                ║
║ tabletLarge    │        4         │          5                ║
║ tabletXLarge   │        4         │          5                ║
║ desktop        │        6         │          6                ║
╚═══════════════════════════════════════════════════════════════╝
```

---

## 💡 أمثلة عملية

### 📱 صفحة متجاوبة كاملة

```dart
import 'package:flutter/material.dart';
import 'package:your_app/core/responsive/responsive.dart';

class ResponsiveHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      appBar: AppBar(
        title: ResponsiveText('الصفحة الرئيسية', fontSize: 18),
        toolbarHeight: AppDimensions.appBarHeight(context),
      ),
      body: SingleChildScrollView(
        padding: ResponsiveUtils.pagePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العنوان
            Text(
              'مرحباً بك',
              style: AppTypography.displaySmall(context),
            ),
            
            ResponsiveSizedBox.height(8),
            
            Text(
              'اكتشف محتوى جديد',
              style: AppTypography.bodyLarge(context, color: Colors.grey),
            ),
            
            ResponsiveSizedBox.height(24),
            
            // البطاقات
            ResponsiveLayoutBuilder(
              mobile: _buildMobileCards(),
              tablet: _buildTabletCards(),
              desktop: _buildDesktopCards(),
            ),
            
            ResponsiveSizedBox.height(32),
            
            // الزر
            ResponsiveButton(
              text: 'استكشف المزيد',
              onPressed: () {},
              height: 56,
              fontSize: 16,
              expand: true,
              backgroundColor: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMobileCards() {
    return Column(
      children: [
        _buildCard(),
        ResponsiveSizedBox.height(16),
        _buildCard(),
      ],
    );
  }
  
  Widget _buildTabletCards() {
    return Row(
      children: [
        Expanded(child: _buildCard()),
        ResponsiveSizedBox.width(16),
        Expanded(child: _buildCard()),
      ],
    );
  }
  
  Widget _buildDesktopCards() {
    return Row(
      children: [
        Expanded(child: _buildCard()),
        ResponsiveSizedBox.width(16),
        Expanded(child: _buildCard()),
        ResponsiveSizedBox.width(16),
        Expanded(child: _buildCard()),
      ],
    );
  }
  
  Widget _buildCard() {
    return Builder(
      builder: (context) {
        return ResponsiveCard(
          padding: EdgeInsets.all(20),
          borderRadius: 16,
          elevation: 2,
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ResponsiveIcon(Icons.star, size: 32, color: Colors.amber),
              ResponsiveSizedBox.height(12),
              Text('عنوان البطاقة', style: AppTypography.titleMedium(context)),
              ResponsiveSizedBox.height(8),
              Text(
                'وصف قصير للبطاقة يوضح المحتوى',
                style: AppTypography.bodySmall(context, color: Colors.grey),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

### 📊 Grid View متجاوب

```dart
class ResponsiveGridExample extends StatelessWidget {
  final List<String> items = List.generate(12, (i) => 'Item ${i + 1}');
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.builder(
        padding: ResponsiveUtils.pagePadding(context),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: ResponsiveUtils.gridColumns(context),
          mainAxisSpacing: 16.s(context),
          crossAxisSpacing: 16.s(context),
          childAspectRatio: ResponsiveUtils.gridAspectRatio(context),
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ResponsiveCard(
            borderRadius: 12,
            child: Center(
              child: ResponsiveText(
                items[index],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        },
      ),
    );
  }
}
```

### 🔄 Layout مختلف حسب الـ Orientation

```dart
class OrientationAwareLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType, orientation) {
        final isLandscape = orientation == Orientation.landscape;
        
        return Scaffold(
          body: isLandscape
              ? Row(
                  children: [
                    Expanded(flex: 2, child: _buildSidebar(context)),
                    Expanded(flex: 5, child: _buildContent(context)),
                  ],
                )
              : Column(
                  children: [
                    _buildHeader(context),
                    Expanded(child: _buildContent(context)),
                  ],
                ),
        );
      },
    );
  }
  
  Widget _buildSidebar(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      padding: ResponsiveUtils.paddingAll(context, 16),
      child: Column(
        children: [
          ResponsiveIcon(Icons.menu, size: 28),
          ResponsiveSizedBox.height(24),
          // Menu items...
        ],
      ),
    );
  }
  
  Widget _buildHeader(BuildContext context) {
    return Container(
      height: AppDimensions.appBarHeight(context),
      color: Theme.of(context).primaryColor,
      padding: ResponsiveUtils.paddingSymmetric(context, horizontal: 20),
      child: Row(
        children: [
          ResponsiveIcon(Icons.menu, size: 24, color: Colors.white),
          ResponsiveSizedBox.width(16),
          ResponsiveText('العنوان', fontSize: 18, color: Colors.white),
        ],
      ),
    );
  }
  
  Widget _buildContent(BuildContext context) {
    return Container(
      padding: ResponsiveUtils.pagePadding(context),
      child: Center(
        child: ResponsiveText('المحتوى الرئيسي', fontSize: 20),
      ),
    );
  }
}
```

---

## ✅ Best Practices

### ✅ افعل (Do)

```dart
// ✅ استخدم الـ Extensions للكود النظيف
Container(
  width: 200.w(context),
  padding: EdgeInsets.all(16.s(context)),
  child: Text('نص', style: TextStyle(fontSize: 14.sp(context))),
)

// ✅ استخدم AppDimensions للقيم الموحدة
SizedBox(height: AppDimensions.lg(context))

// ✅ استخدم AppTypography للنصوص
Text('عنوان', style: AppTypography.titleLarge(context))

// ✅ استخدم ResponsiveLayoutBuilder للـ layouts المختلفة
ResponsiveLayoutBuilder(
  mobile: MobileLayout(),
  tablet: TabletLayout(),
)

// ✅ استخدم ResponsiveUtils.value للقيم المتغيرة
double padding = ResponsiveUtils.value(
  context,
  mobile: 16.0,
  tablet: 24.0,
);
```

### ❌ لا تفعل (Don't)

```dart
// ❌ لا تستخدم قيم ثابتة
Container(
  width: 200,  // ❌ قيمة ثابتة
  padding: EdgeInsets.all(16),  // ❌ قيمة ثابتة
)

// ❌ لا تستخدم MediaQuery مباشرة للتحجيم
double width = MediaQuery.of(context).size.width * 0.5;  // ❌

// ❌ لا تتجاهل الأجهزة الكبيرة
// تأكد من اختبار التطبيق على التابلت والآيباد

// ❌ لا تستخدم قيم كبيرة جداً
fontSize: 100.sp(context);  // ❌ قيمة كبيرة جداً
```

### 💡 نصائح

1. **اختبر على أجهزة متعددة**: استخدم المحاكي لاختبار جميع أحجام الشاشات
2. **استخدم DevicePreview**: مكتبة مفيدة لمعاينة التطبيق على أجهزة مختلفة
3. **الـ Orientation**: لا تنسَ اختبار الـ Portrait والـ Landscape
4. **الحدود القصوى**: استخدم `maxContentWidth` لتجنب تمدد المحتوى على الشاشات الكبيرة

---

## ❓ FAQ

### س: هل يمكنني تغيير المقاس المرجعي؟

**ج:** نعم، يمكنك تعديل `DesignReference` في `responsive_config.dart`:

```dart
static const Map<DeviceType, DesignReference> designReferences = {
  DeviceType.mobileLarge: DesignReference(
    width: 390,  // غير هذه القيم
    height: 844,
    name: 'iPhone 14',
  ),
  // ...
};
```

### س: كيف أضيف نقطة تحول جديدة؟

**ج:** أضف النوع في `DeviceType` وقم بتحديث `ResponsiveConfig`:

```dart
enum DeviceType {
  // ...
  foldable,  // جديد
}

// ثم أضف الإعدادات في ResponsiveConfig
```

### س: هل يدعم الـ Web؟

**ج:** نعم، النظام يعمل على الـ Web ويتعامل مع أحجام النوافذ المختلفة.

### س: كيف أتعامل مع Safe Area؟

**ج:** استخدم:

```dart
EdgeInsets safeArea = ResponsiveUtils.safeAreaPadding(context);
// أو
double safeTop = ResponsiveUtils.safeAreaTop(context);
double safeBottom = ResponsiveUtils.safeAreaBottom(context);
```

### س: هل يمكنني استخدامه مع GetX/Riverpod/Provider؟

**ج:** نعم، النظام مستقل ويعمل مع أي state management.

---

## 📄 License

MIT License - يمكنك استخدام هذا النظام بحرية في مشاريعك.

---

## 🤝 المساهمة

المساهمات مرحب بها! يرجى فتح Issue أو Pull Request.

---

<div align="center">

**صنع بـ ❤️ للمطورين العرب**

</div>
```

---

## 📁 ملف التصدير النهائي

```dart
// lib/core/responsive/responsive.dart

/// Flutter Responsive System
/// نظام متكامل للتصميم المتجاوب
/// 
/// الاستخدام:
/// ```dart
/// import 'package:your_app/core/responsive/responsive.dart';
/// ```

library responsive;

export 'responsive_config.dart';
export 'responsive_utils.dart';
export 'responsive_widgets.dart';
export 'responsive_dimensions.dart';
```