import type { AuthProvider } from "@refinedev/core";

const API_URL = "http://localhost:3000";

export const authProvider: AuthProvider = {
  login: async ({ identifier, email, password }) => {
    try {
      const loginId = identifier || email;
      const response = await fetch(`${API_URL}/auth/login`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ identifier: loginId, password }),
      });

      const data = await response.json();

      if (response.ok && data.body?.access_token) {
        // Check if user is a superuser
        if (data.body.user && data.body.user.is_superuser) {
          localStorage.setItem("token", data.body.access_token);
          return {
            success: true,
            redirectTo: "/",
          };
        } else {
          return {
            success: false,
            error: {
              name: "خطأ في الصلاحيات",
              message: "فقط مدراء النظام (Superusers) يمكنهم الدخول إلى لوحة التحكم.",
            },
          };
        }
      }

      return {
        success: false,
        error: {
          name: "خطأ في تسجيل الدخول",
          message: data.message || "البيانات المدخلة غير صحيحة",
        },
      };
    } catch (error) {
      return {
        success: false,
        error: {
          name: "خطأ في الاتصال",
          message: "لا يمكن الاتصال بالخادم، تأكد من تشغيل الباك‌اند على المنفذ 3000",
        },
      };
    }
  },
  logout: async () => {
    localStorage.removeItem("token");
    return {
      success: true,
      redirectTo: "/login",
    };
  },
  check: async () => {
    const token = localStorage.getItem("token");
    if (token) {
      return {
        authenticated: true,
      };
    }

    return {
      authenticated: false,
      redirectTo: "/login",
      logout: true,
    };
  },
  getPermissions: async () => null,
  getIdentity: async () => {
    const token = localStorage.getItem("token");
    if (!token) {
      return null;
    }

    try {
      const response = await fetch(`${API_URL}/auth/profile`, {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });
      const data = await response.json();
      if (response.ok && data.body) {
        return {
          id: data.body.id,
          name: data.body.first_name + " " + data.body.last_name,
          email: data.body.email,
          avatar: data.body.image || "https://i.pravatar.cc/300",
        };
      }
    } catch (error) {
      return null;
    }

    return null;
  },
  onError: async (error) => {
    console.error(error);
    if (error.response?.status === 401 || error.response?.status === 403) {
      return {
        logout: true,
      };
    }
    return { error };
  },
};
