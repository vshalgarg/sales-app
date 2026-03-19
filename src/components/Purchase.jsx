import { LocalizationProvider } from "@mui/x-date-pickers/LocalizationProvider";
import { AdapterDayjs } from "@mui/x-date-pickers/AdapterDayjs";
import { DatePicker } from "@mui/x-date-pickers/DatePicker";
import { useBillForm } from "../customHooks/useBillForm";
import dayjs from "dayjs";
import { useState, useEffect } from "react";
import { deletePurchaseApi, searchPurchaseHistory } from "../service/PurchaseService";
import { useSnackbar } from "../context/SnackbarContext";
import SupplierService from "../service/SupplierService";
import CustomerService from "../service/CustomerService";
import PurchaseHistory from "./PurchaseHistory";
import EditPurchaseDetail from "../modals/EditPurchaseDetail";
import DeleteConfirmModal from "./common/DeleteConfirmModal";
import AppButton from "./common/AppButton";
import GenericAutocomplete from "./common/GenericAutocomplete";
import { getAllActiveStaffs } from "../service/StaffService";

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
  const [allStaffs, setAllStaffs] = useState([]);
  const [selectedStaff, setSelectedStaff] = useState(null);


  const today = dayjs().format("YYYY-MM-DD");
  const todayDayjs = dayjs();

  const { errors, setErrors, filterObject, setFilterObject } = useBillForm();

  /* ================= LOAD SUPPLIERS & CUSTOMERS ================= */
  useEffect(() => {
    const loadData = async () => {
      try {
        const [suppliers, customers, staffs] = await Promise.all([
          SupplierService.getAllSuppliers(),
          CustomerService.getAllCustomers(),
          getAllActiveStaffs()
        ]);

        const supplierOptions = (suppliers || []).map((s) => ({
          id: s.id,
          label: s.supplierName,
        }));

        const customerOptions = (customers || []).map((c) => ({
          id: c.id,
          label: c.customerName,
        }));

        const staffOptions = (staffs || []).map((s) => ({
          id: s.staffId,
          label: s.staffName,
        }));

        setAllSuppliers(supplierOptions || []);
        setAllCustomers(customerOptions || []);
        setAllStaffs(staffOptions || []);
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
    setSelectedStaff(null);

    setFilterObject({
      supplierId: null,
      customerId: null,
      staffId: null,
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
    !!filterObject.customerId ||
    !!filterObject.staffId;


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

        <div className="px-6 py-5">
          <div className="grid grid-cols-2 md:grid-cols-2 lg:grid-cols-5 gap-3">
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
                    sx: {
                      "& .MuiPickersSectionList-root": {
                        fontSize: { xs: "12px", md: "16px" },
                      },
                    },
                  },
                }}
              />
            </LocalizationProvider>

            <div className="col-span-2 md:col-span-1">
              <GenericAutocomplete
                options={allSuppliers}
                value={selectedSupplier}
                label="Supplier"
                placeholder="Select supplier"
                onChange={(value) => {
                  setSelectedSupplier(value);

                  setFilterObject(p => ({
                    ...p,
                    supplierId: value ? value.id : null
                  }));
                }}
              />
            </div>
            <div className="col-span-2 md:col-span-1">
              <GenericAutocomplete
                options={allCustomers}
                value={selectedCustomer}
                label="Customer"
                placeholder="Select customer"
                onChange={(value) => {
                  setSelectedCustomer(value);
                  setFilterObject(p => ({
                    ...p,
                    customerId: value ? value.id : null
                  }));
                }}
              />
            </div>

            <div className="col-span-2 md:col-span-1">
              <GenericAutocomplete
                options={allStaffs}
                value={selectedStaff}
                label="Staff"
                placeholder="Select staff"
                onChange={(value) => {
                  setSelectedStaff(value);

                  setFilterObject(p => ({
                    ...p,
                    staffId: value ? value.id : null
                  }));
                }}
              />
            </div>

          </div>
        </div>

        <div className="px-6 pb-5 flex justify-end gap-3">

          <AppButton
            type="secondary"
            onClick={clearFiltersAndResults}
          >
            Clear Filters
          </AppButton>

          <AppButton
            type="primary"
            onClick={() => handlePurchaseHistory(1)}
            disabled={!isAnyFilterSelected}
            loading={loading}
          >
            Apply Filters
          </AppButton>

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
            Are you sure you want to delete purchase,
            This action cannot be undone.
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
