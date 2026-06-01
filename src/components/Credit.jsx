import { LocalizationProvider } from "@mui/x-date-pickers/LocalizationProvider";
import { AdapterDayjs } from "@mui/x-date-pickers/AdapterDayjs";
import { DatePicker } from "@mui/x-date-pickers/DatePicker";
import { useBillForm } from "../customHooks/useBillForm";
import dayjs from "dayjs";
import { useState, useEffect } from "react";
import { deleteCreditApi, searchCreditHistory } from "../service/CreditService";
import { useSnackbar } from "../context/SnackbarContext";
import SupplierService from "../service/SupplierService";
import CustomerService from "../service/CustomerService";
import CreditHistory from "./CreditHistory";
import CreditDetail from "../modals/CreditDetail";
import EditCreditDetail from "../modals/EditCreditDetail";
import DeleteConfirmModal from "./common/DeleteConfirmModal";
import AppButton from "./common/AppButton";
import GenericAutocomplete from "./common/GenericAutocomplete";


const Credit = () => {
  const { showSnackbar } = useSnackbar();

  const [currentPage, setCurrentPage] = useState(1);
  const [totalItems, setTotalItems] = useState(0);
  const rowsPerPage = 10;

  const [creditHistoryData, setCreditHistoryData] = useState([]);
  const [loading, setLoading] = useState(false);
  const [filtersApplied, setFiltersApplied] = useState(false);
  const [totalAmount, setTotalAmount] = useState(0);

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
  const { errors, setErrors, filterObject, setFilterObject } = useBillForm();

  /* ================= LOAD SUPPLIERS & CUSTOMERS ================= */
  useEffect(() => {
    const loadData = async () => {
      try {
        const [suppliers, customers] = await Promise.all([
          SupplierService.getAllSuppliers(),
          CustomerService.getAllCustomers(),
        ]);

        const supplierOptions = (suppliers || []).map((s) => ({
          id: s.id,
          label: `${s.supplierName}${s.city ? ` - ${s.city}` : ""}`,
        }));

        const customerOptions = (customers || []).map((c) => ({
          id: c.id,
          label: `${c.customerName}${c.city ? ` - ${c.city}` : ""}`,
        }));
        setAllSuppliers(supplierOptions || []);
        setAllCustomers(customerOptions || []);
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
      let total=data?.totalAmount ?? 0
      setTotalAmount(Math.round(total))
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
          <div className="grid grid-cols-2 md:grid-cols-2 lg:grid-cols-4 gap-3">

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
                    sx: {
                      "& .MuiPickersSectionList-root": {
                        fontSize: { xs: "12px", md: "16px" },
                      },
                    },
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
                    sx: {
                      "& .MuiPickersSectionList-root": {
                        fontSize: { xs: "12px", md: "16px" },
                      },
                    },
                  },
                }}
              />
            </LocalizationProvider>

            {/* Supplier */}
            <div className="col-span-2 md:col-span-1">
              <GenericAutocomplete
                options={allSuppliers}
                value={selectedSupplier}
                label="Supplier"
                placeholder="Select supplier"
                onChange={(value) => {
                  setSelectedSupplier(value);

                  setFilterObject(prev => ({
                    ...prev,
                    supplierId: value ? value.id : null
                  }));
                }}
              />
            </div>

            {/* Customer */}
            <div className="col-span-2 md:col-span-1">
              <GenericAutocomplete
                options={allCustomers}
                value={selectedCustomer}
                label="Customer"
                placeholder="Select customer"
                onChange={(value) => {
                  setSelectedCustomer(value);

                  setFilterObject(prev => ({
                    ...prev,
                    customerId: value ? value.id : null
                  }));
                }}
              />
            </div>
          </div>

          <div className="mt-6 flex justify-end gap-3">

            <AppButton
              type="secondary"
              onClick={clearFiltersAndResults}
            >
              Clear Filters
            </AppButton>

            <AppButton
              type="primary"
              onClick={() => handleCreditHistory(1)}
              disabled={!isAnyFilterSelected}
              loading={loading}
            >
              Apply Filters
            </AppButton>

          </div>

        </div>
      </div>

      {/* ================= TABLE ================= */}
      <CreditHistory
        data={creditHistoryData}
        page={currentPage}
        totalItems={totalItems}
        rowsPerPage={rowsPerPage}
        totalAmount={totalAmount}
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

      <DeleteConfirmModal
        open={isDeleteOpen}
        title="Delete Credit"
        message={
          <>
            Are you sure you want to delete credit{" "}
            <span className="font-medium text-blue-600">
              {creditToDelete?.billNumber}
            </span>
            ? This action cannot be undone.
          </>
        }
        confirmText="Delete"
        cancelText="Cancel"
        onClose={() => {
          setIsDeleteOpen(false);
          setCreditToDelete(null);
        }}
        onConfirm={() => {
          confirmDelete();
          setIsDeleteOpen(false);
          setCreditToDelete(null);
        }}
      />

    </div>
  );
};

export default Credit;
