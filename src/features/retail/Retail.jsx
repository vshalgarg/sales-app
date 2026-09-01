import { useState, useEffect } from "react";
import { useBillForm } from "@/hooks/useBillForm";
import dayjs from "dayjs";
import {
  deleteRetailer,
  deleteSupplierPerRetailer,
  getRetailerDetailsById,
  addDeposits,
  updateRetailer,
  searchRetailerHistory,
  getSupplierAndPaymentHistory,
} from "@/services/RetailService";
import { useSnackbar } from "@/contexts/SnackbarContext";
import SupplierService from "@/services/SupplierService";
import CustomerService from "@/services/CustomerService";
import RetailHistory from "./RetailHistory";
import EditPurchaseDetail from "@/features/purchases/components/EditPurchaseDetail";
import DeleteConfirmModal from "@/components/DeleteConfirmModal";
import GenericAutocomplete from "@/components/GenericAutocomplete";
import { getAllActiveStaffs } from "@/services/StaffService";
import RetailerViewEdit from "./components/RetailerViewEdit";
import EditSupplierModal from "./components/EditSupplier";
import AddSupplierModal from "./components/AddSupplier";
import {
  addSupplierToRetailer,
  updateSupplier,
} from "@/services/RetailService";
import CustomDatePicker from "@/components/CustomDatePicker";
import { IconButton, Tooltip } from "@mui/material";
import { Store, Check, RotateCcw } from "lucide-react";
import { PAGE_TITLE_CLASS } from "@/theme/appTheme";
import {
  SECTION_ICON_CLASS,
  SECTION_ICON_WRAPPER_CLASS,
} from "@/theme/cardTheme";

const Retail = () => {
  const { showSnackbar } = useSnackbar();
  const [currentPage, setCurrentPage] = useState(1);
  const [totalItems, setTotalItems] = useState(0);
  const rowsPerPage = 10;
  const [retailerHistoryData, setRetailerHistoryData] = useState([]);
  const [loading, setLoading] = useState(false);
  const [filtersApplied, setFiltersApplied] = useState(false);
  const [allSuppliers, setAllSuppliers] = useState([]);
  const [allCustomers, setAllCustomers] = useState([]);
  const [selectedSupplier, setSelectedSupplier] = useState(null);
  const [selectedCustomer, setSelectedCustomer] = useState(null);
  const [supplierToEdit, setSupplierToEdit] = useState(null);
  const [isEditSupplierOpen, setIsEditSupplierOpen] = useState(false);
  const [addSupplierRetailerId, setAddSupplierRetailerId] = useState(null);
  const [isAddSupplierOpen, setIsAddSupplierOpen] = useState(false);
  const [isDeleteOpen, setIsDeleteOpen] = useState(false);
  const [retailerToDelete, setRetailerToDelete] = useState(null);
  const [allStaffs, setAllStaffs] = useState([]);
  const [selectedStaff, setSelectedStaff] = useState(null);
  const [supplierToDelete, setSupplierToDelete] = useState(null);
  const [isSupplierDeleteOpen, setIsSupplierDeleteOpen] = useState(false);
  const [viewEditData, setViewEditData] = useState(null);
  const [historyData, setHistoryData] = useState([]);
  const [modalMode, setModalMode] = useState("view");

  const { setErrors, filterObject, setFilterObject } = useBillForm();

  /* ================= LOAD SUPPLIERS & CUSTOMERS ================= */
  useEffect(() => {
    const loadData = async () => {
      try {
        const [suppliers, customers, staffs] = await Promise.all([
          SupplierService.getAllSuppliers(),
          CustomerService.getAllCustomers(),
          getAllActiveStaffs(),
        ]);

        const supplierOptions = (suppliers || []).map((s) => ({
          id: s.id,
          label: `${s.supplierName}${s.city ? ` - ${s.city}` : ""}`,
        }));

        const customerOptions = (customers || []).map((c) => ({
          id: c.id,
          label: `${c.customerName}${c.city ? ` - ${c.city}` : ""}`,
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

  const fetchRetailerDetailsAndHistory = async (retailId) => {
    const [retailerDetail, supplierAndPaymentHistory] = await Promise.all([
      getRetailerDetailsById(retailId),
      getSupplierAndPaymentHistory(retailId),
    ]);
    return { retailerDetail, supplierAndPaymentHistory };
  };

  const openRetailerModal = async (row, mode) => {
    try {
      const { retailerDetail, supplierAndPaymentHistory } =
        await fetchRetailerDetailsAndHistory(row.retailId);

      setModalMode(mode);
      setViewEditData(retailerDetail);
      setHistoryData(supplierAndPaymentHistory ?? []);
    } catch (err) {
      console.error("Failed to load retailer details", err);
      showSnackbar("Failed to load retailer details", "error");
    }
  };

  const handleView = (row) => openRetailerModal(row, "view");

  const handleEdit = (row) => openRetailerModal(row, "edit");

  const handleEditSupplier = (supplierRow) => {
    setSupplierToEdit(supplierRow);
    setIsEditSupplierOpen(true);
  };

  const handleAddSupplier = (row) => {
    setAddSupplierRetailerId(row.retailId);
    setIsAddSupplierOpen(true);
  };

  const handleSaveEditSupplier = async ({ retailSupplierId, totalAmount }) => {
    try {
      const result = await updateSupplier(retailSupplierId, { totalAmount });
      showSnackbar(result.message || "Supplier updated", "success");
      handleRetailerHistory(currentPage);
    } catch (error) {
      showSnackbar(error.message || "Failed to update supplier", "error");
      throw error;
    }
  };

  const handleSaveAddSupplier = async (payload) => {
    try {
      const result = await addSupplierToRetailer(payload);
      showSnackbar(result.message || "Supplier added", "success");
      handleRetailerHistory(currentPage);
    } catch (error) {
      showSnackbar(error.message || "Failed to add supplier", "error");
      throw error;
    }
  };

  const handleSaveDeposits = async (deposits) => {
    try {
      await addDeposits(deposits);
      showSnackbar("Deposits saved successfully", "success");

      const retailId = viewEditData?.id;

      const [detail, history] = await Promise.all([
        getRetailerDetailsById(retailId),
        getSupplierAndPaymentHistory(retailId),
      ]);

      setViewEditData(detail);
      setHistoryData(history ?? []);
      handleRetailerHistory(currentPage);
    } catch (error) {
      showSnackbar(error.message || "something went wrong!", "error");
      throw error;
    }
  };

  const handleSaveRetailer = async ({ retailId, payload }) => {
    try {
      await updateRetailer(retailId, payload);
      showSnackbar("Retailer saved successfully", "success");
      handleRetailerHistory(currentPage);
    } catch (error) {
      showSnackbar(error.message || "something went wrong!", "error");
      throw error;
    }
  };

  const confirmDelete = async () => {
    if (!retailerToDelete) return;

    try {
      await deleteRetailer(retailerToDelete.retailId);
      showSnackbar("Retailer deleted successfully", "success");
      setIsDeleteOpen(false);
      setRetailerToDelete(null);
      handleRetailerHistory(currentPage);
    } catch (err) {
      showSnackbar(err.message || "Failed to delete retailer", "error");
    }
  };

  const handleDeleteSupplier = (supplierRow) => {
    setSupplierToDelete(supplierRow);
    setIsSupplierDeleteOpen(true);
  };

  const confirmDeleteSupplier = async () => {
    try {
      await deleteSupplierPerRetailer(supplierToDelete.retailSupplierId);
      showSnackbar("Supplier entry deleted successfully", "success");
      setIsSupplierDeleteOpen(false);
      handleRetailerHistory(currentPage);
    } catch (err) {
      showSnackbar(err.message || "Failed to delete supplier", "error");
    }
  };
  /* ================= SEARCH ================= */
  const handleRetailerHistory = async (page = 1) => {
    try {
      setLoading(true);
      setFiltersApplied(true);

      const result = await searchRetailerHistory(
        {
          ...filterObject,
          toDate: filterObject.toDate || null,
        },
        page - 1,
        rowsPerPage,
      );
      setRetailerHistoryData(result.data?.content ?? []);
      setTotalItems(result.data?.totalElements ?? 0);
      setCurrentPage(page);
    } catch {
      setRetailerHistoryData([]);
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
    setRetailerHistoryData([]);
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
    <div className="flex flex-col h-full min-h-0">
      <div className="flex flex-col flex-1 min-h-0 gap-3 mt-2">
        <div className="rounded-xl border border-brand-surface-border dark:border-zinc-700/40 bg-brand-tab-inactive/60 dark:bg-zinc-900 shrink-0">
        <div className="px-4 md:px-6 py-3 border-b border-brand-surface-border dark:border-zinc-700/40">
          <div className="flex items-center gap-3">
            <div
              className={`flex h-10 w-10 shrink-0 items-center justify-center rounded-lg ${SECTION_ICON_WRAPPER_CLASS}`}
            >
              <Store className={`h-5 w-5 ${SECTION_ICON_CLASS}`} />
            </div>
            <div>
              <h2 className={PAGE_TITLE_CLASS}>Retailers</h2>
              <p className="text-sm text-brand-search-muted dark:text-gray-400 mt-0.5">
                Filter and review retailer history
              </p>
            </div>
          </div>
        </div>

        <div className="px-4 md:px-6 py-4 flex flex-col gap-3 lg:flex-row lg:items-end">
          <div className="grid flex-1 grid-cols-2 md:grid-cols-2 lg:grid-cols-5 gap-3">
            <CustomDatePicker
              label="From Date"
              value={filterObject.fromDate}
              maxDate={dayjs()}
              onChange={(val) => {
                setFilterObject((p) => ({
                  ...p,
                  fromDate: val,
                  toDate:
                    p.toDate && dayjs(p.toDate).isBefore(dayjs(val))
                      ? ""
                      : p.toDate,
                }));
                setErrors((p) => ({ ...p, fromDate: "" }));
              }}
            />

            <CustomDatePicker
              label="To Date"
              value={filterObject.toDate}
              onChange={(val) =>
                setFilterObject((p) => ({ ...p, toDate: val }))
              }
              minDate={
                filterObject.fromDate ? dayjs(filterObject.fromDate) : undefined
              }
              maxDate={dayjs()}
            />

            <div className="col-span-2 md:col-span-1">
              <GenericAutocomplete
                options={allSuppliers}
                value={selectedSupplier}
                label="Supplier"
                placeholder="Select supplier"
                onChange={(value) => {
                  setSelectedSupplier(value);

                  setFilterObject((p) => ({
                    ...p,
                    supplierId: value ? value.id : null,
                  }));
                }}
              />
            </div>

            <div className="col-span-2 md:col-span-1">
              <GenericAutocomplete
                options={allCustomers}
                value={selectedCustomer}
                label="Referred By"
                placeholder="Select customer"
                onChange={(value) => {
                  setSelectedCustomer(value);
                  setFilterObject((p) => ({
                    ...p,
                    customerId: value ? value.id : null,
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

                  setFilterObject((p) => ({
                    ...p,
                    staffId: value ? value.id : null,
                  }));
                }}
              />
            </div>
          </div>

          <div className="flex items-center justify-end gap-2 shrink-0 pb-0.5">
            <Tooltip title="Apply filters">
              <span>
                <IconButton
                  onClick={() => handleRetailerHistory(1)}
                  disabled={!isAnyFilterSelected || loading}
                  size="medium"
                  aria-label="Apply filters"
                  className="!bg-brand-primary hover:!bg-brand-primary-dark !rounded-lg disabled:!opacity-40"
                >
                  <Check className="h-5 w-5 text-white" />
                </IconButton>
              </span>
            </Tooltip>

            <Tooltip title="Clear filters">
              <span>
                <IconButton
                  onClick={clearFiltersAndResults}
                  disabled={!isAnyFilterSelected || loading}
                  size="medium"
                  aria-label="Clear filters"
                  className="!bg-gray-200 hover:!bg-gray-300 !border !border-brand-surface-border !rounded-lg"
                >
                  <RotateCcw className="h-5 w-5 text-brand-navy" />
                </IconButton>
              </span>
            </Tooltip>
          </div>
        </div>
        </div>

        <div className="flex-1 min-h-0 rounded-xl border border-brand-surface-border dark:border-zinc-700/40 overflow-hidden bg-white dark:bg-zinc-900">
          <RetailHistory
        data={retailerHistoryData}
        page={currentPage}
        totalItems={totalItems}
        rowsPerPage={rowsPerPage}
        onPageChange={handleRetailerHistory}
        emptyMessage={
          filtersApplied
            ? "No data found for selected filters"
            : "Apply filters to view Retail history"
        }
        onView={handleView}
        onEdit={handleEdit}
        onDelete={(row) => {
          setRetailerToDelete(row);
          setIsDeleteOpen(true);
        }}
        onDeleteSupplier={handleDeleteSupplier}
        onAddSupplier={handleAddSupplier}
          onEditSupplier={handleEditSupplier}
          />
        </div>
      </div>

      {viewEditData && (
        <RetailerViewEdit
          open={!!viewEditData}
          data={viewEditData}
          historyData={historyData}
          mode={modalMode}
          onClose={() => setViewEditData(null)}
          onSaveDeposits={handleSaveDeposits}
          onSaveRetailer={handleSaveRetailer}
        />
      )}

      <DeleteConfirmModal
        open={isDeleteOpen}
        title="Delete Retail Entry"
        message="Are you sure you want to delete retailer? This action cannot be undone."
        confirmText="Delete"
        cancelText="Cancel"
        onClose={() => {
          setIsDeleteOpen(false);
          setRetailerToDelete(null);
        }}
        onConfirm={confirmDelete}
      />

      <DeleteConfirmModal
        open={isSupplierDeleteOpen}
        title="Delete Supplier"
        message="Are you sure about deleting this supplier detail? This cannot be undone."
        confirmText="Delete"
        cancelText="Cancel"
        onClose={() => {
          setIsSupplierDeleteOpen(false);
          setSupplierToDelete(null);
        }}
        onConfirm={confirmDeleteSupplier}
      />

      <EditSupplierModal
        open={isEditSupplierOpen}
        onClose={() => {
          setIsEditSupplierOpen(false);
          setSupplierToEdit(null);
        }}
        supplier={supplierToEdit}
        onSave={handleSaveEditSupplier}
      />

      <AddSupplierModal
        open={isAddSupplierOpen}
        onClose={() => {
          setIsAddSupplierOpen(false);
          setAddSupplierRetailerId(null);
        }}
        retailerId={addSupplierRetailerId}
        allSuppliers={allSuppliers}
        maxWidth="sm"
        onSave={handleSaveAddSupplier}
      />
    </div>
  );
};

export default Retail;
