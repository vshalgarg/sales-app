import { LocalizationProvider } from "@mui/x-date-pickers/LocalizationProvider";
import { useBillForm } from "../customHooks/useBillForm";
import CustomTextField from "./CustomTextField";
import { AdapterDayjs } from "@mui/x-date-pickers/AdapterDayjs";
import { DatePicker } from "@mui/x-date-pickers/DatePicker";
import { useState, useEffect} from "react";
import dayjs from "dayjs";
// Assume searchBillHistory is imported from the same service file as other bill services
import { searchBillHistory } from "../service/BillService";
import BillHistory from "./BillHistory"; // Import the component you want to show
import { ArrowLeft, ArrowRight } from "lucide-react";
import { useSnackbar } from "../context/SnackbarContext";

const Bills = () => {
  const { showSnackbar } = useSnackbar();
  const [billFiltersApplied, setBillFiltersApplied] = useState(false);

  // Important: initialize safe defaults
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const rowsPerPage = 7;

  const [billHistoryData, setBillHistoryData] = useState([]);
  const [loading, setLoading] = useState(false);

  const {
    isFilterObject,
    setIsFilterObject,
    errors,
    setErrors,
    suggestions,
    isDropdownOpen,
    setIsDropdownOpen,
    handleSupplierInput,
    searchRef,
    handleSupplierSuggestionClick,
    custSearchRef,
    custSuggestions,
    isCustDropdownOpen,
    setIsCustDropdownOpen,
    handleCustomerSuggestionClick,
    handleCustomerInput,
    filterObject,
    setFilterObject,
  } = useBillForm();

  useEffect(() => {
    const today = dayjs().format("YYYY-MM-DD");
    if (!filterObject.fromDate && !filterObject.toDate) {
      setFilterObject(prev => ({
        ...prev,
        fromDate: today
      }));
    }
  }, [])

  // Fetch a page of bill history from backend pageable response
  const handleBillDetailHistory = async (page = 1) => {
    const { fromDate, toDate } = filterObject;
    const newErrors = {};

    const from = fromDate ? dayjs(fromDate, "YYYY-MM-DD", true) : null;
    const to = toDate ? dayjs(toDate, "YYYY-MM-DD", true) : null;

    // Step 1: Empty fields
    if (!fromDate) {
      newErrors.fromDate = "Please select From Date";
    } else if (!from?.isValid()) {
      newErrors.fromDate = "Invalid From Date format";
    }

    if (!toDate) {
      newErrors.toDate = "Please select To Date";
    } else if (!to?.isValid()) {
      newErrors.toDate = "Invalid To Date format";
    }

    // Step 2: Logical date comparison
    if (from?.isValid() && to?.isValid() && from.isAfter(to)) {
      newErrors.fromDate = "From Date cannot be after To Date";
      newErrors.toDate = "To Date cannot be before From Date";

      const activeField = document.activeElement?.name;

      const message =
        activeField === "toDate"
          ? `To Date (${to.format(
              "DD MMM YYYY"
            )}) cannot be before From Date (${from.format("DD MMM YYYY")})`
          : `From Date (${from.format(
              "DD MMM YYYY"
            )}) cannot be after To Date (${to.format("DD MMM YYYY")})`;

      showSnackbar(message, "error");
    }

    // Step 3: Show snackbar for missing dates
    if (!fromDate || !toDate) {
      showSnackbar("Please select both From Date and To Date", "warning");
    }

    // Step 4: Set all errors
    setErrors((prev) => ({
      ...prev,
      ...newErrors,
    }));

    // Step 5: Return early if errors exist
    if (Object.keys(newErrors).length > 0) {
      return;
    }
    // Basic validation / clamp
    const requestedPage = page < 1 ? 1 : page;
    setBillFiltersApplied(true);

    try {
      setLoading(true);
      const data = await searchBillHistory(
        filterObject,
        requestedPage,
        rowsPerPage
      );

      // backend `Page` (Spring) often returns zero-based `number`
      // convert to 1-based page for the UI
      const backendNumber =
        typeof data?.number === "number" ? data.number + 1 : requestedPage;

      // get totalPages or compute fallback from totalElements
      const backendTotalPages =
        typeof data?.totalPages === "number"
          ? data.totalPages
          : data?.totalElements
          ? Math.max(1, Math.ceil(data.totalElements / rowsPerPage))
          : 1;

      setBillHistoryData(data?.content ?? []);
      setCurrentPage(backendNumber);
      setTotalPages(backendTotalPages);
    } catch (err) {
      console.error("Error fetching bill history:", err);
      setBillHistoryData([]);
      setCurrentPage(1);
      setTotalPages(1);
    } finally {
      setLoading(false);
    }
  };

  // Page change handler — validates and delegates to fetcher
  const handleChangePage = async (page) => {
    if (page < 1 || page > totalPages || page === currentPage || loading)
      return;
    await handleBillDetailHistory(page);
  };

  // Clear filters and reset results
  const clearFiltersAndResults = () => {
    setFilterObject({
      supplierName: "",
      customerName: "",
      fromDate: today,
      toDate: "",
    });
    setErrors([]);
    setBillFiltersApplied(false);
    setBillHistoryData([]);
    setCurrentPage(1);
    setTotalPages(1);
  };

  // Consolidated handlers
  const handleSupplierChange = (e) => {
    handleSupplierInput(e);
    setIsFilterObject(true);
  };

  const handleCustomerChange = (e) => {
    handleCustomerInput(e);
    setIsFilterObject(true);
  };

  // Helper to render page buttons (first, neighbors, last with ellipses)
  const renderPaginationButtons = () => {
    if (totalPages <= 5) {
      return Array.from({ length: totalPages }, (_, i) => i + 1).map((p) => (
        <button
          key={p}
          onClick={() => handleChangePage(p)}
          className={`w-9 h-9 flex items-center justify-center rounded-full border ${
            currentPage === p
              ? "bg-blue-600 text-white"
              : "bg-white hover:bg-gray-200"
          }`}
          disabled={loading}
        >
          {p}
        </button>
      ));
    }

    // For larger page counts show: 1, maybe left ellipsis, (current-1, current, current+1), maybe right ellipsis, last
    const pages = [];
    pages.push(1);

    const left = Math.max(2, currentPage - 1);
    const right = Math.min(totalPages - 1, currentPage + 1);

    if (left > 2) pages.push("left-ellipsis");

    for (let p = left; p <= right; p++) {
      pages.push(p);
    }

    if (right < totalPages - 1) pages.push("right-ellipsis");

    pages.push(totalPages);

    return pages.map((item, idx) => {
      if (item === "left-ellipsis" || item === "right-ellipsis") {
        return (
          <span key={idx} className="px-2 text-gray-500">
            ...
          </span>
        );
      }
      return (
        <button
          key={item}
          onClick={() => handleChangePage(item)}
          className={`w-9 h-9 flex items-center justify-center rounded-full border ${
            currentPage === item
              ? "bg-blue-600 text-white"
              : "bg-white hover:bg-gray-200"
          }`}
          disabled={loading}
        >
          {item}
        </button>
      );
    });
  };

  return (
    <>
      <div className="flex flex-col h-full overflow-y-auto">
        {/* Card (Filter Section) */}
        <div className="bg-white w-full h-[30vh] flex flex-col border p-4 mt-2 rounded border-gray-300">
          <div className="border-b border-gray-300 shrink-0">
            <h2 className="text-2xl font-semibold">Bills</h2>
            <p className="mb-2">
              Select criteria to refine your bill history view
            </p>
          </div>

          {/* Middle content (Filter Inputs) */}
          <div className="flex-1 py-4 space-y-4">
            <div>
              <div className="grid grid-cols-4 gap-4">
                <div ref={searchRef} className="relative w-full">
                  <CustomTextField
                    name="supplierName"
                    value={filterObject.supplierName ?? ""}
                    onChange={handleSupplierChange}
                    onFocus={() => {
                      if (
                        (filterObject?.supplierName?.length ?? 0) > 1 &&
                        suggestions.length > 0
                      ) {
                        setIsDropdownOpen(true);
                      }
                    }}
                    label="Supplier"
                  />

                  {isDropdownOpen && suggestions.length > 0 && (
                    <ul className="absolute mt-1 bg-white border rounded shadow-lg z-50 max-h-60 overflow-y-auto text-sm w-full">
                      {suggestions.map((s, idx) => (
                        <li
                          key={idx}
                          className="p-2 hover:bg-gray-100 cursor-pointer"
                          onClick={() => {
                            handleSupplierSuggestionClick(s);
                            setIsFilterObject(true);
                          }}
                        >
                          {s.supplierName}
                        </li>
                      ))}
                    </ul>
                  )}
                </div>

                <div ref={custSearchRef} className="relative w-full">
                  <CustomTextField
                    name="customerName"
                    value={filterObject.customerName ?? ""}
                    onChange={handleCustomerChange}
                    onFocus={() => {
                      if (
                        (filterObject.customerName?.length ?? 0) > 1 &&
                        custSuggestions.length > 0
                      ) {
                        setIsCustDropdownOpen(true);
                      }
                    }}
                    label="Customer"
                  />

                  {isCustDropdownOpen && custSuggestions.length > 0 && (
                    <ul className="absolute mt-1 bg-white border rounded shadow-lg z-50 max-h-60 overflow-y-auto text-sm w-full">
                      {custSuggestions.map((c, idx) => (
                        <li
                          key={idx}
                          className="p-2 hover:bg-gray-100 cursor-pointer"
                          onClick={() => {
                            handleCustomerSuggestionClick(c);
                            setIsFilterObject(true);
                          }}
                        >
                          {c.customerName}
                        </li>
                      ))}
                    </ul>
                  )}
                </div>

                <LocalizationProvider dateAdapter={AdapterDayjs}>
                  <DatePicker
                    label="From Date"
                    value={
                      filterObject.fromDate
                        ? dayjs(filterObject.fromDate)
                        : null
                    }
                    onChange={(newValue) => {
                      const formatted = newValue
                        ? dayjs(newValue).format("YYYY-MM-DD")
                        : "";

                      // Reset toDate if it's before new fromDate
                      if (
                        filterObject.toDate &&
                        dayjs(filterObject.toDate).isBefore(formatted)
                      ) {
                        setFilterObject((prev) => ({
                          ...prev,
                          fromDate: formatted,
                          toDate: "", // reset toDate
                        }));
                      } else {
                        setFilterObject((prev) => ({
                          ...prev,
                          fromDate: formatted,
                        }));
                      }

                      setErrors((prev) => ({ ...prev, fromDate: "" }));
                    }}
                    slotProps={{
                      textField: {
                        size: "small",
                        fullWidth: true,
                        error: Boolean(errors.fromDate),
                      },
                    }}
                  />
                </LocalizationProvider>

                <LocalizationProvider dateAdapter={AdapterDayjs}>
                  <DatePicker
                    label="To Date"
                    value={
                      filterObject.toDate ? dayjs(filterObject.toDate) : null
                    }
                    minDate={
                      filterObject.fromDate
                        ? dayjs(filterObject.fromDate)
                        : undefined
                    } // ✅ disables earlier dates
                    onChange={(newValue) => {
                      const formatted = newValue
                        ? dayjs(newValue).format("YYYY-MM-DD")
                        : "";
                      setFilterObject((prev) => ({
                        ...prev,
                        toDate: formatted,
                      }));
                      setErrors((prev) => ({ ...prev, toDate: "" }));
                    }}
                    slotProps={{
                      textField: {
                        size: "small",
                        fullWidth: true,
                        error: Boolean(errors.toDate),
                      },
                    }}
                  />
                </LocalizationProvider>
              </div>

              <div className="mt-5 flex justify-end space-x-3">
                <button
                  className="px-4 py-2 border rounded-lg hover:bg-gray-300"
                  onClick={clearFiltersAndResults}
                  disabled={loading}
                >
                  Clear Filters
                </button>

                <button
                  className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-700"
                  onClick={() => handleBillDetailHistory(1)}
                  disabled={loading}
                >
                  Apply Filters
                </button>
              </div>
            </div>
          </div>
        </div>

        {/* BillHistory - pass data + pagination meta */}
        {billHistoryData && (
          <BillHistory
            initialBillHistory={billHistoryData}
            billFiltersApplied={billFiltersApplied}
            paginationMeta={{ currentPage, totalPages, rowsPerPage }}
            onBillUpdated={() => handleBillDetailHistory(currentPage)}
          />
        )}

        {/* Pagination */}
        {totalPages > 1 && (
          <div className="absolute bottom-0 left-0 right-0 text-center p-3">
            <div className="max-w-sm mx-auto flex justify-between items-center space-x-2">
              {/* Prev */}
              <div>
                <button
                  onClick={() => handleChangePage(currentPage - 1)}
                  disabled={currentPage === 1 || loading}
                  className={`w-9 h-9 flex items-center justify-center rounded-full border ${
                    currentPage === 1
                      ? "bg-gray-100 text-gray-400 cursor-not-allowed"
                      : "bg-white hover:bg-gray-200"
                  }`}
                >
                  <ArrowLeft size={18} />
                </button>
              </div>

              {/* Page numbers */}
              <div className="flex">{renderPaginationButtons()}</div>

              {/* Next */}
              <div>
                <button
                  onClick={() => handleChangePage(currentPage + 1)}
                  disabled={currentPage === totalPages || loading}
                  className={`w-9 h-9 flex items-center justify-center rounded-full border ${
                    currentPage === totalPages
                      ? "bg-gray-100 text-gray-400 cursor-not-allowed"
                      : "bg-white hover:bg-gray-200"
                  }`}
                >
                  <ArrowRight size={18} />
                </button>
              </div>
            </div>
          </div>
        )}
      </div>
    </>
  );
};

export default Bills;
