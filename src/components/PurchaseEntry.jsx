import { LocalizationProvider } from "@mui/x-date-pickers/LocalizationProvider";
import CustomTextField from "./CustomTextField";
import { AdapterDayjs } from "@mui/x-date-pickers/AdapterDayjs";
import { DatePicker } from "@mui/x-date-pickers/DatePicker";
import dayjs from "dayjs";
import { useSnackbar } from "../context/SnackbarContext";
import { useBillForm } from "../customHooks/useBillForm";
import { useEffect, useRef, useState } from "react";
import validate from "../validations/Validation";
import { searchStaffs } from "../service/StaffService";
import { addPurchaseEntry } from "../service/purchaseService";

const PurchaseEntry = () => {
  const searchStaffRef = useRef();
  const { showSnackbar } = useSnackbar();
  const [staffSuggestion, setStaffSuggestion] = useState([]);
  const [staffDropdown, setStaffDropdown] = useState(false);
  const {
    searchCustomerRef,
    searchSupplierRef,
    isFilterObject,
    setIsFilterObject,
    errors,
    setErrors,
    suggestions,
    setSuggestions,
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
    date: "",
    staffId: "",
    supplierId: "",
    customerId: "",
    staff: "",
    purchaseAmount: "",
  });

  useEffect(() => {
    const handleClickOutside = (e) => {
      if (
        searchStaffRef.current &&
        !searchStaffRef.current.contains(e.target)
      ) {
        setStaffDropdown(false); // ✅ CORRECT
      }
    };
    document.addEventListener("mousedown", handleClickOutside);
    return () => {
      document.removeEventListener("mousedown", handleClickOutside);
    };
  }, []);

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
    setIsFilterObject(false);
    setFilterObject({});
  };

  const handleDateChange = (name, newValue) => {
    const formatted = newValue ? dayjs(newValue).format("YYYY-MM-DD") : "";

    setFormData((prev) => ({ ...prev, [name]: formatted })); // Add validation for date fields
    setErrors((prev) => ({ ...prev, [name]: validate(name, formatted) || "" }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    const newErrors = {};

    // Step 1: Validate all fields
    Object.keys(formData).forEach((field) => {
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
    });

    setErrors(newErrors);

    // ✅ Step 2: Check if any errors exist after validation
    const hasErrors = Object.values(newErrors).some((val) => val && val !== "");

    if (hasErrors) {
      showSnackbar("Please fill required fields in the form.", "error");
      return;
    }

    // Proceed to submit
    try {
      const response = await addPurchaseEntry(formData);
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

  const handleStaffChange = async (e) => {
    const value = e.target.value;

    setFormData((prev) => ({
      ...prev,
      staff: value,
    }));

    setErrors((prev) => ({
      ...prev,
      staff: validate("staff", value),
    }));

    if (value.length > 1) {
      try {
        const result = await searchStaffs(value);
        setStaffSuggestion(result || []);
        setStaffDropdown(result?.length > 0);
      } catch {
        setStaffSuggestion([]);
        setStaffDropdown(false);
      }
    } else {
      setStaffSuggestion([]);
      setStaffDropdown(false);
    }
  };

  const handleStaffSuggestionClick = (s) => {
    setFormData((prev) => ({
      ...prev,
      staff: s.staffName || "",
      staffId: s.staffId,
    }));

    setErrors((prev) => ({
      ...prev,
      staff: "",
    }));

    setStaffSuggestion([]);
    setStaffDropdown(false);
  };

  const handleSupplierChange = (e) => {
    handleSupplierInput(e);
    setIsFilterObject(true);

    // .trim() खाली स्पेस को भी हटाने के लिए ज़रूरी है
    const inputValue = e.target.value.trim();

    if (inputValue === "") {
      // खाली होने पर ID भी साफ़ करें
      setFormData((prev) => ({ ...prev, supplierId: "" }));
      setErrors((prev) => ({
        ...prev,
        // ID के लिए validation चलाएँ, लेकिन error को 'supplierName' key पर रखें
        supplierId: validate("supplierId", "") || "",
      }));
    } else {
      // 🚀 FIX: टाइप करते समय (onChange) error को साफ़ रखें ताकि यूज़र को टाइप करने दिया जा सके
      setErrors((prev) => ({
        ...prev,
        supplierId: "",
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
        customerId: validate("customerId", "") || "",
      }));
    } else {
      // 🚀 FIX: टाइप करते समय (onChange) error को साफ़ रखें
      setErrors((prev) => ({
        ...prev,
        customerId: "",
      }));
    }
  };

  const handleAmountChange = (e) => {
    const { name, value } = e.target; // Keep the logic for allowing only numbers and one dot
    if (/^\d*\.?\d*$/.test(value)) {
      setFormData((prev) => ({
        ...prev,
        [name]: value,
      })); // Add validation for amount fields
      setErrors((prev) => ({ ...prev, [name]: validate(name, value) || "" }));
    }
  }; // Helper function for onBlur amount formatting

  const handleAmountBlur = (name) => {
    setFormData((prev) => ({
      ...prev,
      [name]: formatAmount(prev[name]),
    }));
  };

  const formatAmount = (val) => {
    const num = parseFloat(val);
    if (!val || isNaN(num)) return ""; // ← Empty string instead of "0.00"

    return Number.isInteger(num) ? num.toFixed(2) : num.toFixed(2);
  };

  return (
    <div className="flex flex-col h-full">
      {/* Grid container: header (64px) - content (1fr) - footer (64px) */}
      <div
        className="bg-white w-full grid"
        style={{ height: "91vh", gridTemplateRows: "64px 1fr 72.8px" }}
        // If Tailwind arbitrary grid rows work in your setup, you can use:
        // className="bg-white w-full grid grid-rows-[64px_1fr_64px]"
      >
        {/* Header */}
        <header className="px-6 border-b border-gray-300 flex items-center h-16">
          {/* remove default margins to avoid extra space */}
          <h2 className="m-0 text-2xl font-semibold leading-none">
            Purchase Entry
          </h2>
        </header>

        {/* Body (scrollable) */}
        <main className="px-6 py-4 overflow-y-auto">
          <div className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div className="border p-4 rounded border-gray-300">
                <h3 className="text-lg font-semibold mb-3 border-b border-gray-300 pb-2">
                  Select Date
                </h3>
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
                          // 👇 Open the calendar when clicking anywhere on the input
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

              <div className="border p-4 rounded border-gray-300">
                <h3 className="text-lg font-semibold mb-3 border-b border-gray-300 pb-2">
                  Select Staff
                </h3>
                <div ref={searchStaffRef} className="relative w-full">
                  <CustomTextField
                    name="staff"
                    label="Staff Name"
                    value={formData.staff}
                    onChange={handleStaffChange}
                    onFocus={() => {
                      if (
                        formData?.staff?.length > 1 &&
                        staffSuggestion.length > 0
                      ) {
                        setStaffDropdown(true);
                      }
                    }}
                    error={!!errors.staff}
                    helperText={errors.Staff || ""}
                  />
                   {" "}
                  {staffDropdown && staffSuggestion.length > 0 && (
                    <ul className="absolute mt-1 bg-white border rounded shadow-lg z-50 max-h-60 overflow-y-auto text-sm w-full">
                                         {" "}
                      {staffSuggestion.map((s, idx) => (
                        <li
                          key={idx}
                          className="p-2 hover:bg-gray-100 cursor-pointer"
                          onClick={() => {
                            handleStaffSuggestionClick(s);
                          }}
                        >
                                                  {s.staffName}                 
                             {" "}
                        </li>
                      ))}
                                       {" "}
                    </ul>
                  )}
                </div>
              </div>
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div className="border p-4 rounded border-gray-300">
                <h3 className="text-lg font-semibold mb-3 border-b border-gray-300 pb-2">
                  Select Supplier
                </h3>
                <div ref={searchSupplierRef} className="relative w-full">
                                 {" "}
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
                                 {" "}
                  {isDropdownOpen && suggestions.length > 0 && (
                    <ul className="absolute mt-1 bg-white border rounded shadow-lg z-50 max-h-60 overflow-y-auto text-sm w-full">
                                         {" "}
                      {suggestions.map((s, idx) => (
                        <li
                          key={idx}
                          className="p-2 hover:bg-gray-100 cursor-pointer"
                          onClick={() => {
                            handleSupplierSuggestionClick(s);
                            setFormData((prev) => ({
                              ...prev,
                              supplierId: s.id,
                            }));
                          }}
                        >
                                                  {s.supplierName}             
                                 {" "}
                        </li>
                      ))}
                                       {" "}
                    </ul>
                  )}
                               {" "}
                </div>
              </div>

              <div className="border p-4 rounded border-gray-300">
                <h3 className="text-lg font-semibold mb-3 border-b border-gray-300 pb-2">
                  Select Customer
                </h3>
                <div ref={searchCustomerRef} className="relative w-full">
                                 {" "}
                  <CustomTextField
                    name="customerName"
                    value={filterObject.customerName ?? ""} // ✅ Updated onChange handler
                    onChange={handleCustomerChange}
                    onFocus={() => {
                      if (
                        (filterObject.customerName?.length ?? 0) > 1 &&
                        custSuggestions.length > 0
                      ) {
                        setIsCustDropdownOpen(true);
                      }
                    }}
                    label="Customer" // ✅ Checking for the error on the 'customerName' key
                    error={!!errors.customerName}
                    helperText={errors.customerName || ""}
                  />
                                 {" "}
                  {isCustDropdownOpen && custSuggestions.length > 0 && (
                    <ul className="absolute mt-1 bg-white border rounded shadow-lg z-50 max-h-60 overflow-y-auto text-sm w-full">
                                         {" "}
                      {custSuggestions.map((c, idx) => (
                        <li
                          key={idx}
                          className="p-2 hover:bg-gray-100 cursor-pointer"
                          onClick={() => {
                            handleCustomerSuggestionClick(c);
                            setFormData((prev) => ({
                              ...prev,
                              customerId: c.id,
                            }));
                          }}
                        >
                                                  {c.customerName}             
                                 {" "}
                        </li>
                      ))}
                                       {" "}
                    </ul>
                  )}
                               {" "}
                </div>
              </div>
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div className="border p-4 rounded border-gray-300">
                <h3 className="text-lg font-semibold mb-3 border-b border-gray-300 pb-2">
                  Amount of Purchase
                </h3>
                <div className="relative w-full">
                  <CustomTextField
                    name="purchaseAmount"
                    label="Purchase Amount"
                    value={formData.purchaseAmount}
                    onChange={handleAmountChange}
                    onBlur={() => handleAmountBlur("purchaseAmount")}
                    error={!!errors.purchaseAmount}
                    helperText={errors.purchaseAmount || ""}
                  />
                </div>
              </div>
              {/* empty block to balance the grid */}
              <div></div>
            </div>
          </div>
        </main>

        {/* Footer (same fixed height as header) */}
        <footer className="px-6 border-t border-gray-300 flex justify-end gap-4 items-center h-16">
          <button
            type="button"
            onClick={handleReset}
            className="px-4 py-2 bg-gray-200 rounded hover:bg-gray-400"
          >
            Reset Form
          </button>
          <button
            type="button"
            onClick={handleSubmit}
            className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-800"
          >
            Save Purchase Entry
          </button>
        </footer>
      </div>
    </div>
  );
};

export default PurchaseEntry;
