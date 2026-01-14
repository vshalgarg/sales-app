import { LocalizationProvider } from "@mui/x-date-pickers/LocalizationProvider";
import { AdapterDayjs } from "@mui/x-date-pickers/AdapterDayjs";
import { DatePicker } from "@mui/x-date-pickers/DatePicker";
import CustomTextField from "./CustomTextField";
import { useBillForm } from "../customHooks/useBillForm";
import dayjs from "dayjs";
import { useState, useEffect } from "react";
import { deleteCreditApi, searchCreditHistory } from "../service/CreditService";
import { useSnackbar } from "../context/SnackbarContext";
import SupplierService from "../service/SupplierService";
import CustomerService from "../service/CustomerService";
import Autocomplete from "@mui/material/Autocomplete";
import CreditHistory from "./CreditHistory";
import CreditDetail from "../modals/CreditDetail";
import EditCreditDetail from "../modals/EditCreditDetail";

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
  const [isEditOpen, setIsEditOpen] = useState(false);
  const [creditToEdit, setCreditToEdit] = useState(null);
  const [isDeleteOpen, setIsDeleteOpen] = useState(false);
  const [creditToDelete, setCreditToDelete] = useState(null);


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

  const confirmDelete = async () => {
    if (!creditToDelete) return;

    try {
      await deleteCreditApi(creditToDelete.id);

      showSnackbar("Credit deleted successfully", "success");

      setIsDeleteOpen(false);
      setCreditToDelete(null);

      handleCreditHistory(currentPage); // refresh list
    } catch (err) {
      showSnackbar(err.message || "Failed to delete credit", "error");
    }
  };


  /* ================= API CALL ================= */
  const handleCreditHistory = async (page = 1) => {

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
      fromDate: null,
      toDate: null,
    });

    setErrors({});
    setCreditHistoryData([]);
    setCurrentPage(1);
    setTotalItems(0);
    setFiltersApplied(false);
  };

  const isAnyFilterSelected =
    !!filterObject.fromDate ||
    !!filterObject.toDate ||
    !!filterObject.supplierId ||
    !!filterObject.customerId;


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
              disabled={!isAnyFilterSelected}
              className={`px-6 py-2 text-sm rounded-lg transition
    ${isAnyFilterSelected
                  ? "bg-blue-600 text-white hover:bg-blue-700"
                  : "bg-gray-300 text-gray-500 cursor-not-allowed"
                }`}
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
        onEdit={(row) => {
          setCreditToEdit(row);
          setIsEditOpen(true);
        }}
        onDelete={(row) => {
          setCreditToDelete(row);
          setIsDeleteOpen(true);
        }}
      />

      {isModalOpen && selectedCreditDetail && (
        <CreditDetail
          selectedCreditDetail={selectedCreditDetail}
          setIsModalOpen={setIsModalOpen}
        />
      )}

      {isEditOpen && creditToEdit && (
        <EditCreditDetail
          open={isEditOpen}
          selectedCreditDetail={creditToEdit}
          setOpen={setIsEditOpen}
          onUpdateSuccess={() => {
            setIsEditOpen(false);
            setCreditToEdit(null);
            handleCreditHistory(currentPage); //refresh table
          }}
        />
      )}

      {isDeleteOpen && creditToDelete && (
        <div className="fixed inset-0 bg-black bg-opacity-40 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg shadow-lg w-full max-w-sm p-5">

            <h3 className="text-lg font-semibold text-gray-800">
              Delete Credit
            </h3>

            <p className="text-sm text-gray-600 mt-2">
              Are you sure you want to delete credit
              <span className="font-medium"> {creditToDelete.billNumber}</span> ?
            </p>

            <div className="flex justify-end gap-3 mt-6">
              <button
                onClick={() => {
                  setIsDeleteOpen(false);
                  setCreditToDelete(null);
                }}
                className="px-4 py-2 text-sm border rounded-lg"
              >
                Cancel
              </button>

              <button
                onClick={confirmDelete}
                className="px-4 py-2 text-sm rounded-lg bg-red-600 text-white hover:bg-red-700"
              >
                Delete
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default Credit;
