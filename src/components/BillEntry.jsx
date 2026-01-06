import CustomTextField from "./CustomTextField";
import { LocalizationProvider } from "@mui/x-date-pickers/LocalizationProvider";
import { DatePicker } from "@mui/x-date-pickers/DatePicker";
import { AdapterDayjs } from "@mui/x-date-pickers/AdapterDayjs";
import dayjs from "dayjs";
import validate from "../validations/Validation";
import { useBillForm } from "../customHooks/useBillForm";
import { useState, useEffect, useRef } from "react";
import { addBill } from "../service/BillService";
import { useSnackbar } from "../context/SnackbarContext";
import { Trash2, Pencil } from "lucide-react";
import ConfirmationModal from "./ConfirmationModel";
import SupplierService from "../service/SupplierService";
import CustomerService from "../service/CustomerService";
import Autocomplete from "@mui/material/Autocomplete";
import TransportService from "../service/TransportService";
import { Box, Paper, Grid, Stack, Divider, Typography, Button } from "@mui/material";


const BillEntry = () => {
  const {
    formData,
    setFormData,
    errors,
    setErrors,
    handleChange,
    handleReset,
  } = useBillForm();

  const { showSnackbar } = useSnackbar();
  const [allTransports, setAllTransports] = useState([]);
  const [taxableValue, setTaxableValue] = useState()
  const [billEntry, setBillEntry] = useState()
  const [isConfirmOpen, setIsConfirmOpen] = useState(false);
  const [isSaving, setIsSaving] = useState(false);
  const [transportLoading, setTransportLoading] = useState(false);

  const [allSuppliers, setAllSuppliers] = useState([]);
  const [allCustomers, setAllCustomers] = useState([]);
  const [supplierLoading, setSupplierLoading] = useState(true)
  const [customerLoading, setCustomerLoading] = useState(true);
  const [isAddItemModalOpen, setIsAddItemModalOpen] = useState(false);
  const [isEditing, setIsEditing] = useState(false);
  const [currentEditIndex, setCurrentEditIndex] = useState(null);
  const [deleteIndex, setDeleteIndex] = useState(null);
  const [selectedSupplier, setSelectedSupplier] = useState(null);
  const [selectedCustomer, setSelectedCustomer] = useState(null);
  const [selectedTransport, setSelectedTransport] = useState(null);



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

        setTransportLoading(true);
        const transports = await TransportService.getAllTransports();
        setAllTransports(transports || []);
        setTransportLoading(false);
      } catch (err) {
        console.error(err);
        showSnackbar("Error loading  data", "error");
        setSupplierLoading(false);
        setCustomerLoading(false);
      }
    };

    fetchData();
  }, []);

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
    setErrors({});
  }

  const handleResetForm = () => {
    resetSupplier();
    resetCustomer();
    resetTransport();

    setFormData(prev => ({
      ...prev,
      date: dayjs().format("YYYY-MM-DD"),
      receivedDate: "",
      order: "",
      transport: "",
      lrNumber: "",
      remarks: "",
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
    }));

    setSavedItems([]);
    setTaxableValue(null);
    setBillEntry(null);
    setErrors({});
  };


  const handleSaveItem = () => {
    if (!formData.grossAmount || Number(formData.grossAmount) <= 0) {
      showSnackbar("Gross Amount is required and must be greater than zero", "error");
      return;
    }
    if (!formData.pieces || Number(formData.pieces) <= 0) {
      showSnackbar("Please enter at least 1 piece", "error");
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

    let successMessage = "";
    if (isEditing && currentEditIndex !== null) {
      // Edit mode: update existing item
      const updatedItems = [...savedItems];
      updatedItems[currentEditIndex] = newItem;
      setSavedItems(updatedItems);
      setIsEditing(false);
      setCurrentEditIndex(null);
      successMessage = "Item updated successfully";
    } else {
      // Add mode: add new item
      setSavedItems([...savedItems, newItem]);
      successMessage = "Item added successfully";
    }

    // Reset bill detail fields
    setFormData(prev => ({
      ...prev,
      pieces: "",
      grossAmount: "",
      discountPercent: "",
      discountAmount: "",
      addOnAmount: "",
      ecrAmount: "",
      gstPercent: "",
      gstAmount: "",
      taxableValue: "",
      billAmount: "",
    }));
    showSnackbar(successMessage, "success");
    setIsAddItemModalOpen(false);
  };

  const handleSubmit = async () => {
    if (savedItems.length === 0) {
      showSnackbar("Please add and save at least one item before submitting the bill", "error");
      return;
    }
    await saveBillEntry();
  };

  const validateBillForm = () => {
    const newErrors = {};

    // Required fields check
    if (!formData.date) newErrors.date = "Date is required";
    if (!formData.receivedDate) newErrors.receivedDate = "Received Date is required";
    if (!formData.order?.trim()) newErrors.order = "Order is required";

    if (!formData.supplierId) newErrors.supplierName = "Supplier is required";
    if (!formData.customerId) newErrors.customerName = "Customer is required";
    // console.log("formData.transport",formData.transport.trim())
    // if (formData.transport?.trim()==='') newErrors.transport = "Transport is required";
    if (savedItems.length === 0) newErrors.items = "At least one item is required";

    setErrors((prev) => ({ ...prev, ...newErrors }));

    return Object.keys(newErrors).length === 0;
  };

  const saveBillEntry = async () => {

    if (!validateBillForm()) {
      showSnackbar("Please fill all required fields", "error");
      return;
    }

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
      setIsSaving(true);
      const response = await addBill(payload);
      if (response?.message) {
        showSnackbar(response.message, "success");
        handleResetForm();
      } else {
        showSnackbar("Unexpected response", "error");
      }
    } catch (err) {
      console.error(err);
      showSnackbar("Error saving bill entry", "error");
    }
    finally {
      setIsSaving(false);
      setIsConfirmOpen(false);
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
  }, [savedItems]);


  const handleEditClick = (index) => {

    setCurrentEditIndex(index);
    setIsEditing(true);

    const itemToEdit = savedItems[index];
    setFormData(prev => ({
      ...prev,
      pieces: itemToEdit.pieces || "",
      grossAmount: itemToEdit.grossAmount || "",
      discountPercent: itemToEdit.discountPercent || "",
      discountAmount: itemToEdit.discountAmount || "",
      addOnAmount: itemToEdit.addOnAmount || "",
      ecrAmount: itemToEdit.ecrAmount || "",
      gstPercent: itemToEdit.gstPercent || "",
      gstAmount: itemToEdit.gstAmount || "",
      taxableValue: itemToEdit.taxableValue || "",
      billAmount: itemToEdit.billAmount || "",
    }));

    setIsAddItemModalOpen(true);
  };

  const handleAddItemModalClose = () => {
    setIsAddItemModalOpen(false);
    setIsEditing(false);
    setCurrentEditIndex(null);
    // Reset only bill detail fields
    setFormData(prev => ({
      ...prev,
      pieces: "",
      grossAmount: "",
      discountPercent: "",
      discountAmount: "",
      addOnAmount: "",
      ecrAmount: "",
      gstPercent: "",
      gstAmount: "",
      taxableValue: "",
      billAmount: "",
    }));
  };

  const handleDeleteClick = (index) => {
    setSavedItems(savedItems.filter((_, i) => i !== index));
  };

  const resetSupplier = () => {
    setSelectedSupplier(null);
    setFormData(prev => ({
      ...prev,
      supplierId: "",
      supplierName: "",
      supplierGroup: "",
      supplierMsme: "",
      supplierGstNo: "",
    }));
  };

  const resetCustomer = () => {
    setSelectedCustomer(null);
    setFormData(prev => ({
      ...prev,
      customerId: "",
      customerName: "",
      customerGroup: "",
      customerMsme: "",
      customerGstNo: "",
    }));
  };

  const resetTransport = () => {
  setSelectedTransport(null);
  setFormData(prev => ({
    ...prev,
    transportId: null,
    transportName: "",
    transportCity: "",
  }));
};


  return (
   <div className="flex flex-col h-full overflow-y-auto">
      {/* Card */}
      <div className="bg-gray-50 w-full h-[91vh] flex flex-col rounded-2xl shadow-xl border border-gray-200">

        {/* Header */}
        <div className="px-6 py-3 border-b border-gray-200 shrink-0 bg-gradient-to-r from-gray-50 to-white">
          <h2 className="text-2xl font-semibold text-gray-800">Bill Entry</h2>
          <p className="text-sm text-gray-500 mt-1">Fill in all required fields to create a new bill</p>
        </div>

        <div className="flex-1 overflow-y-auto px-8 py-6 space-y-6">
          {/* Order Information Card */}
          <div className="border border-gray-200 p-6 rounded-xl shadow-sm bg-white hover:shadow-md transition-shadow duration-200">
            <div className="flex items-center mb-5">
              <div className="w-1 h-8 bg-blue-600 rounded-full mr-3"></div>
              <h3 className="text-lg font-semibold text-gray-800">Order Information</h3>
            </div>
            <div className="grid grid-cols-3 gap-5">
              {/* Bill Date */}
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
                className="w-full"
                error={!!errors.order}
                helperText={errors.order || ""}
              />
            </div>
          </div>

          {/* Supplier Information Card */}
          <div className="border border-gray-200 p-6 rounded-xl shadow-sm bg-white hover:shadow-md transition-shadow duration-200">
            <div className="flex items-center mb-5">
              <div className="w-1 h-8 bg-green-600 rounded-full mr-3"></div>
              <h3 className="text-lg font-semibold text-gray-800">Supplier Information</h3>
            </div>
            <div className="grid grid-cols-3 gap-5 relative">
              <div>
                <Autocomplete
                  options={allSuppliers}
                  value={selectedSupplier}
                  isOptionEqualToValue={(o, v) => o.id === v?.id}
                  getOptionLabel={(o) =>
                    o?.supplierName ? `${o.supplierName} - ${o.city || ""}` : ""
                  }
                  onChange={(e, value) => {
                    if (!value) {
                      resetSupplier();
                      return;
                    }

                    setSelectedSupplier(value);
                    setFormData(prev => ({
                      ...prev,
                      supplierId: value.id,
                      supplierName: value.supplierName,
                      supplierGroup: value.supplierGroup,
                      supplierMsme: value.supplierMsme,
                      supplierGstNo: value.supplierGstNo,
                    }));

                    setErrors(prev => ({ ...prev, supplierName: "" }));
                  }}
                  renderInput={(params) => (
                    <CustomTextField
                      {...params}
                      label="Supplier"
                      error={!!errors.supplierName}
                      helperText={errors.supplierName || "Search supplier"}
                    />
                  )}
                />
              </div>

              <CustomTextField
                value={formData.supplierGroup}
                label="Supplier Group"
                InputProps={{ readOnly: true }}
              />

              <CustomTextField
                value={formData.supplierGstNo}
                label="GSTIN"
                InputProps={{ readOnly: true }}
              />

            </div>
          </div>

          {/* Customer Information Card */}
          <div className="border border-gray-200 p-6 rounded-xl shadow-sm bg-white hover:shadow-md transition-shadow duration-200">
            <div className="flex items-center mb-5">
              <div className="w-1 h-8 bg-purple-600 rounded-full mr-3"></div>
              <h3 className="text-lg font-semibold text-gray-800">Customer Information</h3>
            </div>
            <div className="grid grid-cols-3 gap-5 relative">
              <div>
                <Autocomplete
                  options={allCustomers}
                  value={selectedCustomer}
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
                      customerName: value.customerName,
                      customerGroup: value.customerGroup,
                      customerMsme: value.customerMsme,
                      customerGstNo: value.customerGstNo,
                    }));

                    setErrors(prev => ({ ...prev, customerName: "" }));
                  }}
                  renderInput={(params) => (
                    <CustomTextField
                      {...params}
                      label="Customer"
                      error={!!errors.customerName}
                      helperText={errors.customerName || "Search customer"}
                    />
                  )}
                />
              </div>

              <CustomTextField
                value={formData.customerGroup}
                label="Customer Group"
                InputProps={{ readOnly: true }}
              />

              <CustomTextField
                value={formData.customerGstNo}
                label="GSTIN"
                InputProps={{ readOnly: true }}
              />

            </div>
          </div>

          {/* Add Bill Button */}
          <div className="flex justify-end">
            <button
              onClick={() => setIsAddItemModalOpen(true)}
              className="px-3 py-2 bg-gradient-to-r from-blue-600 to-blue-700 text-white font-medium rounded-lg hover:from-blue-700 hover:to-blue-800 shadow-lg transition-all duration-200 transform hover:scale-[1.02] flex items-center gap-2"
            >
              <svg className="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
              </svg>
              Add Bill Item
            </button>
          </div>

          {/* Total Bills Table */}
          {savedItems.length > 0 && (
            <div className="border border-gray-200 p-6 rounded-xl shadow-sm bg-white hover:shadow-md transition-shadow duration-200 mt-6">
              <div className="flex items-center justify-between mb-6">
                <div className="flex items-center">
                  <div className="w-1 h-8 bg-orange-600 rounded-full mr-3"></div>
                  <h3 className="text-lg font-semibold text-gray-800">
                    Bill Details ({savedItems.length} {savedItems.length === 1 ? "Item" : "Items"})
                  </h3>
                </div>
                <div className="bg-blue-50 text-blue-600 text-sm font-medium px-3 py-1 rounded-full">
                  Total: {billEntry}
                </div>
              </div>

              <div className="overflow-x-auto rounded-lg border border-gray-100">
                <table className="w-full table-auto border-collapse">
                  <thead>
                    <tr className="bg-gradient-to-r from-gray-50 to-gray-100">
                      <th className="px-4 py-3 text-center text-xs font-semibold text-gray-700 uppercase tracking-wider border-r border-gray-200">Pieces</th>
                      <th className="px-4 py-3 text-center text-xs font-semibold text-gray-700 uppercase tracking-wider border-r border-gray-200">Gross Amount</th>
                      <th className="px-4 py-3 text-center text-xs font-semibold text-gray-700 uppercase tracking-wider border-r border-gray-200">Discount%</th>
                      <th className="px-4 py-3 text-center text-xs font-semibold text-gray-700 uppercase tracking-wider border-r border-gray-200">Discount Amount</th>
                      <th className="px-4 py-3 text-center text-xs font-semibold text-gray-700 uppercase tracking-wider border-r border-gray-200">Add-On Amount</th>
                      <th className="px-4 py-3 text-center text-xs font-semibold text-gray-700 uppercase tracking-wider border-r border-gray-200">ECR Amount</th>
                      <th className="px-4 py-3 text-center text-xs font-semibold text-gray-700 uppercase tracking-wider border-r border-gray-200">GST%</th>
                      <th className="px-4 py-3 text-center text-xs font-semibold text-gray-700 uppercase tracking-wider border-r border-gray-200">GST Amount</th>
                      <th className="px-4 py-3 text-center text-xs font-semibold text-gray-700 uppercase tracking-wider border-r border-gray-200">Taxable Value</th>
                      <th className="px-4 py-3 text-center text-xs font-semibold text-gray-700 uppercase tracking-wider border-r border-gray-200">Bill Amount</th>
                      <th className="px-4 py-3 text-center text-xs font-semibold text-gray-700 uppercase tracking-wider">Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    {savedItems.map((item, idx) => (
                      <tr key={idx} className="border-t border-gray-100 hover:bg-gray-50 transition-colors duration-150">
                        <td className="px-4 py-3 text-center font-medium text-gray-700">{item.pieces || "-"}</td>
                        <td className="px-4 py-3 text-center text-gray-600">{item.grossAmount || "0.00"}</td>
                        <td className="px-4 py-3 text-center text-gray-600">{item.discountPercent || "0"}%</td>
                        <td className="px-4 py-3 text-center text-red-500 font-medium">{item.discountAmount || "0.00"}</td>
                        <td className="px-4 py-3 text-center text-green-500 font-medium">{item.addOnAmount || "0.00"}</td>
                        <td className="px-4 py-3 text-center text-gray-600">{item.ecrAmount || "0.00"}</td>
                        <td className="px-4 py-3 text-center text-gray-600">{item.gstPercent || "0"}%</td>
                        <td className="px-4 py-3 text-center text-blue-500 font-medium">{item.gstAmount || "0.00"}</td>
                        <td className="px-4 py-3 text-center font-medium text-gray-800">{item.taxableValue || "0.00"}</td>
                        <td className="px-4 py-3 text-center font-bold text-gray-900">{item.billAmount || "0.00"}</td>
                        <td className="px-4 py-3 text-center">
                          <div className="flex justify-center items-center space-x-3">
                            <button
                              onClick={() => handleEditClick(idx)}
                              className="text-blue-600 hover:text-blue-800 p-2 rounded-full hover:bg-blue-50 transition-colors duration-200"
                              title="Edit"
                            >
                              <Pencil className="w-5 h-5" />
                            </button>
                            <button
                              onClick={() => setDeleteIndex(idx)}
                              className="text-red-600 hover:text-red-800 p-2 rounded-full hover:bg-red-50 transition-colors duration-200"
                              title="Delete"
                            >
                              <Trash2 className="w-5 h-5" />
                            </button>
                          </div>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {/* Total Bill Amount Card */}
          <div className="border border-gray-200 p-6 rounded-xl shadow-sm bg-white hover:shadow-md transition-shadow duration-200">
            <div className="flex items-center mb-5">
              <div className="w-1 h-8 bg-indigo-600 rounded-full mr-3"></div>
              <h3 className="text-lg font-semibold text-gray-800">Total Bill Amount</h3>
            </div>
            <div className="grid grid-cols-2 gap-6">
              <div className="space-y-1">
                <label className="text-sm font-medium text-gray-600">Taxable Value</label>
                <div className="p-4 bg-gray-50 border border-gray-200 rounded-lg text-xl font-bold text-gray-800">
                  {taxableValue}
                </div>
              </div>
              <div className="space-y-1">
                <label className="text-sm font-medium text-gray-600">Bill Amount</label>
                <div className="p-4 bg-blue-50 border border-blue-200 rounded-lg text-2xl font-bold text-blue-700">
                  {billEntry}
                </div>
              </div>
            </div>
          </div>


          {/* Logistics & Notes */}
          <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
            <h2 className="text-xl font-semibold text-gray-800 mb-6">Logistics & Notes</h2>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              {/* Transport */}
              <div className="space-y-1">
                <label className="block text-sm font-medium text-gray-700">Transport</label>
                <div>
                  <Autocomplete
                    options={allTransports}
                    value={selectedTransport}
                    isOptionEqualToValue={(o, v) => o.id === v?.id}
                    getOptionLabel={(o) =>
                      o?.name ? `${o.name} - ${o.city || ""}` : ""
                    }
                    onChange={(e, value) => {
                      if (!value) {
                        resetTransport();
                        return;
                      }

                      setSelectedTransport(value);
                      setFormData(prev => ({
                        ...prev,
                        transportId: value.id,
                        transportName: value.name,
                        transportCity: value.city,
                      }));

                      setErrors(prev => ({ ...prev, transport: "" }));
                    }}
                    renderInput={(params) => (
                      <CustomTextField
                        {...params}
                        //label="Transport"
                      // error={!!errors.transport}
                      // helperText={errors.transport || "Search transport"}
                      />
                    )}
                  />

                </div>
              </div>

              {/* LR Number */}
              <div className="space-y-1">
                <label className="block text-sm font-medium text-gray-700">LR Number</label>
                <div className="flex items-start">
                  <CustomTextField
                    name="lrNumber"
                    value={formData.lrNumber}
                    onChange={handleChange}
                    error={!!errors.lrNumber}
                    helperText={errors.lrNumber || ""}
                    className="w-full"
                  />
                </div>
              </div>

              {/* Remarks */}
              <div className="space-y-1">
                <label className="block text-sm font-medium text-gray-700">Remarks</label>
                <div >
                  <CustomTextField
                    name="remarks"
                    value={formData.remarks}
                    onChange={handleChange}
                    multiline
                    error={!!errors.remarks}
                    helperText={errors.remarks || ""}
                    className="w-full h-full"
                    InputProps={{
                      style: { height: '100%', overflowY: 'auto' }
                    }}
                  />
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Footer */}
        <div className="px-6 py-4 border-t border-gray-200 flex justify-end space-x-4 shrink-0 bg-gray-50">
          <button
            onClick={handleResetForm}
            disabled={isSaving}
            className={`px-3 py-2 rounded-lg border font-medium shadow-sm
    ${isSaving
                ? "bg-gray-200 text-gray-400 cursor-not-allowed"
                : "bg-white text-gray-700 hover:bg-gray-50 hover:border-gray-400"
              }`}
          >
            Reset Form
          </button>


          <button
            onClick={() => setIsConfirmOpen(true)}
            type="button"
            disabled={isSaving}
            className={`px-3 py-2 rounded-lg font-medium shadow-lg transition-all duration-200
    ${isSaving
                ? "bg-gray-400 cursor-not-allowed text-white"
                : "bg-gradient-to-r from-blue-600 to-blue-700 text-white hover:from-blue-700 hover:to-blue-800 transform hover:scale-[1.02]"
              }`}
          >
            {isSaving ? "Saving..." : "Save Bill Entry"}
          </button>


        </div>

        {/* Confirmation Modal*/}
        <ConfirmationModal
          isOpen={isConfirmOpen}
          onClose={() => setIsConfirmOpen(false)}
          onConfirm={() => {
            handleSubmit();
            setIsConfirmOpen(false);
          }}
          title="Confirm Bill Submission"
          message="Please review all entries carefully. Do you want to submit this bill now?"
          confirmText="Submit"
          cancelText="Cancel"
          confirmButtonColor="blue"
          loading={isSaving}
        />

        {/* Add Item Modal*/}
        {isAddItemModalOpen && (
          <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-40">
            <div className="bg-white rounded-lg shadow-lg w-full max-w-4xl mx-4 p-6 relative overflow-y-auto" style={{ maxHeight: '80vh' }}>
              <button
                onClick={handleAddItemModalClose}
                className="absolute top-3 right-3 text-gray-500 hover:text-gray-700 text-2xl font-semibold"
              >
                ×
              </button>

              <h2 className="text-xl font-semibold text-gray-700 mb-5">
                {isEditing ? "Edit Bill Item" : "Add Bill Item"}
              </h2>

              {/* MODAL CONTENT*/}
              <div className="border border-gray-200 p-4 rounded-lg bg-gray-50">
                <div className="grid grid-cols-2 gap-4">
                  <div className="border border-gray-100 p-4 rounded-lg bg-white">
                    <h3 className="text-base font-medium mb-3 border-b border-gray-100 pb-2">
                      Bill Details
                    </h3>
                    <div className="grid grid-cols-2 gap-3">
                      <CustomTextField
                        name="pieces"
                        value={formData.pieces}
                        onChange={(e) => {
                          const val = e.target.value;
                          //(no letters, no decimal)
                          if (/^\d*$/.test(val)) {
                            handleChange({ target: { name: "pieces", value: val } });
                          }
                        }}
                        label="Pieces"
                        error={!!errors.pieces}
                        helperText={errors.pieces}
                      />
                      <CustomTextField
                        name="grossAmount"
                        value={formData.grossAmount}
                        onChange={(e) => {
                          const val = e.target.value;
                          // Allow positive number with max 2 decimal
                          if (/^\d*\.?\d{0,2}$/.test(val)) {
                            handleChange({ target: { name: "grossAmount", value: val } });
                          }
                        }}
                        label="Gross Amount"
                        error={!!errors.grossAmount}
                        helperText={errors.grossAmount || ""}
                      />
                    </div>
                  </div>

                  <div className="border border-gray-100 p-4 rounded-lg bg-white">
                    <h3 className="text-base font-medium mb-3 border-b border-gray-100 pb-2">
                      Add Discount
                    </h3>
                    <div className="grid grid-cols-2 gap-3">
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
                        onChange={handleChange}
                        label="Discount Amount"
                        InputProps={{ readOnly: true }}
                      />
                    </div>
                  </div>

                  <div className="border border-gray-100 p-4 rounded-lg bg-white">
                    <h3 className="text-base font-medium mb-3 border-b border-gray-100 pb-2">
                      Add On Charges
                    </h3>
                    <div className="grid grid-cols-2 gap-3">
                      <CustomTextField
                        name="addOnAmount"
                        value={formData.addOnAmount}
                        onChange={(e) => {
                          const val = e.target.value;
                          if (/^\d*\.?\d{0,2}$/.test(val)) {
                            handleChange({ target: { name: "addOnAmount", value: val } });
                          }
                        }}
                        label="Add-On Amount"
                        error={!!errors.addOnAmount}
                        helperText={errors.addOnAmount || ""}
                      />
                      <CustomTextField
                        name="ecrAmount"
                        value={formData.ecrAmount}
                        onChange={(e) => {
                          const val = e.target.value;
                          if (/^\d*\.?\d{0,2}$/.test(val)) {
                            handleChange({ target: { name: "ecrAmount", value: val } });
                          }
                        }}
                        label="ECR Amount"
                        error={!!errors.ecrAmount}
                        helperText={errors.ecrAmount || ""}
                      />
                    </div>
                  </div>

                  <div className="border border-gray-100 p-4 rounded-lg bg-white">
                    <h3 className="text-base font-medium mb-3 border-b border-gray-100 pb-2">
                      Add GST Details
                    </h3>
                    <div className="grid grid-cols-2 gap-3">
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
                        onChange={handleChange}
                        label="GST Amount"
                        InputProps={{ readOnly: true }}
                      />
                    </div>
                  </div>
                </div>

                <div className="mt-5 grid grid-cols-3 gap-4 p-4 bg-white rounded-lg border border-gray-200">
                  <div className="text-center">
                    <p className="text-sm text-gray-500">Taxable Value</p>
                    <p className="text-lg font-medium text-blue-600 mt-1">
                      {formData.taxableValue || "0.00"}
                    </p>
                  </div>
                  <div className="text-center">
                    <p className="text-sm text-gray-500">GST Amount</p>
                    <p className="text-lg font-medium text-green-600 mt-1">
                      {formData.gstAmount || "0.00"}
                    </p>
                  </div>
                  <div className="text-center">
                    <p className="text-sm text-gray-500">Bill Amount</p>
                    <p className="text-xl font-medium text-indigo-600 mt-1">
                      {formData.billAmount || "0.00"}
                    </p>
                  </div>
                </div>

                {/* BUTTON SECTION*/}
                <div className="flex justify-end mt-5 gap-4">
                  {!isEditing ?
                    <button
                      onClick={handleResetBillDetail}
                      className="px-6 py-2 bg-gray-100 border border-gray-300 rounded-md hover:bg-gray-200 text-sm font-medium"
                    >
                      Reset
                    </button> : null}
                  <button
                    onClick={() => {
                      handleSaveItem();
                    }}
                    className="px-6 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 text-sm font-medium"
                  >
                    {isEditing ? "Update Item" : "Save Item"}
                  </button>
                </div>
              </div>
            </div>
          </div>
        )}

        {deleteIndex !== null && (
          <div className="fixed inset-0 bg-black bg-opacity-30 flex items-center justify-center z-50">
            <div className="bg-white rounded-xl shadow-xl p-6 w-80 animate-scale">
              <div className="flex items-center mb-4">
                <div className="w-10 h-10 bg-red-100 rounded-full flex items-center justify-center mr-3">
                  <Trash2 className="w-5 h-5 text-red-600" />
                </div>
                <h3 className="text-lg font-semibold text-gray-800">Delete Item?</h3>
              </div>

              <p className="text-gray-600 text-sm mb-6">
                Are you sure you want to delete this bill item? This action cannot be undone.
              </p>

              <div className="flex justify-end space-x-3">
                <button
                  onClick={() => setDeleteIndex(null)}
                  className="px-4 py-2 text-gray-700 bg-gray-100 rounded-lg hover:bg-gray-200 transition-colors"
                >
                  Cancel
                </button>
                <button
                  onClick={() => {
                    handleDeleteClick(deleteIndex);
                    setDeleteIndex(null);
                  }}
                  className="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors font-medium"
                >
                  Yes, Delete
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