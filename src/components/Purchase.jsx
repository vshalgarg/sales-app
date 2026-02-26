import { LocalizationProvider } from "@mui/x-date-pickers/LocalizationProvider";
import { AdapterDayjs } from "@mui/x-date-pickers/AdapterDayjs";
import { DatePicker } from "@mui/x-date-pickers/DatePicker";
import CustomTextField from "./CustomTextField";
import { useBillForm } from "../customHooks/useBillForm";
import dayjs from "dayjs";
import { useState, useEffect } from "react";
import { deletePurchaseApi, searchPurchaseHistory } from "../service/PurchaseService";
import { useSnackbar } from "../context/SnackbarContext";
import SupplierService from "../service/SupplierService";
import CustomerService from "../service/CustomerService";
import Autocomplete from "@mui/material/Autocomplete";
import PurchaseHistory from "./PurchaseHistory";
import EditPurchaseDetail from "../modals/EditPurchaseDetail";
import DeleteConfirmModal from "./common/DeleteConfirmModal";

const Purchase = () => {
  const { showSnackbar } = useSnackbar();

  const [currentPage, setCurrentPage] = useState(1);
  const [totalItems, setTotalItems] = useState(0);
  const rowsPerPage = 10;

  const [purchaseHistoryData, setPurchaseHistoryData] = useState([]);
  const [loading, setLoading] = useState(false);
  const [filtersApplied, setFiltersApplied] = useState(false);

  const [allSuppliers, setAllSuppliers] = useState([]);
  const [allCustomers, setAllCustomers] = useState([]);
  const [selectedSupplier, setSelectedSupplier] = useState(null);
  const [selectedCustomer, setSelectedCustomer] = useState(null);
  const [isEditOpen, setIsEditOpen] = useState(false);
  const [purchaseToEdit, setPurchaseToEdit] = useState(null);
  const [isDeleteOpen, setIsDeleteOpen] = useState(false);
  const [purchaseToDelete, setPurchaseToDelete] = useState(null);


  const today = dayjs().format("YYYY-MM-DD");
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
        setAllSuppliers(suppliers || []);
        setAllCustomers(customers || []);
      } catch {
        showSnackbar("Error loading suppliers/customers", "error");
      }
    };
    loadData();
  }, []);

  const confirmDelete = async () => {
    if (!purchaseToDelete) return;

    try {
      await deletePurchaseApi(purchaseToDelete.id);

      showSnackbar("Purchase deleted successfully", "success");

      setIsDeleteOpen(false);
      setPurchaseToDelete(null);

      handlePurchaseHistory(currentPage); // refresh
    } catch (err) {
      showSnackbar(err.message || "Failed to delete purchase", "error");
    }
  };


  /* ================= SEARCH ================= */
  const handlePurchaseHistory = async (page = 1) => {
    try {
      setLoading(true);
      setFiltersApplied(true);

      const data = await searchPurchaseHistory(
        {
          ...filterObject,
          toDate: filterObject.toDate || null,
        },
        page - 1,
        rowsPerPage
      );


      setPurchaseHistoryData(data?.content ?? []);
      setTotalItems(data?.totalElements ?? 0);
      setCurrentPage(page);
    } catch {
      setPurchaseHistoryData([]);
      setTotalItems(0);
      setCurrentPage(1);
      setFiltersApplied(true);
    } finally {
      setLoading(false);
    }
  };

  /* ================= CLEAR ================= */
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
    setPurchaseHistoryData([]);
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
          <h2 className="text-xl font-semibold">Purchases</h2>
          <p className="text-sm text-gray-500 mt-1">
            Filter and review purchase history
          </p>
        </div>

        <div className="px-6 py-5 grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-5">
          <LocalizationProvider dateAdapter={AdapterDayjs}>
            <DatePicker
              label="From Date"
              format="DD-MM-YYYY"
              value={filterObject.fromDate ? dayjs(filterObject.fromDate) : null}
              maxDate={todayDayjs}
              onChange={(v) => {
                const d = v ? dayjs(v).format("YYYY-MM-DD") : "";
                setFilterObject(p => ({
                  ...p,
                  fromDate: d,
                  toDate: p.toDate && dayjs(p.toDate).isBefore(v) ? "" : p.toDate,
                }));
                setErrors(p => ({ ...p, fromDate: "" }));
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
              minDate={filterObject.fromDate ? dayjs(filterObject.fromDate) : undefined}
              maxDate={todayDayjs}
              onChange={(v) =>
                setFilterObject(p => ({
                  ...p,
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
            onChange={(e, v) => {
              setSelectedSupplier(v);
              setFilterObject(p => ({ ...p, supplierId: v ? v.id : null }));
            }}
            renderInput={(p) => <CustomTextField {...p} label="Supplier" />}
          />

          <Autocomplete
            options={allCustomers}
            value={selectedCustomer}
            isOptionEqualToValue={(o, v) => o.id === v?.id}
            getOptionLabel={(o) => o?.customerName || ""}
            onChange={(e, v) => {
              setSelectedCustomer(v);
              setFilterObject(p => ({ ...p, customerId: v ? v.id : null }));
            }}
            renderInput={(p) => <CustomTextField {...p} label="Customer" />}
          />
        </div>

        <div className="px-6 pb-5 flex justify-end gap-3">
          <button onClick={clearFiltersAndResults} className="px-3 py-1.5 text-xs sm:px-5 sm:py-2 sm:text-sm border rounded">
            Clear Filters
          </button>

          <button
            onClick={() => handlePurchaseHistory(1)}
            disabled={!isAnyFilterSelected}
            className={`px-4 py-1.5 text-xs sm:px-6 sm:py-2 sm:text-sm rounded
      ${isAnyFilterSelected
                ? "bg-blue-600 text-white"
                : "bg-gray-300 text-gray-500 cursor-not-allowed"
              }
    `}
          >
            Apply Filters
          </button>

        </div>
      </div>

      {/* ================= TABLE ================= */}
      <PurchaseHistory
        data={purchaseHistoryData}
        loading={loading}
        page={currentPage}
        totalItems={totalItems}
        rowsPerPage={rowsPerPage}
        onPageChange={handlePurchaseHistory}
        emptyMessage={
          filtersApplied
            ? "No data found for selected filters"
            : "Apply filters to view purchase history"
        }
        onEdit={(row) => {
          setPurchaseToEdit(row.id);
          setIsEditOpen(true);
        }}
        onDelete={(row) => {
          setPurchaseToDelete(row);
          setIsDeleteOpen(true);
        }}
      />

      {isEditOpen && purchaseToEdit && (
        <EditPurchaseDetail
          open={isEditOpen}
           purchaseId={purchaseToEdit}
          setOpen={setIsEditOpen}
          onUpdateSuccess={() => {
            setIsEditOpen(false);
            setPurchaseToEdit(null);
            handlePurchaseHistory(currentPage);
          }}
        />
      )}

      <DeleteConfirmModal
        open={isDeleteOpen}
        title="Delete Purchase"
        message={
          <>
            Are you sure you want to delete purchase{" "}
            <span className="font-medium text-blue-600">
              #{purchaseToDelete?.id}
            </span>
            ? This action cannot be undone.
          </>
        }
        confirmText="Delete"
        cancelText="Cancel"
        onClose={() => {
          setIsDeleteOpen(false);
          setPurchaseToDelete(null);
        }}
        onConfirm={() => {
          confirmDelete();
          setIsDeleteOpen(false);
          setPurchaseToDelete(null);
        }}
      />

    </div>
  );
};

export default Purchase;
