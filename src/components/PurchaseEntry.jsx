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
import { getAllActiveStaffs } from "../service/StaffService";
import { addPurchaseEntry } from "../service/PurchaseService";
import validate from "../validations/Validation";
import ImageUploader from "./common/ImageUploader";

const PurchaseEntry = () => {
  const { showSnackbar } = useSnackbar();

  const [allStaffs, setAllStaffs] = useState([]);
  const [allSuppliers, setAllSuppliers] = useState([]);
  const [allCustomers, setAllCustomers] = useState([]);

  const [staffLoading, setStaffLoading] = useState(true);
  const [supplierLoading, setSupplierLoading] = useState(true);
  const [customerLoading, setCustomerLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);
  const [selectedSuppliers, setSelectedSuppliers] = useState([]);
  const [selectedCustomer, setSelectedCustomer] = useState(null);
  const [purchaseImages, setPurchaseImages] = useState([]);



  const [formData, setFormData] = useState({
    date: dayjs().format("YYYY-MM-DD"),
    staffId: "",
    supplierIds: [],
    customerId: "",
    staff: "",
    purchaseAmount: "",
  });

  const [errors, setErrors] = useState({});

  useEffect(() => {
    const fetchAllData = async () => {
      try {
        setStaffLoading(true);
        const staffs = await getAllActiveStaffs();
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

  const handleAmountChange = (e) => {
    const { name, value } = e.target;
    if (/^\d*\.?\d{0,2}$/.test(value)) {
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

    if (isSaving) return;

    const dateError = validate("date", formData.date);
    if (dateError) {
      setErrors({ date: dateError });
      showSnackbar(dateError, "error");
      return;
    }

    if (!formData.supplierIds || formData.supplierIds.length === 0) {
      showSnackbar("Please select at least one Supplier", "error");
      return;
    }

    if (!formData.customerId) {
      showSnackbar("Please select a Customer", "error");
      return;
    }

    setIsSaving(true);

    try {
      const formDataObj = new FormData();

      formDataObj.append(
        "payload",
        new Blob([JSON.stringify(formData)], {
          type: "application/json",
        })
      );
      purchaseImages.forEach((file) => {
        formDataObj.append("images", file);
      });

      const response = await addPurchaseEntry(formDataObj);
      showSnackbar(response.message || "Purchase entry saved", "success");
      handleReset();
    } catch (error) {
      showSnackbar(error.message, "error");
      console.error(error);
    }
    finally {
      setIsSaving(false);
    }
  };

  const handleReset = () => {
    resetSupplier();
    resetCustomer();
    setFormData({
      date: dayjs().format("YYYY-MM-DD"),
      staffId: "",
      supplierId: "",
      customerIds: [],
      staff: "",
      purchaseAmount: "",
    });
    setPurchaseImages([]);
    setErrors({});
  };

  const resetSupplier = () => {
    setSelectedSuppliers([]);
    setFormData(prev => ({
      ...prev,
      supplierIds: [],
    }));
  };

  const resetCustomer = () => {
    setSelectedCustomer(null);
    setFormData(prev => ({
      ...prev,
      customerId: "",
    }));
  };

  return (
    <div className="flex flex-col h-full overflow-y-auto">
      <div className="bg-gray-50 w-full h-[91vh] flex flex-col">

        {/* Header */}
        <div className="px-6 py-3 border-b border-gray-200 shrink-0 bg-gray-50">
          <div className="flex items-center justify-between">
            <div>
              <h2 className="text-2xl font-semibold text-gray-900 leading-tight">
                Purchase Entry
              </h2>
              <p className="text-sm text-gray-500 mt-1">
                Record purchase transactions and manage inventory
              </p>
            </div>
          </div>
        </div>

        {/* Body */}
        <div className="flex-1 overflow-y-auto px-8 py-6 space-y-6">

          {/* Party Information */}
          <div className="border border-gray-200 p-6 rounded-xl bg-white">
            <div className="flex items-start mb-5">
              <div className="w-1 h-10 bg-gradient-to-b from-green-500 to-green-700 rounded-full mr-3"></div>
              <div>
                <h3 className="text-lg font-semibold text-gray-800">
                  Party Information
                </h3>
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">

              <Autocomplete
                options={allCustomers}
                value={selectedCustomer}
                loading={customerLoading}
                isOptionEqualToValue={(o, v) => o.id === v?.id}
                getOptionLabel={(o) =>
                  o?.customerName ? `${o.customerName} - ${o.city || ""}` : ""
                }
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
                }}
                renderInput={(params) => (
                  <CustomTextField
                    {...params}
                    label="Customer *"
                  />
                )}
              />

              <Autocomplete
                multiple
                options={allSuppliers}
                value={selectedSuppliers}
                loading={supplierLoading}
                isOptionEqualToValue={(o, v) => o.id === v.id}
                getOptionLabel={(o) =>
                  o?.supplierName ? `${o.supplierName} - ${o.city || ""}` : ""
                }
                onChange={(e, values) => {
                  setSelectedSuppliers(values);
                  setFormData(prev => ({
                    ...prev,
                    supplierIds: values.map(v => v.id),
                  }));
                }}
                renderInput={(params) => (
                  <CustomTextField
                    {...params}
                    label="Suppliers *"
                  />
                )}
              />
            </div>
          </div>

          {/* Transaction Details */}
          <div className="border border-gray-200 p-6 rounded-xl bg-white shadow-sm">
            <div className="flex items-start mb-5">
              <div className="w-1 h-10 bg-gradient-to-b from-blue-500 to-blue-700 rounded-full mr-3"></div>
              <div>
                <h3 className="text-lg font-semibold text-gray-800">
                  Transaction Details
                </h3>
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <LocalizationProvider dateAdapter={AdapterDayjs}>
                <DatePicker
                  label="Transaction Date *"
                  format="DD-MM-YYYY"
                  value={
                    formData.date
                      ? dayjs(formData.date, "YYYY-MM-DD")
                      : null
                  }
                  onChange={(newValue) => {
                    const formatted = newValue
                      ? dayjs(newValue).format("YYYY-MM-DD")
                      : "";

                    setFormData((prev) => ({
                      ...prev,
                      date: formatted,
                    }));

                    setErrors((prev) => ({
                      ...prev,
                      date: validate("date", formatted) || "",
                    }));
                  }}
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

              <Autocomplete
                options={allStaffs}
                getOptionLabel={(o) => o.staffName || ""}
                value={allStaffs.find(s => s.staffId === formData.staffId) || null}
                onChange={handleStaffSelect}
                loading={staffLoading}
                renderInput={(params) => (
                  <CustomTextField
                    {...params}
                    label="Staff"
                    error={!!errors.staff}
                    helperText={errors.staff || ""}
                  />
                )}
              />
              <CustomTextField
                name="purchaseAmount"
                label="Purchase Amount"
                value={formData.purchaseAmount}
                onChange={handleAmountChange}
                onBlur={() => handleAmountBlur("purchaseAmount")}
                error={!!errors.purchaseAmount}
                helperText={errors.purchaseAmount || ""}
                InputProps={{
                  className: "text-lg font-semibold",
                }}
              />
            </div>
          </div>

          {/* Purchase Images Section */}
          <div className="
  border border-gray-200
  rounded-xl
  bg-white
  shadow-sm
  hover:shadow-md
  transition-shadow
  p-3 sm:p-4 md:p-6
">
            <div className="flex items-center mb-4">
              <div className="w-1 h-7 sm:h-8 bg-pink-600 rounded-full mr-3" />
              <h3 className="text-base sm:text-lg font-semibold text-gray-800">
                Purchase Images
              </h3>
              <span className="ml-2 text-xs text-gray-400">(optional)</span>
            </div>

            <ImageUploader
              value={purchaseImages}
              onChange={setPurchaseImages}
              maxImages={2}
              label="Upload Purchase Images"
              onError={(msg) => showSnackbar(msg, "error")}
            />

            <p className="mt-2 text-xs text-gray-500">
              You can upload up to 2 images only
            </p>
          </div>

        </div>

        {/* Footer */}
        <div
          className="
    px-4 sm:px-8 py-4
    border-t border-gray-200 bg-white
    flex flex-col sm:flex-row
    gap-4 sm:gap-0
    sm:items-center sm:justify-between
    shrink-0 sticky bottom-0 z-10 shadow-md
  "
        >

          <p className="text-xs sm:text-sm text-gray-500 text-center sm:text-left">
            Please review all details before saving the purchase entry.
          </p>

          <div className="flex items-center space-x-3">
            <button
              onClick={handleReset}
              type="button"
              className="
        w-full sm:w-auto
        px-4 sm:px-5 py-2.5
        text-sm font-medium text-gray-600
        border border-gray-300 rounded-lg
        hover:bg-gray-100 hover:text-gray-800
        transition-all duration-200
      "
            >
              Reset
            </button>

            <button
              onClick={handleSubmit}
              type="button"
              className="
        w-full sm:w-auto
        px-5 sm:px-6 py-2.5
        text-sm font-semibold text-white
        rounded-lg
        bg-gradient-to-r from-blue-600 to-blue-700
        hover:from-blue-700 hover:to-blue-800
        shadow-md hover:shadow-lg
        transition-all duration-200
        flex items-center justify-center gap-2
      "
            >
              {isSaving ? (
                <>
                  <svg className="animate-spin h-4 w-4" viewBox="0 0 24 24">
                    <circle
                      className="opacity-25"
                      cx="12"
                      cy="12"
                      r="10"
                      stroke="currentColor"
                      strokeWidth="4"
                      fill="none"
                    />
                    <path
                      className="opacity-75"
                      fill="currentColor"
                      d="M4 12a8 8 0 018-8v4a4 4 0 00-4 4H4z"
                    />
                  </svg>
                  Saving...
                </>
              ) : (
                "Save"
              )}
            </button>
          </div>
        </div>

      </div>
    </div>
  );

};

export default PurchaseEntry;