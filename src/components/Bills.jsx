import { LocalizationProvider } from "@mui/x-date-pickers/LocalizationProvider";
import { useBillForm } from "../customHooks/useBillForm";
import CustomTextField from "./CustomTextField";
import { AdapterDayjs } from "@mui/x-date-pickers/AdapterDayjs";
import { DatePicker } from "@mui/x-date-pickers/DatePicker";
import { useState, useEffect } from "react";
import dayjs from "dayjs";
import { searchBillHistory } from "../service/BillService";
import BillHistory from "./BillHistory";
import { useSnackbar } from "../context/SnackbarContext";
import SupplierService from "../service/SupplierService";
import CustomerService from "../service/CustomerService";
import Autocomplete from "@mui/material/Autocomplete";
import BillDetail from "../modals/BillDetail";
import EditBillDetail from "../modals/EditBillDetail";
import { deleteBill } from "../service/BillService";



const Bills = () => {
  const { showSnackbar } = useSnackbar();
  const [currentPage, setCurrentPage] = useState(1);
  const [totalItems, setTotalItems] = useState(0);
  const rowsPerPage = 10;
  const [billHistoryData, setBillHistoryData] = useState([]);
  const [loading, setLoading] = useState(false);
  const [allSuppliers, setAllSuppliers] = useState([]);
  const [allCustomers, setAllCustomers] = useState([]);
  const [supplierLoading, setSupplierLoading] = useState(true);
  const [customerLoading, setCustomerLoading] = useState(true);
  const [selectedSupplier, setSelectedSupplier] = useState(null);
  const [selectedCustomer, setSelectedCustomer] = useState(null);
  const [selectedBillDetail, setSelectedBillDetail] = useState(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [open, setOpen] = useState(false);
  const [filtersApplied, setFiltersApplied] = useState(false);
  const todayDayjs = dayjs();
  const [billToDelete, setBillToDelete] = useState(null);
  const [isDeleteOpen, setIsDeleteOpen] = useState(false);


  const today = dayjs().format("YYYY-MM-DD");

  const {
    errors,
    setErrors,
    filterObject,
    setFilterObject,
  } = useBillForm();

  /* ================= LOAD SUPPLIERS & CUSTOMERS ================= */
  useEffect(() => {
    const loadData = async () => {
      try {
        setSupplierLoading(true);
        setCustomerLoading(true);

        const [suppliers, customers] = await Promise.all([
          SupplierService.getAllSuppliers(),
          CustomerService.getAllCustomers(),
        ]);

        setAllSuppliers(suppliers || []);
        setAllCustomers(customers || []);
      } catch {
        showSnackbar("Error loading suppliers/customers", "error");
      } finally {
        setSupplierLoading(false);
        setCustomerLoading(false);
      }
    };

    loadData();
  }, []);

  /* ================= API CALL ================= */
  const handleBillDetailHistory = async (page = 1) => {
    const newErrors = {};
    setErrors(newErrors);
    if (Object.keys(newErrors).length) return;
    try {
      setLoading(true);
      setFiltersApplied(true);

      const data = await searchBillHistory(
        {
          ...filterObject,
          toDate: filterObject.toDate || null,
        },
        page - 1,
        rowsPerPage
      );

      setBillHistoryData(data?.content ?? []);
      setTotalItems(data?.totalElements ?? 0);
      setCurrentPage(page);
    } catch {
      setBillHistoryData([]);
      setTotalItems(0);
      setCurrentPage(1);
      setFiltersApplied(true);
    } finally {
      setLoading(false);
    }
  };

  const confirmDelete = async () => {
    try {
      await deleteBill(billToDelete.billNumber);

      showSnackbar("Bill deleted successfully", "success");

      setIsDeleteOpen(false);
      setBillToDelete(null);

      handleBillDetailHistory(currentPage);
    } catch (err) {
      showSnackbar(err.message || "Failed to delete bill", "error");
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
    setBillHistoryData([]);
    setCurrentPage(1);
    setTotalItems(0);
    setFiltersApplied(false);
  };

  const handleDelete = (row) => {
    setBillToDelete(row);
    setIsDeleteOpen(true);
  };


  const isAnyFilterSelected =
    !!filterObject.fromDate ||
    !!filterObject.toDate ||
    !!filterObject.supplierId ||
    !!filterObject.customerId;

  return (
    <>
      <div className="flex flex-col h-full overflow-y-auto">
        {/* ================= FILTER CARD ================= */}
        <div className="bg-gray-50 border rounded-t-lg shadow-sm mt-4">
          {/* Header */}
          <div className="px-6 py-4 border-b">
            <h2 className="text-xl font-semibold text-gray-800">
              Bills
            </h2>
            <p className="text-sm text-gray-500 mt-1">
              Filter and review bill history by supplier, customer and date range
            </p>
          </div>

          {/* Filters */}
          <div className="px-6 py-5">
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-5">

              {/* From Date */}
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
                      //if toDate exists & is before new fromDate → reset toDate
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

              {/* To Date */}
              <LocalizationProvider dateAdapter={AdapterDayjs}>
                <DatePicker
                  label="To Date"
                  format="DD-MM-YYYY"
                  value={filterObject.toDate ? dayjs(filterObject.toDate) : null}
                  minDate={
                    filterObject.fromDate
                      ? dayjs(filterObject.fromDate)
                      : undefined
                  } //cannot select before fromDate
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

              {/* Supplier */}
              <Autocomplete
                options={allSuppliers}
                loading={supplierLoading}
                value={selectedSupplier}
                isOptionEqualToValue={(option, value) =>
                  option.id === value?.id
                }
                getOptionLabel={(option) =>
                  option?.supplierName || ""
                }
                onChange={(e, value) => {
                  setSelectedSupplier(value);
                  setFilterObject(prev => ({
                    ...prev,
                    supplierId: value ? value.id : null,
                  }));
                }}
                renderInput={(params) => (
                  <CustomTextField
                    {...params}
                    label="Supplier"
                    placeholder="Select supplier"
                  />
                )}
              />

              {/* Customer */}
              <Autocomplete
                options={allCustomers}
                loading={customerLoading}
                value={selectedCustomer}
                isOptionEqualToValue={(option, value) =>
                  option.id === value?.id
                }
                getOptionLabel={(option) =>
                  option?.customerName || ""
                }
                onChange={(e, value) => {
                  setSelectedCustomer(value);
                  setFilterObject(prev => ({
                    ...prev,
                    customerId: value ? value.id : null,
                  }));
                }}
                renderInput={(params) => (
                  <CustomTextField
                    {...params}
                    label="Customer"
                    placeholder="Select customer"
                  />
                )}
              />
            </div>

            {/* Actions */}
            <div className="mt-6 flex justify-end gap-3">
              <button
                onClick={clearFiltersAndResults}
                className="px-5 py-2 text-sm rounded-lg border text-gray-600
                         hover:bg-gray-100 transition"
              >
                Clear Filters
              </button>

              <button
                onClick={() => handleBillDetailHistory(1)}
                disabled={!isAnyFilterSelected}
                className={`px-6 py-2 text-sm font-medium rounded-lg transition shadow-sm
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
        <BillHistory
          data={billHistoryData}
          loading={loading}
          page={currentPage}
          totalItems={totalItems}
          rowsPerPage={rowsPerPage}
          onPageChange={handleBillDetailHistory}
          emptyMessage={
            filtersApplied
              ? "No data found for selected filters"
              : "Apply filters to view bill history"
          }
          onView={(row) => {
            setSelectedBillDetail(row);
            setIsModalOpen(true);
          }}
          onEdit={(row) => {
            setSelectedBillDetail(row);
            setOpen(true);
          }}
          onDelete={handleDelete}
        />
      </div>

      {/* ================= VIEW BILL MODAL ================= */}
      {isModalOpen && selectedBillDetail && (
        <BillDetail
          selectedBillDetail={selectedBillDetail}
          setIsModalOpen={setIsModalOpen}
        />
      )}

      {/* ================= EDIT BILL MODAL ================= */}
      {open && selectedBillDetail && (
        <EditBillDetail
          open={open}
          selectedBillDetail={selectedBillDetail}
          setOpen={setOpen}
          onUpdateSuccess={() => {
            setOpen(false);
            handleBillDetailHistory(currentPage);
          }}
        />
      )}

      {isDeleteOpen && deleteBill && (
        <div className="fixed inset-0 bg-black bg-opacity-30 flex items-center justify-center z-50">
          <div className="bg-white rounded-xl shadow-xl p-6 w-96">
            <h3 className="text-lg font-semibold text-gray-800 mb-2">
              Delete Bill?
            </h3>
            <p className="text-sm text-gray-600 mb-6">
              Are you sure you want to delete bill
              <b> #{deleteBill.billNumber}</b>?
              This action cannot be undone.
            </p>

            <div className="flex justify-end gap-3">
              <button
                onClick={() => setIsDeleteOpen(false)}
                className="px-4 py-2 rounded-lg bg-gray-100 text-gray-700"
              >
                Cancel
              </button>

              <button
                onClick={confirmDelete}
                className="px-4 py-2 rounded-lg bg-red-600 text-white hover:bg-red-700"
              >
                Delete
              </button>
            </div>
          </div>
        </div>
      )}

    </>
  );
}
export default Bills;
