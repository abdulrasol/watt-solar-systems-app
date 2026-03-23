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
          description:
              "أضف جميع الأجهزة التي تريد تشغيلها على النظام الشمسي. لكل جهاز اكتب الاسم، القدرة بالواط، العدد، وعدد ساعات التشغيل يومياً حتى يتم حساب الاستهلاك الكلي بشكل صحيح.",
        ),
        ExplanationItem(
          title: "ساعات الاستقلالية",
          description:
              "هي عدد الساعات التي يجب أن تغطيها البطاريات عند غياب الشمس، مثل الليل أو أثناء الغيوم. كلما زادت هذه القيمة زادت سعة البطاريات المطلوبة.",
        ),
        ExplanationItem(
          title: "ساعات ذروة الشمس",
          description:
              "هي متوسط عدد الساعات اليومية التي تكون فيها أشعة الشمس قوية بما يكفي ليعمل اللوح قريباً من قدرته القصوى. في كثير من المناطق تكون تقريباً بين 4 و6 ساعات.",
        ),
        ExplanationItem(
          title: "قدرة اللوح",
          description:
              "أدخل قدرة اللوح الشمسي الواحد الذي ستعتمد عليه في التصميم، مثل 400 واط أو 570 واط. هذا الرقم يؤثر مباشرة على عدد الألواح المقترحة.",
        ),
        ExplanationItem(
          title: "جهد البطارية الواحدة",
          description:
              "اختر جهد البطارية الواحدة التي ستستخدمها داخل النظام، مثل 12V أو 12.8V أو 25.6V أو 51.2V. هذا يساعد التطبيق على تحديد طريقة توصيل البطاريات على التوالي بشكل صحيح.",
        ),
        ExplanationItem(
          title: "جهد النظام",
          description:
              "هو الجهد الكلي لبنك البطاريات الذي سيعمل عليه النظام، مثل 12V أو 24V أو 48V. عادةً الأنظمة الأكبر تستخدم جهداً أعلى لتقليل التيار والفاقد في الأسلاك.",
        ),
      ];
    } else {
      return [
        ExplanationItem(
          title: "Adding Appliances",
          description:
              "Add every appliance you want the solar system to run. For each item, enter the name, wattage, quantity, and daily operating hours so the total energy use is calculated correctly.",
        ),
        ExplanationItem(
          title: "Autonomy Hours",
          description:
              "This is the number of hours the batteries should keep your loads running without sunlight, such as at night or during cloudy weather. Higher autonomy means a larger battery bank.",
        ),
        ExplanationItem(
          title: "Peak Sun Hours",
          description:
              "The average number of hours per day when sunlight is strong enough for the panels to operate near full output. In many locations, this is roughly 4 to 6 hours.",
        ),
        ExplanationItem(
          title: "Panel Wattage",
          description:
              "Enter the wattage of one solar panel, such as 400W or 570W. This value is used to estimate how many panels your system will need.",
        ),
        ExplanationItem(
          title: "Single Battery Voltage",
          description:
              "Choose the voltage of one battery unit in your system, such as 12V, 12.8V, 25.6V, or 51.2V. This helps determine how the batteries should be connected in series.",
        ),
        ExplanationItem(
          title: "System Voltage",
          description:
              "This is the overall battery-bank voltage the system will run on, such as 12V, 24V, or 48V. Larger systems usually use higher voltage to reduce current and wiring losses.",
        ),
      ];
    }
  }

  List<ExplanationItem> getOfferRequestExplanations() {
    if (isAr) {
      return [
        ExplanationItem(
          title: "الألواح الشمسية",
          description:
              "حدد قدرة اللوح الواحد بالواط، ثم أدخل العدد المطلوب من الألواح. هذان الرقمان يحددان القدرة الإجمالية للمصفوفة الشمسية.",
        ),
        ExplanationItem(
          title: "قدرة العاكس",
          description:
              "اختر قدرة العاكس بالكيلوواط أو الكيلو فولت أمبير حسب طريقة العرض في التطبيق. هذه القيمة تحدد الحد الأقصى للأحمال التي يمكن تشغيلها في نفس الوقت.",
        ),
        ExplanationItem(
          title: "فئة جهد العاكس",
          description:
              "اختر جهد منخفض للأنظمة المنزلية الشائعة، أو جهد عالٍ للأنظمة الأكبر والأكثر تطلباً. هذا الخيار يؤثر على نوع البطاريات والمعدات المتوافقة.",
        ),
        ExplanationItem(
          title: "نوع العاكس والفازات",
          description:
              "حدد هل النظام هجين، متصل بالشبكة، أو منفصل عنها. ثم اختر إن كان المطلوب سنكل فاز أو ثلاثي الفاز حسب طبيعة الموقع والأحمال.",
        ),
        ExplanationItem(
          title: "نوع البطارية",
          description:
              "بطاريات الليثيوم تتميز بعمر أطول وكفاءة أعلى وعمق تفريغ أفضل، بينما بطاريات الجل أو الرصاص تبقى خياراً اقتصادياً شائعاً في كثير من المشاريع.",
        ),
        ExplanationItem(
          title: "سعة البطارية",
          description:
              "أدخل سعة البطارية الواحدة والعدد المطلوب. قد تُقاس السعة بالأمبير-ساعة (Ah) في الأنظمة التقليدية، أو بالكيلوواط-ساعة (kWh) في بعض أنظمة الليثيوم والجهد العالي.",
        ),
      ];
    } else {
      return [
        ExplanationItem(
          title: "Solar Panels",
          description:
              "Enter the wattage of one panel and the total number of panels required. Together, these define the total PV array size.",
        ),
        ExplanationItem(
          title: "Inverter Capacity",
          description:
              "Choose the inverter size in kW or kVA, depending on how the app presents it. This determines the maximum load the system can supply at one time.",
        ),
        ExplanationItem(
          title: "Inverter Voltage Class",
          description:
              "Choose Low Voltage for typical residential systems, or High Voltage for larger and more demanding installations. This affects battery and equipment compatibility.",
        ),
        ExplanationItem(
          title: "Inverter Type & Phase",
          description:
              "Select whether the system is Hybrid, On-Grid, or Off-Grid, then choose Single Phase or Three Phase based on the site and load requirements.",
        ),
        ExplanationItem(
          title: "Battery Type",
          description:
              "Lithium batteries usually offer longer life, better efficiency, and deeper usable capacity. Gel or lead-acid batteries remain the more traditional budget option.",
        ),
        ExplanationItem(
          title: "Battery Capacity",
          description:
              "Enter the capacity of one battery and the number required. Capacity may be shown in Ah for conventional systems, or in kWh for some lithium and high-voltage systems.",
        ),
      ];
    }
  }

  // --- Panels ---
  List<ExplanationItem> getPanelExplanations() {
    return isAr
        ? [
            ExplanationItem(
              title: "الاستهلاك اليومي",
              description:
                  "أدخل إجمالي استهلاك الطاقة اليومي الذي تريد تغطيته من الألواح. كلما زاد الاستهلاك زاد عدد الألواح المطلوبة.",
            ),
            ExplanationItem(
              title: "جهد النظام",
              description:
                  "هو الجهد الذي يعمل عليه بنك البطاريات أو النظام المستمر، مثل 12V أو 24V أو 48V.",
            ),
            ExplanationItem(
              title: "قدرة اللوح",
              description:
                  "قدرة اللوح الشمسي الواحد بالواط. يستخدم هذا الرقم لتحويل احتياج الطاقة إلى عدد ألواح فعلي.",
            ),
            ExplanationItem(
              title: "كفاءة النظام",
              description:
                  "تعبر عن الفاقد الناتج من الأسلاك، منظم الشحن، الحرارة، وعوامل التشغيل. استخدام قيمة مثل 0.8 يعني احتساب فاقد تقريبي بنسبة 20%.",
            ),
          ]
        : [
            ExplanationItem(
              title: "Total Daily Usage",
              description:
                  "Enter the total daily energy consumption that the solar panels need to cover. Higher daily usage means more panels are required.",
            ),
            ExplanationItem(
              title: "System Voltage",
              description:
                  "The DC operating voltage of the battery bank or solar system, such as 12V, 24V, or 48V.",
            ),
            ExplanationItem(
              title: "Panel Wattage",
              description:
                  "The rated power of one solar panel in watts. This value is used to convert energy demand into an estimated panel count.",
            ),
            ExplanationItem(
              title: "System Efficiency",
              description:
                  "This accounts for real-world losses such as wiring, controller losses, temperature, and charging inefficiencies. A value of 0.8 means the calculation assumes about 20% losses.",
            ),
          ];
  }

  // --- Inverter ---
  List<ExplanationItem> getInverterExplanations() {
    return isAr
        ? [
            ExplanationItem(
              title: "تيار الحمل الكلي",
              description:
                  "هو مجموع التيار أو الحمل المتوقع للأجهزة التي قد تعمل في الوقت نفسه. هذا الرقم أساسي لاختيار عاكس مناسب.",
            ),
            ExplanationItem(
              title: "جهد النظام المتناوب",
              description:
                  "هو جهد الكهرباء المتناوبة في الموقع، مثل 230V أو 110V أو 380V حسب الدولة ونوع التغذية.",
            ),
            ExplanationItem(
              title: "معامل الأمان",
              description:
                  "يتم استخدامه لزيادة قدرة العاكس فوق الحمل المحسوب، حتى يتحمل تيارات الإقلاع وتذبذب الأحمال ويعمل براحة أكبر.",
            ),
          ]
        : [
            ExplanationItem(
              title: "Total Load Amps",
              description:
                  "This is the combined current or load of all appliances expected to run at the same time. It is a key input for choosing the right inverter size.",
            ),
            ExplanationItem(
              title: "AC System Voltage",
              description:
                  "The AC voltage used at the site, such as 230V, 110V, or 380V depending on the country and electrical setup.",
            ),
            ExplanationItem(
              title: "Safety Factor",
              description:
                  "This adds extra capacity above the calculated load so the inverter can handle startup surges, fluctuating demand, and cooler operation.",
            ),
          ];
  }

  // --- Battery ---
  List<ExplanationItem> getBatteryExplanations() {
    return isAr
        ? [
            ExplanationItem(
              title: "تيار الحمل الكلي",
              description:
                  "هو مقدار التيار المستمر الذي تسحبه الأحمال من البطاريات أثناء التشغيل.",
            ),
            ExplanationItem(
              title: "وقت التشغيل المطلوب",
              description:
                  "عدد الساعات التي تريد أن تستمر فيها البطاريات بتشغيل الأحمال عند غياب مصدر الشحن.",
            ),
            ExplanationItem(
              title: "عمق التفريغ",
              description:
                  "هو النسبة المسموح باستخدامها من سعة البطارية دون التأثير الكبير على عمرها. مثال شائع: 50% لبطاريات الجل و80% أو أكثر لبعض بطاريات الليثيوم.",
            ),
          ]
        : [
            ExplanationItem(
              title: "Total Load Amps",
              description:
                  "The continuous DC current drawn from the battery bank while the loads are operating.",
            ),
            ExplanationItem(
              title: "Backup Time",
              description:
                  "The number of hours you want the batteries to keep the loads running when no charging source is available.",
            ),
            ExplanationItem(
              title: "Depth of Discharge (DoD)",
              description:
                  "The percentage of battery capacity you plan to use without significantly shortening battery life. A common assumption is about 50% for gel batteries and 80% or more for some lithium batteries.",
            ),
          ];
  }

  // --- Wires ---
  List<ExplanationItem> getWiresExplanations() {
    return isAr
        ? [
            ExplanationItem(
              title: "نوع التطبيق",
              description:
                  "حدد هل السلك مخصص للألواح، البطاريات، أو الأحمال المتناوبة AC لأن طريقة الحساب قد تختلف حسب الاستخدام.",
            ),
            ExplanationItem(
              title: "التيار",
              description:
                  "هو التيار المتوقع مروره داخل السلك بالأمبير. كلما ارتفع التيار احتجت إلى مقطع سلك أكبر.",
            ),
            ExplanationItem(
              title: "المسافة",
              description:
                  "أدخل طول مسار السلك من المصدر إلى الحمل باتجاه واحد، لأن المسافة تؤثر مباشرة على هبوط الجهد.",
            ),
            ExplanationItem(
              title: "هبوط الجهد المسموح",
              description:
                  "هو مقدار الانخفاض المقبول في الجهد بين بداية السلك ونهايته. في الأنظمة الشمسية يفضّل عادة إبقاؤه منخفضاً، مثل 1% إلى 3%.",
            ),
          ]
        : [
            ExplanationItem(
              title: "Application Type",
              description:
                  "Choose whether the cable is for solar panels, batteries, or AC loads, because the sizing approach can vary by application.",
            ),
            ExplanationItem(
              title: "Current",
              description:
                  "This is the expected current flowing through the cable in amps. Higher current requires a thicker cable.",
            ),
            ExplanationItem(
              title: "Distance",
              description:
                  "Enter the one-way cable run length from the source to the load, since distance directly affects voltage drop.",
            ),
            ExplanationItem(
              title: "Voltage Drop",
              description:
                  "This is the amount of voltage loss you are willing to accept between the start and end of the cable. In solar systems, it is usually best to keep it low, such as 1% to 3%.",
            ),
          ];
  }

  // --- Pump ---
  List<ExplanationItem> getPumpExplanations() {
    return isAr
        ? [
            ExplanationItem(
              title: "حجم المياه اليومي",
              description:
                  "أدخل كمية المياه التي تريد ضخها يومياً بالمتر المكعب. هذه القيمة تحدد احتياج النظام من الطاقة.",
            ),
            ExplanationItem(
              title: "الارتفاع الديناميكي الكلي",
              description:
                  "يمثل مجموع الرفع العمودي، وفواقد الاحتكاك داخل الأنابيب، والضغط المطلوب عند نقطة الخروج. كلما ارتفعت هذه القيمة احتجت إلى مضخة أقوى.",
            ),
            ExplanationItem(
              title: "ساعات الضخ",
              description:
                  "عدد الساعات اليومية المتاحة لتشغيل المضخة. تقليل عدد الساعات يعني الحاجة إلى قدرة أعلى خلال وقت أقصر.",
            ),
            ExplanationItem(
              title: "ساعات ذروة الشمس",
              description:
                  "متوسط عدد ساعات الشمس الفعلية القوية في موقع المشروع، وهي قيمة مهمة لتحديد حجم الألواح المطلوبة.",
            ),
          ]
        : [
            ExplanationItem(
              title: "Daily Water Volume",
              description:
                  "Enter the amount of water you need to pump each day in cubic meters. This is a core input for estimating the energy requirement.",
            ),
            ExplanationItem(
              title: "Total Dynamic Head (TDH)",
              description:
                  "This includes the vertical lift, pipe friction losses, and the required pressure at the outlet. Higher TDH means a stronger pump and more power are needed.",
            ),
            ExplanationItem(
              title: "Pumping Hours",
              description:
                  "The number of hours per day available to run the pump. Fewer hours usually mean a higher required pumping power.",
            ),
            ExplanationItem(
              title: "Peak Sun Hours",
              description:
                  "The average number of effective strong-sun hours at the project location, used to size the solar array for the pump.",
            ),
          ];
  }

  // --- Direction ---
  List<ExplanationItem> getDirectionExplanations() {
    return isAr
        ? [
            ExplanationItem(
              title: "خط العرض",
              description:
                  "هو موقعك الجغرافي شمالاً أو جنوباً بالنسبة لخط الاستواء، ويستخدم لتقدير أفضل زاوية ميل للألواح.",
            ),
            ExplanationItem(
              title: "الاتجاه",
              description:
                  "هو الاتجاه الذي يجب أن تواجهه الألواح لتحقيق أفضل استقبال للشمس. غالباً يكون الجنوب في النصف الشمالي من الكرة الأرضية، والشمال في النصف الجنوبي.",
            ),
            ExplanationItem(
              title: "زاوية الميل",
              description:
                  "هي الزاوية بين اللوح وسطح الأرض. في كثير من الحالات تكون الزاوية السنوية المناسبة قريبة من قيمة خط العرض.",
            ),
          ]
        : [
            ExplanationItem(
              title: "Latitude",
              description:
                  "Your position north or south of the equator. It is used to estimate a suitable panel tilt angle.",
            ),
            ExplanationItem(
              title: "Direction",
              description:
                  "The compass direction the panels should face for the best solar exposure. This is usually south in the Northern Hemisphere and north in the Southern Hemisphere.",
            ),
            ExplanationItem(
              title: "Tilt Angle",
              description:
                  "The angle between the panel and the ground. For year-round performance, the tilt is often close to the site latitude.",
            ),
          ];
  }

  // --- General Hints ---
  List<ExplanationItem> getGeneralHints() {
    return isAr
        ? [
            ExplanationItem(
              title: "لماذا تختار الطاقة الشمسية؟",
              description:
                  "تساعدك أنظمة الطاقة الشمسية على توفير فواتير الكهرباء وتأمين طاقة مستدامة وصديقة للبيئة في منزلك أو عملك.",
            ),
            ExplanationItem(
              title: "نصيحة للمبتدئين",
              description:
                  "قبل البدء بشراء المعدات، استخدم قسم (أدوات الحساب) لتحديد عدد الألواح والبطاريات المناسبة لاستهلاكك الفعلي.",
            ),
            ExplanationItem(
              title: "أهمية الاستهلاك اليومي",
              description:
                  "حساب استهلاكك اليومي (بالواط) بدقة يجنبك شراء نظام أكبر من حاجتك أو أضعف مما تتوقع.",
            ),
          ]
        : [
            ExplanationItem(
              title: "Why go solar?",
              description:
                  "Solar energy systems help you save on electricity bills and secure sustainable, eco-friendly energy for your home or business.",
            ),
            ExplanationItem(
              title: "Beginner's Tip",
              description:
                  "Before buying equipment, use the 'Calculator Tools' section to determine exactly how many panels and batteries fit your actual usage.",
            ),
            ExplanationItem(
              title: "The Importance of Daily Usage",
              description:
                  "Accurately calculating your daily energy usage (in Watts) prevents you from buying a system that's too big or too weak for your needs.",
            ),
          ];
  }
}

class ExplanationItem {
  final String title;
  final String description;

  ExplanationItem({required this.title, required this.description});
}
