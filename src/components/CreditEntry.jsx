import CustomTextField from "./CustomTextField";
import dayjs from "dayjs";
import { useState, useEffect } from "react";
import BasicSelect from "./BasicSelect";
import { useBillForm } from "../customHooks/useBillForm";
import { useSnackbar } from "../context/SnackbarContext";
import { addCreditEntry } from "../service/CreditService";
import validate from "../validations/Validation";
import SupplierService from "../service/SupplierService";
import CustomerService from "../service/CustomerService";
import { mapToOption } from "../utils/optionMapper";
import GenericAutocomplete from "./common/GenericAutocomplete";
import { useUnsaved } from "../context/UnsavedChangesContext";
import useUnsavedChanges from "../customHooks/useUnsavedChanges";
import CustomDatePicker from "./common/CustomDatePicker";
import FormSection from "./common/FormSection";
import FormFooter from "./common/FormFooter";
import AppButton from "./common/AppButton";
import { PAGE_TITLE_CLASS } from "../theme/appTheme";
import { CARD_GRID_SHELL_CLASS, FORM_SCROLL_AREA_CLASS } from "../theme/cardTheme";
import { Users, Receipt, FileText } from "lucide-react";

export default function CreditEntryForm() {
  const { showSnackbar } = useSnackbar();
  const {
    errors,
    setErrors,
    setFilterObject,
  } = useBillForm();

  const [formData, setFormData] = useState({
    paymentType: "",
    billNumber: "",
    date: dayjs().format("YYYY-MM-DD"),
    referenceNumber: "",
    referenceDate: "",
    receivedAmount: "",
    supplierId: "",
    customerId: "",
    slipNumber: "",
    drawType: "",
    remark: "",
  });

  const [allSuppliers, setAllSuppliers] = useState([]);
  const [allCustomers, setAllCustomers] = useState([]);
  const [isSaving, setIsSaving] = useState(false);
  const [userTouched, setUserTouched] = useState(false);
  const { setIsDirty } = useUnsaved();

  const { isDirty: localDirty } = useUnsavedChanges(formData);
  useEffect(() => {
    if (!userTouched) {
      setIsDirty(false);
      return;
    }

    setIsDirty(localDirty());
  }, [formData, userTouched]);

  const supplierOptions = mapToOption(allSuppliers, "id", "supplierName");
  const customerOptions = mapToOption(allCustomers, "id", "customerName");


  useEffect(() => {
    const fetchData = async () => {
      try {
        const suppliers = await SupplierService.getAllSuppliers();
        setAllSuppliers(suppliers || []);

        const customers = await CustomerService.getAllCustomers();
        setAllCustomers(customers || []);
      } catch (err) {
        console.error(err);
        showSnackbar("Error loading suppliers/customers", "error");
      }
    };

    fetchData();
  }, []);

  const handleSlipNumberChange = (e) => {
    const val = e.target.value;

    if (/^[a-zA-Z0-9/-]*$/.test(val)) {
      handleChange("slipNumber", val);
    }
  };


  const handleReset = () => {
    setUserTouched(false);
    resetSupplier();
    resetCustomer();

    setFormData({
      paymentType: "",
      billNumber: "",
      referenceNumber: "",
      referenceDate: "",
      receivedAmount: "",
      supplierId: "",
      customerId: "",
      slipNumber: "",
      drawType: "",
      remark: "",
    });
    setErrors({});
    setFilterObject({});
  };

  const resetSupplier = () => {
    setFormData(prev => ({
      ...prev,
      supplierId: "",
    }));
  };

  const resetCustomer = () => {
    setFormData(prev => ({
      ...prev,
      customerId: "",
    }));
  };


  const formatAmount = (val) => {
    if (val === "" || isNaN(val)) return "0.00";
    const num = parseFloat(val);
    return Number.isInteger(num) ? num.toFixed(2) : String(num);
  };


  const handleBillNumberChange = (e) => {
    setUserTouched(true);
    const raw = e.target.value;
    const sanitized = raw.replace(/[^a-zA-Z0-9/-]/g, "");

    setFormData((prev) => ({
      ...prev,
      billNumber: sanitized,
    }));

    // ❗ special char case → validation skip
    if (raw !== sanitized) {
      setErrors((prev) => ({ ...prev, billNumber: "" }));
      return;
    }

    // normal typing → validate
    setErrors((prev) => ({
      ...prev,
      billNumber: validate("billNumber", sanitized) || "",
    }));
  };

  const handleAmountBlur = (name) => {
    setFormData((prev) => ({
      ...prev,
      [name]: formatAmount(prev[name]),
    }));
  };

  const handleReferenceNumberChange = (e) => {
    setUserTouched(true);
    const raw = e.target.value;
    const sanitized = raw.replace(/[^a-zA-Z0-9/-]/g, "");

    setFormData((prev) => ({
      ...prev,
      referenceNumber: sanitized,
    }));

    // ❗ special char typed → no error
    if (raw !== sanitized) {
      setErrors((prev) => ({ ...prev, referenceNumber: "" }));
      return;
    }

    setErrors((prev) => ({
      ...prev,
      referenceNumber: validate("referenceNumber", sanitized) || "",
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (isSaving) return;
    setIsSaving(true);

    const newErrors = {};

    Object.keys(formData).forEach((field) => {

      if (field === "drawType" || field === "remark" || field === "billNumber") return;

      // Supplier
      if (field === "supplierId" && !formData.supplierId) {
        newErrors.supplierName = "Supplier is required";
        return;
      }

      // Customer
      if (field === "customerId" && !formData.customerId) {
        newErrors.customerName = "Customer is required";
        return;
      }

      if (field === "supplierId" || field === "customerId") return;

      // Cheque conditional
      if (
        (field === "chequeNumber" || field === "chequeDate") &&
        formData.paymentType !== "CHEQUE"
      ) {
        return;
      }

      const error = validate(field, formData[field]);
      if (error) {
        newErrors[field] = error;
      }
    });

    setErrors(newErrors);

    if (Object.keys(newErrors).length > 0) {
      setIsSaving(false);
      showSnackbar("Please fill required fields in the form.", "error");
      return;
    }

    try {
      const payload = {
        ...formData,
        date: formData.date || null,
        referenceDate: formData.referenceDate || null,
        drawType: formData.drawType || null
      };

      const response = await addCreditEntry(payload);

      if (
        response &&
        typeof response === "object" &&
        "code" in response &&
        "message" in response
      ) {
        showSnackbar(response.message, "error");
        return;
      }

      showSnackbar(response.message, "success");
      handleReset();
      setFilterObject({});

    } catch (error) {
      showSnackbar(error.message, "error");
    } finally {
      setIsSaving(false);
    }
  };

  const handleChange = (name, value) => {
    setUserTouched(true);

    setFormData((prev) => ({
      ...prev,
      [name]: value,
    }));

    if (name !== "drawType" && name !== "remark") {
      setErrors((prev) => ({
        ...prev,
        [name]: validate(name, value) || "",
      }));
    }
  };


  return (
    <div className="flex flex-col h-full min-h-0">
      <div className={`flex flex-col h-full min-h-0 overflow-hidden ${CARD_GRID_SHELL_CLASS}`}>
        <div className="px-4 md:px-6 py-4 border-b border-brand-surface-border dark:border-zinc-700 shrink-0 bg-white dark:bg-zinc-900">
          <h2 className={PAGE_TITLE_CLASS}>Credit Entry</h2>
          <p className="text-sm text-brand-search-muted dark:text-gray-400 mt-0.5">
            Record and manage all credit transactions and payments
          </p>
        </div>

        <div className={`flex-1 overflow-y-auto p-3 md:p-4 space-y-4 ${FORM_SCROLL_AREA_CLASS}`}>
          <FormSection title="Party Information" icon={Users} variantIndex={0}>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">

              {/* Customer */}
              <GenericAutocomplete
                options={customerOptions}
                value={customerOptions.find(c => c.id === formData.customerId) || null}
                label="Customer"
                required={true}
                error={!!errors.customerName}
                helperText={errors.customerName || "Search/select customer"}
                onChange={(value) => {
                  if (!value) {
                    resetCustomer();
                    return;
                  }
                  handleChange("customerId", value.id);

                  setErrors(prev => ({ ...prev, customerName: "" }));
                }}
              />

              {/* Supplier */}
              <GenericAutocomplete
                options={supplierOptions}
                value={supplierOptions.find(s => s.id === formData.supplierId) || null}
                label="Supplier"
                required={true}
                error={!!errors.supplierName}
                helperText={errors.supplierName || "Search/select supplier"}
                onChange={(value) => {
                  if (!value) {
                    resetSupplier();
                    return;
                  }
                  handleChange("supplierId", value.id);

                  setErrors(prev => ({ ...prev, supplierName: "" }));
                }}
              />

            </div>
          </FormSection>

          <FormSection title="Transaction Details" icon={Receipt} variantIndex={1}>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              {/* Payment Mode */}
              <BasicSelect
                name="paymentType"
                value={formData.paymentType}
                onChange={(e) => handleChange(e.target.name, e.target.value)}
                label="Payment Mode*"
                options={[
                  { value: "NEFT_RTGS", label: "NEFT / RTGS" },
                  { value: "UPI", label: "UPI" },
                  { value: "CASH", label: "CASH" },
                  { value: "CHEQUE", label: "CHEQUE" },
                ]}
                error={!!errors.paymentType}
                helperText={errors.paymentType || ""}
              />

              {/* Bill Number */}
              <CustomTextField
                name="billNumber"
                value={formData.billNumber}
                onChange={handleBillNumberChange}
                label="Invoice Number"
                error={!!errors.billNumber}
                helperText={errors.billNumber || ""}
              />

              {/* Received Amount */}
              <CustomTextField
                name="receivedAmount"
                type="text"
                value={formData.receivedAmount}
                onChange={(e) => {
                  const val = e.target.value;

                  if (/^\d*\.?\d{0,2}$/.test(val)) {
                    handleChange("receivedAmount", val);
                  }
                }}
                onBlur={() => handleAmountBlur("receivedAmount")}
                label="Received Amount"
                error={!!errors.receivedAmount}
                helperText={errors.receivedAmount || ""}
                InputProps={{
                  className: "text-lg font-semibold"
                }}
              />

              {/* Reference Number (Cheque / UPI / NEFT) */}
              <CustomTextField
                name="referenceNumber"
                value={formData.referenceNumber}
                onChange={handleReferenceNumberChange}
                label="Reference Number*"
                error={!!errors.referenceNumber}
                helperText={errors.referenceNumber || "Cheque / UPI / NEFT reference"}
              />


              {/* Reference Date */}
              <CustomDatePicker
                label="Reference Date*"
                value={formData.referenceDate}
                error={errors.referenceDate}
                helperText={errors.referenceDate}
                onChange={(val) => handleChange("referenceDate", val)}
              />

              {/* Date */}
              <CustomDatePicker
                label="Transaction Date"
                value={formData.date}
                error={errors.date}
                helperText={errors.date}
                onChange={(val) => handleChange("date", val)}
              />
              {/* Slip Number (Optional) */}
              <CustomTextField
                name="slipNumber"
                value={formData.slipNumber}
                onChange={handleSlipNumberChange}
                label="Slip Number (Optional)"
                inputProps={{
                  maxLength: 30,
                }}
              />

            </div>
          </FormSection>

          <FormSection title="Additional Information" icon={FileText} variantIndex={2}>
            <p className="text-sm text-brand-search-muted dark:text-gray-400 -mt-2 mb-4">
              Optional details
            </p>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <BasicSelect
                name="drawType"
                value={formData.drawType}
                onChange={(e) => handleChange(e.target.name, e.target.value)}
                label="Draw Type"
                options={[
                  { value: "DRAW", label: "DRAW" },
                  { value: "CHEQUE", label: "CHEQUE" },
                ]}
              />

              <CustomTextField
                name="remark"
                value={formData.remark}
                onChange={(e) => handleChange(e.target.name, e.target.value)}
                label="Remarks"
                multiline
                minRows={0}
              />
            </div>
          </FormSection>
        </div>

        <FormFooter background="bg-white dark:bg-zinc-900 border-brand-surface-border dark:border-zinc-700">
          <AppButton type="secondary" onClick={handleReset}>
            Reset
          </AppButton>
          <AppButton type="primary" onClick={handleSubmit} loading={isSaving}>
            {isSaving ? "Saving..." : "Save"}
          </AppButton>
        </FormFooter>
      </div>
    </div>
  );
}
