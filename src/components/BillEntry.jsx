import CustomTextField from "./CustomTextField";
import { LocalizationProvider } from "@mui/x-date-pickers/LocalizationProvider";
import { DatePicker } from "@mui/x-date-pickers/DatePicker";
import { AdapterDayjs } from "@mui/x-date-pickers/AdapterDayjs";
import dayjs from "dayjs";
import validate from "../validations/Validation";
import { useBillForm } from "../customHooks/useBillForm";
import { useState, useEffect, useRef } from "react";
import { addBill, searchTransports } from "../service/BillService";
import { useSnackbar } from "../context/SnackbarContext";
import { Trash2, Pencil } from "lucide-react";
import ConfirmationModal from "./ConfirmationModel";

const BillEntry = () => {
  const {
    formData,
    setFormData,
    errors,
    setErrors,
    handleChange,
    handleReset,
    suggestions,
    custSuggestions,
    isDropdownOpen,
    isCustDropdownOpen,
    setIsDropdownOpen,
    setIsCustDropdownOpen,
    handleSupplierInput,
    handleSupplierSuggestionClick,
    handleCustomerInput,
    handleCustomerSuggestionClick,
    searchRef,
    custSearchRef,
    transportSearchRef,
  } = useBillForm();

  const { showSnackbar } = useSnackbar();
  const [transportSuggestions, setTransportSuggestions] = useState([]);
  const [isTransportDropdownOpen, setIsTransportDropdownOpen] = useState(false);
  const [transportLoading, setTransportLoading] = useState(false);
  const [showConfirmPopup, setShowConfirmPopup] = useState(false);
  const [pendingTransportName, setPendingTransportName] = useState("");
  const [editingIndex, setEditingIndex] = useState(null);
  const [editForm, setEditForm] = useState({});

  const transportTimeout = useRef(null);
  const [taxableValue, setTaxableValue] = useState()
  const [billEntry, setBillEntry] = useState()
  const [isConfirmOpen, setIsConfirmOpen] = useState(false);
  const [isSaving, setIsSaving] = useState(false);
  const [currentButton, seCurrentButton] = useState("")



  //🔹 Auto calculations
  // useEffect(() => {
  //   const gross = parseFloat(formData.grossAmount) || 0;
  //   const discPercent = parseFloat(formData.discountPercent) || 0;
  //   const addOn = parseFloat(formData.addOnAmount) || 0;
  //   const ecr = parseFloat(formData.ecrAmount) || 0;
  //   const gstPercent = parseFloat(formData.gstPercent) || 0;

  //   const discountAmount =
  //     gross && discPercent ? (gross * discPercent) / 100 : "";

  //     const gstAmount =
  //     taxableValue && gstPercent
  //       ? (parseFloat(taxableValue) * gstPercent) / 100
  //       : "";

  //   const taxableValue =
  //     gross || discPercent || addOn || ecr
  //       ? gross - (gross * discPercent) / 100 + addOn + ecr
  //       : "";



  //   const billAmount =
  //     taxableValue || gstAmount
  //       ? (parseFloat(taxableValue) || 0) + (parseFloat(gstAmount) || 0)
  //       : "";

  //   setFormData((prev) => ({
  //     ...prev,
  //     discountAmount: discountAmount === "" ? "" : discountAmount.toFixed(2),
  //     taxableValue:
  //       taxableValue === "" ? "" : parseFloat(taxableValue).toFixed(2),
  //     gstAmount: gstAmount === "" ? "" : gstAmount.toFixed(2),
  //     billAmount: billAmount === "" ? "" : billAmount.toFixed(2),
  //   }));
  // }, [
  //   formData.grossAmount,
  //   formData.discountPercent,
  //   formData.addOnAmount,
  //   formData.ecrAmount,
  //   formData.gstPercent,
  // ]);

  // Add this useEffect in your BillEntry component (after the other useEffects)
  useEffect(() => {
    if (editingIndex === null) return; // only run when editing

    const gross = parseFloat(editForm.grossAmount) || 0;
    const discPercent = parseFloat(editForm.discountPercent) || 0;
    const addOn = parseFloat(editForm.addOnAmount) || 0;
    const ecr = parseFloat(editForm.ecrAmount) || 0;
    const gstPercent = parseFloat(editForm.gstPercent) || 0;

    // Discount Amount = (gross * discount%) / 100
    const discountAmount = gross && discPercent ? (gross * discPercent) / 100 : 0;

    // Taxable Value = gross - discount + addOn + ecr
    const taxable = gross - discountAmount + addOn + ecr;

    // GST Amount = (taxable * gst%) / 100
    const gstAmount = taxable && gstPercent ? (taxable * gstPercent) / 100 : 0;

    // Update editForm with calculated values
    setEditForm(prev => ({
      ...prev,
      discountAmount: discountAmount.toFixed(2),
      taxableValue: taxable.toFixed(2),
      gstAmount: gstAmount.toFixed(2),
      billAmount: (taxable + gstAmount).toFixed(2),
    }));
  }, [
    editForm.grossAmount,
    editForm.discountPercent,
    editForm.addOnAmount,
    editForm.ecrAmount,
    editForm.gstPercent,
    editingIndex //it resets when editing stops
  ]);


  const handleTransportInput = (e) => {
    const value = e.target.value;
    setFormData(prev => ({ ...prev, transport: value }));

    if (transportTimeout.current) {
      clearTimeout(transportTimeout.current);
    }

    transportTimeout.current = setTimeout(async () => {
      setTransportLoading(true);
      const results = await searchTransports(value);
      console.log("Received transports:", results);
      setTransportSuggestions(results);
      setIsTransportDropdownOpen(results.length > 0);
      setTransportLoading(false);
    }, 300);
  };

  const [savedItems, setSavedItems] = useState([]);


  const handleResetBillDetail = () => {
    setFormData((prev) => ({
      ...prev,
      pieces: "",
      grossAmount: "",
      discountPercent: "",
      discountAmount: "",
      addOnAmount: "",
      ecrAmount: "",
      gstPercent: "",
      gstAmount: "",

    }));

  }

  const handleResetForm = () => {
    setFormData((prev) => ({
      ...prev,
      customerId: "",
      supplierId: "",
      date: dayjs().format("YYYY-MM-DD"),
      receivedDate: "",
      order: "",
      supplierName: "",
      supplierGroup: "",
      supplierMsme: "",
      supplierGstNo: "",
      customerName: "",
      customerGroup: "",
      customerMsme: "",
      customerGstNo: "",
      pieces: "",
      grossAmount: "",
      discountPercent: "",
      discountAmount: "",
      gstPercent: "",
      gstAmount: "",
      billAmount: "",
      addOnAmount: "",
      ecrAmount: "",
      taxableValue: "",
      transport: "",
      lrNumber: "",
      remarks: "",
    }))
    setTaxableValue(null)
    setBillEntry(null)
    setSavedItems([])

  }

  const handleSaveItemWithConfirm = () => {
    setIsSaving(true);
    handleSaveItem();
    setIsConfirmOpen(false);
    setIsSaving(false);
  };

  const handleSaveItem = () => {
    if (!formData.grossAmount) {
      showSnackbar("Please save at least one item", "error");
      return;
    }
     if (formData.pieces <= 0) {
      showSnackbar("Please add atleast 1 piece", "error");
      return;
    }

    const newItem = {
      pieces: formData.pieces,
      grossAmount: formData.grossAmount,
      discountPercent: formData.discountPercent,
      discountAmount: formData.discountAmount,
      addOnAmount: formData.addOnAmount,
      ecrAmount: formData.ecrAmount,
      gstPercent: formData.gstPercent,
      gstAmount: formData.gstAmount,
      taxableValue: formData.taxableValue,
      billAmount: formData.billAmount,

    };

    setSavedItems([...savedItems, newItem]);

    setFormData((prev) => ({
      ...prev,
      pieces: "",
      grossAmount: "",
      discountPercent: "",
      discountAmount: "",
      addOnAmount: "",
      ecrAmount: "",
      gstPercent: "",
      gstAmount: "",

    }));
  };



  const handleSubmitWithConfirm = () => {
    setIsSaving(true);
    handleSubmit();
    setIsConfirmOpen(false);
    setIsSaving(false);
  };
  const handleSubmit = async () => {
    

    if (savedItems.length === 0) {
      showSnackbar("Please save at least one item", "error");
      return;
    }

    const currentTransport = formData.transport?.trim();
    const isNewTransport = currentTransport &&
      !transportSuggestions.some(t =>
        t.name.toLowerCase() === currentTransport.toLowerCase()
      );

    if (isNewTransport) {
      setPendingTransportName(currentTransport);
      setShowConfirmPopup(true);
      return; // wait for user decision
    }
    await saveBillEntry();
  };

  const saveBillEntry = async () => {
    const payload = {
      ...formData,
      date: formData.date || null,
      receivedDate: formData.receivedDate || null,
      supplierId: formData.supplierId ? parseInt(formData.supplierId) : null,
      customerId: formData.customerId ? parseInt(formData.customerId) : null,
      transport: formData.transport?.trim() || null,
      taxableValue: parseFloat(taxableValue) || 0,
      billAmount: parseFloat(billEntry) || 0,
      billItems: savedItems.map(item => ({
        pieces: parseInt(item.pieces) || 0,
        grossAmount: parseFloat(item.grossAmount) || 0,
        discountPercent: parseFloat(item.discountPercent) || 0,
        discountAmount: parseFloat(item.discountAmount) || 0,
        addOnAmount: parseFloat(item.addOnAmount) || 0,
        ecrAmount: parseFloat(item.ecrAmount) || 0,
        gstPercent: parseFloat(item.gstPercent) || 0,
        gstAmount: parseFloat(item.gstAmount) || 0,
      }))
    };

    try {
      const response = await addBill(payload);
      if (response?.message) {
        showSnackbar(response.message, "success");
        handleReset();
        setSavedItems([]);
      } else {
        showSnackbar("Unexpected response", "error");
      }
    } catch (err) {
      console.error(err);
      showSnackbar("Error saving bill entry", "error");
    }
  };

  useEffect(() => {
    let totalTaxable = 0;
    let totalBill = 0;

    savedItems.forEach((item) => {
      totalTaxable += parseFloat(item.taxableValue) || 0;
      totalBill += parseFloat(item.billAmount) || 0;
    });
    setTaxableValue(totalTaxable.toFixed(2))
    setBillEntry(totalBill.toFixed(2))

    // setFormData((prev) => ({
    //   ...prev,
    //   taxableValue: totalTaxable.toFixed(2),
    //   billAmount: totalBill.toFixed(2),
    // }));
  }, [savedItems]);


  const handleEditClick = (index) => {
    setEditingIndex(index);
    setEditForm({ ...savedItems[index] });
  };

  const handleDeleteClick = (index) => {
    setSavedItems(savedItems.filter((_, i) => i !== index));
  };

  const handleEditSave = () => {
    if (editingIndex !== null) {
      const updatedItems = [...savedItems];
      updatedItems[editingIndex] = { ...editForm };
      setSavedItems(updatedItems);
      setEditingIndex(null);
      setEditForm({});
    }
  };

  const handleEditCancel = () => {
    setEditingIndex(null);
    setEditForm({});
  };

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
                  value={formData.date ? dayjs(formData.date, "YYYY-MM-DD") : null}
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

          <div className="border p-4 rounded border-gray-500">
            <div className="grid grid-cols-2 gap-4 ">
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
            <div className="flex justify-end mt-4 gap-4">
              <button
                onClick={handleResetBillDetail}
                type="button"
                className="px-4 py-2 bg-gray-200 border-solid border-2 border-gray-400 rounded hover:bg-gray-400"
              >
                Reset
              </button>
              <button
                onClick={() => { setIsConfirmOpen(true), seCurrentButton("SaveItem") }}
                type="button"
                className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-800"
              >
                Save Item
              </button>

            </div>
          </div>

          {/* total bills table */}
          {savedItems.length > 0 && (
            <div className="border p-4 rounded border-gray-300 mt-6">
              <h3 className="text-lg font-semibold mb-4 border-b border-gray-300 pb-3">
                Bill Details ({savedItems.length} {savedItems.length === 1 ? "Item" : "Items"})
              </h3>
              <div className="overflow-x-auto">
                <table className="w-full table-auto border-collapse">
                  <thead>
                    <tr className="bg-gray-100">
                      <th className="px-4 py-2 text-center text-xs font-medium text-gray-700 uppercase">Pieces</th>
                      <th className="px-4 py-2 text-center text-xs font-medium text-gray-700 uppercase">Gross Amount</th>
                      <th className="px-4 py-2 text-center text-xs font-medium text-gray-700 uppercase">Discount%</th>
                      <th className="px-4 py-2 text-center text-xs font-medium text-gray-700 uppercase">Discount Amount</th>
                      <th className="px-4 py-2 text-center text-xs font-medium text-gray-700 uppercase">Add-On Amount</th>
                      <th className="px-4 py-2 text-center text-xs font-medium text-gray-700 uppercase">ECR Amount</th>
                      <th className="px-4 py-2 text-center text-xs font-medium text-gray-700 uppercase">GST%</th>
                      <th className="px-4 py-2 text-center text-xs font-medium text-gray-700 uppercase">GST Amount</th>
                      <th className="px-4 py-2 text-center text-xs font-medium text-gray-700 uppercase">Taxable Value</th>
                      <th className="px-4 py-2 text-center text-xs font-medium text-gray-700 uppercase">Bill Amount</th>
                      <th className="px-4 py-2 text-center text-xs font-medium text-gray-700 uppercase">Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    {savedItems.map((item, idx) => (
                      <tr key={idx} className="border-t">
                        {editingIndex === idx ? (
                          <>
                            {/* Edit Mode - All inputs + readOnly fields */}
                            <td className="px-2 py-1">
                              <input
                                type="number"
                                value={editForm.pieces || ""}
                                onChange={(e) => setEditForm({ ...editForm, pieces: e.target.value })}
                                className="w-full border rounded px-2 py-1 text-sm"
                              />
                            </td>
                            <td className="px-2 py-1">
                              <input
                                type="number"
                                value={editForm.grossAmount || ""}
                                onChange={(e) => setEditForm({ ...editForm, grossAmount: e.target.value })}
                                className="w-full border rounded px-2 py-1 text-sm"
                              />
                            </td>
                            <td className="px-2 py-1">
                              <input
                                type="number"
                                value={editForm.discountPercent || ""}
                                onChange={(e) => setEditForm({ ...editForm, discountPercent: e.target.value })}
                                className="w-full border rounded px-2 py-1 text-sm"
                              />
                            </td>
                            <td className="px-2 py-1">
                              <input
                                type="number"
                                value={editForm.discountAmount || ""}
                                readOnly
                                className="w-full border rounded px-2 py-1 text-sm bg-gray-100"
                              />
                            </td>
                            <td className="px-2 py-1">
                              <input
                                type="number"
                                value={editForm.addOnAmount || ""}
                                onChange={(e) => setEditForm({ ...editForm, addOnAmount: e.target.value })}
                                className="w-full border rounded px-2 py-1 text-sm"
                              />
                            </td>
                            <td className="px-2 py-1">
                              <input
                                type="number"
                                value={editForm.ecrAmount || ""}
                                onChange={(e) => setEditForm({ ...editForm, ecrAmount: e.target.value })}
                                className="w-full border rounded px-2 py-1 text-sm"
                              />
                            </td>
                            <td className="px-2 py-1">
                              <input
                                type="number"
                                value={editForm.gstPercent || ""}
                                onChange={(e) => setEditForm({ ...editForm, gstPercent: e.target.value })}
                                className="w-full border rounded px-2 py-1 text-sm"
                              />
                            </td>
                            <td className="px-2 py-1">
                              <input
                                type="number"
                                value={editForm.gstAmount || ""}
                                readOnly
                                className="w-full border rounded px-2 py-1 text-sm bg-gray-100"
                              />
                            </td>
                            <td className="px-2 py-1">
                              <input
                                type="text"
                                value={editForm.taxableValue || ""}
                                readOnly
                                className="w-full border rounded px-2 py-1 text-sm bg-gray-100"
                              />
                            </td>
                            <td className="px-2 py-1">
                              <input
                                type="text"
                                value={editForm.billAmount || ""}
                                readOnly
                                className="w-full border rounded px-2 py-1 text-sm bg-gray-100 font-medium"
                              />
                            </td>
                            <td className="px-2 py-1 text-center">
                              <button
                                onClick={handleEditSave}
                                className="text-green-600 hover:text-green-800 mr-3 inline-flex items-center"
                                title="Save"
                              >
                                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                                </svg>
                              </button>
                              <button
                                onClick={handleEditCancel}
                                className="text-red-600 hover:text-red-800 inline-flex items-center"
                                title="Cancel"
                              >
                                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                                </svg>
                              </button>
                            </td>
                          </>
                        ) : (
                          <>
                            {/* View Mode */}
                            <td className="px-4 py-2 text-center">{item.pieces || "-"}</td>
                            <td className="px-4 py-2 text-center">{item.grossAmount || "0.00"}</td>
                            <td className="px-4 py-2 text-center">{item.discountPercent || "0"}</td>
                            <td className="px-4 py-2 text-center">{item.discountAmount || "0.00"}</td>
                            <td className="px-4 py-2 text-center">{item.addOnAmount || "0.00"}</td>
                            <td className="px-4 py-2 text-center">{item.ecrAmount || "0.00"}</td>
                            <td className="px-4 py-2 text-center">{item.gstPercent || "0"}</td>
                            <td className="px-4 py-2 text-center">{item.gstAmount || "0.00"}</td>
                            <td className="px-4 py-2 text-center">{item.taxableValue || "0.00"}</td>
                            <td className="px-4 py-2 text-center font-medium">{item.billAmount || "0.00"}</td>
                            <td className="px-4 text-center py-2 flex">
                              <button
                                onClick={() => handleEditClick(idx)}
                                className="text-blue-600 hover:text-blue-800 mr-3"
                                title="Edit"
                              >
                                <Pencil className="w-5 h-5" />
                              </button>
                              <button
                                onClick={() => handleDeleteClick(idx)}
                                className="text-red-600 hover:text-red-800"
                                title="Delete"
                              >
                                <Trash2 className="w-5 h-5" />
                              </button>
                            </td>
                          </>
                        )}
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          <div className="border p-4 rounded border-gray-300">
            <h3 className="text-lg font-semibold mb-3 border-b border-gray-300 pb-2">
              Total Bill Amount
            </h3>
            <div className="grid grid-cols-2 gap-4">
              <CustomTextField
                name="taxableValue"
                value={taxableValue}
                // onChange={handleChange}
                label="Taxable Value"
                className="border p-2 rounded"
                InputProps={{ readOnly: true }}
              />
              <CustomTextField
                name="billAmount"
                value={billEntry}
                // onChange={handleChange}
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
              <div ref={transportSearchRef} className="relative w-full">
                <CustomTextField
                  name="transport"
                  value={formData.transport || ""}
                  onChange={handleTransportInput}
                  onFocus={() => {
                    if (transportSuggestions.length > 0) {
                      setIsTransportDropdownOpen(true);
                    }
                  }}
                  label="Transport"
                  autoComplete="off"
                  error={!!errors.transport}
                  helperText={errors.transport || ""}
                  disabled={!formData.supplierName && !formData.customerName}
                  //loading indicator
                  InputProps={{
                    endAdornment: transportLoading ? (
                      <span className="text-xs text-gray-500">Searching...</span>
                    ) : null
                  }}
                />

                {/* Suggestions Dropdown */}
                {isTransportDropdownOpen && transportSuggestions.length > 0 && (
                  <ul className="absolute left-0 right-0 mt-1 bg-white border border-gray-300 rounded-md shadow-lg z-50 max-h-60 overflow-y-auto text-sm">
                    {transportSuggestions.map((t, idx) => (
                      <li
                        key={t.id || idx}
                        className="p-2 hover:bg-gray-100 cursor-pointer"
                        onClick={() => {
                          setFormData(prev => ({ ...prev, transport: t.name }));
                          setIsTransportDropdownOpen(false);
                          setErrors(prev => ({ ...prev, transport: "" }));
                        }}
                      >
                        {t.name}
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

        {/* Generic Confirmation Modal */}
        <ConfirmationModal
          isOpen={isConfirmOpen}
          onClose={() => setIsConfirmOpen(false)}
          onConfirm={currentButton === "SaveItem" ? handleSaveItemWithConfirm : handleSubmitWithConfirm}
          title={currentButton === "SaveItem" ? "Save Item" : "Confirm Bill Submission"}
          message={currentButton === "SaveItem" ? "Are you sure you want to save this item with the current details?" : "Please review all entries carefully. Do you want to submit this bill now?"}
          confirmText={currentButton === "SaveItem" ? "Save" : "Submit"}
          cancelText="Cancel"
          confirmButtonColor="blue"
          loading={isSaving}
        />

        {/* Footer */}
        <div className="px-6 py-4 border-t border-gray-300 flex justify-end space-x-4 shrink-0">
          <button
            onClick={handleResetForm}
            type="button"
            className="px-4 py-2 bg-gray-200 rounded border-solid border-2 border-gray-400 hover:bg-gray-400"
          >
            Reset Form
          </button>
          <button
            onClick={() => { setIsConfirmOpen(true), seCurrentButton("SaveBillEntry") }}
            type="button"
            className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-800"
          >
            Save Bill Entry
          </button>
        </div>

        {/* <ConfirmationModal
          isOpen={isConfirmOpen}
          onClose={() => setIsConfirmOpen(false)}
          onConfirm={handleSubmit}
          title="Confirm Bill Submission"
          message="Please review all entries carefully. Do you want to submit this bill now?"
          confirmText="Yes, Submit"
          cancelText="Cancel"
          confirmButtonColor="blue"
          loading={isSaving}
        /> */}

        {showConfirmPopup && (
          <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
            <div className="bg-white rounded-lg shadow-xl p-6 max-w-sm w-full mx-4">
              <h3 className="text-lg font-semibold text-gray-800 mb-4">
                Add New Transport?
              </h3>
              <p className="text-gray-600 mb-6">
                The transport "<span className="font-medium text-blue-600">{pendingTransportName}</span>" does not exist.
                <br /><br />
                Do you want to add it?
              </p>
              <div className="flex justify-end space-x-3">
                <button
                  onClick={() => setShowConfirmPopup(false)}
                  className="px-5 py-2 bg-gray-200 text-gray-800 rounded hover:bg-gray-300 transition"
                >
                  Cancel
                </button>
                <button
                  onClick={() => {
                    setShowConfirmPopup(false);
                    saveBillEntry();
                  }}
                  className="px-5 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 transition"
                >
                  Yes, Add & Save
                </button>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default BillEntry;