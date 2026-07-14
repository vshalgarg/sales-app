import { LocalizationProvider } from "@mui/x-date-pickers/LocalizationProvider";
import { useBillForm } from "../customHooks/useBillForm";
import { AdapterDayjs } from "@mui/x-date-pickers/AdapterDayjs";
import { DatePicker } from "@mui/x-date-pickers/DatePicker";
import { useState, useEffect } from "react";
import dayjs from "dayjs";
import { searchBillHistory } from "../service/BillService";
import BillHistory from "./BillHistory";
import { useSnackbar } from "../context/SnackbarContext";
import SupplierService from "../service/SupplierService";
import CustomerService from "../service/CustomerService";
import BillDetail from "../modals/BillDetail";
import EditBillDetail from "../modals/EditBillDetail";
import { deleteBill } from "../service/BillService";
import DeleteConfirmModal from "./common/DeleteConfirmModal";
import AppButton from "./common/AppButton";
import GenericAutocomplete from "./common/GenericAutocomplete";
import { formatIndianCurrency } from "../utils/currencyUtils";
import { IconButton, Tooltip } from "@mui/material";
import { FilterX, Funnel, Receipt, Check, RotateCcw } from "lucide-react";
import { PAGE_TITLE_CLASS } from "../theme/appTheme";
import {
  SECTION_ICON_CLASS,
  SECTION_ICON_WRAPPER_CLASS,
} from "../theme/cardTheme";

const Bills = () => {
  const { showSnackbar } = useSnackbar();
  const [currentPage, setCurrentPage] = useState(1);
  const [totalItems, setTotalItems] = useState(0);
  const [totalAmount, setTotalAmount] = useState(0);
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

  const { errors, setErrors, filterObject, setFilterObject } = useBillForm();

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
        rowsPerPage,
      );

      setBillHistoryData(data?.content ?? []);
      setTotalItems(data?.totalElements ?? 0);
      setCurrentPage(page);
      let total = data?.totalAmount ?? 0;
      setTotalAmount(formatIndianCurrency(Math.round(total)));
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
      <div className="flex flex-col h-full min-h-0">
        <div className="flex flex-col flex-1 min-h-0 gap-3 mt-2">
          {/* ================= FILTER CARD ================= */}
          <div className="rounded-xl border border-brand-surface-border dark:border-zinc-700/40 bg-brand-tab-inactive/60 dark:bg-zinc-900 shrink-0">
            {/* Header */}
            <div className="px-4 md:px-6 py-3 border-b border-brand-surface-border dark:border-zinc-700/40">
              <div className="flex items-center gap-3">
                <div
                  className={`flex h-10 w-10 shrink-0 items-center justify-center rounded-lg ${SECTION_ICON_WRAPPER_CLASS}`}
                >
                  <Receipt className={`h-5 w-5 ${SECTION_ICON_CLASS}`} />
                </div>
                <div>
                  <h2 className={PAGE_TITLE_CLASS}>Bills</h2>
                  <p className="text-sm text-brand-search-muted dark:text-gray-400 mt-0.5">
                    Filter and review bill history by supplier, customer and
                    date range
                  </p>
                </div>
              </div>
            </div>

            {/* Filters */}

            <div className="px-4 md:px-6 py-4 flex flex-col gap-3 lg:flex-row lg:items-end">
              <div className="grid flex-1 grid-cols-2 md:grid-cols-2 lg:grid-cols-4 gap-3">
                {/* From Date */}
                <LocalizationProvider dateAdapter={AdapterDayjs}>
                  <DatePicker
                    label="From Date"
                    format="DD-MM-YYYY"
                    value={
                      filterObject.fromDate
                        ? dayjs(filterObject.fromDate)
                        : null
                    }
                    maxDate={todayDayjs}
                    onChange={(v) => {
                      const formatted = v ? dayjs(v).format("YYYY-MM-DD") : "";

                      setFilterObject((prev) => ({
                        ...prev,
                        fromDate: formatted,
                        //if toDate exists & is before new fromDate → reset toDate
                        toDate:
                          prev.toDate && dayjs(prev.toDate).isBefore(v)
                            ? ""
                            : prev.toDate,
                      }));

                      setErrors((prev) => ({ ...prev, fromDate: "" }));
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

                {/* To Date */}
                <LocalizationProvider dateAdapter={AdapterDayjs}>
                  <DatePicker
                    label="To Date"
                    format="DD-MM-YYYY"
                    value={
                      filterObject.toDate ? dayjs(filterObject.toDate) : null
                    }
                    minDate={
                      filterObject.fromDate
                        ? dayjs(filterObject.fromDate)
                        : undefined
                    } //cannot select before fromDate
                    maxDate={todayDayjs}
                    onChange={(v) =>
                      setFilterObject((prev) => ({
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
                    loading={supplierLoading}
                    label="Supplier"
                    placeholder="Select supplier"
                    onChange={(value) => {
                      setSelectedSupplier(value);
                      setFilterObject((prev) => ({
                        ...prev,
                        supplierId: value ? value.id : null,
                      }));
                    }}
                  />
                </div>

                {/* Customer */}
                <div className="col-span-2 md:col-span-1">
                  <GenericAutocomplete
                    options={allCustomers}
                    value={selectedCustomer}
                    loading={customerLoading}
                    label="Customer"
                    placeholder="Select customer"
                    onChange={(value) => {
                      setSelectedCustomer(value);
                      setFilterObject((prev) => ({
                        ...prev,
                        customerId: value ? value.id : null,
                      }));
                    }}
                  />
                </div>
              </div>

              {/* Actions */}
              <div className="flex items-center justify-end gap-2 shrink-0 pb-0.5">
                <Tooltip title="Apply filters">
                  <span>
                    <IconButton
                      onClick={() => handleBillDetailHistory(1)}
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
            <BillHistory
              data={billHistoryData}
              page={currentPage}
              totalItems={totalItems}
              rowsPerPage={rowsPerPage}
              totalAmount={totalAmount}
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
        </div>
      </div>

      {/* ================= VIEW BILL MODAL ================= */}
      {isModalOpen && selectedBillDetail && (
        <BillDetail
          billNumber={selectedBillDetail.billNumber}
          setIsModalOpen={setIsModalOpen}
        />
      )}

      {/* ================= EDIT BILL MODAL ================= */}
      {open && selectedBillDetail && (
        <EditBillDetail
          open={open}
          billNumber={selectedBillDetail.billNumber}
          setOpen={setOpen}
          onUpdateSuccess={() => {
            setOpen(false);
            handleBillDetailHistory(currentPage);
          }}
        />
      )}

      <DeleteConfirmModal
        open={isDeleteOpen}
        title="Delete Bill"
        message={
          <>
            Are you sure you want to delete bill{" "}
            <span className="font-semibold text-blue-600">
              #{billToDelete?.billNumber}
            </span>
            ? This action cannot be undone.
          </>
        }
        confirmText="Delete"
        cancelText="Cancel"
        onClose={() => {
          setIsDeleteOpen(false);
          setBillToDelete(null);
        }}
        onConfirm={() => {
          confirmDelete();
          setIsDeleteOpen(false);
          setBillToDelete(null);
        }}
      />
    </>
  );
};
export default Bills;
