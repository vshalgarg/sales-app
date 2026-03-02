import useResponsive from "../customHooks/useResponsive";
import PurchaseView from "../modals/PurchaseView";
import DataTable from "./DataTable";
import dayjs from "dayjs";
import { useState } from "react";

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
  const [viewData, setViewData] = useState(null);

  const handleView = (row) => {
    setViewData(row);
  };

  const handleCloseView = () => {
    setViewData(null);
  };

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
    <>
      <DataTable
        columns={isMobile ? columns.mobile : columns.desktop}
        data={data}
        loading={loading}
        page={page}
        totalCount={totalItems}
        rowsPerPage={rowsPerPage}
        onPageChange={onPageChange}
        actions
        onEdit={onEdit}
        onDelete={onDelete}
        onView={handleView}
        emptyMessage={emptyMessage}
      />

      {/* View Modal */}
      {viewData && (
        <PurchaseView
          open={!!viewData}
          data={viewData}
          onClose={handleCloseView}
        />
      )}
    </>
  );
};

export default PurchaseHistory;
