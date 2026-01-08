import { LocalizationProvider } from "@mui/x-date-pickers/LocalizationProvider";
import { AdapterDayjs } from "@mui/x-date-pickers/AdapterDayjs";
import { DatePicker } from "@mui/x-date-pickers/DatePicker";
import CustomTextField from "./CustomTextField";
import { useBillForm } from "../customHooks/useBillForm";
import dayjs from "dayjs";
import { useState, useEffect } from "react";
import { searchCreditHistory } from "../service/CreditService";
import { useSnackbar } from "../context/SnackbarContext";
import SupplierService from "../service/SupplierService";
import CustomerService from "../service/CustomerService";
import Autocomplete from "@mui/material/Autocomplete";
import CreditHistory from "./CreditHistory";
import CreditDetail from "../modals/CreditDetail";

const Credit = () => {
  const { showSnackbar } = useSnackbar();

  const [currentPage, setCurrentPage] = useState(1);
  const [totalItems, setTotalItems] = useState(0);
  const rowsPerPage = 10;

  const [creditHistoryData, setCreditHistoryData] = useState([]);
  const [loading, setLoading] = useState(false);
  const [filtersApplied, setFiltersApplied] = useState(false);

  const [allSuppliers, setAllSuppliers] = useState([]);
  const [allCustomers, setAllCustomers] = useState([]);
  const [selectedSupplier, setSelectedSupplier] = useState(null);
  const [selectedCustomer, setSelectedCustomer] = useState(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [selectedCreditDetail, setSelectedCreditDetail] = useState(null);


  const todayDayjs = dayjs();
  const today = dayjs().format("YYYY-MM-DD");

  const { errors, setErrors, filterObject, setFilterObject } = useBillForm();

  /* ================= LOAD SUPPLIERS & CUSTOMERS ================= */
  useEffect(() => {
    const loadData = async () => {
      try {
        const [suppliers, customers] = await Promise.all([
          SupplierService.getAllSuppliers(),
          CustomerService.getAllCustomers(),
        ]);
        setAllSuppliers(suppliers || []);
        setAllCustomers(customers || []);
      } catch {
        showSnackbar("Error loading suppliers/customers", "error");
      }
    };
    loadData();
  }, []);

  /* ================= API CALL ================= */
  const handleCreditHistory = async (page = 1) => {
    const { fromDate } = filterObject;
    const newErrors = {};

    if (!fromDate) newErrors.fromDate = "Please select From Date";

    setErrors(newErrors);
    if (Object.keys(newErrors).length) return;

    try {
      setLoading(true);
      setFiltersApplied(true);

      const data = await searchCreditHistory(
        {
          ...filterObject,
          toDate: filterObject.toDate || null,
        },
        page - 1,
        rowsPerPage
      );

      setCreditHistoryData(data?.content ?? []);
      setTotalItems(data?.totalElements ?? 0);
      setCurrentPage(page);
    } catch {
      setCreditHistoryData([]);
      setTotalItems(0);
      setCurrentPage(1);
      setFiltersApplied(true);
    } finally {
      setLoading(false);
    }
  };

  const clearFiltersAndResults = () => {
    setSelectedSupplier(null);
    setSelectedCustomer(null);

    setFilterObject({
      supplierId: null,
      customerId: null,
      fromDate: today,
      toDate: today,
    });

    setErrors({});
    setCreditHistoryData([]);
    setCurrentPage(1);
    setTotalItems(0);
    setFiltersApplied(false);
  };

  return (
    <div className="flex flex-col h-full overflow-y-auto">
      {/* ================= FILTER CARD ================= */}
      <div className="bg-gray-50 border rounded-t-lg shadow-sm mt-4">
        <div className="px-6 py-4 border-b">
          <h2 className="text-xl font-semibold">Credits</h2>
          <p className="text-sm text-gray-500 mt-1">
            Filter and review credit history by supplier, customer and date range
          </p>
        </div>

        <div className="px-6 py-5">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-5">

            <LocalizationProvider dateAdapter={AdapterDayjs}>
              <DatePicker
                label="From Date"
                format="DD-MM-YYYY"
                value={filterObject.fromDate ? dayjs(filterObject.fromDate) : null}
                maxDate={todayDayjs}
                onChange={(v) => {
                  const formatted = v ? dayjs(v).format("YYYY-MM-DD") : "";
                  setFilterObject(prev => ({
                    ...prev,
                    fromDate: formatted,
                    toDate:
                      prev.toDate && dayjs(prev.toDate).isBefore(v)
                        ? ""
                        : prev.toDate,
                  }));
                  setErrors(prev => ({ ...prev, fromDate: "" }));
                }}
                slotProps={{
                  textField: {
                    size: "small",
                    fullWidth: true,
                  },
                }}
              />
            </LocalizationProvider>

            <LocalizationProvider dateAdapter={AdapterDayjs}>
              <DatePicker
                label="To Date"
                format="DD-MM-YYYY"
                value={filterObject.toDate ? dayjs(filterObject.toDate) : null}
                minDate={
                  filterObject.fromDate
                    ? dayjs(filterObject.fromDate)
                    : undefined
                }
                maxDate={todayDayjs}
                onChange={(v) =>
                  setFilterObject(prev => ({
                    ...prev,
                    toDate: v ? dayjs(v).format("YYYY-MM-DD") : "",
                  }))
                }
                slotProps={{
                  textField: {
                    size: "small",
                    fullWidth: true,
                  },
                }}
              />
            </LocalizationProvider>

            <Autocomplete
              options={allSuppliers}
              value={selectedSupplier}
              isOptionEqualToValue={(o, v) => o.id === v?.id}
              getOptionLabel={(o) => o?.supplierName || ""}
              onChange={(e, value) => {
                setSelectedSupplier(value);
                setFilterObject(prev => ({
                  ...prev,
                  supplierId: value ? value.id : null,
                }));
              }}
              renderInput={(params) => (
                <CustomTextField {...params} label="Supplier" />
              )}
            />

            <Autocomplete
              options={allCustomers}
              value={selectedCustomer}
              isOptionEqualToValue={(o, v) => o.id === v?.id}
              getOptionLabel={(o) => o?.customerName || ""}
              onChange={(e, value) => {
                setSelectedCustomer(value);
                setFilterObject(prev => ({
                  ...prev,
                  customerId: value ? value.id : null,
                }));
              }}
              renderInput={(params) => (
                <CustomTextField {...params} label="Customer" />
              )}
            />
          </div>

          <div className="mt-6 flex justify-end gap-3">
            <button
              onClick={clearFiltersAndResults}
              className="px-5 py-2 text-sm rounded-lg border text-gray-600"
            >
              Clear Filters
            </button>

            <button
              onClick={() => handleCreditHistory(1)}
              className="px-6 py-2 text-sm rounded-lg bg-blue-600 text-white"
            >
              Apply Filters
            </button>
          </div>
        </div>
      </div>

      {/* ================= TABLE ================= */}
      <CreditHistory
        data={creditHistoryData}
        loading={loading}
        page={currentPage}
        totalItems={totalItems}
        rowsPerPage={rowsPerPage}
        onPageChange={handleCreditHistory}
        emptyMessage={
          filtersApplied
            ? "No data found for selected filters"
            : "Apply filters to view credit history"
        }
        onView={(row) => {
          setSelectedCreditDetail(row);
          setIsModalOpen(true);
        }}
      />

      {isModalOpen && selectedCreditDetail && (
        <CreditDetail
          selectedCreditDetail={selectedCreditDetail}
          setIsModalOpen={setIsModalOpen}
        />
      )}

    </div>
  );
};

export default Credit;
