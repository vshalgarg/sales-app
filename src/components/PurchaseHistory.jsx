import useResponsive from "../customHooks/useResponsive";
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

  const { isMobile } = useResponsive();

  const columns = {
    desktop: [
      {
        key: "date",
        label: "Date",
        render: (r) => (r.date ? dayjs(r.date).format("DD-MM-YYYY") : "-"),
      },

      { key: "staffName", label: "Staff" },

      {
        key: "supplierNames",
        label: "Suppliers",
        render: (r) =>
          r.supplierNames && r.supplierNames.length > 0
            ? r.supplierNames.join(", ")
            : "-",
      },

      {
        key: "customerName",
        label: "Customer",
        render: (r) => r.customerName || "-",
      },

      {
        key: "purchaseAmount",
        label: "Amount",
        render: (r) =>
          r.purchaseAmount != null
            ? `₹ ${Number(r.purchaseAmount).toFixed(2)}`
            : "-",
      },
    ],

    mobile: [
      {
        key: "date",
        label: "Date",
        render: (r) => (r.date ? dayjs(r.date).format("DD-MM-YYYY") : "-"),
      },
      {
        key: "supplierNames",
        label: "Suppliers",
        render: (r) =>
          r.supplierNames && r.supplierNames.length > 0
            ? r.supplierNames.join(", ")
            : "-",
      },
      {
        key: "purchaseAmount",
        label: "Amount",
        render: (r) =>
          r.purchaseAmount != null
            ? `₹ ${Number(r.purchaseAmount).toFixed(2)}`
            : "-",
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
      onEdit={onEdit}
      onDelete={onDelete}
      emptyMessage={emptyMessage}
    />
  );
};

export default PurchaseHistory;
