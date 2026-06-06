import { useState, useEffect } from "react";
import { useBillForm } from "../customHooks/useBillForm";
import dayjs from "dayjs";
import {
  deleteRetailer,
  deleteSupplierPerRetailer,
  getRetailerDetailsById,
  addDeposits,
  updateRetailer,
  searchRetailerHistory,
  getSupplierAndPaymentHistory,
} from "../service/RetailService";
import { useSnackbar } from "../context/SnackbarContext";
import SupplierService from "../service/SupplierService";
import CustomerService from "../service/CustomerService";
import RetailHistory from "./RetailHistory";
import EditPurchaseDetail from "../modals/EditPurchaseDetail";
import DeleteConfirmModal from "./common/DeleteConfirmModal";
import AppButton from "./common/AppButton";
import GenericAutocomplete from "./common/GenericAutocomplete";
import { getAllActiveStaffs } from "../service/StaffService";
import RetailerViewEdit from "../modals/RetailerViewEdit";
import EditSupplierModal from "../modals/EditSupplier";
import AddSupplierModal from "../modals/AddSupplier";
import {
  addSupplierToRetailer,
  updateSupplier,
} from "../service/RetailService";
import CustomDatePicker from "./common/CustomDatePicker";

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

  const fetchHistory = async (retailId) => {
    const history = await getSupplierAndPaymentHistory(retailId);
    setHistoryData(history ?? []);
  };

  const handleView = async (row) => {
    try {
      console.log(row);
      const detail = await getRetailerDetailsById(row.retailId);
      await fetchHistory(row.retailId);
      setModalMode("view");
      setViewEditData(detail);
    } catch {
      showSnackbar("Failed to load retailer details", "error");
    }
  };

  const handleEdit = async (row) => {
    try {
      const detail = await getRetailerDetailsById(row.retailId);
      await fetchHistory(row.retailId);
      setModalMode("edit");
      setViewEditData(detail);
    } catch {
      showSnackbar("Failed to load retailer details", "error");
    }
  };

  const handleEditSupplier = (supplierRow) => {
    setSupplierToEdit(supplierRow);
    setIsEditSupplierOpen(true);
  };

  const handleAddSupplier = (row) => {
    console.log("row", row);
    setAddSupplierRetailerId(row.retailId);
    setIsAddSupplierOpen(true);
  };

  const handleSaveEditSupplier = async ({ retailSupplierId, totalAmount }) => {
    const result = await updateSupplier(retailSupplierId, { totalAmount });
    showSnackbar(result.message || "Supplier updated", "success");
    handleRetailerHistory(currentPage);
  };

  const handleSaveAddSupplier = async (payload) => {
    const result = await addSupplierToRetailer(payload);
    showSnackbar(result.message || "Supplier added", "success");
    handleRetailerHistory(currentPage);
  };

  const handleSaveDeposits = async (deposits) => {
    await addDeposits(deposits);
    showSnackbar("Deposits saved", "success");

    const retailId = viewEditData?.id;

    const [detail, history] = await Promise.all([
      getRetailerDetailsById(retailId),
      getSupplierAndPaymentHistory(retailId),
    ]);

    setViewEditData(detail);
    setHistoryData(history ?? []);
    handleRetailerHistory(currentPage);
  };

  const handleSaveRetailer = async ({ retailId, payload }) => {
    await updateRetailer(retailId, payload);
    showSnackbar("Retailer saved", "success");
    handleRetailerHistory(currentPage);
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
      showSnackbar("Supplier entry deleted", "success");
      setIsSupplierDeleteOpen(false);
      handleRetailerHistory(currentPage);
    } catch (err) {
      showSnackbar(err.message || "Failed to delete", "error");
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
    <div className="flex flex-col h-full overflow-y-auto">
      {/* ================= FILTER CARD ================= */}
      <div className="bg-gray-50 border rounded-t-lg shadow-sm mt-4">
        <div className="px-6 py-4 border-b">
          <h2 className="text-xl font-semibold">Retailers</h2>
          <p className="text-sm text-gray-500 mt-1">
            Filter and review Retailer history
          </p>
        </div>

        <div className="px-6 py-5">
          <div className="grid grid-cols-2 md:grid-cols-2 lg:grid-cols-5 gap-3">
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
                label="ReferredBy"
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
        </div>

        <div className="px-6 pb-5 flex justify-end gap-3">
          <AppButton type="secondary" onClick={clearFiltersAndResults}>
            Clear Filters
          </AppButton>

          <AppButton
            type="primary"
            onClick={() => handleRetailerHistory(1)}
            disabled={!isAnyFilterSelected}
            loading={loading}
          >
            Apply Filters
          </AppButton>
        </div>
      </div>

      {/* ================= TABLE ================= */}
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
