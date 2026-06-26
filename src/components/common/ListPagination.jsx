import { TablePagination } from "@mui/material";

const ListPagination = ({
  page,
  totalCount,
  rowsPerPage = 10,
  onPageChange,
  entityLabel = "items",
  totalAmount,
}) => {
  if (!totalCount) return null;

  const from = (page - 1) * rowsPerPage + 1;
  const to = Math.min(page * rowsPerPage, totalCount);

  return (
    <div className="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between border-t border-gray-200 dark:border-zinc-700 bg-white dark:bg-zinc-900 px-3 py-2 rounded-b-lg">
      <p className="text-sm text-gray-600 dark:text-gray-300 whitespace-nowrap">
        Showing {from}-{to} of {totalCount} {entityLabel}
      </p>

      {totalAmount != null && (
        <p className="text-sm font-semibold whitespace-nowrap">
          Total Amount: ₹{totalAmount}
        </p>
      )}

      <TablePagination
        component="div"
        count={totalCount}
        page={page - 1}
        rowsPerPage={rowsPerPage}
        onPageChange={(_, newPage) => onPageChange?.(newPage + 1)}
        rowsPerPageOptions={[]}
        showFirstButton
        showLastButton
        labelDisplayedRows={() => ""}
        sx={{
          marginLeft: { sm: "auto" },
          ".MuiTablePagination-toolbar": { minHeight: 40, px: 0 },
          ".MuiTablePagination-selectLabel, .MuiTablePagination-displayedRows": {
            display: "none",
          },
        }}
      />
    </div>
  );
};

export default ListPagination;
