import CustomTextField from "./CustomTextField";
import { LocalizationProvider } from "@mui/x-date-pickers/LocalizationProvider";
import { DatePicker } from "@mui/x-date-pickers/DatePicker";
import { AdapterDayjs } from "@mui/x-date-pickers/AdapterDayjs";
import dayjs from "dayjs";
import { useState, useEffect } from "react";
import BasicSelect from "./BasicSelect";
import { useBillForm } from "../customHooks/useBillForm";
import { useSnackbar } from "../context/SnackbarContext";
import { addCreditEntry } from "../service/CreditService";
import validate from "../validations/Validation";
import Autocomplete from "@mui/material/Autocomplete";
import SupplierService from "../service/SupplierService";
import CustomerService from "../service/CustomerService";

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
    date: dayjs().format("DD-MM-YYYY"),
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
  const [supplierLoading, setSupplierLoading] = useState(true);
  const [customerLoading, setCustomerLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);
  const [selectedSupplier, setSelectedSupplier] = useState(null);
  const [selectedCustomer, setSelectedCustomer] = useState(null);



  useEffect(() => {
    const fetchData = async () => {
      try {
        setSupplierLoading(true);
        const suppliers = await SupplierService.getAllSuppliers();
        setAllSuppliers(suppliers || []);
        setSupplierLoading(false);

        setCustomerLoading(true);
        const customers = await CustomerService.getAllCustomers();
        setAllCustomers(customers || []);
        setCustomerLoading(false);
      } catch (err) {
        console.error(err);
        showSnackbar("Error loading suppliers/customers", "error");
        setSupplierLoading(false);
        setCustomerLoading(false);
      }
    };

    fetchData();
  }, []);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
    if (name !== "drawType" && name !== "remark") {
      setErrors((prev) => ({ ...prev, [name]: validate(name, value) || "" }));
    }
  };

  const handleSlipNumberChange = (e) => {
    const { value } = e.target;

    // allow only alphanumeric
    if (/^[a-zA-Z0-9/-]*$/.test(value)) {
      setFormData((prev) => ({
        ...prev,
        slipNumber: value,
      }));

      setErrors((prev) => ({
        ...prev,
        slipNumber: "",
      }));
    }
  };


  const handleReset = () => {
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
    setSelectedSupplier(null);
    setFormData(prev => ({
      ...prev,
      supplierId: "",
    }));
  };

  const resetCustomer = () => {
    setSelectedCustomer(null);
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

  const handleDateChange = (name, newValue) => {
    const formatted = newValue
      ? dayjs(newValue).format("DD-MM-YYYY")
      : "";

    setFormData(prev => ({ ...prev, [name]: formatted }));
    setErrors(prev => ({ ...prev, [name]: validate(name, formatted) || "" }));
  };


  const handleAmountChange = (e) => {
    const { name, value } = e.target;

    //allow only numbers + decimal with max 2 digits
    if (/^\d*\.?\d{0,2}$/.test(value)) {
      setFormData((prev) => ({
        ...prev,
        [name]: value,
      }));

      setErrors((prev) => ({
        ...prev,
        [name]: validate(name, value) || "",
      }));
    }
  };

  const handleAmountBlur = (name) => {
    setFormData((prev) => ({
      ...prev,
      [name]: formatAmount(prev[name]),
    }));
  };

  const handleBillNumberChange = (e) => {
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


  const handleReferenceNumberChange = (e) => {
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
        date: formData.date
          ? dayjs(formData.date, "DD-MM-YYYY").format("YYYY-MM-DD")
          : null,

        referenceDate: formData.referenceDate
          ? dayjs(formData.referenceDate, "DD-MM-YYYY").format("YYYY-MM-DD")
          : null,
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




  return (
    <div className="flex flex-col h-full overflow-y-auto">
      {/* Card */}
      <div className="bg-gray-50 w-full h-[91vh] flex flex-col rounded-2xl shadow-xl border border-gray-200">
        {/* Header */}
        <div className="
  px-4 sm:px-6 py-3 
  border-b border-gray-200 
  shrink-0 
  bg-gradient-to-r from-gray-50 to-white
  sticky top-0 z-20
">
          <h2 className="text-xl sm:text-2xl font-semibold text-gray-800">
            Credit Entry
          </h2>
          <p className="text-sm sm:text-sm text-gray-500 mt-1">
            Record and manage all credit transactions and payments
          </p>
        </div>

        <div className="flex-1 overflow-y-auto p-3 sm:px-8 sm:py-6 space-y-6">

          {/* Party Information Card */}
          <div className="border border-gray-200 p-4 sm:p-6 rounded-xl bg-white shadow-sm hover:shadow-md transition-shadow duration-200">
            <div className="flex items-start mb-5">
              <div className="w-1 h-8 bg-gradient-to-b from-green-500 to-green-700 rounded-full mr-3"></div>
              <div>
                <h3 className="text-lg font-semibold text-gray-800">
                  Party Information
                </h3>
              </div>
            </div>


            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">

              {/* Customer */}
              <Autocomplete
                options={allCustomers}
                value={selectedCustomer}
                isOptionEqualToValue={(o, v) => o.id === v?.id}
                getOptionLabel={(o) =>
                  o?.customerName ? `${o.customerName} - ${o.city || ""}` : ""
                }
                loading={customerLoading}
                onChange={(e, value) => {
                  if (!value) {
                    resetCustomer();
                    return;
                  }

                  setSelectedCustomer(value);
                  setFormData(prev => ({
                    ...prev,
                    customerId: value.id,
                  }));

                  setErrors(prev => ({ ...prev, customerName: "" }));
                }}
                renderInput={(params) => (
                  <CustomTextField
                    {...params}
                    label="Customer *"
                    error={!!errors.customerName}
                    helperText={errors.customerName || "Search/select customer"}
                  />
                )}
              />

               {/* Supplier */}
              <Autocomplete
                options={allSuppliers}
                value={selectedSupplier}
                isOptionEqualToValue={(o, v) => o.id === v?.id}
                getOptionLabel={(o) =>
                  o?.supplierName ? `${o.supplierName} - ${o.city || ""}` : ""
                }
                loading={supplierLoading}
                onChange={(e, value) => {
                  if (!value) {
                    resetSupplier();
                    return;
                  }

                  setSelectedSupplier(value);
                  setFormData(prev => ({
                    ...prev,
                    supplierId: value.id,
                  }));

                  setErrors(prev => ({ ...prev, supplierName: "" }));
                }}
                renderInput={(params) => (
                  <CustomTextField
                    {...params}
                    label="Supplier *"
                    error={!!errors.supplierName}
                    helperText={errors.supplierName || "Search/select supplier"}
                  />
                )}
              />


            </div>
          </div>


          {/* Transaction Details Card */}
          <div className="border border-gray-200 p-4 rounded-xl bg-white shadow-sm">
            <div className="flex items-start mb-5">
              <div className="w-1 h-8 bg-gradient-to-b from-blue-500 to-blue-700 rounded-full mr-3"></div>

              <div>
                <h3 className="text-lg font-semibold text-gray-800">
                  Transaction Details
                </h3>
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              {/* Payment Mode */}
              <BasicSelect
                name="paymentType"
                value={formData.paymentType}
                onChange={handleChange}
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
                label="Bill Number"
                error={!!errors.billNumber}
                helperText={errors.billNumber || ""}
              />

              {/* Received Amount */}
              <CustomTextField
                name="receivedAmount"
                type="text"
                value={formData.receivedAmount}
                onChange={handleAmountChange}
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
              <LocalizationProvider dateAdapter={AdapterDayjs}>
                <DatePicker
                  label="Reference Date*"
                  format="DD-MM-YYYY"
                  value={
                    formData.referenceDate
                      ? dayjs(formData.referenceDate, "DD-MM-YYYY")
                      : null
                  }
                  onChange={(newValue) =>
                    handleDateChange("referenceDate", newValue)
                  }
                  slotProps={{
                    textField: {
                      fullWidth: true,
                      size: "small",
                      error: !!errors.referenceDate,
                      helperText: errors.referenceDate || "",
                    },
                  }}
                />
              </LocalizationProvider>

              {/* Date */}
              <LocalizationProvider dateAdapter={AdapterDayjs}>
                <DatePicker
                  label="Transaction Date"
                  format="DD-MM-YYYY"
                  value={
                    formData.date
                      ? dayjs(formData.date, "DD-MM-YYYY")
                      : null
                  }
                  onChange={(newValue) => handleDateChange("date", newValue)}
                  slotProps={{
                    textField: {
                      fullWidth: true,
                      size: "small",
                      error: !!errors.date,
                      helperText: errors.date || "",
                    },
                  }}
                />
              </LocalizationProvider>
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
          </div>

          {/* Additional Information */}
          <div className="border border-gray-200 p-6 rounded-xl bg-white">
            <div className="flex items-start mb-5">
              <div className="w-1 h-10 bg-gradient-to-b from-orange-500 to-orange-700 rounded-full mr-3"></div>
              <div>
                <h3 className="text-lg font-semibold text-gray-800">
                  Additional Information
                </h3>
                <p className="text-sm text-gray-500">
                  Optional details
                </p>
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <BasicSelect
                name="drawType"
                value={formData.drawType}
                onChange={handleChange}
                label="Draw Type"
                options={[
                  { value: "DRAW", label: "DRAW" },
                  { value: "CHEQUE", label: "CHEQUE" },
                ]}
              />

              <CustomTextField
                name="remark"
                value={formData.remark}
                onChange={handleChange}
                label="Remarks"
                multiline
                minRows={0}
              />
            </div>
          </div>

        </div>

        {/* Footer */}
        <div className="px-4 sm:px-8 py-3 border-t border-gray-200 bg-white shrink-0 shadow-sm">

          <div className="flex items-center justify-end gap-3">

            <button
              onClick={handleReset}
              type="button"
              className="px-4 py-2 text-sm font-medium text-gray-600 bg-gray-100 rounded-lg hover:bg-gray-200"
            >
              Reset
            </button>

            <button
              onClick={handleSubmit}
              type="button"
              className="px-5 py-2 text-sm font-semibold text-white rounded-lg bg-blue-600 hover:bg-blue-700 shadow-md"
            >
              {isSaving ? "Saving..." : "Save"}
            </button>

          </div>
        </div>

      </div>
    </div>
  );
}
