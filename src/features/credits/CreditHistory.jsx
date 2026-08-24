import useResponsive from "@/hooks/useResponsive";
import { formatIndianCurrency } from "@/utils/currencyUtils";
import { roundUp } from "@/utils/numberUtils";
import DataTable from "@/components/DataTable";
import NameWithTooltip from "@/components/NameWithTooltip";
import dayjs from "dayjs";

const CreditHistory = ({
  data,
  loading,
  page,
  totalItems,
  rowsPerPage,
  totalAmount,
  onPageChange,
  onView,
  onEdit,
  onDelete,
  emptyMessage,
}) => {

  const { isMobile } = useResponsive();
  const tableHeaderRowSx = {
    backgroundColor: "#f3f0ff",
  };
  const tableHeaderCellSx = {
    color: "#203A8F",
    fontWeight: 600,
    backgroundColor: "inherit",
    whiteSpace: "nowrap",
  };

  const columns = {
    desktop: [
      { key: "billNumber", width: "12%", label: "Invoice Number" },
      {
        key: "date",
        label: "Date",
        width: "10%",
        render: (row) =>
          row.date ? dayjs(row.date).format("DD-MM-YYYY") : "-",
      },
      { key: "paymentType", width: "12%", label: "Payment Type" },
      {
        key: "supplierName",
        label: "Supplier",
        render: (row) => (
          <NameWithTooltip name={row.supplierName} city={row.supplierCity} />
        ),
      },
      {
        key: "customerName",
        label: "Customer",
        render: (row) => (
          <NameWithTooltip name={row.customerName} city={row.customerCity} />
        ),
      },
      { key: "referenceNumber", width: "16%", label: "Reference No" },
      {
        key: "receivedAmount",
        width: "10%",
        label: "Amount",
        render: (row) =>
          row.receivedAmount != null
            ? formatIndianCurrency(roundUp(row.receivedAmount))
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
      totalAmount={totalAmount}
      actions={true}
      onView={onView}
      onEdit={onEdit}
      onDelete={onDelete}
      emptyMessage={emptyMessage}
      headerRowSx={tableHeaderRowSx}
      headerCellSx={tableHeaderCellSx}
      actionsHeaderSx={tableHeaderCellSx}
    />
  );
};

export default CreditHistory;
