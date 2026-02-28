import 'package:flutter/material.dart' show BuildContext, Localizations;

class AppExplanations {
  AppExplanations(this.context);

  final BuildContext context;

  bool get isAr => Localizations.localeOf(context).languageCode == 'ar';

  List<ExplanationItem> getExplanations() {
    if (isAr) {
      return [
        ExplanationItem(
          title: "إضافة الأجهزة",
          description: "قم بإضافة جميع الأجهزة التي ترغب في تشغيلها على النظام الشمسي. لكل جهاز، حدد قدرته بالواط وعدد ساعات التشغيل اليومية.",
        ),
        ExplanationItem(
          title: "ساعات الاستقلالية (Autonomy Hours)",
          description: "هي المدة التي يجب أن تعمل فيها البطاريات لتشغيل الأجهزة دون وجود شمس (ليلاً أو في الأيام الغائمة).",
        ),
        ExplanationItem(
          title: "ساعات ذروة الشمس (Sun Peak Hours)",
          description: "متوسط عدد الساعات التي تكون فيها الشمس قوية بما يكفي لتوليد الطاقة القصوى من الألواح. عادة ما تكون بين 4 إلى 6 ساعات.",
        ),
        ExplanationItem(
          title: "قدرة اللوح (Panel Wattage)",
          description: "اختر قدرة اللوح الشمسي الذي تنوي استخدامه (مثلاً 400 واط أو 550 واط) لحساب عدد الألواح المطلوبة بدقة.",
        ),
        ExplanationItem(
          title: "جهد البطارية الواحدة",
          description: "الجهد الكهربائي للبطارية التي ستستخدمها في النظام (مثلاً 12 فولت للبطاريات التقليدية أو 48 فولت لبطاريات الليثيوم).",
        ),
        ExplanationItem(
          title: "جهد النظام (System Voltage)",
          description: "الجهد الكلي لنظام البطاريات. الأنظمة الأكبر تحتاج لجهد أعلى (24 أو 48 فولت) لتقليل الفاقد في الأسلاك.",
        ),
      ];
    } else {
      return [
        ExplanationItem(
          title: "Adding Appliances",
          description: "Add all appliances you want to run on the solar system. For each appliance, specify its power in Watts and daily running hours.",
        ),
        ExplanationItem(
          title: "Autonomy Hours",
          description: "The duration your batteries need to power your appliances without sunlight (at night or on cloudy days).",
        ),
        ExplanationItem(
          title: "Sun Peak Hours",
          description: "The average hours per day the sun is strong enough to generate maximum power. Usually between 4 to 6 hours.",
        ),
        ExplanationItem(
          title: "Panel Wattage",
          description: "Select the wattage of the solar panel you intend to use (e.g., 400W or 550W) to calculate the required panel count accurately.",
        ),
        ExplanationItem(
          title: "Single Battery Voltage",
          description: "The voltage of a single battery you will use (e.g., 12V for traditional batteries or 48V for lithium).",
        ),
        ExplanationItem(
          title: "System Voltage",
          description: "The total voltage of the battery bank. Larger systems require higher voltage (24V or 48V) to reduce power loss.",
        ),
      ];
    }
  }

  List<ExplanationItem> getOfferRequestExplanations() {
    if (isAr) {
      return [
        ExplanationItem(title: "الألواح الشمسية", description: "قم بتحديد قدرة اللوح الواحد (بالواط) والعدد الإجمالي للألواح التي تحتاجها."),
        ExplanationItem(title: "قدرة العاكس (Inverter)", description: "اختر حجم العاكس بالكيلوواط (kW). هذا يحدد الحد الأقصى للحمل الذي يمكن تشغيله."),
        ExplanationItem(
          title: "نوع نظام العاكس",
          description: "جهد منخفض (Low Voltage) للأنظمة المنزلية المعتادة (48 فولت)، أو جهد عالي (High Voltage) للأنظمة التجارية الكبيرة.",
        ),
        ExplanationItem(
          title: "نوع العاكس والفازات",
          description: "اختر ما إذا كنت تحتاج نظام هجين (Hybrid)، متصل بالشبكة (On-Grid)، أو منفصل (Off-Grid). وحدد ما إذا كان سنجل فاز أو 3 فاز.",
        ),
        ExplanationItem(
          title: "نوع البطارية",
          description: "بطاريات الليثيوم توفر عمرًا أطول وأداءً أفضل، بينما بطاريات الجل/الرصاص هي الخيار الاقتصادي التقليدي.",
        ),
        ExplanationItem(
          title: "سعة البطارية",
          description: "تُقاس بالأمبير (Ah) للأنظمة التقليدية، أو بالكيلوواط (kWh) لأنظمة الجهد العالي والليثيوم. حدد السعة والعدد المطلوب.",
        ),
      ];
    } else {
      return [
        ExplanationItem(title: "Solar Panels", description: "Specify the single panel wattage (W) and the total count of panels you require."),
        ExplanationItem(title: "Inverter Capacity", description: "Select the inverter size in Kilowatts (kW). This determines the maximum load you can run."),
        ExplanationItem(
          title: "Inverter System Type",
          description: "Low Voltage (LV) for typical home systems (48V), or High Voltage (HV) for larger commercial systems.",
        ),
        ExplanationItem(
          title: "Inverter Type & Phase",
          description: "Choose Hybrid, On-Grid, or Off-Grid. Also specify if you need Single Phase or Three Phase.",
        ),
        ExplanationItem(
          title: "Battery Type",
          description: "Lithium batteries offer longer life and better performance, while Gel/Lead-Acid are the traditional economic choice.",
        ),
        ExplanationItem(
          title: "Battery Capacity",
          description: "Measured in Ampere-hours (Ah) for traditional systems, or Kilowatt-hours (kWh) for HV/Lithium systems. Specify capacity and count.",
        ),
      ];
    }
  }

  // --- Panels ---
  List<ExplanationItem> getPanelExplanations() {
    return isAr
        ? [
            ExplanationItem(title: "الاستهلاك اليومي", description: "إجمالي الطاقة التي تستهلكها يومياً بالأمبير-ساعة (Ah)."),
            ExplanationItem(title: "جهد النظام", description: "جهد البطاريات الذي صممت النظام ليعمل عليه (مثلاً 12 فولت أو 24 فولت)."),
            ExplanationItem(title: "قدرة اللوح", description: "قدرة اللوح الشمسي الواحد بالواط (W) الذي تنوي استخدامه."),
            ExplanationItem(title: "كفاءة النظام", description: "نسبة الفاقد في النظام. عادة نستخدم 0.8 (80%) لحساب الفاقد في الأسلاك والشحن."),
          ]
        : [
            ExplanationItem(title: "Total Daily Usage", description: "Total energy consumed daily in Amp-hours (Ah)."),
            ExplanationItem(title: "System Voltage", description: "The DC voltage of your battery bank (e.g., 12V, 24V)."),
            ExplanationItem(title: "Panel Wattage", description: "The power rating of a single solar panel in Watts (W)."),
            ExplanationItem(
              title: "System Efficiency",
              description: "Accounts for energy losses. Typically 0.8 (80%) allows for wiring and charge inefficiencies.",
            ),
          ];
  }

  // --- Inverter ---
  List<ExplanationItem> getInverterExplanations() {
    return isAr
        ? [
            ExplanationItem(title: "تيار الحمل الكلي", description: "مجموع التيارات للأجهزة التي ستعمل في نفس الوقت بالأمبير."),
            ExplanationItem(title: "جهد النظام المتناوب", description: "الجهد الكهربائي للمنزل (مثلاً 220 فولت أو 110 فولت)."),
            ExplanationItem(title: "معامل الأمان", description: "زيادة حجم العاكس بنسبة معينة (مثلاً 1.25) لتحمل أحمال البدء ولتجنب ارتفاع الحرارة."),
          ]
        : [
            ExplanationItem(title: "Total Load Amps", description: "The sum of amps for all appliances running simultaneously."),
            ExplanationItem(title: "AC System Voltage", description: "Your home's voltage standard (e.g., 220V or 110V)."),
            ExplanationItem(title: "Safety Factor", description: "Oversizing the inverter (e.g., x1.25) to handle startup surges and prevent overheating."),
          ];
  }

  // --- Battery ---
  List<ExplanationItem> getBatteryExplanations() {
    return isAr
        ? [
            ExplanationItem(title: "تيار الحمل الكلي", description: "معدل استهلاك التيار المستمر من البطاريات بالأمبير."),
            ExplanationItem(title: "وقت التشغيل المطلوب", description: "عدد الساعات التي تحتاج أن تعمل فيها الأجهزة اعتماداً على البطارية."),
            ExplanationItem(title: "عمق التفريغ (DoD)", description: "نسبة تفريغ البطارية المسموح بها للحفاظ على عمرها (مثلاً 50% للجل و 80% لليثيوم)."),
          ]
        : [
            ExplanationItem(title: "Total Load Amps", description: "The continuous DC current drawn from the batteries in Amps."),
            ExplanationItem(title: "Backup Time", description: "Total hours you need your appliances to run on battery power."),
            ExplanationItem(
              title: "Depth of Discharge (DoD)",
              description: "Percentage of battery capacity usable without damage (e.g., 50% for Gel, 80% for Lithium).",
            ),
          ];
  }

  // --- Wires ---
  List<ExplanationItem> getWiresExplanations() {
    return isAr
        ? [
            ExplanationItem(title: "نوع التطبيق", description: "حدد ما إذا كان السلك لألواح شمسية، بطاريات، أو كهرباء منزلية (AC)."),
            ExplanationItem(title: "التيار", description: "التيار المار في السلك بالأمبير. كلما زاد التيار زاد سمك السلك المطلوب."),
            ExplanationItem(title: "المسافة", description: "طول السلك من المصدر إلى الحمل (اتجاه واحد)."),
            ExplanationItem(title: "هبوط الجهد المسموح", description: "النسبة المئوية المقبولة لنقصان الجهد في نهاية السلك. (1-3% للأنظمة الشمسية)."),
          ]
        : [
            ExplanationItem(title: "Application Type", description: "Select if wire is for DC Solar, Batteries, or AC Household."),
            ExplanationItem(title: "Current", description: "The current flowing through the wire in Amps. Higher current requires thicker wires."),
            ExplanationItem(title: "Distance", description: "One-way length of the wire run from source to load."),
            ExplanationItem(title: "Voltage Drop", description: "Acceptable percentage of voltage loss. Keep low (1-3%) for solar efficiency."),
          ];
  }

  // --- Pump ---
  List<ExplanationItem> getPumpExplanations() {
    return isAr
        ? [
            ExplanationItem(title: "حجم المياه اليومي", description: "كمية المياه المطلوبة يومياً بالمتر المكعب (m³)."),
            ExplanationItem(
              title: "الارتفاع الديناميكي الكلي (TDH)",
              description: "مجموع الارتفاع العمودي + فواق الاحتكاك في الأنابيب + الضغط المطلوب عند المخرج.",
            ),
            ExplanationItem(title: "ساعات الضخ", description: "عدد الساعات التي ستعمل فيها المضخة يومياً."),
            ExplanationItem(title: "ساعات ذروة الشمس", description: "متوسط عدد ساعات الشمس القوية في موقعك."),
          ]
        : [
            ExplanationItem(title: "Daily Water Volume", description: "Target water quantity per day in cubic meters (m³)."),
            ExplanationItem(title: "Total Dynamic Head (TDH)", description: "Vertical lift + Pipe friction losses + Required output pressure."),
            ExplanationItem(title: "Pumping Hours", description: "Number of hours the pump will operate per day."),
            ExplanationItem(title: "Peak Sun Hours", description: "Average hours of full solar intensity at your location."),
          ];
  }

  // --- Direction ---
  List<ExplanationItem> getDirectionExplanations() {
    return isAr
        ? [
            ExplanationItem(title: "خط العرض", description: "موقعك الجغرافي شمال أو جنوب خط الاستواء. يحدد زاوية ميل الألواح المثالية."),
            ExplanationItem(title: "التوجيه (Azimuth)", description: "الاتجاه الذي يجب أن تواجهه الألواح (الجنوب في نصف الكرة الشمالي والعكس)."),
            ExplanationItem(title: "زاوية الميل", description: "الزاوية بين اللوح والأرض. أفضل زاوية سنوية تساوي عادةً خط العرض."),
          ]
        : [
            ExplanationItem(title: "Latitude", description: "Your geographic location. Determines the optimal tilt angle for panels."),
            ExplanationItem(
              title: "Azimuth (Direction)",
              description: "The compass direction panels should face (South in Northern Hemisphere, North in Southern).",
            ),
            ExplanationItem(title: "Tilt Angle", description: "Angle between the panel and the ground. Optimal yearly angle usually equals latitude."),
          ];
  }
}

class ExplanationItem {
  final String title;
  final String description;

  ExplanationItem({required this.title, required this.description});
}
