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
      { key: "supplierName", label: "Supplier" },
      {
        key: "customerNames",
        label: "Customer(s)",
        render: (r) =>
          r.customerNames && r.customerNames.length > 0
            ? r.customerNames.join(", ")
            : "-",
      },
      { key: "purchaseAmount", label: "Amount" },
    ],

    mobile: [
      {
        key: "date",
        label: "Date",
        render: (r) => (r.date ? dayjs(r.date).format("DD-MM-YYYY") : "-"),
      },
      { key: "supplierName", label: "Supplier" },
      { key: "purchaseAmount", label: "Amount" },
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
