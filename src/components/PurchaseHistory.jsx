import useResponsive from "../customHooks/useResponsive";
import PurchaseView from "../modals/PurchaseView";
import { getPurchaseDetailsById } from "../service/PurchaseService";
import DataTable from "./DataTable";
import dayjs from "dayjs";
import { useState } from "react";
import { roundUp } from "../utils/numberUtils";


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

  const handleView = async (row) => {
  try {

    const detail = await getPurchaseDetailsById(row.id);

    setViewData(detail);

  } catch {
    showSnackbar("Failed to load purchase details", "error");
  }
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
        key: "remarks",
        label: "Remarks",
        render: (r) =>
          r.remarks != null
            ? r.remarks
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
