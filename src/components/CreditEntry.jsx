import CustomTextField from "./CustomTextField";
import { LocalizationProvider } from "@mui/x-date-pickers/LocalizationProvider";
import { DatePicker } from "@mui/x-date-pickers/DatePicker";
import { AdapterDayjs } from "@mui/x-date-pickers/AdapterDayjs";
import dayjs from "dayjs";
import { useState } from "react";
import BasicSelect from "./BasicSelect";
import { useBillForm } from "../customHooks/useBillForm";
import { useSnackbar } from "../context/SnackbarContext";
import { addCreditEntry } from "../service/CreditService";
import validate from "../validations/Validation";

export default function CreditEntryForm() {
  const { showSnackbar } = useSnackbar();
  const {
    searchSupplierRef,
    searchCustomerRef,
    isFilterObject,
    setIsFilterObject,
    errors,
    setErrors,
    suggestions,
    isDropdownOpen,
    setIsDropdownOpen,
    handleSupplierInput,
    searchRef,
    handleSupplierSuggestionClick,
    custSearchRef,
    custSuggestions,
    isCustDropdownOpen,
    setIsCustDropdownOpen,
    handleCustomerSuggestionClick,
    handleCustomerInput,
    filterObject,
    setFilterObject,
  } = useBillForm();

  const [formData, setFormData] = useState({
    paymentType: "",
    billNumber: "",
    date: dayjs().format("YYYY-MM-DD"),
    chequeNumber: "",
    chequeDate: "",
    receivedAmount: "",
    supplierId: "",
    customerId: "",
    supplierCurrentBalance: "",
    customerCurrentBalance: "",
    slipNumber: "",
    drawType: "",
    remark: "",
  });

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
    if (name !== "drawType" && name !== "remark") {
      setErrors((prev) => ({ ...prev, [name]: validate(name, value) || "" }));
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    console.log("Form submitted:", formData);

    const newErrors = {};
    Object.keys(formData).forEach((field) => {
      if (field !== "drawType" && field !== "remark") {
        const error = validate(field, formData[field]);
        if (error) {
          if (field === "supplierId") {
            newErrors.supplierName = error;
          } else if (field === "customerId") {
            newErrors.customerName = error;
          } else {
            newErrors[field] = error;
          }
        }
      }
    });

    setErrors(newErrors);

    if (Object.keys(newErrors).length > 0) {
      showSnackbar("Please fill required fields in the form.", "error");
      return;
    }

    try {
      const response = await addCreditEntry(formData);
      if (
        response &&
        typeof response === "object" &&
        "code" in response &&
        "message" in response &&
        "timestamp" in response
      ) {
        showSnackbar(response.message, "error");
        return;
      }
      showSnackbar(response.message, "success");
      handleReset();
      setFilterObject({});
    } catch (error) {
      showSnackbar("Error while saving bill entry", "error");
      console.error("Error while saving bill entry:", error);
    }
  };

  const handleReset = () => {
    setFormData({
      paymentType: "",
      billNumber: "",
      chequeNumber: "",
      date: dayjs().format("YYYY-MM-DD"),
      chequeDate: "",
      receivedAmount: "",
      supplierId: "",
      customerId: "",
      supplierCurrentBalance: "",
      customerCurrentBalance: "",
      slipNumber: "",
      drawType: "",
      remark: "",
    });
    setErrors({});
    setIsFilterObject(false);
    setFilterObject({});
  };

  const handleSupplierChange = (e) => {
    handleSupplierInput(e);
    setIsFilterObject(true);

    const inputValue = e.target.value.trim();

    if (inputValue === "") {
      setFormData((prev) => ({ ...prev, supplierId: "" }));
      setErrors((prev) => ({
        ...prev,
        supplierName: validate("supplier", "") || "",
      }));
    } else {
      setErrors((prev) => ({
        ...prev,
        supplierName: "",
      }));
    }
  };

  const handleCustomerChange = (e) => {
    handleCustomerInput(e);
    setIsFilterObject(true);

    const inputValue = e.target.value.trim();

    if (inputValue === "") {
      setFormData((prev) => ({ ...prev, customerId: "" }));
      setErrors((prev) => ({
        ...prev,
        customerName: validate("customer", "") || "",
      }));
    } else {
      setErrors((prev) => ({
        ...prev,
        customerName: "",
      }));
    }
  };

  const formatAmount = (val) => {
    if (val === "" || isNaN(val)) return "0.00";
    const num = parseFloat(val);
    return Number.isInteger(num) ? num.toFixed(2) : String(num);
  };

  const handleDateChange = (name, newValue) => {
    const formatted = newValue ? dayjs(newValue).format("YYYY-MM-DD") : "";
    setFormData((prev) => ({ ...prev, [name]: formatted }));
    setErrors((prev) => ({ ...prev, [name]: validate(name, formatted) || "" }));
  };

  const handleAmountChange = (e) => {
    const { name, value } = e.target;
    if (/^\d*\.?\d*$/.test(value)) {
      setFormData((prev) => ({
        ...prev,
        [name]: value,
      }));
      setErrors((prev) => ({ ...prev, [name]: validate(name, value) || "" }));
    }
  };

  const handleAmountBlur = (name) => {
    setFormData((prev) => ({
      ...prev,
      [name]: formatAmount(prev[name]),
    }));
  };

  return (
    <div className="flex flex-col h-full overflow-y-auto">
      <div className="bg-white w-full h-[91vh] flex flex-col">
        <div className="px-6 py-4 border-b border-gray-300 shrink-0">
          <h2 className="text-2xl font-semibold">Credit Entry</h2>
        </div>

        <div className="flex-1 overflow-y-auto px-6 py-4 space-y-4">
          {/* Transaction Details */}
          <div className="border p-4 rounded border-gray-300">
            <h3 className="text-lg font-semibold mb-3 border-b border-gray-300 pb-2">
              Transaction Details
            </h3>
            <div className="grid grid-cols-3 gap-4">
              <BasicSelect
                name="paymentType"
                value={formData.paymentType}
                onChange={handleChange}
                label="Select Payment Type"
                options={[
                  { value: "CASH", label: "CASH" },
                  { value: "CHEQUE", label: "CHEQUE" },
                  { value: "UPI", label: "UPI" },
                ]}
                error={!!errors.paymentType}
                helperText={errors.paymentType || ""}
              />

              <CustomTextField
                name="billNumber"
                value={formData.billNumber}
                onChange={handleChange}
                label="Bill Number"
                error={!!errors.billNumber}
                helperText={errors.billNumber || ""}
              />

              <LocalizationProvider dateAdapter={AdapterDayjs}>
                <DatePicker
                  label="Date"
                  value={formData.date ? dayjs(formData.date) : null}
                  onChange={(newValue) => handleDateChange("date", newValue)}
                  slotProps={{
                    textField: {
                      fullWidth: true,
                      size: "small",
                      error: !!errors.date,
                      helperText: errors.date || "",
                      onClick: (e) => {
                        const iconButton =
                          e.currentTarget.parentElement.querySelector(
                            "button[aria-label]"
                          );
                        iconButton?.click();
                      },
                    },
                  }}
                />
              </LocalizationProvider>
            </div>
          </div>

          {/* Party Information */}
          <div className="border p-4 rounded border-gray-300">
            <h3 className="text-lg font-semibold mb-3 border-b border-gray-300 pb-2">
              Party Information
            </h3>

            <div className="grid grid-cols-4 gap-4">
              <div ref={searchSupplierRef} className="relative w-full">
                <CustomTextField
                  name="supplierName"
                  value={filterObject.supplierName ?? ""}
                  onChange={handleSupplierChange}
                  onFocus={() => {
                    if (
                      (filterObject?.supplierName?.length ?? 0) > 1 &&
                      suggestions.length > 0
                    ) {
                      setIsDropdownOpen(true);
                    }
                  }}
                  label="Supplier"
                  error={!!errors.supplierName}
                  helperText={errors.supplierName || ""}
                />
                {isDropdownOpen && suggestions.length > 0 && (
                  <ul className="absolute mt-1 bg-white border rounded shadow-lg z-50 max-h-60 overflow-y-auto text-sm w-full">
                    {suggestions.map((s, idx) => (
                      <li
                        key={idx}
                        className="p-2 hover:bg-gray-100 cursor-pointer"
                        onClick={() => {
                          handleSupplierSuggestionClick(s);
                          setIsFilterObject(true);
                          setFormData((prev) => ({
                            ...prev,
                            supplierId: s.id,
                          }));
                          setErrors((prev) => ({
                            ...prev,
                            supplierName: "",
                          }));
                        }}
                      >
                        {s.supplierName}
                      </li>
                    ))}
                  </ul>
                )}
              </div>

              <CustomTextField
                name="supplierCurrentBalance"
                value={formData.supplierCurrentBalance}
                onChange={handleAmountChange}
                onBlur={() => handleAmountBlur("supplierCurrentBalance")}
                label="Supplier Current Balance"
                error={!!errors.supplierCurrentBalance}
                helperText={errors.supplierCurrentBalance || ""}
              />

              <div ref={searchCustomerRef} className="relative w-full">
                <CustomTextField
                  name="customerName"
                  value={filterObject.customerName ?? ""}
                  onChange={handleCustomerChange}
                  onFocus={() => {
                    if (
                      (filterObject.customerName?.length ?? 0) > 1 &&
                      custSuggestions.length > 0
                    ) {
                      setIsCustDropdownOpen(true);
                    }
                  }}
                  label="Customer"
                  error={!!errors.customerName}
                  helperText={errors.customerName || ""}
                />
                {isCustDropdownOpen && custSuggestions.length > 0 && (
                  <ul className="absolute mt-1 bg-white border rounded shadow-lg z-50 max-h-60 overflow-y-auto text-sm w-full">
                    {custSuggestions.map((c, idx) => (
                      <li
                        key={idx}
                        className="p-2 hover:bg-gray-100 cursor-pointer"
                        onClick={() => {
                          handleCustomerSuggestionClick(c);
                          setIsFilterObject(true);
                          setFormData((prev) => ({
                            ...prev,
                            customerId: c.id,
                          }));
                          setErrors((prev) => ({
                            ...prev,
                            customerName: "",
                          }));
                        }}
                      >
                        {c.customerName}
                      </li>
                    ))}
                  </ul>
                )}
              </div>

              <CustomTextField
                name="customerCurrentBalance"
                value={formData.customerCurrentBalance}
                onChange={handleAmountChange}
                onBlur={() => handleAmountBlur("customerCurrentBalance")}
                label="Customer Current Balance"
                error={!!errors.customerCurrentBalance}
                helperText={errors.customerCurrentBalance || ""}
              />
            </div>
          </div>

          {/* Cheque Details */}
          <div className="border p-4 rounded border-gray-300">
            <h3 className="text-lg font-semibold mb-3 border-b border-gray-300 pb-2">
              Cheque Details
            </h3>

            <div className="grid grid-cols-4 gap-4">
              <LocalizationProvider dateAdapter={AdapterDayjs}>
                <DatePicker
                  label="Cheque Date"
                  value={
                    formData.chequeDate ? dayjs(formData.chequeDate) : null
                  }
                  onChange={(newValue) =>
                    handleDateChange("chequeDate", newValue)
                  }
                  slotProps={{
                    textField: {
                      fullWidth: true,
                      size: "small",
                      error: !!errors.chequeDate,
                      helperText: errors.chequeDate || "",
                      onClick: (e) => {
                        const iconButton =
                          e.currentTarget.parentElement.querySelector(
                            "button[aria-label]"
                          );
                        iconButton?.click();
                      },
                    },
                  }}
                />
              </LocalizationProvider>

              <CustomTextField
                name="chequeNumber"
                value={formData.chequeNumber}
                onChange={handleChange}
                label="Cheque Number"
                error={!!errors.chequeNumber}
                helperText={errors.chequeNumber || ""}
              />

              <CustomTextField
                name="receivedAmount"
                type="text"
                value={formData.receivedAmount}
                onChange={handleAmountChange}
                onBlur={() => handleAmountBlur("receivedAmount")}
                label="Received Amount"
                error={!!errors.receivedAmount}
                helperText={errors.receivedAmount || ""}
              />

              <CustomTextField
                name="slipNumber"
                label="Slip Number"
                value={formData.slipNumber}
                onChange={handleChange}
                error={!!errors.slipNumber}
                helperText={errors.slipNumber || ""}
              />
            </div>
          </div>

          {/* Miscellaneous */}
          <div className="border p-4 rounded border-gray-300">
            <h3 className="text-lg font-semibold mb-3 border-b border-gray-300 pb-2">
              Miscellaneous
            </h3>
            <div className="grid grid-cols-2 gap-4">
              <BasicSelect
                name="drawType"
                value={formData.drawType}
                onChange={handleChange}
                label="Draw / Cheque"
                options={[
                  { value: "DRAW", label: "DRAW" },
                  { value: "CHEQUE", label: "CHEQUE" },
                ]}
              />

              <CustomTextField
                name="remark"
                value={formData.remark}
                onChange={handleChange}
                label="Remark"
              />
            </div>
          </div>
        </div>

        <div className="px-6 py-4 border-t border-gray-300 flex justify-end space-x-4 shrink-0">
          <button
            onClick={handleReset}
            type="button"
            className="px-4 py-2 bg-gray-200 rounded hover:bg-gray-400"
          >
            Reset
          </button>
          <button
            onClick={handleSubmit}
            type="button"
            className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-800"
          >
            Save Credit Entry
          </button>
        </div>
      </div>
    </div>
  );
}
