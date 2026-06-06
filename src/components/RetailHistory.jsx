import dayjs from "dayjs";
import ExpandableDataTable from "./ExpandableDataTable";
import { IconButton } from "@mui/material";
import VisibilityIcon from "@mui/icons-material/Visibility";
import EditIcon from "@mui/icons-material/Edit";
import DeleteIcon from "@mui/icons-material/Delete";
import AddIcon from "@mui/icons-material/Add";
import RetailerViewEdit from "../modals/RetailerViewEdit";

const RetailHistory = ({
  data,
  loading,
  page,
  totalItems,
  rowsPerPage,
  onPageChange,
  onEdit,
  onDelete,
  onView,
  onAddSupplier,
  onEditSupplier,
  onDeleteSupplier,
  emptyMessage,
}) => {
  const columns = [
    {
      key: "date",
      label: "Date",
      width: "15%",
      render: (r) => (r.date ? dayjs(r.date).format("DD-MM-YYYY") : "-"),
    },
    {
      key: "retailName",
      label: "Retailer",
      width: "20%",
    },
    {
      key: "referredByCustomerName",
      label: "Referred By",
      width: "30%",
      render: (r) => (
        <div className="flex flex-col">
          <span>{r.referredByCustomerName || "-"}</span>
          {r.customerCity && (
            <span className="text-xs text-gray-500">
              {r.referredByCustomerCity}
            </span>
          )}
        </div>
      ),
    },
    {
      key: "staffName",
      label: "Staff",
      width: "20%",
    },
  ];

  const expandedColumns = [
    {
      key: "supplierName",
      label: "Supplier",
      width: "25%",
      render: (s) => (
        <div className="flex flex-col">
          <span>{s.supplierName || "-"}</span>
          {s.supplierCity && (
            <span className="text-xs text-gray-500">{s.supplierCity}</span>
          )}
        </div>
      ),
    },
    {
      key: "totalAmount",
      label: "Total Amount",
      width: "18%",
      render: (s) => (s.totalAmount ? Math.round(s.totalAmount) : "-"),
    },
    {
      key: "depositAmount",
      label: "Deposit",
      width: "18%",
      render: (s) => (s.depositAmount ? Math.round(s.depositAmount) : "-"),
    },
    {
      key: "balanceAmount",
      label: "Balance",
      width: "18%",
      render: (s) => (s.balanceAmount ? Math.round(s.balanceAmount) : "-"),
    },
  ];

  const actionItems = [
    {
      label: "View",
      icon: VisibilityIcon,
      onClick: (row) => onView(row),
    },
    {
      label: "Edit",
      icon: EditIcon,
      onClick: (row) => onEdit(row),
    },
    {
      label: "Add Supplier",
      icon: AddIcon,
      onClick: (row) => onAddSupplier(row),
    },
    {
      label: "Delete",
      icon: DeleteIcon,
      onClick: (row) => onDelete(row),
      sx: { color: "error.main" },
    },
  ];

  const expandedActionItems = [
    {
      label: "Delete",
      icon: DeleteIcon,
      onClick: (s) => onDeleteSupplier(s),
      sx: { color: "error.main" },
    },
    {
      label: "Edit",
      icon: EditIcon,
      onClick: (s) => onEditSupplier(s),
    },
  ];

  return (
    <>
      <ExpandableDataTable
        columns={columns}
        data={data}
        loading={loading}
        page={page}
        totalCount={totalItems}
        rowsPerPage={rowsPerPage}
        onPageChange={onPageChange}
        emptyMessage={emptyMessage}
        actions
        actionsWidth="80px"
        actionItems={actionItems}
        expandedColumns={expandedColumns}
        expandedActionItems={expandedActionItems}
        getExpandedRows={(row) => row.suppliers || []}
        // expandedLabel={(row) => `Suppliers for ${row.retailName}`}
      />
    </>
  );
};

export default RetailHistory;
