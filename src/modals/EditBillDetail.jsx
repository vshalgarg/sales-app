import CustomTextField from "../components/CustomTextField";
import { useEffect, useState } from "react";
import { useBillForm } from "../customHooks/useBillForm";
import { LocalizationProvider } from "@mui/x-date-pickers/LocalizationProvider";
import { DatePicker } from "@mui/x-date-pickers/DatePicker";
import { AdapterDayjs } from "@mui/x-date-pickers/AdapterDayjs";
import dayjs from "dayjs";
import validate from "../validations/Validation";
import { searchCustomers } from "../service/CustomerService";
import { searchSuppliers } from "../service/SupplierService";
import { useSnackbar } from "../context/SnackbarContext";
import { updateBillApi } from "../service/BillService";

const EditBillDetail = ({ open, selectedBillDetail, setOpen }) => {
  const {
    formData,
    setFormData,
    errors,
    setErrors,
    getActiveTransports,
    setCustomerTransports,
    setSupplierTransports,
    suggestions,
    custSuggestions,
    isDropdownOpen,
    isCustDropdownOpen,
    isTransportDropdownOpen,
    setIsDropdownOpen,
    setIsCustDropdownOpen,
    setIsTransportDropdownOpen,
    handleSupplierInput,
    handleSupplierSuggestionClick,
    handleCustomerInput,
    handleCustomerSuggestionClick,
    searchRef,
    custSearchRef,
    transportSearchRef,
  } = useBillForm();

  // In useBillForm.js (new state for changed fields)
  const [changedFields, setChangedFields] = useState({});
  const { showSnackbar } = useSnackbar();

  // Modified handleChange
  const handleChange = (e) => {
    const { name, value } = e.target;

    setFormData((prev) => ({ ...prev, [name]: value }));
    setErrors((prev) => ({ ...prev, [name]: validate(name, value) || "" }));

    // Track changed fields compared to selectedBillDetail
    setChangedFields((prev) => {
      // Agar selectedBillDetail me original value hai
      const originalValue = selectedBillDetail?.[name] ?? "";

      if (value !== originalValue) {
        return { ...prev, [name]: value };
      } else {
        // User ne vaapas original value daal di → remove from changedFields
        const updated = { ...prev };
        delete updated[name];
        return updated;
      }
    });
  };

  const handleUpdate = async (e) => {
    e.preventDefault();

    // 1️⃣ Validate all fields
    const newErrors = {};
    Object.keys(formData).forEach((field) => {
      const error = validate(field, formData[field]);
      if (error) newErrors[field] = error;
    });

    // 2️⃣ Update errors state
    setErrors(newErrors);

    if (Object.keys(newErrors).length > 0) {
      showSnackbar("Please fill required fields.", "error");
      return;
    }

    try {
      const response = await updateBillApi(formData.billNumber, changedFields);
      if (
        response &&
        typeof response === "object" &&
        "code" in response &&
        "message" in response &&
        "timestamp" in response
      ) {
        console.log(response.message);
        showSnackbar(response.message, "error");
        return;
      }
      setOpen(false);
      showSnackbar(response.message, "success");
    } catch (err) {
      console.log(err);
      showSnackbar("Error updating bill", "error");
    }
  };

  useEffect(() => {
    if (selectedBillDetail) {
      console.log(selectedBillDetail);
      setFormData((prev) => ({
        ...prev,
        ...selectedBillDetail,
      }));
      setErrors((prev) => ({ ...prev }));
    }
  }, [selectedBillDetail, setFormData]);

  useEffect(() => {
    if (selectedBillDetail) {
      setFormData((prev) => {
        const newData = { ...prev };

        // Example: supplierGroup
        if (!prev.supplierGroup) {
          newData.supplierGroup = selectedBillDetail.supplierGroup || "";
        }

        // Example: supplierMsme
        if (!prev.supplierMsme) {
          newData.supplierMsme = selectedBillDetail.supplierMsme || "";
        }

        // Example: supplierGstNo
        if (!prev.supplierGstNo) {
          newData.supplierGstNo = selectedBillDetail.supplierGstNo || "";
        }

        return newData;
      });
    }
  }, [selectedBillDetail]);

  // const availableTransports =
  //   customerTransports.length > 0 ? customerTransports : supplierTransports;

  // 🔹 Load selectedBillDetail into formData on mount
  useEffect(() => {
    const fetchTransports = async () => {
      if (formData.customerId) {
        const customers = await searchCustomers(formData.customerName);
        const customer = customers.find((c) => c.id === formData.customerId);
        if (customer) {
          const transports = (customer.preferredTransport || []).map((t) => ({
            value: t,
            label: t,
          }));
          setCustomerTransports(transports);

          // Only set transport if it's empty AND no error exists
          if (!formData.transport && !errors.transport) {
            setFormData((prev) => ({
              ...prev,
              transport: transports[0]?.value || "",
            }));
          }
        }
      } else if (formData.supplierId) {
        const suppliers = await searchSuppliers(formData.supplierName);
        const supplier = suppliers.find((s) => s.id === formData.supplierId);
        if (supplier) {
          const transports = (supplier.preferredTransport || []).map((t) => ({
            value: t,
            label: t,
          }));
          setSupplierTransports(transports);

          if (!formData.transport && !errors.transport) {
            setFormData((prev) => ({
              ...prev,
              transport: transports[0]?.value || "",
            }));
          }
        }
      }
    };

    fetchTransports();
  }, [formData.customerId, formData.supplierId]);

  const handleTransportInput = (e) => {
    const value = e.target.value;
    setFormData((prev) => ({ ...prev, transport: value }));
    setErrors((prev) => ({ ...prev, transport: validate("transport", value) }));

    const activeTransports = getActiveTransports();
    if (value.length > 0) {
      const filtered = activeTransports.filter((t) =>
        t.label.toLowerCase().includes(value.toLowerCase())
      );
      setIsTransportDropdownOpen(filtered.length > 0);
    } else {
      setIsTransportDropdownOpen(activeTransports.length > 0);
    }
  };

  if (!open) return null;

  return (
    <div className="fixed inset-0 flex items-center justify-center bg-black bg-opacity-80 z-50">
      <div className="bg-white dark:bg-gray-900 w-full max-w-4xl max-h-[90vh] rounded-lg shadow-lg flex flex-col">
        <div className="p-6 border-b">
          <h2 className="text-xl font-semibold">Edit Bill Details</h2>
        </div>

        <div className="px-6 py-4 overflow-y-auto flex-1 space-y-6">
          {/* --- Section: Bill Info --- */}
          <h3 className="text-lg font-semibold mb-3">Bill Information</h3>
          <div className="grid grid-cols-2 gap-4 mb-6">
            <CustomTextField
              name="billNumber"
              value={formData.billNumber}
              readOnly
              label="Bill Number"
            />
            <LocalizationProvider dateAdapter={AdapterDayjs}>
              <DatePicker
                label="Date"
                value={formData.date ? dayjs(formData.date) : null} // ✅ convert string → dayjs
                onChange={(newValue) => {
                  const formatted = newValue
                    ? dayjs(newValue).format("YYYY-MM-DD")
                    : "";
                  setFormData((prev) => ({ ...prev, date: formatted }));
                  setErrors((prev) => ({
                    ...prev,
                    date: validate("date", formatted),
                  }));
                }}
                slotProps={{
                  textField: {
                    size: "small",
                    fullWidth: true,
                    error: !!errors.date,
                    helperText: errors.date || "",
                  },
                }}
              />
            </LocalizationProvider>
            <LocalizationProvider dateAdapter={AdapterDayjs}>
              <DatePicker
                label="Received Date"
                value={
                  formData.receivedDate ? dayjs(formData.receivedDate) : null
                } // ✅ convert string → dayjs
                onChange={(newValue) => {
                  const formatted = newValue
                    ? dayjs(newValue).format("YYYY-MM-DD")
                    : "";
                  setFormData((prev) => ({
                    ...prev,
                    receivedDate: formatted,
                  }));
                  setErrors((prev) => ({
                    ...prev,
                    receivedDate: validate("receivedDate", formatted),
                  })); // ✅ store as string
                }}
                slotProps={{
                  textField: {
                    size: "small",
                    fullWidth: true,
                    error: !!errors.receivedDate,
                    helperText: errors.receivedDate || "",
                  },
                }}
              />
            </LocalizationProvider>
            <CustomTextField
              name="order"
              value={formData.order}
              onChange={handleChange}
              label="Order"
              error={!!errors.order}
              helperText={errors.order || ""}
            />
          </div>

          {/* --- Section: Supplier --- */}
          <h3 className="text-lg font-semibold mb-3">Supplier Information</h3>
          <div className="grid grid-cols-2 gap-4 mb-6">
            <div ref={searchRef} className="relative w-full">
              <CustomTextField
                name="supplierName"
                value={formData.supplierName}
                onChange={handleSupplierInput} // search API
                onFocus={() => {
                  if (
                    formData.supplierName.length > 1 &&
                    suggestions.length > 0
                  ) {
                    setIsDropdownOpen(true); // reopen dropdown on focus
                  }
                }}
                label="Supplier"
                // autoComplete="off"
                error={!!errors.supplierName}
                helperText={errors.supplierName || ""}
              />

              {/* Suggestions dropdown */}
              {isDropdownOpen && suggestions.length > 0 && (
                <ul
                  className="absolute mt-1 bg-white border rounded shadow-lg z-50 
                 max-h-60 overflow-y-auto text-sm w-full"
                >
                  {suggestions.map((s, idx) => (
                    <li
                      key={idx}
                      className="p-2 hover:bg-gray-100 cursor-pointer"
                      onClick={() => handleSupplierSuggestionClick(s)}
                    >
                      {s.supplierName}
                    </li>
                  ))}
                </ul>
              )}
            </div>
            <CustomTextField
              name="supplierGroup"
              value={formData.supplierGroup}
              label="Supplier Group"
              readOnly
              error={!!errors.supplierGroup}
              helperText={errors.supplierGroup || ""}
              hideErrorUI={true}
            />
            <CustomTextField
              name="supplierMsme"
              value={formData.supplierMsme}
              label="MSME"
              readOnly
              error={!!errors.supplierMsme}
              helperText={errors.supplierMsme || ""}
              hideErrorUI={true}
            />
            <CustomTextField
              name="supplierGstNo"
              value={formData.supplierGstNo}
              label="GSTIN"
              readOnly
              error={!!errors.supplierGstNo}
              helperText={errors.supplierGstNo || ""}
              hideErrorUI={true}
            />
          </div>

          {/* --- Section: Customer --- */}
          <h3 className="text-lg font-semibold mb-3">Customer Information</h3>
          <div className="grid grid-cols-2 gap-4 mb-6">
            <div ref={custSearchRef} className="relative w-full">
              <CustomTextField
                name="customerName"
                value={formData.customerName}
                onChange={handleCustomerInput} // search API
                onFocus={() => {
                  if (
                    formData.customerName.length > 1 &&
                    custSuggestions.length > 0
                  ) {
                    setIsCustDropdownOpen(true);
                  }
                }}
                error={!!errors.customerName}
                helperText={errors.customerName || ""}
                label="Customer"
                autoComplete="off"
              />

              {/* Suggestions dropdown */}
              {isCustDropdownOpen && custSuggestions.length > 0 && (
                <ul
                  className="absolute mt-1 bg-white border rounded shadow-lg z-50 
                 max-h-60 overflow-y-auto text-sm w-full"
                >
                  {custSuggestions.map((c, idx) => (
                    <li
                      key={idx}
                      className="p-2 hover:bg-gray-100 cursor-pointer"
                      onClick={() => handleCustomerSuggestionClick(c)}
                    >
                      {c.customerName}
                    </li>
                  ))}
                </ul>
              )}
            </div>
            <CustomTextField
              name="customerGroup"
              value={formData.customerGroup}
              label="Customer Group"
              readOnly
              error={!!errors.customerGroup}
              helperText={errors.customerGroup || ""}
              hideErrorUI={true}
            />
            <CustomTextField
              name="customerMsme"
              value={formData.customerMsme}
              label="MSME"
              readOnly
              error={!!errors.customerMsme}
              helperText={errors.customerMsme || ""}
              hideErrorUI={true}
            />
            <CustomTextField
              name="customerGstNo"
              value={formData.customerGstNo}
              label="GSTIN"
              readOnly
              error={!!errors.customerGstNo}
              helperText={errors.customerGstNo || ""}
              hideErrorUI={true}
            />
          </div>

          {/* --- Section: Amounts --- */}
          <h3 className="text-lg font-semibold mb-3">Amount Information</h3>
          <div className="grid grid-cols-2 gap-4 mb-6">
            <CustomTextField
              name="pieces"
              value={formData.pieces}
              onChange={handleChange}
              label="Pieces"
              error={!!errors.pieces}
              helperText={errors.pieces || ""}
            />
            <CustomTextField
              name="grossAmount"
              value={formData.grossAmount}
              onChange={handleChange}
              label="Gross Amount"
              error={!!errors.grossAmount}
              helperText={errors.grossAmount || ""}
            />
            <CustomTextField
              name="discountPercent"
              value={formData.discountPercent}
              onChange={handleChange}
              label="Discount %"
              error={!!errors.discountPercent}
              helperText={errors.discountPercent || ""}
            />
            <CustomTextField
              name="discountAmount"
              value={formData.discountAmount}
              label="Discount Amount"
              readOnly
            />
            <CustomTextField
              name="addOnAmount"
              value={formData.addOnAmount}
              onChange={handleChange}
              label="Add-On Amount"
              error={!!errors.addOnAmount}
              helperText={errors.addOnAmount || ""}
            />
            <CustomTextField
              name="ecrAmount"
              value={formData.ecrAmount}
              onChange={handleChange}
              label="ECR Amount"
              error={!!errors.ecrAmount}
              helperText={errors.ecrAmount || ""}
            />
            <CustomTextField
              name="gstPercent"
              value={formData.gstPercent}
              onChange={handleChange}
              label="GST %"
              error={!!errors.gstPercent}
              helperText={errors.gstPercent || ""}
            />
            <CustomTextField
              name="gstAmount"
              value={formData.gstAmount}
              label="GST Amount"
              readOnly
            />
            <CustomTextField
              name="taxableValue"
              value={formData.taxableValue}
              label="Taxable Value"
              readOnly
            />
            <CustomTextField
              name="billAmount"
              value={formData.billAmount}
              label="Bill Amount"
              readOnly
            />
          </div>

          {/* --- Section: Transport --- */}
          <h3 className="text-lg font-semibold mb-3">
            Transport & Logistics Information
          </h3>
          <div className="grid grid-cols-2 gap-4">
            <div ref={transportSearchRef} className="relative w-full">
              <CustomTextField
                name="transport"
                value={formData.transport}
                onChange={handleTransportInput}
                onFocus={() => {
                  const activeTransports = getActiveTransports();
                  if (activeTransports.length > 0)
                    setIsTransportDropdownOpen(true);
                }}
                label="Transport"
                autoComplete="off"
                error={!!errors.transport}
                helperText={errors.transport || ""}
              />

              {isTransportDropdownOpen && getActiveTransports().length > 0 && (
                <ul className="absolute left-0 right-0 mt-1 bg-white border border-gray-300 rounded-md shadow-lg z-50 max-h-60 overflow-y-auto text-sm">
                  {getActiveTransports()
                    .filter(
                      (t) =>
                        formData.transport
                          ? t.label
                              .toLowerCase()
                              .includes(formData.transport.toLowerCase())
                          : true // ✅ show all transports if field is empty
                    )
                    .map((t, idx) => (
                      <li
                        key={idx}
                        className="p-2 hover:bg-gray-100 cursor-pointer"
                        onClick={() => {
                          setFormData((prev) => ({
                            ...prev,
                            transport: t.value,
                          }));
                          setErrors((prev) => ({ ...prev, transport: "" }));
                          setIsTransportDropdownOpen(false);
                        }}
                      >
                        {t.label}
                      </li>
                    ))}
                </ul>
              )}
            </div>
            <CustomTextField
              name="lrNumber"
              value={formData.lrNumber}
              onChange={handleChange}
              label="LR Number"
              error={!!errors.lrNumber}
              helperText={errors.lrNumber || ""}
            />
            <CustomTextField
              name="remarks"
              value={formData.remarks}
              onChange={handleChange}
              label="Remarks"
            />
          </div>
        </div>

        {/* --- Footer --- */}
        <div className="p-4 border-t flex justify-end space-x-3">
          <button
            onClick={() => {
              localStorage.removeItem("billFormData");
              localStorage.removeItem("billFormErrors");
              setOpen(false);
            }}
            className="px-4 py-2 bg-gray-400 text-white rounded-lg hover:bg-gray-500"
          >
            Cancel
          </button>
          <button
            onClick={(e) => {
              handleUpdate(e);
            }}
            className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
          >
            Save Changes
          </button>
        </div>
      </div>
    </div>
  );
};

export default EditBillDetail;
