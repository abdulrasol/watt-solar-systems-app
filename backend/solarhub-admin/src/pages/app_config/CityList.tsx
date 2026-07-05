import { List, useTable, DateField } from "@refinedev/antd";
import { Table } from "antd";
import React from "react";

export const CityList: React.FC = () => {
  const { tableProps } = useTable({ syncWithLocation: true });

  return (
    <List>
      <Table {...tableProps} rowKey="id">
        <Table.Column dataIndex="id" title="ID" />
        <Table.Column dataIndex="name" title="الاسم (Name)" />
        <Table.Column dataIndex="code" title="الرمز (Code)" />
        <Table.Column dataIndex="country_id" title="معرف الدولة (Country ID)" />
        <Table.Column 
          dataIndex="created_at" 
          title="تاريخ الإنشاء" 
          render={(value: string) => <DateField value={value} format="YYYY-MM-DD" />}
        />
      </Table>
    </List>
  );
};
