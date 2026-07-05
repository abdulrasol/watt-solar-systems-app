import { List, useTable, DateField, TagField } from "@refinedev/antd";
import { Table } from "antd";
import React from "react";

export const NotificationList: React.FC = () => {
  const { tableProps } = useTable({ syncWithLocation: true });

  return (
    <List>
      <Table {...tableProps} rowKey="id">
        <Table.Column dataIndex="id" title="ID" />
        <Table.Column dataIndex="title" title="العنوان" />
        <Table.Column dataIndex="body" title="المحتوى" />
        <Table.Column dataIndex="notification_type" title="النوع" />
        <Table.Column dataIndex="user_id" title="معرف المستخدم" />
        <Table.Column 
          dataIndex="is_read" 
          title="مقروءة؟" 
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
