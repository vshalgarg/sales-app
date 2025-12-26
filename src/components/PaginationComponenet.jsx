import { ArrowLeft, ArrowRight } from "lucide-react";

const PaginationComponent = ({ 
  currentPage, 
  totalPages, 
  onPageChange,
  showInfo = true,
  totalItems 
}) => {
  if (totalPages <= 1) return null;

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
          className="w-8 h-8 rounded hover:bg-gray-200 dark:hover:bg-gray-700 text-sm"
        >
          1
        </button>
      );
      if (startPage > 2) {
        pages.push(
          <span key="ellipsis1" className="px-1 text-gray-500 dark:text-gray-400">
            ...
          </span>
        );
      }
    }

    // Page numbers
    for (let i = startPage; i <= endPage; i++) {
      pages.push(
        <button
          key={i}
          onClick={() => onPageChange(i)}
          className={`w-8 h-8 rounded text-sm ${
            currentPage === i
              ? 'bg-blue-600 text-white font-semibold'
              : 'hover:bg-gray-200 dark:hover:bg-gray-700'
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
          <span key="ellipsis2" className="px-1 text-gray-500 dark:text-gray-400">
            ...
          </span>
        );
      }
      pages.push(
        <button
          key={totalPages}
          onClick={() => onPageChange(totalPages)}
          className="w-8 h-8 rounded hover:bg-gray-200 dark:hover:bg-gray-700 text-sm"
        >
          {totalPages}
        </button>
      );
    }

    return pages;
  };

  return (
    <div className="mt-6 flex justify-center items-center space-x-2">
      {/* Previous button */}
      <button
        onClick={() => onPageChange(currentPage - 1)}
        disabled={currentPage === 1}
        className={`p-2 rounded ${
          currentPage === 1
            ? 'opacity-50 cursor-not-allowed'
            : 'hover:bg-gray-200 dark:hover:bg-gray-700'
        }`}
      >
        <ArrowLeft size={18} />
      </button>
      
      {/* Page numbers */}
      <div className="flex space-x-1">
        {renderPageNumbers()}
      </div>
      
      {/* Next button */}
      <button
        onClick={() => onPageChange(currentPage + 1)}
        disabled={currentPage === totalPages}
        className={`p-2 rounded ${
          currentPage === totalPages
            ? 'opacity-50 cursor-not-allowed'
            : 'hover:bg-gray-200 dark:hover:bg-gray-700'
        }`}
      >
        <ArrowRight size={18} />
      </button>
    </div>
  );
};

export default PaginationComponent;