import DataTable from "./DataTable";
import dayjs from "dayjs";

const PurchaseHistory = ({
  data,
  loading,
  page,
  totalItems,
  rowsPerPage,
  onPageChange,
  onEdit,
  onDelete,
  emptyMessage,
}) => {
  const columns = [
    { key: "id", label: "Purchase ID" },
    {
      key: "date",
      label: "Date",
      render: (r) => (r.date ? dayjs(r.date).format("DD-MM-YYYY") : "-"),
    },
    { key: "staffName", label: "Staff" },
    { key: "supplierName", label: "Supplier" },
    { key: "customerName", label: "Customer" },
    { key: "purchaseAmount", label: "Amount" },
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
      onEdit={onEdit}
      onDelete={onDelete}
      emptyMessage={emptyMessage}
    />
  );
};

export default PurchaseHistory;
