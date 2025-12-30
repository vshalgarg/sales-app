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

  const [allSuppliers, setAllSuppliers] = useState([]);
  const [allCustomers, setAllCustomers] = useState([]);
  const [supplierLoading, setSupplierLoading] = useState(true);
  const [customerLoading, setCustomerLoading] = useState(true);


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


  const handleSupplierSelect = (event, value) => {
    if (value) {
      setFormData(prev => ({
        ...prev,
        supplierId: value.id,
        supplierName: value.supplierName,
      }));
      setErrors(prev => ({ ...prev, supplierName: "" }));
    } else {
      setFormData(prev => ({
        ...prev,
        supplierId: "",
        supplierName: "",
      }));
    }
  };

  const handleCustomerSelect = (event, value) => {
    if (value) {
      setFormData(prev => ({
        ...prev,
        customerId: value.id,
        customerName: value.customerName,
      }));
      setErrors(prev => ({ ...prev, customerName: "" }));
    } else {
      setFormData(prev => ({
        ...prev,
        customerId: "",
        customerName: "",
      }));
    }
  };

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
      {/* Card */}
      <div className="bg-white w-full h-[91vh] flex flex-col">
        {/* Header */}
        <div className="px-8 py-5 border-b border-gray-200 shrink-0 bg-gradient-to-r from-gray-50 to-white">
          <h2 className="text-2xl font-bold text-gray-800">Credit Entry</h2>
          <p className="text-sm text-gray-500 mt-1">Record all credit transactions and payments</p>
        </div>

        <div className="flex-1 overflow-y-auto px-8 py-6 space-y-6">

          {/* Party Information Card */}
          <div className="border border-gray-200 p-6 rounded-xl shadow-sm bg-white hover:shadow-md transition-shadow duration-200">
            <div className="flex items-center mb-5">
              <div className="w-1 h-8 bg-green-600 rounded-full mr-3"></div>
              <h3 className="text-lg font-semibold text-gray-800">Party Information</h3>
            </div>
            <div className="grid grid-cols-4 gap-5">
              {/* Supplier */}
              <div>
                <Autocomplete
                  options={allSuppliers}
                  getOptionLabel={(option) => option.supplierName || ""}
                  getOptionKey={(option) => option.id}
                  value={allSuppliers.find(s => s.id === formData.supplierId) || null}
                  onChange={handleSupplierSelect}
                  loading={supplierLoading}
                  isOptionEqualToValue={(option, value) => option.id === value?.id}
                  renderInput={(params) => (
                    <CustomTextField
                      {...params}
                      label="Supplier"
                      error={!!errors.supplierName}
                      helperText={errors.supplierName || ""}
                      InputProps={{
                        ...params.InputProps,
                        endAdornment: (
                          <>
                            {supplierLoading ? (
                              <span className="text-xs text-gray-500">Loading...</span>
                            ) : null}
                            {params.InputProps.endAdornment}
                          </>
                        ),
                      }}
                    />
                  )}
                />
              </div>

              {/* Supplier Current Balance */}
              <CustomTextField
                name="supplierCurrentBalance"
                value={formData.supplierCurrentBalance}
                onChange={handleAmountChange}
                onBlur={() => handleAmountBlur("supplierCurrentBalance")}
                label="Supplier Current Balance"
                className="w-full"
                error={!!errors.supplierCurrentBalance}
                helperText={errors.supplierCurrentBalance || ""}
              />

              {/* Customer */}
              <div>
                <Autocomplete
                  options={allCustomers}
                  getOptionLabel={(option) => option.customerName || ""}
                  getOptionKey={(option) => option.id}
                  value={allCustomers.find(c => c.id === formData.customerId) || null}
                  onChange={handleCustomerSelect}
                  loading={customerLoading}
                  isOptionEqualToValue={(option, value) => option.id === value?.id}
                  renderInput={(params) => (
                    <CustomTextField
                      {...params}
                      label="Customer"
                      error={!!errors.customerName}
                      helperText={errors.customerName || ""}
                      InputProps={{
                        ...params.InputProps,
                        endAdornment: (
                          <>
                            {customerLoading ? (
                              <span className="text-xs text-gray-500">Loading...</span>
                            ) : null}
                            {params.InputProps.endAdornment}
                          </>
                        ),
                      }}
                    />
                  )}
                />
              </div>

              {/* Customer Current Balance */}
              <CustomTextField
                name="customerCurrentBalance"
                value={formData.customerCurrentBalance}
                onChange={handleAmountChange}
                onBlur={() => handleAmountBlur("customerCurrentBalance")}
                label="Customer Current Balance"
                className="w-full"
                error={!!errors.customerCurrentBalance}
                helperText={errors.customerCurrentBalance || ""}
              />
            </div>
          </div>

          {/* Transaction Details Card */}
          <div className="border border-gray-200 p-6 rounded-xl shadow-sm bg-white hover:shadow-md transition-shadow duration-200">
            <div className="flex items-center mb-5">
              <div className="w-1 h-8 bg-blue-600 rounded-full mr-3"></div>
              <h3 className="text-lg font-semibold text-gray-800">Transaction Details</h3>
            </div>
            <div className="grid grid-cols-3 gap-5">
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
                className="w-full"
              />

              <CustomTextField
                name="billNumber"
                value={formData.billNumber}
                onChange={handleChange}
                label="Bill Number"
                className="w-full"
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

          {/* Cheque Details Card */}
          <div className="border border-gray-200 p-6 rounded-xl shadow-sm bg-white hover:shadow-md transition-shadow duration-200">
            <div className="flex items-center mb-5">
              <div className="w-1 h-8 bg-purple-600 rounded-full mr-3"></div>
              <h3 className="text-lg font-semibold text-gray-800">Payment Details</h3>
            </div>
            <div className="grid grid-cols-4 gap-5">
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
                className="w-full"
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
                className="w-full"
                error={!!errors.receivedAmount}
                helperText={errors.receivedAmount || ""}
              />

              <CustomTextField
                name="slipNumber"
                label="Slip Number"
                value={formData.slipNumber}
                onChange={handleChange}
                className="w-full"
                error={!!errors.slipNumber}
                helperText={errors.slipNumber || ""}
              />
            </div>
          </div>

          {/* Miscellaneous Card */}
          <div className="border border-gray-200 p-6 rounded-xl shadow-sm bg-white hover:shadow-md transition-shadow duration-200">
            <div className="flex items-center mb-5">
              <div className="w-1 h-8 bg-orange-600 rounded-full mr-3"></div>
              <h3 className="text-lg font-semibold text-gray-800">Additional Information</h3>
            </div>
            <div className="grid grid-cols-2 gap-6">
              <BasicSelect
                name="drawType"
                value={formData.drawType}
                onChange={handleChange}
                label="Draw / Cheque"
                options={[
                  { value: "DRAW", label: "DRAW" },
                  { value: "CHEQUE", label: "CHEQUE" },
                ]}
                className="w-full"
              />

              <CustomTextField
                name="remark"
                value={formData.remark}
                onChange={handleChange}
                label="Remarks"
                className="w-full"
                multiline
                InputProps={{
                  style: { height: '100%', overflowY: 'auto' }
                }}
              />
            </div>
          </div>
        </div>

        {/* Footer */}
        <div className="px-8 py-5 border-t border-gray-200 flex justify-end space-x-4 shrink-0 bg-gray-50">
          <button
            onClick={handleReset}
            type="button"
            className="px-6 py-3 bg-white text-gray-700 rounded-lg border border-gray-300 hover:bg-gray-50 hover:border-gray-400 transition-all duration-200 font-medium shadow-sm hover:shadow-md"
          >
            Reset Form
          </button>
          <button
            onClick={handleSubmit}
            type="button"
            className="px-6 py-3 bg-gradient-to-r from-blue-600 to-blue-700 text-white font-medium rounded-lg hover:from-blue-700 hover:to-blue-800 shadow-lg transition-all duration-200 transform hover:scale-[1.02]"
          >
            Save Credit Entry
          </button>
        </div>
      </div>
    </div>
  );
}
