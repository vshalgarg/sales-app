import CustomTextField from "./CustomTextField";
import { LocalizationProvider } from "@mui/x-date-pickers/LocalizationProvider";
import { DatePicker } from "@mui/x-date-pickers/DatePicker";
import { AdapterDayjs } from "@mui/x-date-pickers/AdapterDayjs";
import dayjs from "dayjs";
import validate from "../validations/Validation";
import { useBillForm } from "../customHooks/useBillForm";

const BillEntry = () => {
  const {
    formData,
    setFormData,
    errors,
    setErrors,
    handleChange,
    handleReset,
    handleSubmit,
    supplierTransports,
    customerTransports,
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

  const availableTransports =
    customerTransports.length > 0 ? customerTransports : supplierTransports;

  return (
    <div className="flex flex-col h-full overflow-y-auto">
      {/* Card */}
      <div className="bg-white w-full h-[91vh] flex flex-col ">
        {/* Header */}
        <div className="px-6 py-4 border-b border-gray-300 shrink-0">
          <h2 className="text-2xl font-semibold">Bill Entry</h2>
        </div>

        {/* Middle content (only this can scroll) */}
        <div className="flex-1 overflow-y-auto px-6 py-4 space-y-4">
          <div className="border p-4 rounded border-gray-300">
            <h3 className="text-lg font-semibold mb-3 border-b border-gray-300 pb-2">
              Order Information
            </h3>
            <div className="grid grid-cols-3 gap-4">
              {/* Bill Date */}
              {/* Date Field */}
              <LocalizationProvider dateAdapter={AdapterDayjs}>
                <DatePicker
                  label="Date"
                  value={formData.date ? dayjs(formData.date) : null} // convert string → dayjs
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
                      onClick: (e) => {
                        // 👇 Opens calendar when clicking anywhere in field
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

              {/* Received Date Field */}
              <LocalizationProvider dateAdapter={AdapterDayjs}>
                <DatePicker
                  label="Received Date"
                  value={
                    formData.receivedDate ? dayjs(formData.receivedDate) : null
                  }
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
                    }));
                  }}
                  slotProps={{
                    textField: {
                      size: "small",
                      fullWidth: true,
                      error: !!errors.receivedDate,
                      helperText: errors.receivedDate || "",
                      onClick: (e) => {
                        // 👇 Opens calendar when clicking anywhere in field
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
                name="order"
                value={formData.order}
                onChange={handleChange}
                label="Order"
                className="border p-2 rounded"
                error={!!errors.order}
                helperText={errors.order || ""}
              />
            </div>
          </div>
          {/* Supplier Information */}
          {/* Supplier Information */}
          <div className="border p-4 rounded border-gray-300">
            <h3 className="text-lg font-semibold mb-3 border-b border-gray-300 pb-2">
              Supplier Information
            </h3>
            <div className="grid grid-cols-4 gap-4 relative">
              {/* Supplier with Auto-suggestions */}
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
                  error={!!errors.supplierName}
                  helperText={errors.supplierName || ""}
                />

                {/* Suggestions dropdown */}
                {isDropdownOpen && suggestions.length > 0 && (
                  <ul className="absolute left-0 right-0 mt-1 bg-white border border-gray-300 rounded-md shadow-lg z-50 max-h-60 overflow-y-auto text-sm">
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
                onChange={handleChange}
                label="Supplier Group"
                InputProps={{ readOnly: true }}
              />
              <CustomTextField
                name="supplierMsme"
                value={formData.supplierMsme}
                onChange={handleChange}
                label="MSME"
                InputProps={{ readOnly: true }}
              />
              <CustomTextField
                name="supplierGstNo"
                value={formData.supplierGstNo}
                onChange={handleChange}
                label="GSTIN"
                InputProps={{ readOnly: true }}
              />
            </div>
          </div>
          <div className="border p-4 rounded border-gray-300">
            <h3 className="text-lg font-semibold mb-3 border-b border-gray-300 pb-2">
              Customer Information
            </h3>
            <div className="grid grid-cols-4 gap-4 relative">
              {/* Customer with Auto-suggestions */}
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
                  <ul className="absolute left-0 right-0 mt-1 bg-white border border-gray-300 rounded-md shadow-lg z-50 max-h-60 overflow-y-auto text-sm">
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
                onChange={handleChange}
                label="Customer Group"
                InputProps={{ readOnly: true }}
              />
              <CustomTextField
                name="customerMsme"
                value={formData.customerMsme}
                onChange={handleChange}
                label="MSME"
                InputProps={{ readOnly: true }}
              />
              <CustomTextField
                name="customerGstNo"
                value={formData.customerGstNo}
                onChange={handleChange}
                label="GSTIN"
                InputProps={{ readOnly: true }}
              />
            </div>
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div className="border p-4 rounded border-gray-300">
              <h3 className="text-lg font-semibold mb-3 border-b border-gray-300 pb-2">
                Bill Details
              </h3>
              <div className="grid grid-cols-2 gap-4">
                <CustomTextField
                  name="pieces"
                  value={formData.pieces}
                  onChange={handleChange}
                  label="Pieces"
                  className="border p-2 rounded"
                  error={!!errors.pieces}
                  helperText={errors.pieces}
                />
                <CustomTextField
                  name="grossAmount"
                  value={formData.grossAmount}
                  onChange={handleChange}
                  label="Gross Amount"
                  className="border p-2 rounded"
                  error={!!errors.grossAmount}
                  helperText={errors.grossAmount || ""}
                />
              </div>
            </div>
            <div className="border p-4 rounded border-gray-300">
              <h3 className="text-lg font-semibold mb-3 border-b border-gray-300 pb-2">
                Add Discount
              </h3>
              <div className="grid grid-cols-2 gap-4">
                <CustomTextField
                  name="discountPercent"
                  value={formData.discountPercent}
                  onChange={handleChange}
                  label="Discount%"
                  className="border p-2 rounded"
                  error={!!errors.discountPercent}
                  helperText={errors.discountPercent || ""}
                />
                <CustomTextField
                  name="discountAmount"
                  value={formData.discountAmount}
                  onChange={handleChange}
                  label="Discount Amount"
                  className="border p-2 rounded"
                  InputProps={{ readOnly: true }}
                />
              </div>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div className="border p-4 rounded border-gray-300">
              <h3 className="text-lg font-semibold mb-3 border-b border-gray-300 pb-2">
                Add On Charges
              </h3>
              <div className="grid grid-cols-2 gap-4">
                <CustomTextField
                  name="addOnAmount"
                  value={formData.addOnAmount}
                  onChange={handleChange}
                  label="Add-On Amount"
                  className="border p-2 rounded"
                  error={!!errors.addOnAmount}
                  helperText={errors.addOnAmount || ""}
                />
                <CustomTextField
                  name="ecrAmount"
                  value={formData.ecrAmount}
                  onChange={handleChange}
                  label="ECR Amount"
                  className="border p-2 rounded"
                  error={!!errors.ecrAmount}
                  helperText={errors.ecrAmount || ""}
                />
              </div>
            </div>
            <div className="border p-4 rounded border-gray-300">
              <h3 className="text-lg font-semibold mb-3 border-b border-gray-300 pb-2">
                Add GST Details
              </h3>
              <div className="grid grid-cols-2 gap-4">
                <CustomTextField
                  name="gstPercent"
                  value={formData.gstPercent}
                  onChange={handleChange}
                  label="GST%"
                  className="border p-2 rounded"
                  error={!!errors.gstPercent}
                  helperText={errors.gstPercent || ""}
                />
                <CustomTextField
                  name="gstAmount"
                  value={formData.gstAmount}
                  onChange={handleChange}
                  label="GST Amount"
                  className="border p-2 rounded"
                  InputProps={{ readOnly: true }}
                />
              </div>
            </div>
          </div>

          <div className="border p-4 rounded border-gray-300">
            <h3 className="text-lg font-semibold mb-3 border-b border-gray-300 pb-2">
              Total Bill Amount
            </h3>
            <div className="grid grid-cols-2 gap-4">
              <CustomTextField
                name="taxableValue"
                value={formData.taxableValue}
                onChange={handleChange}
                label="Taxable Value"
                className="border p-2 rounded"
                InputProps={{ readOnly: true }}
              />
              <CustomTextField
                name="billAmount"
                value={formData.billAmount}
                onChange={handleChange}
                label="Bill Amount"
                className="border p-2 rounded"
                InputProps={{ readOnly: true }}
              />
            </div>
          </div>

          <div className="border p-4 rounded border-gray-300">
            <h3 className="text-lg font-semibold mb-3 border-b border-gray-300 pb-2">
              Logistics & Notes
            </h3>
            <div className="grid grid-cols-3 gap-4">
              {/* Transport Field with suggestions */}
              <div ref={transportSearchRef} className="relative w-full">
                <CustomTextField
                  name="transport"
                  value={formData.transport}
                  onChange={(e) => {
                    const value = e.target.value;
                    setFormData((prev) => ({ ...prev, transport: value }));
                    setErrors((prev) => ({
                      ...prev,
                      transport: validate("transport", value),
                    }));
                  }}
                  onFocus={() => {
                    if (availableTransports.length > 0) {
                      setIsTransportDropdownOpen(true);
                    }
                  }}
                  label="Transport"
                  autoComplete="off"
                  error={!!errors.transport}
                  helperText={errors.transport || ""}
                  disabled={!formData.supplierName && !formData.customerName}
                />

                {/* Dropdown */}
                {isTransportDropdownOpen && availableTransports.length > 0 && (
                  <ul className="absolute left-0 right-0 mt-1 bg-white border border-gray-300 rounded-md shadow-lg z-50 max-h-60 overflow-y-auto text-sm">
                    {availableTransports.map((t, idx) => (
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
                className="border p-2 rounded"
                error={!!errors.lrNumber}
                helperText={errors.lrNumber || ""}
              />

              <CustomTextField
                name="remarks"
                value={formData.remarks}
                onChange={handleChange}
                label="Remarks"
                className="border p-2 rounded"
              />
            </div>
          </div>
        </div>

        {/* Footer */}
        <div className="px-6 py-4 border-t border-gray-300 flex justify-end space-x-4 shrink-0">
          <button
            onClick={handleReset}
            type="button"
            className="px-4 py-2 bg-gray-200 rounded hover:bg-gray-400"
          >
            Reset Form
          </button>
          <button
            onClick={handleSubmit}
            type="button"
            className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-800"
          >
            Save Bill Entry
          </button>
        </div>
      </div>
    </div>
  );
};

export default BillEntry;
