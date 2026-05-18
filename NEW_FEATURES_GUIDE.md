# Solar Hub — Premium New Features Guide

Welcome to the **Solar Hub Premium Feature Suite**! We have successfully designed, built, and polished a set of high-impact, state-of-the-art features across the entire stack. This document details each feature, how to access it, and its underlying design/logic.

---

## 🌿 Phase 1: Admin Data Hub Revamp & State Optimization

### 1. Modernized Botanical Admin UI
* **Description:** The `AdminDataHubScreen` has been completely redesigned with a curated premium botanical color palette, clean glassmorphism containers, smooth fade/sliding animated tabs, and interactive metrics cards.
* **How to Access:** 
  1. Log in with an **Admin** account.
  2. Navigate to **Admin Data Hub** from the settings or navigation drawer.
  3. Explore the **Overview**, **Join Requests**, and **Analytics** tabs. Enjoy the custom sliding transitions and hover/press micro-animations.

### 2. Tab-Based Join Requests Filtering
* **Description:** Resolved state synchronization bugs and added real-time, tab-based server-side filtering for registration requests.
* **How to Access:**
  1. Go to **Admin Data Hub** -> **Join Requests** tab.
  2. Tap the filter pills at the top (**Pending**, **Approved**, **Rejected**).
  3. Notice that the UI instantly synchronizes, requests the corresponding state from the server, and displays localized empty states or cards with accurate badges.

---

## 🔔 Phase 2: Real-time Multi-Channel Notification Hub

### 1. Appwrite WebSocket Real-time Service
* **Description:** A robust background real-time listener connected to Appwrite websocket channels that dynamically listens for updates.
* **Channels Covered:**
  * **User/Buyer Channel:** Listens to new offer replies, system notifications, or bids on your solar requests.
  * **Storefront/Order Channel:** Listens for new B2C/B2B orders placed, updating order listings and notifying sellers in real-time.
  * **System/Admin Channel:** Listens for join request status updates and admin alerts.

### 2. Premium In-App Notification Overlay (Toast System)
* **Description:** A beautiful, non-intrusive floating toast overlay that slides in from the top of the screen whenever a notification is received. It features a modern green botanical border, semi-transparent blur, smooth spring entrance, and dismiss-on-swipe gesture behavior.
* **How to Access:** Keep the app open. Whenever a new offer, order, or request is received, the overlay will automatically slide into view with professional sound feedback.

---

## 💼 Phase 3: Sales CRM and Lead Capture Automation

### 1. Lead Visual Representation & Manual Conversion
* **Description:** Designed a dedicated visual card for CRM leads. Features contact details, specialized icons, and a conversion button.
* **How to Access:**
  1. Go to **CRM / Customers** section from your company dashboard.
  2. Tap the **Leads** tab.
  3. You will see a list of potential leads. Tap **Convert to Lead** on a request card to manually ingest a marketplace request as a permanent sales prospect.

### 2. Automated Lead Capture (Marketplace to CRM Ingestion)
* **Description:** Fully automated B2B/B2C transition flow. When your company makes a bid or responds to an offer request from a buyer, the buyer's profile is automatically registered as a new **Lead** record in your company's CRM database (both frontend and backend).
* **How to Access:**
  1. Go to **Marketplace / Solar Requests**.
  2. Select an open request and tap **Send Offer / Reply**.
  3. Submit your bid.
  4. Navigate to your **CRM -> Leads** page; you will find that the buyer has been automatically added to your sales pipelines as a CRM Lead with their full name, phone number, email, and city pre-filled.

### 3. Granular Value-Equality State Optimization
* **Description:** Refactored dashboard state providers and the `CompanyStats` model to use deep structural value-equality (`operator ==` and `hashCode`). This allows Riverpod selectors (`ref.watch(companyStatsProvider.select(...))`) to optimize rebuild signals and completely eliminate redundant dashboard widget redraws or count-up animation resets when identical stats are re-fetched.
* **How to Access:**
  1. Go to the **Company Dashboard**.
  2. Notice the sleek animated circular graphs and summary indicators.
  3. As metrics poll or refresh in the background, the graphs and counters stay perfectly smooth without flickering or re-animating, updating only when values actually change.

### 4. Real-time Notification Center Integration & In-App Toasts
* **Description:** Connected a broadcast stream from `PushNotificationService` to `NotificationHistoryController`. Foreground push messages received via Firebase Cloud Messaging (FCM) or Apple Push Notification Service (APNs) are intercepted and immediately processed. This updates the notifications count badge and list in real-time, and triggers a premium, context-safe in-app Toast notification.
* **How to Access:**
  1. Observe the notification bell icon badge count in the dashboard header.
  2. Receive a foreground notification (e.g., a new offer bid or order).
  3. A beautiful floating Toast appears at the bottom of the screen.
  4. The bell badge count instantly increments in real-time without needing a manual refresh or waiting for the polling timer.

---

## 📐 Phase 4: Visual Roof Grid Layout Simulator with Custom Specifications Configuration & In-App Help System

### 1. Interactive Visual 2D Roof Grid Canvas
* **Description:** A premium state-of-the-art interactive drawing canvas supporting multi-mode tool painting (**Solar Panels**, **Building Obstacles/ACs**, **Wall Shadows**, **Tree Shading**, and **Eraser**) with dynamic sizing, live metrics dashboard, and smart autofill logic that avoids all obstacles and shadows. It features **non-destructive cell preservation**, keeping your painted layout intact when resizing the roof!
* **How to Access:**
  1. Open the app, and navigate to **Calculator Landing Page** (Calculators).
  2. Under the Quick Tools section, tap **Roof Simulator** (محاكي الأسطح والألواح).
  3. Draw on the grid cells using the scrollable toolbar containing Panels, Obstacles, Shadows, Trees, and Eraser!

### 2. Custom Mechanical and Electrical Specifications Controls
* **Description:** Elegant collapsible glassmorphic settings panels allowing users to define physical parameters.
  * **Roof Dimensions Configuration:** Input the actual physical **Roof Width (m)** and **Roof Length (m)** side-by-side in one row with an `ExplanationButton`. The grid columns and rows will automatically calculate to fit maximum panels!
  * **Panel Rated Power (Watts):** Customizable via number text input (pre-filled with the default **`620W`**).
  * **Panel Dimensions (meters):** Side-by-side **Length** and **Width** text fields. It instantly calculates and displays the resulting occupied surface area (pre-filled with the default **`2.20 m × 1.10 m = 2.42 m²`**).
  * **Structural Weight (kg):** Sleek slider pre-filled with the default **`22 kg`**.
* **How to Access:** Go to the **Roof Simulator** tool, scroll to the **Roof Dimensions** or **Panel Specifications** cards. Type new dimensions into the side-by-side inputs and see the layout size adapt instantly without losing your drawing!

### 3. Integrated Global Help System
* **Description:** Seamlessly integrates our premium in-app explanation system. Replaced basic alert popups with the custom **`ExplanationButton`** that summons a premium semi-transparent **`ExplanationDialog`** with custom slide-in animations.
* **How to Access:** 
  1. Tap the information/question icon in the top right corner of the **Roof Simulator AppBar** to read how the visual simulator works.
  2. Tap the help icon next to the **Roof Width and Length** inputs or the **Panel Length and Width** inputs to read the physical sizing guidelines.

### 4. Sunlight Orientation, Shading Buffer Zones, & Shading Loss Simulation
* **Description:** Real-world physical shadowing and orientation simulation:
  * **Sunlight Facing & Panel Orientation:** A premium card with a selector for the panel direction: **South** (recommended for Northern hemisphere/Middle East), **North**, **East**, or **West**.
  * **Smart Shade Buffer Avoidance:** A high-end toggle button. When enabled, **Smart Autofill** calculates the sun's path and leaves a 1-cell buffer zone in the direction opposite the sun (shadow cast area) around trees, structures, and parapets to maximize overall panel efficiency.
  * **Live Shading Warnings:** If the user manually paints a panel within an active shade zone, the cell visualizer automatically transitions to a slate blue-grey panel style with a warning border and triggers a warning caution overlay icon.
  * **Dynamic Shading Power Loss:** Shaded panels dynamically experience a **70% power loss** in the metrics engine, causing the peak output value to update in real-time.
* **How to Access:** Go to the **Roof Simulator**, select **South** or **East** facing, place an obstacle/tree next to your panels, and watch the panel cells dynamically adapt their styling, caution badges, and live system peak output power!

---

## 🛠️ Global Architecture Rules & Conventions (Project Roles)
* **Explanation / Help Dialog Rule:** To maintain design coherence and provide a consistent premium user experience:
  * **DO NOT** use default `showDialog` or `AlertDialog` boxes for educational explanations, user help, or glossary descriptors.
  * **ALWAYS** use the custom **`ExplanationButton`** widget, passing an array of `ExplanationItem` objects. This ensures that help overlays are rendered inside the premium, animated, semi-transparent **`ExplanationDialog`** globally across all screens and calculators in the application.
  * **Single-Row Dimensional Standard:** Group panel dimensions (such as Length and Width text inputs) in a single horizontal row followed by an `ExplanationButton` for a clean, compact aesthetic.

