import { List, useTable, DateField, TagField } from "@refinedev/antd";
import { Table } from "antd";
import React from "react";

export const SubscriptionList: React.FC = () => {
  const { tableProps } = useTable({ syncWithLocation: true });

  return (
    <List>
      <Table {...tableProps} rowKey="id">
        <Table.Column dataIndex="id" title="ID" />
        <Table.Column dataIndex="name" title="الاسم" />
        <Table.Column dataIndex="duration_days" title="المدة (بالأيام)" />
        <Table.Column dataIndex="price" title="السعر" />
        <Table.Column 
          dataIndex="is_active" 
          title="مفعلة؟" 
          render={(value: boolean) => (
            <TagField value={value ? 'نعم' : 'لا'} color={value ? 'green' : 'red'} />
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
