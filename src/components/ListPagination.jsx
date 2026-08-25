import {
  ChevronLeft,
  ChevronRight,
  ChevronsLeft,
  ChevronsRight,
  ChevronDown,
} from "lucide-react";
import {
  PAGINATION_NAV_CLASS,
  PAGINATION_PAGE_ACTIVE_CLASS,
  PAGINATION_PAGE_INACTIVE_CLASS,
  PAGINATION_SELECT_CLASS,
  PAGINATION_SHELL_CLASS,
  PAGINATION_TEXT_CLASS,
  ROWS_PER_PAGE_OPTIONS,
} from "../theme/cardTheme";

const pageButtonClass = (isActive) =>
  `inline-flex h-8 min-w-8 items-center justify-center rounded-lg border px-2 text-sm font-medium transition-colors ${
    isActive ? PAGINATION_PAGE_ACTIVE_CLASS : PAGINATION_PAGE_INACTIVE_CLASS
  }`;

const navButtonClass = `${PAGINATION_NAV_CLASS} inline-flex h-8 w-8 items-center justify-center rounded-lg border transition-colors`;

const getVisiblePages = (page, totalPages) => {
  if (totalPages <= 5) {
    return Array.from({ length: totalPages }, (_, i) => i + 1);
  }

  const pages = new Set([1, totalPages, page]);

  if (page > 1) pages.add(page - 1);
  if (page < totalPages) pages.add(page + 1);
  if (page > 2) pages.add(page - 2);
  if (page < totalPages - 1) pages.add(page + 2);

  const sorted = [...pages].sort((a, b) => a - b);
  const result = [];

  sorted.forEach((num, index) => {
    if (index > 0 && num - sorted[index - 1] > 1) {
      result.push("ellipsis");
    }
    result.push(num);
  });

  return result;
};

const ListPagination = ({
  page,
  totalCount,
  rowsPerPage = 10,
  onPageChange,
  entityLabel = "items",
  totalAmount,
  rowsPerPageOptions = ROWS_PER_PAGE_OPTIONS,
  onRowsPerPageChange,
}) => {
  if (!totalCount) return null;

  const totalPages = Math.max(1, Math.ceil(totalCount / rowsPerPage));
  const safePage = Math.min(Math.max(page, 1), totalPages);
  const from = (safePage - 1) * rowsPerPage + 1;
  const to = Math.min(safePage * rowsPerPage, totalCount);
  const visiblePages = getVisiblePages(safePage, totalPages);
  const canChangePageSize = typeof onRowsPerPageChange === "function";

  return (
    <div
      className={`${PAGINATION_SHELL_CLASS} flex flex-col gap-3 px-3 py-3 sm:px-4 sm:py-3.5 lg:flex-row lg:items-center lg:justify-between`}
    >
      <div className="flex flex-col gap-2 sm:flex-row sm:items-center sm:gap-4 min-w-0">
        <p className={`${PAGINATION_TEXT_CLASS} whitespace-nowrap`}>
          Showing {from}-{to} of {totalCount} {entityLabel}
        </p>

        {totalAmount != null && (
          <p className="text-sm font-semibold text-brand-navy dark:text-gray-200 whitespace-nowrap">
            Total Amount: ₹{totalAmount}
          </p>
        )}
      </div>

      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-end sm:gap-4">
        <div className="relative w-fit min-w-[7.5rem]">
          {canChangePageSize ? (
            <select
              value={rowsPerPage}
              onChange={(e) =>
                onRowsPerPageChange(Number(e.target.value))
              }
              className={PAGINATION_SELECT_CLASS}
              aria-label="Rows per page"
            >
              {rowsPerPageOptions.map((option) => (
                <option key={option} value={option}>
                  {option} per page
                </option>
              ))}
            </select>
          ) : (
            <div className={`${PAGINATION_SELECT_CLASS} pointer-events-none`}>
              {rowsPerPage} per page
            </div>
          )}
          <ChevronDown className="pointer-events-none absolute right-2 top-1/2 h-4 w-4 -translate-y-1/2 text-brand-search-muted" />
        </div>

        <div className="flex items-center gap-1 overflow-x-auto pb-0.5 sm:pb-0">
          <button
            type="button"
            className={navButtonClass}
            onClick={() => onPageChange?.(1)}
            disabled={safePage <= 1}
            aria-label="First page"
          >
            <ChevronsLeft className="h-4 w-4" />
          </button>

          <button
            type="button"
            className={navButtonClass}
            onClick={() => onPageChange?.(safePage - 1)}
            disabled={safePage <= 1}
            aria-label="Previous page"
          >
            <ChevronLeft className="h-4 w-4" />
          </button>

          <div className="hidden sm:flex items-center gap-1 px-1">
            {visiblePages.map((item, index) =>
              item === "ellipsis" ? (
                <span
                  key={`ellipsis-${index}`}
                  className="px-1 text-sm text-brand-search-muted"
                >
                  ...
                </span>
              ) : (
                <button
                  key={item}
                  type="button"
                  className={pageButtonClass(item === safePage)}
                  onClick={() => onPageChange?.(item)}
                  aria-label={`Page ${item}`}
                  aria-current={item === safePage ? "page" : undefined}
                >
                  {item}
                </button>
              ),
            )}
          </div>

          <span className="sm:hidden px-2 text-sm text-brand-navy dark:text-gray-200 whitespace-nowrap">
            {safePage} / {totalPages}
          </span>

          <button
            type="button"
            className={navButtonClass}
            onClick={() => onPageChange?.(safePage + 1)}
            disabled={safePage >= totalPages}
            aria-label="Next page"
          >
            <ChevronRight className="h-4 w-4" />
          </button>

          <button
            type="button"
            className={navButtonClass}
            onClick={() => onPageChange?.(totalPages)}
            disabled={safePage >= totalPages}
            aria-label="Last page"
          >
            <ChevronsRight className="h-4 w-4" />
          </button>
        </div>
      </div>
    </div>
  );
};

export default ListPagination;
