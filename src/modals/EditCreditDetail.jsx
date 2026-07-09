import { useEffect, useMemo, useState } from "react";
import CustomTextField from "../components/CustomTextField";
import Autocomplete from "@mui/material/Autocomplete";
import { useSnackbar } from "../context/SnackbarContext";
import { updateCreditApi } from "../service/CreditService";
import SupplierService from "../service/SupplierService";
import CustomerService from "../service/CustomerService";
import dayjs from "dayjs";
import { LocalizationProvider } from "@mui/x-date-pickers/LocalizationProvider";
import { AdapterDayjs } from "@mui/x-date-pickers/AdapterDayjs";
import { DatePicker } from "@mui/x-date-pickers/DatePicker";
import MenuItem from "@mui/material/MenuItem";
import ArrowBackIcon from "@mui/icons-material/ArrowBack";
import CloseIcon from "@mui/icons-material/Close";
import { IconButton } from "@mui/material";
import AppButton from "../components/common/AppButton";
import FormFooter from "../components/common/FormFooter";
import FormSection from "../components/common/FormSection";
import ModalSectionLayout from "../components/common/ModalSectionLayout";
import {
  CREDIT_SECTION_IDS,
  getCreditModalSections,
} from "../components/common/creditModalSections";
import { useModalSectionNav } from "../customHooks/useModalSectionNav";
import useUnsavedChanges from "../customHooks/useUnsavedChanges";
import ConfirmDialog from "../components/common/ConfirmDialog";
import CustomDatePicker from "../components/common/CustomDatePicker";
import useResponsive from "../customHooks/useResponsive";
import { PAGE_TITLE_CLASS } from "../theme/appTheme";
import { ClipboardList, FileText, Link2, Users } from "lucide-react";

const PAYMENT_TYPES = [
  "CASH",
  "UPI",
  "NEFT_RTGS",
  "CHEQUE",
];

const DRAW_TYPES = [
  "DRAW",
  "CHEQUE",
];

const EditCreditDetail = ({
  open,
  selectedCreditDetail,
  setOpen,
  onUpdateSuccess,
}) => {
  const { showSnackbar } = useSnackbar();
  const { isMobile } = useResponsive();

  const [allSuppliers, setAllSuppliers] = useState([]);
  const [allCustomers, setAllCustomers] = useState([]);

  const [selectedSupplier, setSelectedSupplier] = useState(null);
  const [selectedCustomer, setSelectedCustomer] = useState(null);

  const [formData, setFormData] = useState({
    date: null,
    paymentType: "",
    referenceNumber: "",
    referenceDate: null,
    slipNumber: "",
    drawType: "",
    receivedAmount: "",
    remark: "",
  });

  const [saving, setSaving] = useState(false);
  const [isLoaded, setIsLoaded] = useState(false);
  const [confirmOpen, setConfirmOpen] = useState(false);

  const sections = useMemo(() => getCreditModalSections(), []);
  const sectionIds = useMemo(
    () => sections.map((section) => section.id),
    [sections],
  );

  const { activeSection, scrollToSection, scrollContainerRef, setSectionRef } =
    useModalSectionNav(sectionIds, { enabled: open });

  const { isDirty } = useUnsavedChanges(
    { ...formData, supplierId: selectedSupplier?.id, customerId: selectedCustomer?.id },
    open && isLoaded
  );

  /* ================= LOAD MASTER DATA ================= */
  useEffect(() => {
    Promise.all([
      SupplierService.getAllSuppliers(),
      CustomerService.getAllCustomers(),
    ]).then(([suppliers, customers]) => {
      setAllSuppliers(suppliers || []);
      setAllCustomers(customers || []);
    });
  }, []);

  /* ================= PREFILL DATA ================= */
  useEffect(() => {
    if (!selectedCreditDetail || !open) return;
    setIsLoaded(false);
    setFormData({
      date: selectedCreditDetail.date || null,
      paymentType: selectedCreditDetail.paymentType || "",
      referenceNumber: selectedCreditDetail.referenceNumber || "",
      referenceDate: selectedCreditDetail.referenceDate
        ? dayjs(selectedCreditDetail.referenceDate)
        : null,
      slipNumber: selectedCreditDetail.slipNumber || "",
      drawType: selectedCreditDetail.drawType || "",
      receivedAmount: selectedCreditDetail.receivedAmount || "",
      remark: selectedCreditDetail.remark || "",
    });

    if (allSuppliers.length > 0) {
      setSelectedSupplier(
        allSuppliers.find(
          s => s.id === Number(selectedCreditDetail.supplierId)
        ) || null
      );
    }

    if (allCustomers.length > 0) {
      setSelectedCustomer(
        allCustomers.find(
          c => c.id === Number(selectedCreditDetail.customerId)
        ) || null
      );
    }
  }, [selectedCreditDetail, allSuppliers, allCustomers]);

  useEffect(() => {
    if (
      open &&
      selectedCreditDetail &&
      selectedSupplier !== null &&
      selectedCustomer !== null
    ) {
      setIsLoaded(true);
    }
  }, [open, selectedSupplier, selectedCustomer, selectedCreditDetail]);

  useEffect(() => {
    if (!open) {
      setIsLoaded(false);
    }
  }, [open]);

  if (!open) return null;

  const handleClose = () => {
    if (isDirty()) {
      setConfirmOpen(true);
      return;
    }

    setOpen(false);
  };

  /* ================= RECEIVED AMOUNT VALIDATION ================= */
  const handleReceivedAmountChange = (e) => {
    const value = e.target.value;

    // only numbers + max 2 decimals
    if (/^\d*\.?\d{0,2}$/.test(value)) {
      setFormData(p => ({ ...p, receivedAmount: value }));
      setErrors(p => ({ ...p, receivedAmount: "" }));
    }
  };

  const handleSlipNumberChange = (e) => {
    const value = e.target.value;

    // letters + numbers only
    if (/^[a-zA-Z0-9]*$/.test(value)) {
      setFormData(p => ({ ...p, slipNumber: value }));
      setErrors(p => ({ ...p, slipNumber: "" }));
    } else {
      setErrors(p => ({
        ...p,
        slipNumber: "Only letters and numbers are allowed",
      }));
    }
  };

  /* ================= HANDLERS ================= */
  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  const handleUpdate = async () => {

    try {
      setSaving(true);

      const payload = {
        supplierId: selectedSupplier?.id || null,
        customerId: selectedCustomer?.id || null,
        date: formData.date || null,
        paymentType: formData.paymentType,
        referenceNumber: formData.referenceNumber || null,
        referenceDate: formData.referenceDate
          ? dayjs(formData.referenceDate).format("YYYY-MM-DD")
          : null,

        slipNumber: formData.slipNumber || null,
        drawType: formData.drawType || null,
        receivedAmount: Number(formData.receivedAmount),
        remark: formData.remark || null,
      };

      await updateCreditApi(selectedCreditDetail.id, payload);

      showSnackbar("Credit updated successfully", "success");
      onUpdateSuccess();
    } catch (err) {
      showSnackbar(err.message || "Failed to update credit", "error");
    } finally {
      setSaving(false);
    }
  };

  /* ================= UI ================= */
  return (
    <div className="fixed inset-0 flex items-center justify-center bg-black/80 z-50 p-0 md:p-4">
      <div
        className={`bg-white dark:bg-gray-900 flex flex-col w-full overflow-hidden shadow-lg ${
          isMobile ? "h-full" : "max-w-6xl max-h-[90vh] rounded-xl"
        }`}
      >
        <div className="px-4 sm:px-6 py-4 border-b border-brand-surface-border dark:border-zinc-700 flex items-center justify-between gap-3 shrink-0 bg-white dark:bg-gray-900">
          <div className="flex items-center gap-3 min-w-0">
            <IconButton
              onClick={handleClose}
              className="md:hidden"
              size="small"
              aria-label="Go back"
            >
              <ArrowBackIcon />
            </IconButton>

            <h2 className={`${PAGE_TITLE_CLASS} truncate`}>Edit Credit</h2>
          </div>
          <IconButton
            onClick={handleClose}
            size="small"
            aria-label="Close"
            className="hidden md:inline-flex border border-brand-surface-border rounded-lg"
          >
            <CloseIcon fontSize="small" />
          </IconButton>
        </div>

        <ModalSectionLayout
          sections={sections}
          activeSection={activeSection}
          onSectionClick={scrollToSection}
          scrollContainerRef={scrollContainerRef}
        >
          <div
            ref={setSectionRef(CREDIT_SECTION_IDS.TRANSACTION)}
            id={CREDIT_SECTION_IDS.TRANSACTION}
            className="scroll-mt-4"
          >
            <FormSection
              title="Transaction Details"
              icon={FileText}
              variantIndex={0}
            >
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <CustomTextField
                  label="Invoice Number"
                  value={selectedCreditDetail.billNumber}
                  disabled
                />
                <CustomDatePicker
                  label="Date"
                  value={formData.date}
                  onChange={(val) =>
                    setFormData(prev => ({ ...prev, date: val }))
                  }
                />
                <CustomTextField
                  select
                  label="Payment Type"
                  name="paymentType"
                  value={formData.paymentType}
                  onChange={handleChange}
                >
                  {PAYMENT_TYPES.map(type => (
                    <MenuItem key={type} value={type}>{type}</MenuItem>
                  ))}
                </CustomTextField>
                <CustomTextField
                  label="Received Amount"
                  name="receivedAmount"
                  value={formData.receivedAmount}
                  onChange={handleReceivedAmountChange}
                />
              </div>
            </FormSection>
          </div>

          <div
            ref={setSectionRef(CREDIT_SECTION_IDS.PARTY)}
            id={CREDIT_SECTION_IDS.PARTY}
            className="scroll-mt-4"
          >
            <FormSection
              title="Party Information"
              icon={Users}
              variantIndex={1}
            >
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <Autocomplete
                  options={allSuppliers}
                  value={selectedSupplier}
                  isOptionEqualToValue={(o, v) => o.id === v?.id}
                  getOptionLabel={(o) =>
                    o?.supplierName ? `${o.supplierName}${o.city ? ` - ${o.city}` : ""}`: ""
                  }
                  onChange={(e, v) => setSelectedSupplier(v)}
                  renderInput={(params) => (
                    <CustomTextField {...params} label="Supplier" />
                  )}
                />

                <Autocomplete
                  options={allCustomers}
                  value={selectedCustomer}
                  isOptionEqualToValue={(o, v) => o.id === v?.id}
                  getOptionLabel={(o) =>
                    o?.customerName ? `${o.customerName}${o.city ? ` - ${o.city}` : ""}`: ""
                  }
                  onChange={(e, v) => setSelectedCustomer(v)}
                  renderInput={(params) => (
                    <CustomTextField {...params} label="Customer" />
                  )}
                />
              </div>
            </FormSection>
          </div>

          <div
            ref={setSectionRef(CREDIT_SECTION_IDS.REFERENCE)}
            id={CREDIT_SECTION_IDS.REFERENCE}
            className="scroll-mt-4"
          >
            <FormSection
              title="Reference Details"
              icon={Link2}
              variantIndex={2}
            >
              <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
                <CustomTextField
                  label="Reference Number"
                  name="referenceNumber"
                  value={formData.referenceNumber}
                  onChange={handleChange}
                />

                <LocalizationProvider dateAdapter={AdapterDayjs}>
                  <DatePicker
                    label="Reference Date"
                    value={formData.referenceDate}
                    onChange={(newValue) =>
                      setFormData(prev => ({ ...prev, referenceDate: newValue }))
                    }
                    slotProps={{
                      textField: {
                        fullWidth: true,
                        size: "small",
                      },
                    }}
                  />
                </LocalizationProvider>

                <CustomTextField
                  label="Slip Number"
                  name="slipNumber"
                  value={formData.slipNumber}
                  onChange={handleSlipNumberChange}
                />
              </div>
            </FormSection>
          </div>

          <div
            ref={setSectionRef(CREDIT_SECTION_IDS.MISC)}
            id={CREDIT_SECTION_IDS.MISC}
            className="scroll-mt-4"
          >
            <FormSection
              title="Miscellaneous"
              icon={ClipboardList}
              variantIndex={3}
            >
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <CustomTextField
                  select
                  label="Draw Type"
                  name="drawType"
                  value={formData.drawType}
                  onChange={handleChange}
                >
                  {DRAW_TYPES.map(type => (
                    <MenuItem key={type} value={type}>{type}</MenuItem>
                  ))}
                </CustomTextField>

                <CustomTextField
                label="Remark"
                name="remark"
                value={formData.remark}
                onChange={handleChange}
                multiline
                rows={2}
              />
              </div>

              
            </FormSection>
          </div>
        </ModalSectionLayout>

        <FormFooter background="bg-white dark:bg-gray-900">
          <AppButton
            type="primary"
            onClick={handleUpdate}
            loading={saving}
            sx={{ minWidth: "130px" }}
          >
            Update
          </AppButton>

          <AppButton
            type="cancel"
            onClick={handleClose}
            disabled={saving}
          >
            Cancel
          </AppButton>
        </FormFooter>

        <ConfirmDialog
          open={confirmOpen}
          onConfirm={() => {
            setConfirmOpen(false);
            setOpen(false);
          }}
          onCancel={() => setConfirmOpen(false)}
        />
      </div>
    </div>
  );
};

export default EditCreditDetail;
