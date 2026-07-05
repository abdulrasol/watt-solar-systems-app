import { List, useTable, DateField, TagField } from "@refinedev/antd";
import { Table } from "antd";
import React from "react";

export const AppConfigList: React.FC = () => {
  const { tableProps } = useTable({ syncWithLocation: true });

  return (
    <List>
      <Table {...tableProps} rowKey="key">
        <Table.Column dataIndex="key" title="المفتاح (Key)" />
        <Table.Column 
          dataIndex="value" 
          title="القيمة (Value)" 
          render={(value: boolean) => (
            <TagField value={value ? 'صحيح (True)' : 'خطأ (False)'} color={value ? 'blue' : 'default'} />
          )}
        />
        <Table.Column dataIndex="description" title="الوصف" />
        <Table.Column 
          dataIndex="updated_at" 
          title="تاريخ التحديث" 
          render={(value: string) => <DateField value={value} format="YYYY-MM-DD" />}
        />
      </Table>
    </List>
  );
};
