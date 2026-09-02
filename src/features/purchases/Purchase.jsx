import { LocalizationProvider } from "@mui/x-date-pickers/LocalizationProvider";
import { AdapterDayjs } from "@mui/x-date-pickers/AdapterDayjs";
import { DatePicker } from "@mui/x-date-pickers/DatePicker";
import { useBillForm } from "@/hooks/useBillForm";
import dayjs from "dayjs";
import { useState, useEffect } from "react";
import { deletePurchaseApi, downloadPurchaseHistory, searchPurchaseHistory } from "@/services/PurchaseService";
import { useSnackbar } from "@/contexts/SnackbarContext";
import SupplierService from "@/services/SupplierService";
import CustomerService from "@/services/CustomerService";
import PurchaseHistory from "./PurchaseHistory";
import EditPurchaseDetail from "./components/EditPurchaseDetail";
import DeleteConfirmModal from "@/components/DeleteConfirmModal";
import GenericAutocomplete from "@/components/GenericAutocomplete";
import { getAllActiveStaffs } from "@/services/StaffService";
import { IconButton, Tooltip } from "@mui/material";
import { Check, Download, RotateCcw, ShoppingCart } from "lucide-react";
import { PAGE_TITLE_CLASS } from "@/theme/appTheme";
import {
  SECTION_ICON_CLASS,
  SECTION_ICON_WRAPPER_CLASS,
} from "@/theme/cardTheme";
import { downloadFile } from "@/utils/downloadFile";

const rowsPerPage = 10;

const Purchase = () => {
  const { showSnackbar } = useSnackbar();
  const [currentPage, setCurrentPage] = useState(1);
  const [totalItems, setTotalItems] = useState(0);
  const [purchaseHistoryData, setPurchaseHistoryData] = useState([]);
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
    } 
  };

  const handleDownload = async () => {
    try {
      const response = await downloadPurchaseHistory({
        ...filterObject
      });
      const downloadOptions = {
        data:response.data,
        type:"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        headers:response.headers,
        defaultFileName:"purchases.xlsx"
      }
      downloadFile(downloadOptions)
    } catch (err) {
      showSnackbar(err.message || "Download failed, Please try again!", "error");
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
    <div className="flex flex-col h-full min-h-0">
      <div className="flex flex-col flex-1 min-h-0 gap-3 mt-2">
      {/* ================= FILTER CARD ================= */}
      <div className="rounded-xl border border-brand-surface-border dark:border-zinc-700/40 bg-brand-tab-inactive/60 dark:bg-zinc-900 shrink-0">
        <div className="px-4 md:px-6 py-3 border-b border-brand-surface-border dark:border-zinc-700/40">
          <div className="flex items-center gap-3">
            <div
              className={`flex h-10 w-10 shrink-0 items-center justify-center rounded-lg ${SECTION_ICON_WRAPPER_CLASS}`}
            >
              <ShoppingCart className={`h-5 w-5 ${SECTION_ICON_CLASS}`} />
            </div>
            <div>
              <h2 className={PAGE_TITLE_CLASS}>Purchases</h2>
              <p className="text-sm text-brand-search-muted dark:text-gray-400 mt-0.5">
                Filter and review purchase history
              </p>
            </div>
          </div>
        </div>

        <div className="px-4 md:px-6 py-4 flex flex-col gap-3 lg:flex-row lg:items-end">
          <div className="grid flex-1 grid-cols-2 md:grid-cols-2 lg:grid-cols-5 gap-3">
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

          <div className="flex items-center justify-end gap-2 shrink-0 pb-0.5">
            <Tooltip title="Apply filters">
              <span>
                <IconButton
                  onClick={() => handlePurchaseHistory(1)}
                  disabled={!isAnyFilterSelected}
                  size="medium"
                  aria-label="Apply filters"
                  className="!bg-brand-primary hover:!bg-brand-primary-dark !rounded-lg disabled:!opacity-40"
                >
                  <Check className="h-5 w-5 text-white" />
                </IconButton>
              </span>
            </Tooltip>

            <Tooltip title="Download Excel">
              <span>
                <IconButton
                  onClick={handleDownload}
                  disabled={!isAnyFilterSelected}
                  size="medium"
                  aria-label="Download Excel"
                  className="!bg-brand-primary hover:!bg-brand-primary-dark !rounded-lg disabled:!opacity-40"
                >
                  <Download className="h-5 w-5 text-white" />
                </IconButton>
              </span>
            </Tooltip>

            <Tooltip title="Clear filters">
              <span>
                <IconButton
                  onClick={clearFiltersAndResults}
                  disabled={!isAnyFilterSelected}
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

      {/* ================= TABLE ================= */}
      <div className="flex-1 min-h-0 rounded-xl border border-brand-surface-border dark:border-zinc-700/40 overflow-hidden bg-white dark:bg-zinc-900">
        <PurchaseHistory
          data={purchaseHistoryData}
          page={currentPage}
          totalItems={totalItems}
          filterObject={filterObject}
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
      </div>
      </div>

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
