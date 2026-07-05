import { 
  List, 
  useTable, 
  EditButton, 
  ShowButton, 
  DeleteButton,
  TagField,
  EmailField,
  DateField
} from "@refinedev/antd";
import { Table, Space } from "antd";
import React from "react";

export const UserList: React.FC = () => {
  const { tableProps } = useTable({
    syncWithLocation: true,
  });

  return (
    <List>
      <Table {...tableProps} rowKey="id">
        <Table.Column dataIndex="id" title="ID" />
        <Table.Column dataIndex="username" title="اسم المستخدم (Username)" />
        <Table.Column 
          dataIndex="email" 
          title="البريد الإلكتروني (Email)" 
          render={(value: string) => <EmailField value={value} />}
        />
        <Table.Column dataIndex="first_name" title="الاسم الأول" />
        <Table.Column dataIndex="last_name" title="اسم العائلة" />
        <Table.Column 
          dataIndex="is_active" 
          title="الحالة" 
          render={(value: boolean) => (
            <TagField value={value ? 'نشط' : 'غير نشط'} color={value ? 'green' : 'red'} />
          )}
        />
        <Table.Column 
          dataIndex="is_superuser" 
          title="الصلاحية" 
          render={(value: boolean) => (
            <TagField value={value ? 'مدير عام' : 'مستخدم'} color={value ? 'gold' : 'blue'} />
          )}
        />
        <Table.Column 
          dataIndex="created_at" 
          title="تاريخ التسجيل" 
          render={(value: string) => <DateField value={value} format="YYYY-MM-DD" />}
        />
        <Table.Column
          title="الإجراءات"
          dataIndex="actions"
          render={(_, record: any) => (
            <Space>
              <EditButton hideText size="small" recordItemId={record.id} />
              <ShowButton hideText size="small" recordItemId={record.id} />
              <DeleteButton hideText size="small" recordItemId={record.id} />
            </Space>
          )}
        />
      </Table>
    </List>
  );
};
