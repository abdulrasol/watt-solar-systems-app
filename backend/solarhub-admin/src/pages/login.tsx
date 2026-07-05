import React from "react";
import { useLogin } from "@refinedev/core";
import { Form, Input, Button, Card, Typography, Space } from "antd";
import { ThemedTitleV2 } from "@refinedev/antd";

const { Title } = Typography;

export const Login: React.FC = () => {
  const { mutate: login, isPending } = useLogin();

  const onFinish = (values: any) => {
    login({
      identifier: values.identifier,
      password: values.password,
    });
  };

  return (
    <div
      style={{
        display: "flex",
        justifyContent: "center",
        alignItems: "center",
        height: "100vh",
        backgroundColor: "#f0f2f5",
      }}
    >
      <Card style={{ width: 400, padding: "20px" }}>
        <Space direction="vertical" align="center" style={{ width: "100%", marginBottom: "24px" }}>
          <ThemedTitleV2 collapsed={false} text="SolarHub Admin" />
          <Title level={4}>تسجيل الدخول</Title>
        </Space>
        
        <Form layout="vertical" onFinish={onFinish} requiredMark={false}>
          <Form.Item
            label="اسم المستخدم، الإيميل، أو رقم الهاتف"
            name="identifier"
            rules={[{ required: true, message: "الرجاء إدخال اسم المستخدم أو الإيميل أو رقم الهاتف" }]}
          >
            <Input 
              placeholder="admin / admin@example.com" 
              size="large"
            />
          </Form.Item>

          <Form.Item
            label="كلمة المرور"
            name="password"
            rules={[{ required: true, message: "الرجاء إدخال كلمة المرور" }]}
          >
            <Input.Password 
              placeholder="••••••••" 
              size="large"
            />
          </Form.Item>

          <Form.Item>
            <Button 
              type="primary" 
              htmlType="submit" 
              block 
              size="large"
              loading={isPending}
            >
              دخول
            </Button>
          </Form.Item>
        </Form>
      </Card>
    </div>
  );
};
