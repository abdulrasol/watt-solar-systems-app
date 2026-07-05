import { List, useTable, DateField } from "@refinedev/antd";
import { Table } from "antd";
import React from "react";

// Note: Ensure the API endpoint maps correctly since it is app_config/controllers/admin-company.controller.ts

export const AdminCompanyList: React.FC = () => {
  const { tableProps } = useTable({ syncWithLocation: true });

  return (
    <List>
      <Table {...tableProps} rowKey="id">
        <Table.Column dataIndex="id" title="ID" />
        <Table.Column dataIndex="name" title="الاسم" />
        <Table.Column dataIndex="status" title="الحالة" />
        <Table.Column dataIndex="phone" title="رقم الهاتف" />
        <Table.Column 
          dataIndex="created_at" 
          title="تاريخ الإنشاء" 
          render={(value: string) => <DateField value={value} format="YYYY-MM-DD" />}
        />
      </Table>
    </List>
  );
};
