import CustomTextField from "@/components/CustomTextField";
import dayjs from "dayjs";
import { useBillForm } from "@/hooks/useBillForm";
import { useState, useEffect, useRef } from "react";
import { addBill } from "@/services/BillService";
import { useSnackbar } from "@/contexts/SnackbarContext";
import {
  Trash2,
  Pencil,
  FileText,
  Building2,
  Users,
  Receipt,
  Truck,
  Upload,
  Plus,
  Percent,
  CircleDollarSign,
  BadgePercent,
  Calculator,
} from "lucide-react";
import ConfirmationModal from "@/components/ConfirmationModel";
import SupplierService from "@/services/SupplierService";
import CustomerService from "@/services/CustomerService";
import Autocomplete from "@mui/material/Autocomplete";
import TransportService from "@/services/TransportService";
import { IconButton } from "@mui/material";
import ArrowBackIcon from "@mui/icons-material/ArrowBack";
import { roundUp } from "@/utils/numberUtils";
import { useUnsaved } from "@/contexts/UnsavedChangesContext";
import useUnsavedChanges from "@/hooks/useUnsavedChanges";
import CustomDatePicker from "@/components/CustomDatePicker";
import ImagePreviewDialog from "@/components/ImagePreviewDialog";
import UploadDialog from "@/components/UploadDialog";
import FormSection from "@/components/FormSection";
import FormFooter from "@/components/FormFooter";
import AppButton from "@/components/AppButton";
import { PAGE_TITLE_CLASS } from "@/theme/appTheme";
import { CARD_GRID_SHELL_CLASS, FORM_SCROLL_AREA_CLASS } from "@/theme/cardTheme";
import CloseIcon from "@mui/icons-material/Close";
import { formatIndianCurrency } from "@/utils/currencyUtils";


const BillEntry = () => {
  const {
    formData,
    setFormData,
    errors,
    setErrors,
  } =
    useBillForm();

  const billForm = formData;

  const { showSnackbar } = useSnackbar();
  const [allTransports, setAllTransports] = useState([]);
  const [taxableValue, setTaxableValue] = useState();
  const [billEntry, setBillEntry] = useState();
  const [isConfirmOpen, setIsConfirmOpen] = useState(false);
  const [isSaving, setIsSaving] = useState(false);
  const [allSuppliers, setAllSuppliers] = useState([]);
  const [allCustomers, setAllCustomers] = useState([]);
  const [isAddItemModalOpen, setIsAddItemModalOpen] = useState(false);
  const [isEditing, setIsEditing] = useState(false);
  const [currentEditIndex, setCurrentEditIndex] = useState(null);
  const [deleteIndex, setDeleteIndex] = useState(null);
  const [selectedSupplier, setSelectedSupplier] = useState(null);
  const [selectedCustomer, setSelectedCustomer] = useState(null);
  const [selectedTransport, setSelectedTransport] = useState(null);
  const [savedItems, setSavedItems] = useState([]);
  const [billDocuments, setBillDocuments] = useState([]);
  const [previewIndex, setPreviewIndex] = useState(null);
  const [isUploadOpen, setIsUploadOpen] = useState(false);
  const [tempDocuments, setTempDocuments] = useState([]);
  const fileInputRef = useRef(null);
  const [userTouched, setUserTouched] = useState(false);
  const { setIsDirty } = useUnsaved();
  const combinedData = {
    formData,
    savedItems,
    selectedSupplier,
    selectedCustomer,
    selectedTransport,
    billDocuments,
  };
  const { isDirty: localDirty } = useUnsavedChanges(combinedData);

  useEffect(() => {
    if (!userTouched) {
      setIsDirty(false);
      return;
    }

    setIsDirty(localDirty());
  }, [combinedData, userTouched]);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const suppliers = await SupplierService.getAllSuppliers();
        setAllSuppliers(suppliers || []);

        const customers = await CustomerService.getAllCustomers();
        setAllCustomers(customers || []);

        const transports = await TransportService.getAllTransports();
        setAllTransports(transports || []);
      } catch (err) {
        console.error(err);
        showSnackbar("Error loading  data", "error");
      }
    };
    fetchData();
  }, []);

  useEffect(() => {
    setFormData(prev => ({
      ...prev,
      date: dayjs().format("YYYY-MM-DD")
    }));
  }, []);


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
  };

  useEffect(() => {
    let totalTaxable = 0;
    let totalBill = 0;

    savedItems.forEach((item) => {
      totalTaxable += parseFloat(item.taxableValue) || 0;
      totalBill += parseFloat(item.billAmount) || 0;
    });
    setTaxableValue(totalTaxable.toFixed(2));
    setBillEntry(totalBill.toFixed(2));
  }, [savedItems]);

  const handleEditClick = (index) => {
    setCurrentEditIndex(index);
    setIsEditing(true);

    const itemToEdit = savedItems[index];
    setFormData((prev) => ({
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
      taxableValue: "",
      billAmount: "",
    }));
  };

  const handleDeleteClick = (index) => {
    setSavedItems(savedItems.filter((_, i) => i !== index));
  };

  const resetSupplier = () => {
    setSelectedSupplier(null);
    setFormData((prev) => ({
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
    setFormData((prev) => ({
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
    setFormData((prev) => ({
      ...prev,
      transportId: null,
      transportName: "",
      transportCity: "",
    }));
  };

  const handleResetForm = () => {

    setUserTouched(false);
    setIsDirty(false);
    resetSupplier();
    resetCustomer();
    resetTransport();

    setFormData((prev) => ({
      ...prev,
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
    setBillDocuments([]);
    if (fileInputRef.current) {
      fileInputRef.current.value = "";
    }
    setErrors({});
  };

  const handleSaveItem = () => {
    if (!billForm.grossAmount || Number(billForm.grossAmount) <= 0) {
      showSnackbar(
        "Gross Amount is required and must be greater than zero",
        "error",
      );
      return;
    }
    if (!billForm.pieces || Number(billForm.pieces) <= 0) {
      showSnackbar("Please enter at least 1 piece", "error");
      return;
    }

    const newItem = {
      pieces: billForm.pieces,
      grossAmount: billForm.grossAmount,
      discountPercent: billForm.discountPercent,
      discountAmount: billForm.discountAmount,
      addOnAmount: billForm.addOnAmount,
      ecrAmount: billForm.ecrAmount,
      gstPercent: billForm.gstPercent,
      gstAmount: billForm.gstAmount,
      taxableValue: billForm.taxableValue,
      billAmount: billForm.billAmount,
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

    setErrors(prev => ({
      ...prev,
      items: ""
    }));

    // Reset bill detail fields
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
      taxableValue: "",
      billAmount: "",
    }));
    showSnackbar(successMessage, "success");
    setIsAddItemModalOpen(false);
  };

  const validateBillForm = () => {
    const newErrors = {};
    // Required fields check
    if (!billForm.date) newErrors.date = "Date is required";
    if (!billForm.order || billForm.order.trim() === "") {
      newErrors.order = "Invoice is required";
    }

    if (!billForm.supplierId) newErrors.supplierName = "Supplier is required";
    if (!billForm.customerId) newErrors.customerName = "Customer is required";
    if (savedItems.length === 0)
      newErrors.items = "Please add at least one bill item";

    setErrors(newErrors);

    return Object.keys(newErrors).length === 0;
  };

  const handleOpenConfirm = () => {
    const isValid = validateBillForm();

    if (!isValid) {
      showSnackbar("Please fill all required fields", "error");
      return;
    }

    setIsConfirmOpen(true);
  };


  const saveBillEntry = async () => {

    const payload = {
      date: billForm.date || null,
      receivedDate: billForm.receivedDate || null,
      order: billForm.order || null,
      supplierId: billForm.supplierId ? Number(billForm.supplierId) : null,
      customerId: billForm.customerId ? Number(billForm.customerId) : null,

      transportId: billForm.transportId || null,
      transportName: billForm.transportName || null,
      transportCity: billForm.transportCity || null,

      lrNumber: billForm.lrNumber || null,
      remarks: billForm.remarks || null,

      taxableValue: Number(taxableValue) || 0,
      billAmount: Number(billEntry) || 0,

      billItems: savedItems.map((item) => ({
        pieces: Number(item.pieces) || 0,
        grossAmount: Number(item.grossAmount) || 0,
        discountPercent: Number(item.discountPercent) || 0,
        discountAmount: Number(item.discountAmount) || 0,
        addOnAmount: Number(item.addOnAmount) || 0,
        ecrAmount: Number(item.ecrAmount) || 0,
        gstPercent: Number(item.gstPercent) || 0,
        gstAmount: Number(item.gstAmount) || 0,
      })),
    };
    try {
      setIsSaving(true);

      const billFormObj = new FormData();
      billFormObj.append(
        "payload",
        new Blob([JSON.stringify(payload)], {
          type: "application/json",
        })
      );

      billDocuments.forEach((file) => {
        billFormObj.append("images", file);
      });

      const response = await addBill(billFormObj);
      showSnackbar(response?.message || "Bill added successfully", "success");
      handleResetForm();
    } catch (err) {
      const errorMsg =
        err?.response?.data?.message || err.message || "Something went wrong";
      showSnackbar(errorMsg, "error");
    } finally {
      setIsSaving(false);
      setIsConfirmOpen(false);
    }
  };

  const handleChange = (e) => {
    const { name, value } = e.target;

    setUserTouched(true);
    let finalValue = value;
    // special cleaning
    if (name === "order" || name === "lrNumber") {
      finalValue = value.replace(/[^a-zA-Z0-9\s\-_/\.@#&()]/g, "");
    }
    setFormData((prev) => ({
      ...prev,
      [name]: finalValue,
    }));
    setErrors((prev) => ({
      ...prev,
      [name]: "",
    }));
  };

  // Non-event handler (DatePicker, Autocomplete, custom)
  const handleFieldChange = (name, value) => {
    setUserTouched(true);
    setFormData((prev) => ({
      ...prev,
      [name]: value,
    }));
    setErrors((prev) => ({
      ...prev,
      [name]: "",
    }));
  };

  return (
    <div className="flex flex-col h-full min-h-0">
      <div className={`flex flex-col h-full min-h-0 overflow-hidden ${CARD_GRID_SHELL_CLASS}`}>
        <div className="px-4 md:px-6 py-4 border-b border-brand-surface-border dark:border-zinc-700 shrink-0 bg-white dark:bg-zinc-900">
          <h2 className={PAGE_TITLE_CLASS}>Bill Entry</h2>
          <p className="text-sm text-brand-search-muted dark:text-gray-400 mt-0.5">
            Fill in all required fields to create a new bill
          </p>
        </div>

        <div className={`flex-1 overflow-y-auto p-3 md:p-4 space-y-4 ${FORM_SCROLL_AREA_CLASS}`}>
          <FormSection title="Order Information" icon={FileText} variantIndex={0}>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-5">
              {/* Bill Date */}
              <CustomDatePicker
                label="Date *"
                value={billForm.date}
                error={errors.date}
                helperText={errors.date}
                onChange={(val) => handleFieldChange("date", val)}
              />

              {/* Received Date Field */}
              <CustomDatePicker
                label="Received Date"
                value={billForm.receivedDate}
                error={errors.receivedDate}
                helperText={errors.receivedDate}
                onChange={(val) => handleFieldChange("receivedDate", val)}
              />

              <CustomTextField
                name="order"
                value={billForm.order}
                onChange={handleChange}
                label="Invoice *"
                className="w-full"
                error={!!errors.order}
                helperText={errors.order || ""}
              />
            </div>
          </FormSection>

          <FormSection title="Supplier Information" icon={Building2} variantIndex={1}>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-5 relative">
              <div>
                <Autocomplete
                  options={allSuppliers}
                  value={selectedSupplier}
                  isOptionEqualToValue={(o, v) => o.id === v?.id}
                  getOptionLabel={(o) =>
                    o?.supplierName ? `${o.supplierName} - ${o.city || ""}` : ""
                  }
                  renderOption={(props, option) => (
                    <li {...props} key={option.id}>
                      {option.supplierName} - {option.city || ""}
                    </li>
                  )}
                  onChange={(e, value) => {
                    if (!value) {
                      resetSupplier();
                      return;
                    }

                    setSelectedSupplier(value);
                    handleFieldChange("supplierId", value.id);
                    setFormData((prev) => ({
                      ...prev,
                      supplierId: value.id,
                      supplierName: value.supplierName,
                      supplierGroup: value.supplierGroup,
                      supplierMsme: value.supplierMsme,
                      supplierGstNo: value.supplierGstNo,
                    }));

                    setErrors((prev) => ({ ...prev, supplierName: "" }));
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

              <CustomTextField
                value={billForm.supplierGroup}
                label="Supplier Group"
                disabled
              />

              <CustomTextField
                value={billForm.supplierGstNo}
                label="GSTIN"
                disabled
              />
            </div>
          </FormSection>

          <FormSection title="Customer Information" icon={Users} variantIndex={2}>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-5 relative">
              <div>
                <Autocomplete
                  options={allCustomers}
                  value={selectedCustomer}
                  isOptionEqualToValue={(o, v) => o.id === v?.id}
                  getOptionLabel={(o) =>
                    o?.customerName ? `${o.customerName} - ${o.city || ""}` : ""
                  }
                  renderOption={(props, option) => (
                    <li {...props} key={option.id}>
                      {option.customerName} - {option.city || ""}
                    </li>
                  )}
                  onChange={(e, value) => {
                    if (!value) {
                      resetCustomer();
                      return;
                    }

                    setSelectedCustomer(value);
                    handleFieldChange("customerId", value.id);
                    setFormData((prev) => ({
                      ...prev,
                      customerId: value.id,
                      customerName: value.customerName,
                      customerGroup: value.customerGroup,
                      customerMsme: value.customerMsme,
                      customerGstNo: value.customerGstNo,
                    }));

                    setErrors((prev) => ({ ...prev, customerName: "" }));
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
              </div>

              <CustomTextField
                value={billForm.customerGroup}
                label="Customer Group"
                disabled
              />

              <CustomTextField
                value={billForm.customerGstNo}
                label="GSTIN"
                disabled
              />
            </div>
          </FormSection>

          <div className="flex flex-col sm:flex-row sm:items-center sm:justify-end gap-3">
            <div className="flex items-center justify-between sm:justify-start gap-2 w-full sm:w-auto">
              <AppButton
                type="secondary"
                fullWidth
                onClick={() => {
                  setTempDocuments(billDocuments);
                  setIsUploadOpen(true);
                }}
                startIcon={<Upload className="h-4 w-4" />}
                sx={{
                  "@media (min-width:640px)": { width: "auto" },
                }}
              >
                Upload Documents
              </AppButton>
              <span className="text-xs text-brand-search-muted dark:text-gray-400 whitespace-nowrap">
                {billDocuments.length} files
              </span>
            </div>

            <AppButton
              type="primary"
              fullWidth
              onClick={() => setIsAddItemModalOpen(true)}
              startIcon={<Plus className="h-4 w-4" />}
              sx={{
                "@media (min-width:640px)": { width: "auto" },
              }}
            >
              Add Bill Item
            </AppButton>
          </div>

          {errors.items && (
            <div className="flex justify-end mt-2">
              <p className="text-red-600 text-sm">
                {errors.items}
              </p>
            </div>
          )}

          {/* Total Bills Table */}
          {savedItems.length > 0 && (
            <FormSection
              title={`Bill Details (${savedItems.length} ${savedItems.length === 1 ? "Item" : "Items"})`}
              icon={Receipt}
              variantIndex={3}
            >
              <div className="flex justify-end mb-4">
                <div className="bg-brand-primary/10 text-brand-primary text-sm font-medium px-3 py-1 rounded-full">
                  Total: {billEntry}
                </div>
              </div>

              <div className="overflow-x-auto rounded-lg border border-brand-surface-border/60 dark:border-zinc-700/40">
                <table className="w-full table-auto border-collapse">
                  <thead>
                    <tr className="bg-gradient-to-r from-gray-50 to-gray-100">
                      <th className="px-4 py-3 text-center text-xs font-semibold text-gray-700 uppercase tracking-wider border-r border-gray-200">
                        Pieces
                      </th>
                      <th className="px-4 py-3 text-center text-xs font-semibold text-gray-700 uppercase tracking-wider border-r border-gray-200">
                        Gross Amount
                      </th>
                      <th className="px-4 py-3 text-center text-xs font-semibold text-gray-700 uppercase tracking-wider border-r border-gray-200">
                        Discount%
                      </th>
                      <th className="px-4 py-3 text-center text-xs font-semibold text-gray-700 uppercase tracking-wider border-r border-gray-200">
                        Discount Amount
                      </th>
                      <th className="px-4 py-3 text-center text-xs font-semibold text-gray-700 uppercase tracking-wider border-r border-gray-200">
                        Add-On Amount
                      </th>
                      <th className="px-4 py-3 text-center text-xs font-semibold text-gray-700 uppercase tracking-wider border-r border-gray-200">
                        ECR Amount
                      </th>
                      <th className="px-4 py-3 text-center text-xs font-semibold text-gray-700 uppercase tracking-wider border-r border-gray-200">
                        GST%
                      </th>
                      <th className="px-4 py-3 text-center text-xs font-semibold text-gray-700 uppercase tracking-wider border-r border-gray-200">
                        GST Amount
                      </th>
                      <th className="px-4 py-3 text-center text-xs font-semibold text-gray-700 uppercase tracking-wider border-r border-gray-200">
                        Taxable Value
                      </th>
                      <th className="px-4 py-3 text-center text-xs font-semibold text-gray-700 uppercase tracking-wider border-r border-gray-200">
                        Bill Amount
                      </th>
                      <th className="px-4 py-3 text-center text-xs font-semibold text-gray-700 uppercase tracking-wider">
                        Actions
                      </th>
                    </tr>
                  </thead>
                  <tbody>
                    {savedItems.map((item, idx) => (
                      <tr
                        key={idx}
                        className="border-t border-gray-100 hover:bg-gray-50 transition-colors duration-150"
                      >
                        <td className="px-4 py-3 text-center font-medium text-gray-700">
                          {item.pieces || "-"}
                        </td>
                        <td className="px-4 py-3 text-center text-gray-600">
                          {item.grossAmount || "0.00"}
                        </td>
                        <td className="px-4 py-3 text-center text-gray-600">
                          {item.discountPercent || "0"}%
                        </td>
                        <td className="px-4 py-3 text-center text-red-500 font-medium">
                          {item.discountAmount || "0.00"}
                        </td>
                        <td className="px-4 py-3 text-center text-green-500 font-medium">
                          {item.addOnAmount || "0.00"}
                        </td>
                        <td className="px-4 py-3 text-center text-gray-600">
                          {item.ecrAmount || "0.00"}
                        </td>
                        <td className="px-4 py-3 text-center text-gray-600">
                          {item.gstPercent || "0"}%
                        </td>
                        <td className="px-4 py-3 text-center text-blue-500 font-medium">
                          {item.gstAmount || "0.00"}
                        </td>
                        <td className="px-4 py-3 text-center font-medium text-gray-800">
                          {roundUp(item.taxableValue)}
                        </td>
                        <td className="px-4 py-3 text-center font-bold text-gray-900">
                          {roundUp(item.billAmount)}
                        </td>
                        <td className="px-4 py-3 text-center">
                          <div className="flex justify-center items-center space-x-3">
                            <button
                              onClick={() => handleEditClick(idx)}
                              className="text-brand-primary hover:text-brand-primaryDark p-2 rounded-full hover:bg-brand-primary/10 transition-colors duration-200"
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
                  <tfoot>
                    <tr className="bg-gray-100 border-t-2 border-gray-300">
                      <td colSpan={7}></td>
                      <td className="px-4 py-3 text-right font-semibold text-gray-700">
                        Total
                      </td>
                      <td className="px-4 py-3 text-center font-semibold text-gray-900">
                        {roundUp(taxableValue)}
                      </td>
                      <td className="px-4 py-3 text-center font-bold text-brand-primary">
                        {roundUp(billEntry)}
                      </td>
                      <td></td>
                    </tr>
                  </tfoot>
                </table>
              </div>
            </FormSection>
          )}

          <FormSection
            title="Logistics & Notes"
            icon={Truck}
            variantIndex={savedItems.length > 0 ? 4 : 3}
          >
            <div className="grid grid-cols-1 md:grid-cols-3 gap-2 md:gap-6">
              {/* Transport */}
              <div className="space-y-1">
                <label className="block text-sm font-medium text-gray-700">
                  Transport
                </label>
                <div>
                  <Autocomplete
                    options={allTransports}
                    value={selectedTransport}
                    isOptionEqualToValue={(o, v) => o.id === v?.id}
                    getOptionLabel={(o) =>
                      o?.name ? `${o.name} - ${o.city || ""}` : ""
                    }
                    renderOption={(props, option) => (
                      <li {...props} key={option.id}>
                        {option.name} - {option.city || ""}
                      </li>
                    )}
                    onChange={(e, value) => {
                      if (!value) {
                        resetTransport();
                        return;
                      }

                      setSelectedTransport(value);
                      handleFieldChange("transportId", value.id);
                      setFormData((prev) => ({
                        ...prev,
                        transportId: value.id,
                        transportName: value.name,
                        transportCity: value.city,
                      }));

                      setErrors((prev) => ({ ...prev, transport: "" }));
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
                <label className="block text-sm font-medium text-gray-700">
                  LR Number
                </label>
                <div className="flex items-start">
                  <CustomTextField
                    name="lrNumber"
                    value={billForm.lrNumber}
                    onChange={handleChange}
                    error={!!errors.lrNumber}
                    helperText={errors.lrNumber || ""}
                    className="w-full"
                  />
                </div>
              </div>

              {/* Remarks */}
              <div className="space-y-1">
                <label className="block text-sm font-medium text-gray-700">
                  Remarks
                </label>
                <div>
                  <CustomTextField
                    name="remarks"
                    value={billForm.remarks}
                    onChange={handleChange}
                    multiline
                    error={!!errors.remarks}
                    helperText={errors.remarks || ""}
                    className="w-full h-full"
                    InputProps={{
                      style: { height: "100%", overflowY: "auto" },
                    }}
                  />
                </div>
              </div>
            </div>
          </FormSection>
        </div>

        <FormFooter background="bg-white dark:bg-zinc-900 border-brand-surface-border dark:border-zinc-700">
          <AppButton type="secondary" onClick={handleResetForm} disabled={isSaving}>
            Reset
          </AppButton>
          <AppButton
            type="primary"
            onClick={handleOpenConfirm}
            disabled={isSaving}
            loading={isSaving}
          >
            {isSaving ? "Saving..." : "Save Bill"}
          </AppButton>
        </FormFooter>

        {/* Confirmation Modal*/}
        <ConfirmationModal
          isOpen={isConfirmOpen}
          onClose={() => setIsConfirmOpen(false)}
          onConfirm={saveBillEntry}
          title="Confirm Bill Submission"
          message="Please review all entries carefully. Do you want to submit this bill now?"
          confirmText="Submit"
          cancelText="Cancel"
          confirmButtonColor="blue"
          loading={isSaving}
        />

        {/* Add Item Modal*/}
        {isAddItemModalOpen && (
          <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
            <div
              className="bg-white w-full h-full md:h-auto md:max-h-[80vh] md:max-w-4xl md:rounded-lg relative overflow-y-auto"
            >

              <div className="flex items-center justify-between px-4 py-3 border-b border-gray-200 sticky top-0 bg-white z-10">

                <div className="flex items-center">

                  <IconButton
                    onClick={handleAddItemModalClose}
                    size="small"
                    className="mr-2 md:!hidden"
                  >
                    <ArrowBackIcon />
                  </IconButton>

                  <h2 className="text-base font-semibold text-gray-800">
                    {isEditing ? "Edit Bill Item" : "Add Bill Item"}
                  </h2>

                </div>

                <IconButton
                  onClick={handleAddItemModalClose}
                  size="small"
                  className="!hidden md:!flex"
                >
                  <CloseIcon />
                </IconButton>

              </div>

              {/* MODAL CONTENT*/}
              <div className={`p-4 space-y-4 ${FORM_SCROLL_AREA_CLASS}`}>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <FormSection title="Bill Details" icon={Receipt} variantIndex={0}>
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                      <CustomTextField
                        name="pieces"
                        value={billForm.pieces}
                        onChange={(e) => {
                          const val = e.target.value;
                          //(no letters, no decimal)
                          if (/^\d*$/.test(val)) {
                            handleChange({
                              target: { name: "pieces", value: val },
                            });
                          }
                        }}
                        label="Pieces *"
                        error={!!errors.pieces}
                        helperText={errors.pieces}
                      />
                      <CustomTextField
                        name="grossAmount"
                        value={billForm.grossAmount}
                        onChange={(e) => {
                          const val = e.target.value;
                          // Allow positive number with max 2 decimal
                          if (/^\d*\.?\d{0,2}$/.test(val)) {
                            handleChange({
                              target: { name: "grossAmount", value: val },
                            });
                          }
                        }}
                        label="Gross Amount *"
                        error={!!errors.grossAmount}
                        helperText={errors.grossAmount || ""}
                      />
                    </div>
                  </FormSection>

                  <FormSection title="Add Discount" icon={Percent} variantIndex={1}>
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                      <CustomTextField
                        name="discountPercent"
                        value={billForm.discountPercent}
                        onChange={(e) => {
                          const val = e.target.value;
                          //only numbers + decimal (max 2 digits)
                          if (/^\d*\.?\d{0,2}$/.test(val)) {
                            handleChange({
                              target: { name: "discountPercent", value: val },
                            });
                          }
                        }}
                        label="Discount %"
                        error={!!errors.discountPercent}
                        helperText={errors.discountPercent || ""}
                      />
                      <CustomTextField
                        name="discountAmount"
                        value={billForm.discountAmount}
                        onChange={handleChange}
                        label="Discount Amount"
                        InputProps={{ readOnly: true }}
                      />
                    </div>
                  </FormSection>

                  <FormSection title="Add On Charges" icon={CircleDollarSign} variantIndex={2}>
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                      <CustomTextField
                        name="addOnAmount"
                        value={billForm.addOnAmount}
                        onChange={(e) => {
                          const val = e.target.value;
                          if (/^\d*\.?\d{0,2}$/.test(val)) {
                            handleChange({
                              target: { name: "addOnAmount", value: val },
                            });
                          }
                        }}
                        label="Add-On Amount"
                        error={!!errors.addOnAmount}
                        helperText={errors.addOnAmount || ""}
                      />
                      <CustomTextField
                        name="ecrAmount"
                        value={billForm.ecrAmount}
                        onChange={(e) => {
                          const val = e.target.value;
                          if (/^\d*\.?\d{0,2}$/.test(val)) {
                            handleChange({
                              target: { name: "ecrAmount", value: val },
                            });
                          }
                        }}
                        label="ECR Amount"
                        error={!!errors.ecrAmount}
                        helperText={errors.ecrAmount || ""}
                      />
                    </div>
                  </FormSection>

                  <FormSection title="Add GST Details" icon={BadgePercent} variantIndex={3}>
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                      <CustomTextField
                        name="gstPercent"
                        value={billForm.gstPercent}
                        onChange={(e) => {
                          const val = e.target.value;
                          //only numbers + decimal (max 2 decimal places)
                          if (/^\d*\.?\d{0,2}$/.test(val)) {
                            handleChange({
                              target: { name: "gstPercent", value: val },
                            });
                          }
                        }}
                        label="GST %"
                        error={!!errors.gstPercent}
                        helperText={errors.gstPercent || ""}
                      />
                      <CustomTextField
                        name="gstAmount"
                        value={billForm.gstAmount}
                        onChange={handleChange}
                        label="GST Amount"
                        InputProps={{ readOnly: true }}
                      />
                    </div>
                  </FormSection>
                </div>

                <div className="mt-2 flex flex-col md:flex-row md:divide-x divide-brand-surface-border dark:divide-zinc-700/40 rounded-xl border border-brand-surface-border dark:border-zinc-700/40 bg-blue-50/70 dark:bg-blue-950/20 overflow-hidden">
                  <div className="flex flex-1 items-center gap-3 justify-center p-4">
                    <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-blue-100 dark:bg-blue-900/40">
                      <Calculator className="h-5 w-5 text-blue-600 dark:text-blue-400" />
                    </div>
                    <div className="text-left">
                      <p className="text-sm text-brand-search-muted dark:text-gray-400">Taxable Value</p>
                      <p className="md:text-lg font-semibold text-blue-600 dark:text-blue-400 mt-0.5">
                        {formatIndianCurrency(roundUp(billForm.taxableValue))}
                      </p>
                    </div>
                  </div>
                  <div className="flex flex-1 items-center gap-3 justify-center p-4 border-t md:border-t-0 border-brand-surface-border dark:border-zinc-700/40">
                    <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-green-100 dark:bg-green-900/40">
                      <Percent className="h-5 w-5 text-green-600 dark:text-green-400" />
                    </div>
                    <div className="text-left">
                      <p className="text-sm text-brand-search-muted dark:text-gray-400">GST Amount</p>
                      <p className="md:text-lg font-semibold text-green-600 dark:text-green-400 mt-0.5">
                        {formatIndianCurrency(roundUp(billForm.gstAmount))}
                      </p>
                    </div>
                  </div>
                  <div className="flex flex-1 items-center gap-3 justify-center p-4 border-t md:border-t-0 border-brand-surface-border dark:border-zinc-700/40">
                    <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-violet-100 dark:bg-violet-900/40">
                      <Receipt className="h-5 w-5 text-violet-600 dark:text-violet-400" />
                    </div>
                    <div className="text-left">
                      <p className="text-sm text-brand-search-muted dark:text-gray-400">Bill Amount</p>
                      <p className="md:text-xl font-semibold text-violet-600 dark:text-violet-400 mt-0.5">
                        {formatIndianCurrency(roundUp(billForm.billAmount))}
                      </p>
                    </div>
                  </div>
                </div>

                <div className="flex justify-end mt-2 gap-3">
                  {!isEditing ? (
                    <AppButton type="secondary" onClick={handleResetBillDetail}>
                      Reset
                    </AppButton>
                  ) : null}
                  <AppButton
                    type="primary"
                    onClick={() => {
                      handleSaveItem();
                    }}
                  >
                    {isEditing ? "Update Item" : "Save Item"}
                  </AppButton>
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
                <h3 className="text-lg font-semibold text-gray-800">
                  Delete Item?
                </h3>
              </div>

              <p className="text-gray-600 text-sm mb-6">
                Are you sure you want to delete this bill item? This action
                cannot be undone.
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

        <ImagePreviewDialog
          open={previewIndex !== null}
          images={billDocuments.map((file) =>
            file instanceof File
              ? URL.createObjectURL(file)
              : file.url
          )}
          files={billDocuments}
          index={previewIndex || 0}
          onChangeIndex={setPreviewIndex}
          onClose={() => setPreviewIndex(null)}
        />

        <UploadDialog
          open={isUploadOpen}
          onClose={() => {
            setIsUploadOpen(false);
            setTempDocuments([]);
          }}
          files={tempDocuments}
          setFiles={(files) => {
            setUserTouched(true);
            setTempDocuments(files);
          }}
          onSave={() => {
            setBillDocuments(tempDocuments);
            setIsUploadOpen(false);
          }}
          title="Upload Bill Documents"
          maxFiles={3}
          onError={(msg) => showSnackbar(msg, "error")}
        />
      </div>
    </div>
  );
};

export default BillEntry;
