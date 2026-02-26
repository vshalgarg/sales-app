import useResponsive from "../customHooks/useResponsive";
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

  const { isMobile } = useResponsive();

  const columns = {
    desktop: [
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
      {
        key: "billAmount",
        label: "Bill Amount",
        render: (row) =>
          row.billAmount != null
            ? Number(row.billAmount).toFixed(2)
            : "-"
      },
    ],
    mobile: [
      { key: "billNumber", label: "Bill No" },
      {
        key: "date",
        label: "Date",
        render: (row) =>
          row.date ? dayjs(row.date).format("DD-MM-YYYY") : "-",
      },
      { key: "billAmount", label: "Amount" },
    ],
  };

  return (
    <DataTable
      columns={isMobile ? columns.mobile : columns.desktop}
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
