import { CircularProgress, Typography } from "@mui/material";
import EntityCard from "./EntityCard";
import ListPagination from "./ListPagination";

const EntityCardGrid = ({
  items = [],
  loading = false,
  emptyMessage = "No records found",
  getItemKey = (item, index) => item.id ?? item.code ?? index,
  buildCardProps,
  page,
  totalCount,
  rowsPerPage = 10,
  onPageChange,
  entityLabel = "items",
  totalAmount,
}) => (
  <div className="flex flex-col h-full min-h-0 border rounded-lg bg-white dark:bg-zinc-900 overflow-hidden">
    <div className="flex-1 min-h-0 overflow-y-auto p-3 md:p-4">
      {loading ? (
        <div className="flex items-center justify-center py-16">
          <CircularProgress />
        </div>
      ) : items.length > 0 ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-4">
          {items.map((item, index) => (
            <EntityCard
              key={getItemKey(item, index)}
              variantIndex={index}
              {...buildCardProps(item, index)}
            />
          ))}
        </div>
      ) : (
        <div className="flex items-center justify-center py-16">
          <Typography color="text.secondary">{emptyMessage}</Typography>
        </div>
      )}
    </div>

    <ListPagination
      page={page}
      totalCount={totalCount}
      rowsPerPage={rowsPerPage}
      onPageChange={onPageChange}
      entityLabel={entityLabel}
      totalAmount={totalAmount}
    />
  </div>
);

export default EntityCardGrid;
