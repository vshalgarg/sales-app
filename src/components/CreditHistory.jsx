import DataTable from "./DataTable";
import dayjs from "dayjs";

const CreditHistory = ({
  data,
  loading,
  page,
  totalItems,
  rowsPerPage,
  onPageChange,
  onView,
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
    { key: "paymentType", label: "Payment Type" },
    { key: "supplierName", label: "Supplier" },
    { key: "customerName", label: "Customer" },
    { key: "referenceNumber", label: "Reference No" },
    { key: "receivedAmount", label: "Received Amount" },
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
      emptyMessage={emptyMessage}
    />
  );
};

export default CreditHistory;
