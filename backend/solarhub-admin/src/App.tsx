import { Refine, Authenticated } from "@refinedev/core";
import dataProvider, { axiosInstance } from "@refinedev/simple-rest";
import { BrowserRouter, Route, Routes, Outlet } from "react-router-dom";
import { ConfigProvider } from "antd";
import { ThemedLayoutV2, ThemedTitleV2, ErrorComponent, RefineThemes } from "@refinedev/antd";
import routerBindings, { NavigateToResource, UnsavedChangesNotifier, DocumentTitleHandler, CatchAllNavigate } from "@refinedev/react-router-v6";
import "@refinedev/antd/dist/reset.css";

import { authProvider } from "./authProvider";

// Import all list pages
import { UserList } from "./pages/users/list";
import { CityList } from "./pages/app_config/CityList";
import { CountryList } from "./pages/app_config/CountryList";
import { CurrencyList } from "./pages/app_config/CurrencyList";
import { AppConfigList } from "./pages/app_config/AppConfigList";
import { FeedbackList } from "./pages/app_config/FeedbackList";
import { NotificationList } from "./pages/app_config/NotificationList";
import { SubscriptionList } from "./pages/app_config/SubscriptionList";
import { CategoryList } from "./pages/app_config/CategoryList";
import { AdminCompanyList } from "./pages/app_config/AdminCompanyList";
import { Login } from "./pages/login";

// --- Interceptor to handle Authentication Token & NestJS Response Wrapper ---
axiosInstance.interceptors.request.use((config) => {
  const token = localStorage.getItem("token");
  if (token) {
    if (config.headers) {
      config.headers["Authorization"] = `Bearer ${token}`;
    }
  }
  return config;
});

axiosInstance.interceptors.response.use((response) => {
  if (response.data && response.data.body !== undefined) {
    if (response.data.body && response.data.body.data && Array.isArray(response.data.body.data)) {
      response.headers["x-total-count"] = response.data.body.total;
      response.data = response.data.body.data;
    } else if (Array.isArray(response.data.body)) {
      // Some endpoints might return an array directly in the body
      response.headers["x-total-count"] = response.data.body.length;
      response.data = response.data.body;
    } else {
      response.data = response.data.body;
    }
  }
  return response;
});

function App() {
  return (
    <BrowserRouter>
      <ConfigProvider theme={RefineThemes.Blue}>
        <Refine
          dataProvider={dataProvider("http://localhost:3000", axiosInstance)}
          routerProvider={routerBindings}
          authProvider={authProvider}
          resources={[
            { name: "auth", list: "/users", meta: { label: "المستخدمين" } },
            { name: "cities", list: "/cities", meta: { label: "المدن" } },
            { name: "countries", list: "/countries", meta: { label: "الدول" } },
            { name: "currencies", list: "/currencies", meta: { label: "العملات" } },
            { name: "config", list: "/config", meta: { label: "إعدادات التطبيق" } },
            { name: "feedbacks", list: "/feedbacks", meta: { label: "الملاحظات (Feedbacks)" } },
            { name: "notifications", list: "/notifications", meta: { label: "الإشعارات" } },
            { name: "subscriptions", list: "/subscriptions", meta: { label: "الاشتراكات" } },
            { name: "categories", list: "/categories", meta: { label: "التصنيفات" } },
            { name: "companies", list: "/companies", meta: { label: "الشركات" } },
          ]}
          options={{
            syncWithLocation: true,
            warnWhenUnsavedChanges: true,
          }}
        >
          <Routes>
            <Route
              element={
                <Authenticated
                  key="authenticated-layout"
                  fallback={<CatchAllNavigate to="/login" />}
                >
                  <ThemedLayoutV2
                    Title={({ collapsed }: { collapsed: boolean }) => (
                      <ThemedTitleV2
                        collapsed={collapsed}
                        text="SolarHub"
                      />
                    )}
                  >
                    <Outlet />
                  </ThemedLayoutV2>
                </Authenticated>
              }
            >
              <Route index element={<NavigateToResource resource="auth" />} />
              
              <Route path="/users" element={<UserList />} />
              <Route path="/cities" element={<CityList />} />
              <Route path="/countries" element={<CountryList />} />
              <Route path="/currencies" element={<CurrencyList />} />
              <Route path="/config" element={<AppConfigList />} />
              <Route path="/feedbacks" element={<FeedbackList />} />
              <Route path="/notifications" element={<NotificationList />} />
              <Route path="/subscriptions" element={<SubscriptionList />} />
              <Route path="/categories" element={<CategoryList />} />
              <Route path="/companies" element={<AdminCompanyList />} />

              <Route path="*" element={<ErrorComponent />} />
            </Route>

            <Route
              element={
                <Authenticated
                  key="authenticated-outer"
                  fallback={<Outlet />}
                >
                  <NavigateToResource />
                </Authenticated>
              }
            >
              <Route path="/login" element={<Login />} />
            </Route>
          </Routes>
          <UnsavedChangesNotifier />
          <DocumentTitleHandler />
        </Refine>
      </ConfigProvider>
    </BrowserRouter>
  );
}

export default App;
