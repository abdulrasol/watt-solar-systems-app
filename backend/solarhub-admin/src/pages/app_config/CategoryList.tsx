import { List, useTable } from "@refinedev/antd";
import { Table } from "antd";
import React from "react";

export const CategoryList: React.FC = () => {
  const { tableProps } = useTable({ syncWithLocation: true });

  return (
    <List>
      <Table {...tableProps} rowKey="id">
        <Table.Column dataIndex="id" title="ID" />
        <Table.Column dataIndex="name" title="الاسم (Name)" />
        <Table.Column dataIndex="icon" title="الأيقونة" />
      </Table>
    </List>
  );
};
