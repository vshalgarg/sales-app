import { ArrowLeft, ArrowRight } from "lucide-react";

const PaginationComponent = ({
  currentPage,
  totalPages,
  totalItems,
  onPageChange,
  showInfo = true,
}) => {
  // Don't render if no pages or no data
  if (totalPages <= 1 || totalItems === 0) return null;

  const renderPageNumbers = () => {
    const pages = [];
    const maxVisiblePages = 5;

    let startPage = Math.max(1, currentPage - Math.floor(maxVisiblePages / 2));
    let endPage = Math.min(totalPages, startPage + maxVisiblePages - 1);

    if (endPage - startPage + 1 < maxVisiblePages) {
      startPage = Math.max(1, endPage - maxVisiblePages + 1);
    }

    // First page
    if (startPage > 1) {
      pages.push(
        <button
          key={1}
          onClick={() => onPageChange(1)}
          className="px-3 py-1.5 sm:px-3 sm:py-2 rounded-md border border-gray-300 dark:border-gray-600 text-sm hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors"
        >
          1
        </button>
      );
      if (startPage > 2) {
        pages.push(
          <span key="ellipsis1" className="px-1 py-1.5 sm:px-2 sm:py-2 text-gray-500 dark:text-gray-400">
            ...
          </span>
        );
      }
    }

    // Visible pages
    for (let i = startPage; i <= endPage; i++) {
      pages.push(
        <button
          key={i}
          onClick={() => onPageChange(i)}
          className={`px-3 py-1.5 sm:px-3 sm:py-2 rounded-md border text-sm font-medium transition-colors ${
            currentPage === i
              ? "bg-blue-600 border-blue-600 text-white"
              : "border-gray-300 dark:border-gray-600 hover:bg-gray-50 dark:hover:bg-gray-800"
          }`}
        >
          {i}
        </button>
      );
    }

    // Last page
    if (endPage < totalPages) {
      if (endPage < totalPages - 1) {
        pages.push(
          <span key="ellipsis2" className="px-1 py-1.5 sm:px-2 sm:py-2 text-gray-500 dark:text-gray-400">
            ...
          </span>
        );
      }
      pages.push(
        <button
          key={totalPages}
          onClick={() => onPageChange(totalPages)}
          className="px-3 py-1.5 sm:px-3 sm:py-2 rounded-md border border-gray-300 dark:border-gray-600 text-sm hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors"
        >
          {totalPages}
        </button>
      );
    }

    return pages;
  };

  // Showing info calculation
  const startItem = (currentPage - 1) * 10 + 1;
  const endItem = Math.min(currentPage * 10, totalItems);

  return (
    <div className="w-full">
      <div className="flex justify-between items-center gap-3 px-1">
        {/* Showing info */}
        {showInfo && totalItems > 0 && (
          <div className="text-sm text-gray-600 dark:text-gray-400 whitespace-nowrap">
            Showing <span className="font-medium">{startItem}-{endItem}</span> of{" "}
            <span className="font-medium">{totalItems}</span> entries
          </div>
        )}

        {/* Pagination Controls */}
        <div className="flex items-center gap-1 flex-wrap justify-center">
          <button
            onClick={() => onPageChange(currentPage - 1)}
            disabled={currentPage === 1}
            className={`flex items-center gap-1 px-3 py-1.5 sm:px-4 sm:py-2 rounded-md border text-sm font-medium transition-all ${
              currentPage === 1
                ? "opacity-50 cursor-not-allowed border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-800"
                : "border-gray-300 dark:border-gray-600 hover:bg-gray-50 dark:hover:bg-gray-800 hover:shadow-sm"
            }`}
          >
            <ArrowLeft size={16} />
            <span className="hidden sm:inline">Prev</span>
          </button>

          <div className="flex gap-1 flex-wrap justify-center">{renderPageNumbers()}</div>

          <button
            onClick={() => onPageChange(currentPage + 1)}
            disabled={currentPage === totalPages}
            className={`flex items-center gap-1 px-3 py-1.5 sm:px-4 sm:py-2 rounded-md border text-sm font-medium transition-all ${
              currentPage === totalPages
                ? "opacity-50 cursor-not-allowed border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-800"
                : "border-gray-300 dark:border-gray-600 hover:bg-gray-50 dark:hover:bg-gray-800 hover:shadow-sm"
            }`}
          >
            <span className="hidden sm:inline">Next</span>
            <ArrowRight size={16} />
          </button>
        </div>
      </div>
    </div>
  );
};

export default PaginationComponent;