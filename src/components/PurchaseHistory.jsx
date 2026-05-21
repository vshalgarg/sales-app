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
        width: "10%",
        render: (r) => (r.date ? dayjs(r.date).format("DD-MM-YYYY") : "-"),
      },

      { key: "staffName", width: "20%", label: "Staff" },

      {
        key: "supplierName",
        label: "Supplier",
        width: "22%",
        render: (r) => (
          <div className="flex flex-col">
            <span>{r.supplierName || "-"}</span>
            {r.supplierCity && (
              <span className="text-xs text-gray-500">
                {r.supplierCity}
              </span>
            )}
          </div>
        ),
      },

      {
        key: "customerName",
        label: "Customer",
        width: "18%",
        render: (r) => (
          <div className="flex flex-col">
            <span>{r.customerName || "-"}</span>
            {r.customerCity && (
              <span className="text-xs text-gray-500">
                {r.customerCity}
              </span>
            )}
          </div>
        ),
      },

      {
        key: "remarks",
        label: "Remarks",
        width: "16%",
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
        key: "supplierName",
        label: "Supplier",
        render: (r) => (
          <div className="flex flex-col">
            <span>{r.supplierName || "-"}</span>
            <span className="text-xs text-gray-500">
              {r.supplierCity || "-"}
            </span>
          </div>
        ),
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
