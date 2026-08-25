import useResponsive from "../customHooks/useResponsive";
import PurchaseView from "../modals/PurchaseView";
import {
  getPurchaseDetailsById,
  getSupplierDataByCustomer,
} from "../service/PurchaseService";
import { IconButton, Tooltip, CircularProgress } from "@mui/material";
import ContentCopyIcon from "@mui/icons-material/ContentCopy";
import { getSuppliersFormattedText } from "../utils/copyFormatter";
import CopyDetailsModal from "../components/common/CopyDetailsModal";
import DataTable from "./DataTable";
import dayjs from "dayjs";
import { useState } from "react";
import { useSnackbar } from "../context/SnackbarContext";
import NameWithTooltip from "./common/NameWithTooltip";

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
  const tableHeaderRowSx = {
    backgroundColor: "#f3f0ff",
  };
  const tableHeaderCellSx = {
    color: "#203A8F",
    fontWeight: 600,
    backgroundColor: "inherit",
    whiteSpace: "nowrap",
  };
  const [viewData, setViewData] = useState(null);
  const [copyData, setCopyData] = useState(null);
  const [copyLoadingId, setCopyLoadingId] = useState(null);
  const { showSnackbar } = useSnackbar();

  const handleCopyClick = async (row) => {
    try {
      setCopyLoadingId(row.id);

      const result = await getSupplierDataByCustomer({
        fromDate: row.date,
        toDate: row.date,
        customerId: row.customerId,
      });
      setCopyData(
        getSuppliersFormattedText(result, {
          date: row.date,
          customerName: row.customerName,
        }),
      );
    } catch {
      showSnackbar("Failed to load copy data", "error");
    } finally {
      setCopyLoadingId(null);
    }
  };

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
          <NameWithTooltip name={r.supplierName} city={r.supplierCity} />
        ),
      },

      {
        key: "customerName",
        label: "Customer",
        width: "18%",
        render: (r) => (
          <div className="flex items-center gap-1 min-w-0">
            <NameWithTooltip name={r.customerName} city={r.customerCity} />

            {r.customerId && (
              <Tooltip title="Copy supplier data">
                <span>
                  <IconButton
                    size="small"
                    onClick={(e) => {
                      e.stopPropagation();
                      handleCopyClick(r);
                    }}
                    disabled={copyLoadingId === r.id}
                  >
                    {copyLoadingId === r.id ? (
                      <CircularProgress size={14} />
                    ) : (
                      <ContentCopyIcon sx={{ fontSize: 14 }} />
                    )}
                  </IconButton>
                </span>
              </Tooltip>
            )}
          </div>
        ),
      },

      {
        key: "remarks",
        label: "Remarks",
        width: "16%",
        render: (r) => (r.remarks != null ? r.remarks : "-"),
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
          <NameWithTooltip name={r.supplierName} city={r.supplierCity} />
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
        headerRowSx={tableHeaderRowSx}
        headerCellSx={tableHeaderCellSx}
        actionsHeaderSx={tableHeaderCellSx}
      />

      {/* View Modal */}
      {viewData && (
        <PurchaseView
          open={!!viewData}
          data={viewData}
          onClose={handleCloseView}
        />
      )}

      {copyData && (
        <CopyDetailsModal
          open={!!copyData}
          title="Supplier Details"
          formattedText={copyData}
          showSelection={false}
          onClose={() => setCopyData(null)}
        />
      )}
    </>
  );
};

export default PurchaseHistory;
