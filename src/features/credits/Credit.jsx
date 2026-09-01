import { LocalizationProvider } from "@mui/x-date-pickers/LocalizationProvider";
import { AdapterDayjs } from "@mui/x-date-pickers/AdapterDayjs";
import { DatePicker } from "@mui/x-date-pickers/DatePicker";
import { useBillForm } from "@/hooks/useBillForm";
import dayjs from "dayjs";
import { useState, useEffect } from "react";
import { deleteCreditApi, searchCreditHistory } from "@/services/CreditService";
import { useSnackbar } from "@/contexts/SnackbarContext";
import SupplierService from "@/services/SupplierService";
import CustomerService from "@/services/CustomerService";
import CreditHistory from "./CreditHistory";
import CreditDetail from "./components/CreditDetail";
import EditCreditDetail from "./components/EditCreditDetail";
import DeleteConfirmModal from "@/components/DeleteConfirmModal";
import GenericAutocomplete from "@/components/GenericAutocomplete";
import { formatIndianCurrency } from "@/utils/currencyUtils";
import { IconButton, Tooltip } from "@mui/material";
import { CreditCard, Check, RotateCcw } from "lucide-react";
import { PAGE_TITLE_CLASS } from "@/theme/appTheme";
import {
  SECTION_ICON_CLASS,
  SECTION_ICON_WRAPPER_CLASS,
} from "@/theme/cardTheme";


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
      setTotalAmount(formatIndianCurrency(Math.round(total)))
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
    <div className="flex flex-col h-full min-h-0">
      <div className="flex flex-col flex-1 min-h-0 gap-3 mt-2">
      {/* ================= FILTER CARD ================= */}
      <div className="rounded-xl border border-brand-surface-border dark:border-zinc-700/40 bg-brand-tab-inactive/60 dark:bg-zinc-900 shrink-0">
        <div className="px-4 md:px-6 py-3 border-b border-brand-surface-border dark:border-zinc-700/40">
          <div className="flex items-center gap-3">
            <div
              className={`flex h-10 w-10 shrink-0 items-center justify-center rounded-lg ${SECTION_ICON_WRAPPER_CLASS}`}
            >
              <CreditCard className={`h-5 w-5 ${SECTION_ICON_CLASS}`} />
            </div>
            <div>
              <h2 className={PAGE_TITLE_CLASS}>Credits</h2>
              <p className="text-sm text-brand-search-muted dark:text-gray-400 mt-0.5">
                Filter and review credit history by supplier, customer and date range
              </p>
            </div>
          </div>
        </div>

        <div className="px-4 md:px-6 py-4 flex flex-col gap-3 lg:flex-row lg:items-end">
          <div className="grid flex-1 grid-cols-2 md:grid-cols-2 lg:grid-cols-4 gap-3">
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

          <div className="flex items-center justify-end gap-2 shrink-0 pb-0.5">
            <Tooltip title="Apply filters">
              <span>
                <IconButton
                  onClick={() => handleCreditHistory(1)}
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

      {/* ================= TABLE ================= */}
      <div className="flex-1 min-h-0 rounded-xl border border-brand-surface-border dark:border-zinc-700/40 overflow-hidden bg-white dark:bg-zinc-900">
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
      </div>
      </div>

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
