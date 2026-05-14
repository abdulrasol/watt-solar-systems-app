# SolarHub Project TODO List

This file tracks suggested edits, new features, and technical debt. Mark items as `[x]` when completed.

## 🚀 High Priority
- [x] Standardize API Data Fetching: Remove pagination from Countries and Cities endpoints (Backend & Frontend).
- [ ] UI Localization: Translate hardcoded strings in `direction_calculator.dart`.
- [ ] Admin CRUD: Implement Create, Update, Delete operations for App Configurations in the Admin Dashboard.
- [ ] System Requests: Implement "Submit Request" logic in `system_request_confirmation_sheet.dart`.

## ✨ New Features
- [ ] Enable Store: Finalize and enable the store module in `user_dashboard.dart`.
- [ ] Notification Cleanup: Handle `ServiceRequest` references in `notification_content_widget.dart` after module removal.

## 🛠 Technical Debt & Refactoring
- [ ] Localization parity: Ensure all language files have parity with `en.dart`.
- [ ] Test coverage: Update and expand admin shell tests after module refactoring.

## ✅ Completed Tasks
- [x] Remove "Service Requests" module from Admin Dashboard.
- [x] Standardize Countries/Cities API to use non-paginated lists.
- [x] Enhance Offer Requests: Show user names, avatars, and implement refined lifecycle (offered -> accepted -> closed).
- [x] Full Localization: Migrate Offer Reply, Solar Request, and Offer Details to `AppLocalizations`.
- [x] Fix compilation errors in Admin Dashboard screens and controllers.
