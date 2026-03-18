import useResponsive from "../customHooks/useResponsive";
import { roundUp } from "../utils/numberUtils";
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
      { key: "paymentType", label: "Payment Type" },
      { key: "supplierName", label: "Supplier" },
      { key: "customerName", label: "Customer" },
      { key: "referenceNumber", label: "Reference No" },
      {
        key: "receivedAmount",
        label: "Amount",
        render: (row) =>
          row.receivedAmount != null
            ? roundUp(row.receivedAmount)
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
      {
        key: "receivedAmount",
        label: "Received Amount",
        render: (row) =>
          row.receivedAmount != null
            ? roundUp(row.receivedAmount)
            : "-"
      },
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

export default CreditHistory;
