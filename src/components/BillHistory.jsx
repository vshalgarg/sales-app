import useResponsive from "../customHooks/useResponsive";
import { formatIndianCurrency } from "../utils/currencyUtils";
import { roundUp } from "../utils/numberUtils";
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
      { key: "invoiceNo", width: "14%", label: "Invoice Number" },
      {
        key: "date",
        label: "Date",
        width: "12%",
        render: (row) =>
          row.date ? dayjs(row.date).format("DD-MM-YYYY") : "-",
      },
      {
        key: "receivedDate",
        label: "Received Date",
        width: "14%",
        render: (row) =>
          row.receivedDate ? dayjs(row.receivedDate).format("DD-MM-YYYY") : "-",
      },
      {
        key: "supplierName", width: "22%", label: "Supplier",
        render: (row) => (
          <div className="flex flex-col">
            <span>{row.supplierName || "-"}</span>

            <span className="text-xs text-gray-500">
              {row.supplierCity || "-"}
            </span>
          </div>
        ),
      },
      {
        key: "customerName", width: "22%", label: "Customer",
        render: (row) => (
          <div className="flex flex-col">
            <span>{row.customerName || "-"}</span>

            <span className="text-xs text-gray-500">
              {row.customerCity || "-"}
            </span>
          </div>
        ),

      },
      {
        key: "billAmount",
        width: "10%",
        label: "Bill Amount",
        render: (row) =>
          row.billAmount != null
            ? formatIndianCurrency(roundUp(row.billAmount))
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
        key: "billAmount",
        label: "Amount",
        render: (row) =>
          row.billAmount != null
            ? formatIndianCurrency(roundUp(row.billAmount))
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

export default BillHistory;
