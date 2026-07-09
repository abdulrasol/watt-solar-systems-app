---
trigger: always_on
---

# Project Rules

---
description: Comprehensive project architecture, backend integration, pagination, error handling, and code quality standards for this workspace.
globs: **/*
---

## Project Context & External References

- **Backend Location:** The backend code for this application is located locally at `/Users/rasol/DevsTools/codes/flutter/watt/go_backend`.
- **Action Required:** Before editing APIs, creating new endpoints, or completing tasks, you MUST read the Python backend source code at this path to fully understand the payload models, database logic, and API responses. Ensure frontend implementations match the backend logic perfectly.

## API & URL Configuration

- **API Registry File:** `lib/src/utils/app_urls.dart`
- **Action Required:** Whenever a backend API is added, modified, or referenced, you must update or add the endpoint string inside `lib/src/utils/app_urls.dart`. Organize the URLs strictly under their corresponding categorized lists.
- **Connectivity:** When working in debug mode, ensure `baseUrl` handles the platform mapping correctly: `10.0.2.2` for Android Emulator and `127.0.0.1` for iOS/Desktop to ensure connectivity to the local backend.

## Architecture, Core Models & Errors

- **Architectural Pattern:** Follow **Clean Architecture** principles strictly (Separation of concerns: Data, Domain, and Presentation layers).
- **Base Response Model:** Use `lib/src/core/models/response.dart` as the standard base response model for all data parsing and API handling. If a new API feature requires changes, extend or modify this specific base file cautiously.
- **Error Handling:** Centralize and manage all application exceptions, failures, and network errors using the classes and utilities defined in `lib/src/core/errors/`.

## UI Patterns & UX Behaviors

- **Refresh Mechanism:** Implement a "pull-down-to-refresh" mechanism on all scrollable list views and dashboard data feeds to reload content.
- **Pagination Strategy:**
  - Set the hardcoded pagination limit to exactly **12 items** per page/request.
  - Implement automatic next-page loading triggered when the user scrolls to the bottom of the list (Infinite Scrolling), provided a next page is available from the API response.
- **Widget Modularization:** Never write massive single-file UI widgets. Reduce code size by breaking down large screens or complex widgets into small, isolated widget files. This makes maintenance and testing easier.
- **Shared Utilities & Mixins:**
  - Check `lib/src/utils/helper_methods.dart` first before writing any utility logic; reuse existing helpers whenever possible.
  - If a UI configuration, theme, or component pattern is repeated across the app, extract it into a dedicated mixin or place it in the global utility folder (`lib/src/utils/`).

## Code Quality & Documentation

- **Performance & Memory:** Every code modification or new feature must prioritize low memory usage and high rendering performance. Avoid unnecessary rebuilds and deep widget trees.
- **Documentation:** Add clear, comprehensive code comments to explain the underlying logic for every single edit or new feature written, ensuring easy future maintenance.
- **Mandatory Quality Check:** After every code modification, especially those linked to backend APIs, you MUST run `flutter analyze`. You are strictly required to resolve all reported errors, warnings, and info diagnostics immediately to maintain codebase integrity before finalizing any task.
