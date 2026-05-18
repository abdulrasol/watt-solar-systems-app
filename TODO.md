# 🏢 SolarHub B2B & Company Dashboard TODO List

This file tracks the evolution of the B2B side of the application. Mark items as `[x]` when completed.

## 🛠️ Phase 1: UI/UX Excellence & Polish (COMPLETED ✅)
- [x] **Data Visualization**: Add interactive charts (Revenue trends, Stock distribution) to `OverviewContent` using `fl_chart`.
- [x] **Modern Sidebar**: Refine the `SidebarContent` with better active states, hover effects, and a collapsible "Slim" mode for desktop.
- [x] **Quick Actions**: Add a "Quick Action" FAB or header menu for (Add Product, Create Offer, Invite Member).
- [x] **Empty States**: Design beautiful, branded empty states for new companies with no data yet.
- [x] **Search UI**: Implement a global search UI in the dashboard header.

## ⚙️ Phase 2: Functional Depth & Search (COMPLETED ✅)
- [x] **Global Search Logic**: Connect the Search UI to the backend to search across Inventory, Offers, and Contacts.
- [x] **Inventory Intelligence**: Implement low-stock alerts and bulk inventory import/export (CSV/Excel).
- [x] **Dynamic Analytics**: Refactor `DashboardCharts` to fetch real data from the `Accounting` and `Orders` providers.
- [x] **RBAC UI**: Implement a user interface for managing company member roles (Admin, Staff, Viewer).
- [x] **Invoicing System**: Generate and download PDF invoices for B2B orders directly from the Accounting module.

## 🚀 Phase 3: Performance & Advanced CRM (COMPLETED ✅)
- [x] **CRM Lead Linking**: Automatically create CRM leads when a user requests an offer from the company.
- [x] **Granular State Management**: Refactor `summary_provider.dart` to allow partial updates without re-triggering the full dashboard animation.
- [x] **Notification Center**: Implement the logic for the notification icon in the header (In-app notifications for new offers/orders).

---

## 📈 Phase 4: Financial & Savings Intelligence (UPCOMING)
- [ ] **Dynamic ROI & Solar Savings Calculator**: Develop a premium savings simulator with interactive input sliders (monthly electric bill, location/solar irradiation factor, and target system size).
- [ ] **Interactive Visual Analytics**: Integrate custom line and bar charts showing the break-even timeline, payback period (years), and cumulative savings over 25 years.
- [ ] **Localized Financial Metrics**: Add full English/Arabic localization for utility rate inflation, discount rate parameters, and initial system cost estimations.

---

## ✅ Completed (May 2026)
- [x] **Advanced CRM & Performance Suite (Phase 3)**: Automated lead capture triggers on marketplace bids, added value-based value equality to `CompanyStats` for highly optimized granular selector updates, and connected push messaging stream triggers to notification controller for real-time header count and in-app toasts.
- [x] **Granular Projects Roles & Permissions**: Integrated, secured, and enforced the `'projects'` permission key across workspace grids, sidebars, page actions, and deep-link routing.
- [x] **Full B2B Modularization**: Refactored all management screens (Inventory, Orders, CRM, Accounting, Work, Members, Contacts, Public Services, Categories) to support "embedded" mode.
- [x] **Unified Dashboard Navigation**: Centralized navigation in `DashboardContent` with dynamic switching and sidebar integration.
- [x] Standardize API Data Fetching (Non-paginated Countries/Cities).
- [x] UI Localization for Orientation Calculator.
- [x] Admin CRUD for App Configurations.
- [x] Orientation Calculator integration into Landing Page.
- [x] Store module activation and navigation.
- [x] Full Localization parity (English/Arabic).
- [x] Embedded Inventory, Orders, CRM, Accounting, and Company Work.
- [x] **Invoicing System**: Implemented PDF receipt generation and system invoice download integration via `PdfService` and `printing`.
