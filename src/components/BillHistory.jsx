import DataTable from "./DataTable";
import dayjs from "dayjs";

const BillHistory = ({
  data,
  loading,
  page,
  totalItems,
  rowsPerPage,
  onPageChange,
  onView,
  onEdit,
  onDelete,
  emptyMessage,
}) => {
  const columns = [
    { key: "billNumber", label: "Bill Number" },
    {
      key: "date",
      label: "Date",
      render: (row) =>
        row.date ? dayjs(row.date).format("DD-MM-YYYY") : "-",
    },
    {
      key: "receivedDate",
      label: "Received Date",
      render: (row) =>
        row.receivedDate ? dayjs(row.receivedDate).format("DD-MM-YYYY") : "-",
    },
    { key: "order", label: "Order" },
    { key: "supplierName", label: "Supplier" },
    { key: "customerName", label: "Customer" },
    { key: "billAmount", label: "Bill Amount" },
  ];

  return (
    <DataTable
      columns={columns}
      data={data}
      loading={loading}
      page={page}
      totalCount={totalItems}
      rowsPerPage={rowsPerPage}
      onPageChange={onPageChange}
      actions={true}
      onView={onView}
      onEdit={onEdit}
      onDelete={onDelete}
      emptyMessage={emptyMessage}
    />
  );
};

export default BillHistory;
