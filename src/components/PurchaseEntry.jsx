import { LocalizationProvider } from "@mui/x-date-pickers/LocalizationProvider";
import CustomTextField from "./CustomTextField";
import { AdapterDayjs } from "@mui/x-date-pickers/AdapterDayjs";
import { DatePicker } from "@mui/x-date-pickers/DatePicker";
import dayjs from "dayjs";
import { useSnackbar } from "../context/SnackbarContext";
import { useEffect, useState } from "react";
import Autocomplete from "@mui/material/Autocomplete";
import SupplierService from "../service/SupplierService";
import CustomerService from "../service/CustomerService";
import { searchStaffs } from "../service/StaffService";
import { addPurchaseEntry } from "../service/purchaseService";
import validate from "../validations/Validation";

const PurchaseEntry = () => {
  const { showSnackbar } = useSnackbar();

  const [allStaffs, setAllStaffs] = useState([]);
  const [allSuppliers, setAllSuppliers] = useState([]);
  const [allCustomers, setAllCustomers] = useState([]);

  const [staffLoading, setStaffLoading] = useState(true);
  const [supplierLoading, setSupplierLoading] = useState(true);
  const [customerLoading, setCustomerLoading] = useState(true);

  const [formData, setFormData] = useState({
    date: "",
    staffId: "",
    supplierId: "",
    customerId: "",
    staff: "",
    purchaseAmount: "",
  });

  const [errors, setErrors] = useState({});

  useEffect(() => {
    const fetchAllData = async () => {
      try {
        setStaffLoading(true);
        const staffs = await searchStaffs("");
        setAllStaffs(staffs || []);
        setStaffLoading(false);

        setSupplierLoading(true);
        const suppliers = await SupplierService.getAllSuppliers();
        setAllSuppliers(suppliers || []);
        setSupplierLoading(false);

        setCustomerLoading(true);
        const customers = await CustomerService.getAllCustomers();
        setAllCustomers(customers || []);
        setCustomerLoading(false);
      } catch (err) {
        console.error("Error loading data:", err);
        showSnackbar("Failed to load data", "error");
      } finally {
        setStaffLoading(false);
        setSupplierLoading(false);
        setCustomerLoading(false);
      }
    };

    fetchAllData();
  }, []);

  const handleStaffSelect = (event, value) => {
    if (value) {
      setFormData((prev) => ({
        ...prev,
        staffId: value.staffId,
        staff: value.staffName || "",
      }));
      setErrors((prev) => ({ ...prev, staff: "" }));
    } else {
      setFormData((prev) => ({
        ...prev,
        staffId: "",
        staff: "",
      }));
    }
  };

  const handleSupplierSelect = (event, value) => {
    if (value) {
      setFormData((prev) => ({
        ...prev,
        supplierId: value.id,
      }));
      setErrors((prev) => ({ ...prev, supplierName: "" }));
    } else {
      setFormData((prev) => ({
        ...prev,
        supplierId: "",
      }));
    }
  };

  const handleCustomerSelect = (event, value) => {
    if (value) {
      setFormData((prev) => ({
        ...prev,
        customerId: value.id,
      }));
      setErrors((prev) => ({ ...prev, customerName: "" }));
    } else {
      setFormData((prev) => ({
        ...prev,
        customerId: "",
      }));
    }
  };

  const handleDateChange = (name, newValue) => {
    const formatted = newValue ? dayjs(newValue).format("YYYY-MM-DD") : "";
    setFormData((prev) => ({ ...prev, [name]: formatted }));
    setErrors((prev) => ({ ...prev, [name]: validate(name, formatted) || "" }));
  };

  const handleAmountChange = (e) => {
    const { name, value } = e.target;
    if (/^\d*\.?\d*$/.test(value)) {
      setFormData((prev) => ({ ...prev, [name]: value }));
      setErrors((prev) => ({ ...prev, [name]: validate(name, value) || "" }));
    }
  };

  const handleAmountBlur = (name) => {
    const val = formData[name];
    const num = parseFloat(val);
    setFormData((prev) => ({
      ...prev,
      [name]: isNaN(num) || !val ? "" : num.toFixed(2),
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    const newErrors = {};

    Object.keys(formData).forEach((field) => {
      const error = validate(field, formData[field]);
      if (error) {
        if (field === "supplierId") newErrors.supplierName = error;
        else if (field === "customerId") newErrors.customerName = error;
        else newErrors[field] = error;
      }
    });

    setErrors(newErrors);

    if (Object.values(newErrors).some((err) => err)) {
      showSnackbar("Please fill required fields", "error");
      return;
    }

    try {
      const response = await addPurchaseEntry(formData);
      showSnackbar(response.message || "Purchase entry saved", "success");
      handleReset();
    } catch (error) {
      showSnackbar("Error saving purchase entry", "error");
      console.error(error);
    }
  };

  const handleReset = () => {
    setFormData({
      date: "",
      staffId: "",
      supplierId: "",
      customerId: "",
      staff: "",
      purchaseAmount: "",
    });
    setErrors({});
  };

 return (
  <div className="flex flex-col h-full overflow-y-auto">
    {/* Card */}
    <div className="bg-white w-full h-[91vh] flex flex-col">
      {/* Header */}
      <div className="px-8 py-5 border-b border-gray-200 shrink-0 bg-gradient-to-r from-gray-50 to-white">
        <h2 className="text-2xl font-bold text-gray-800">Purchase Entry</h2>
        <p className="text-sm text-gray-500 mt-1">Record purchase transactions and manage inventory</p>
      </div>

      <div className="flex-1 overflow-y-auto px-8 py-6 space-y-6">
        {/* Date & Staff Card */}
        <div className="border border-gray-200 p-6 rounded-xl shadow-sm bg-white hover:shadow-md transition-shadow duration-200">
          <div className="flex items-center mb-5">
            <div className="w-1 h-8 bg-blue-600 rounded-full mr-3"></div>
            <h3 className="text-lg font-semibold text-gray-800">Transaction Information</h3>
          </div>
          <div className="grid grid-cols-2 gap-6">
            <LocalizationProvider dateAdapter={AdapterDayjs}>
              <DatePicker
                label="Date"
                value={formData.date ? dayjs(formData.date) : null}
                onChange={(newValue) => handleDateChange("date", newValue)}
                slotProps={{
                  textField: {
                    size: "small",
                    fullWidth: true,
                    error: !!errors.date,
                    helperText: errors.date || "",
                    onClick: (e) => {
                      const iconButton = e.currentTarget.parentElement.querySelector(
                        "button[aria-label]"
                      );
                      iconButton?.click();
                    },
                  },
                }}
              />
            </LocalizationProvider>

            <Autocomplete
              options={allStaffs}
              getOptionLabel={(option) => option.staffName || ""}
              getOptionKey={(option) => option.staffId}
              value={allStaffs.find((s) => s.staffId === formData.staffId) || null}
              onChange={handleStaffSelect}
              loading={staffLoading}
              isOptionEqualToValue={(option, value) => option.staffId === value?.staffId}
              renderInput={(params) => (
                <CustomTextField
                  {...params}
                  label="Staff Name"
                  error={!!errors.staff}
                  helperText={errors.staff || ""}
                  InputProps={{
                    ...params.InputProps,
                    endAdornment: (
                      <>
                        {staffLoading ? <span className="text-xs text-gray-500">Loading...</span> : null}
                        {params.InputProps.endAdornment}
                      </>
                    ),
                  }}
                />
              )}
            />
          </div>
        </div>

        {/* Party Information Card */}
        <div className="border border-gray-200 p-6 rounded-xl shadow-sm bg-white hover:shadow-md transition-shadow duration-200">
          <div className="flex items-center mb-5">
            <div className="w-1 h-8 bg-green-600 rounded-full mr-3"></div>
            <h3 className="text-lg font-semibold text-gray-800">Party Information</h3>
          </div>
          <div className="grid grid-cols-2 gap-6">
            <Autocomplete
              options={allSuppliers}
              getOptionLabel={(option) => option.supplierName || ""}
              getOptionKey={(option) => option.id}
              value={allSuppliers.find((s) => s.id === formData.supplierId) || null}
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
                        {supplierLoading ? <span className="text-xs text-gray-500">Loading...</span> : null}
                        {params.InputProps.endAdornment}
                      </>
                    ),
                  }}
                />
              )}
            />

            <Autocomplete
              options={allCustomers}
              getOptionLabel={(option) => option.customerName || ""}
              getOptionKey={(option) => option.id}
              value={allCustomers.find((c) => c.id === formData.customerId) || null}
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
                        {customerLoading ? <span className="text-xs text-gray-500">Loading...</span> : null}
                        {params.InputProps.endAdornment}
                      </>
                    ),
                  }}
                />
              )}
            />
          </div>
        </div>

        {/* Purchase Amount Card */}
        <div className="border border-gray-200 p-6 rounded-xl shadow-sm bg-white hover:shadow-md transition-shadow duration-200">
          <div className="flex items-center mb-5">
            <div className="w-1 h-8 bg-purple-600 rounded-full mr-3"></div>
            <h3 className="text-lg font-semibold text-gray-800">Purchase Details</h3>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <CustomTextField
              name="purchaseAmount"
              label="Purchase Amount"
              value={formData.purchaseAmount}
              onChange={handleAmountChange}
              onBlur={() => handleAmountBlur("purchaseAmount")}
              error={!!errors.purchaseAmount}
              helperText={errors.purchaseAmount || ""}
              className="w-full"
            />
            
            {/* Optional: Add more fields here if needed in future */}
            <div></div>
          </div>
        </div>

        {/* Optional: Remarks or Additional Information Card */}
        {formData.remarks && (
          <div className="border border-gray-200 p-6 rounded-xl shadow-sm bg-white hover:shadow-md transition-shadow duration-200">
            <div className="flex items-center mb-5">
              <div className="w-1 h-8 bg-orange-600 rounded-full mr-3"></div>
              <h3 className="text-lg font-semibold text-gray-800">Additional Information</h3>
            </div>
            <CustomTextField
              name="remarks"
              label="Remarks"
              value={formData.remarks}
              onChange={handleChange}
              multiline
              rows={3}
              className="w-full"
              InputProps={{
                style: { height: '100%', overflowY: 'auto' }
              }}
            />
          </div>
        )}
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
          Save Purchase Entry
        </button>
      </div>
    </div>
  </div>
);
};

export default PurchaseEntry;