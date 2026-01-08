import DataTable from "./DataTable";
import dayjs from "dayjs";

const PurchaseHistory = ({
  data,
  loading,
  page,
  totalItems,
  rowsPerPage,
  onPageChange,
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
      actions={false}
      emptyMessage={emptyMessage}
    />
  );
};

export default PurchaseHistory;
