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
            <div className="grid grid-cols-2 md:grid-cols-2 lg:grid-cols-4 gap-3">

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
                    setFilterObject(prev => ({
                      ...prev,
                      customerId: value ? value.id : null
                    }));
                  }}
                />
              </div>
            </div>

            {/* Actions */}
            <div className="mt-6 flex justify-end gap-3">
              <AppButton
                type="secondary"
                onClick={clearFiltersAndResults}
              >
                Clear Filters
              </AppButton>

              <AppButton
                type="primary"
                onClick={() => handleBillDetailHistory(1)}
                disabled={!isAnyFilterSelected}
                loading={loading}
              >
                Apply Filters
              </AppButton>

            </div>
          </div>
        </div>

        {/* ================= TABLE ================= */}
        <BillHistory
          data={billHistoryData}
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
}
export default Bills;
