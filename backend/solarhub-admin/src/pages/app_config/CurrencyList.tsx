import { List, useTable, DateField, TagField } from "@refinedev/antd";
import { Table } from "antd";
import React from "react";

export const CurrencyList: React.FC = () => {
  const { tableProps } = useTable({ syncWithLocation: true });

  return (
    <List>
      <Table {...tableProps} rowKey="id">
        <Table.Column dataIndex="id" title="ID" />
        <Table.Column dataIndex="name" title="الاسم (Name)" />
        <Table.Column dataIndex="code" title="الرمز (Code)" />
        <Table.Column dataIndex="symbol" title="العلامة (Symbol)" />
        <Table.Column 
          dataIndex="is_default" 
          title="الافتراضي؟" 
          render={(value: boolean) => (
            <TagField value={value ? 'نعم' : 'لا'} color={value ? 'green' : 'default'} />
          )}
        />
        <Table.Column 
          dataIndex="created_at" 
          title="تاريخ الإنشاء" 
          render={(value: string) => <DateField value={value} format="YYYY-MM-DD" />}
        />
      </Table>
    </List>
  );
};
