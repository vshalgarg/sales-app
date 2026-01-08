import CustomTextField from "../components/CustomTextField";
import { useState, useEffect, useRef } from "react";
import { useBillForm } from "../customHooks/useBillForm";
import { LocalizationProvider } from "@mui/x-date-pickers/LocalizationProvider";
import { DatePicker } from "@mui/x-date-pickers/DatePicker";
import { AdapterDayjs } from "@mui/x-date-pickers/AdapterDayjs";
import dayjs from "dayjs";
import validate from "../validations/Validation";
import { useSnackbar } from "../context/SnackbarContext";
import { updateBillApi, searchTransports } from "../service/BillService";
import { Trash2 } from "lucide-react";
import SupplierService from "../service/SupplierService";
import CustomerService from "../service/CustomerService";
import TransportService from "../service/TransportService";
import Autocomplete from "@mui/material/Autocomplete";

const EditBillDetail = ({ open, selectedBillDetail, setOpen, onUpdateSuccess }) => {
  const { showSnackbar } = useSnackbar();
  const [showConfirmPopup, setShowConfirmPopup] = useState(false);
  const [pendingTransportName, setPendingTransportName] = useState("");
  // ===== OPTIONS =====
  const [allSuppliers, setAllSuppliers] = useState([]);
  const [allCustomers, setAllCustomers] = useState([]);
  const [allTransports, setAllTransports] = useState([]);

  // ===== SELECTED =====
  const [selectedSupplier, setSelectedSupplier] = useState(null);
  const [selectedCustomer, setSelectedCustomer] = useState(null);
  const [selectedTransport, setSelectedTransport] = useState(null);

  // ===== LOADING =====
  const [loading, setLoading] = useState({
    supplier: false,
    customer: false,
    transport: false,
  });


  const {
    formData,
    setFormData,
    errors,
    setErrors,
    searchRef,
    custSearchRef,
    transportSearchRef,
  } = useBillForm();

  const [items, setItems] = useState([]);


  useEffect(() => {
    const loadMasterData = async () => {
      try {
        setLoading({ supplier: true, customer: true, transport: true });

        const [suppliers, customers, transports] = await Promise.all([
          SupplierService.getAllSuppliers(),
          CustomerService.getAllCustomers(),
          TransportService.getAllTransports(),
        ]);

        setAllSuppliers(suppliers || []);
        setAllCustomers(customers || []);
        setAllTransports(transports || []);

      } catch (e) {
        showSnackbar("Failed to load master data", "error");
      } finally {
        setLoading({ supplier: false, customer: false, transport: false });
      }
    };

    loadMasterData();
  }, []);

  useEffect(() => {
    if (!selectedBillDetail) return;

    setSelectedSupplier(
      allSuppliers.find(s => s.id === selectedBillDetail.supplierId) || null
    );

    setSelectedCustomer(
      allCustomers.find(c => c.id === selectedBillDetail.customerId) || null
    );

    setSelectedTransport(
      allTransports.find(t => t.name === selectedBillDetail.transport) || null
    );

  }, [selectedBillDetail, allSuppliers, allCustomers, allTransports]);


  // Load data when modal opens
  useEffect(() => {
    if (selectedBillDetail) {
      setFormData((prev) => ({
        ...prev,
        ...selectedBillDetail,
        taxableValue: selectedBillDetail.taxableValue?.toFixed(2) || "0.00",
        billAmount: selectedBillDetail.billAmount?.toFixed(2) || "0.00",
      }));

      if (selectedBillDetail.items && selectedBillDetail.items.length > 0) {
        setItems(
          selectedBillDetail.items.map(item => ({
            pieces: item.pieces,
            grossAmount: item.grossAmount.toFixed(2),
            discountPercent: item.discountPercent,
            discountAmount: item.discountAmount.toFixed(2),
            addOnAmount: item.addOnAmount.toFixed(2),
            ecrAmount: item.ecrAmount.toFixed(2),
            gstPercent: item.gstPercent,
            gstAmount: item.gstAmount.toFixed(2),
          }))
        );
      } else {
        setItems([]);
      }
    }
  }, [selectedBillDetail, setFormData]);

  // Recalculate totals live
  useEffect(() => {
    let totalTaxable = 0;
    let totalBill = 0;

    items.forEach((item) => {
      const gross = parseFloat(item.grossAmount) || 0;
      const discAmt = parseFloat(item.discountAmount) || 0;
      const addOn = parseFloat(item.addOnAmount) || 0;
      const ecr = parseFloat(item.ecrAmount) || 0;
      const gstPercent = parseFloat(item.gstPercent) || 0;

      const taxable = gross - discAmt + addOn + ecr;
      const gst = taxable * gstPercent / 100;

      totalTaxable += taxable;
      totalBill += taxable + gst;
    });

    setFormData((prev) => ({
      ...prev,
      taxableValue: totalTaxable.toFixed(2),
      billAmount: totalBill.toFixed(2),
    }));
  }, [items, setFormData]);


  // Handle inline editing of any item field
  const handleItemChange = (index, field, value) => {
    const updated = [...items];
    updated[index][field] = value;

    const item = updated[index];
    const gross = parseFloat(item.grossAmount) || 0;
    const discPercent = parseFloat(item.discountPercent) || 0;

    // Auto calculate discount amount
    item.discountAmount = (gross * discPercent / 100).toFixed(2);

    // Auto calculate GST amount
    const taxable = gross - parseFloat(item.discountAmount) + (parseFloat(item.addOnAmount) || 0) + (parseFloat(item.ecrAmount) || 0);
    const gstPercent = parseFloat(item.gstPercent) || 0;
    item.gstAmount = (taxable * gstPercent / 100).toFixed(2);

    setItems(updated);
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  const handleUpdate = async () => {
    if (items.length === 0) {
      showSnackbar("At least one item is required", "error");
      return;
    }
    await saveBill();

  };

  const saveBill = async () => {
    const payload = {
      date: formData.date || null,
      receivedDate: formData.receivedDate || null,
      order: formData.order || null,
      supplierId: formData.supplierId ? parseInt(formData.supplierId) : null,
      customerId: formData.customerId ? parseInt(formData.customerId) : null,
      transport: formData.transport || null,
      lrNumber: formData.lrNumber || null,
      remarks: formData.remarks || null,
      taxableValue: Math.round((parseFloat(formData.taxableValue) || 0)),
      billAmount: Math.round((parseFloat(formData.billAmount) || 0)),
      billItems: items.map(item => ({
        pieces: parseInt(item.pieces) || 0,
        grossAmount: Math.round(parseFloat(item.grossAmount || 0)),
        discountPercent: parseFloat(item.discountPercent || 0),
        discountAmount: Math.round(parseFloat(item.discountAmount || 0)),
        addOnAmount: Math.round(parseFloat(item.addOnAmount || 0)),
        ecrAmount: Math.round(parseFloat(item.ecrAmount || 0)),
        gstPercent: parseFloat(item.gstPercent || 0),
        gstAmount: Math.round(parseFloat(item.gstAmount || 0)),
      }))
    };

    try {
      const response = await updateBillApi(formData.billNumber, payload);
      showSnackbar(response?.message || "Bill updated successfully!", "success");
      setOpen(false);
      if (onUpdateSuccess) {
        onUpdateSuccess();
      }
    } catch (err) {
      console.error(err);
      showSnackbar("Failed to update bill", "error");
    }
  };

  if (!open) return null;

  return (
    <div className="fixed inset-0 flex items-center justify-center bg-black bg-opacity-80 z-50">
      <div className="bg-white w-full max-w-6xl max-h-[90vh] rounded-lg shadow-lg flex flex-col">
        <div className="p-6 border-b">
          <h2 className="text-2xl font-semibold">Edit Bill Details</h2>
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
                format="DD-MM-YYYY"
                value={
                  formData.receivedDate
                    ? dayjs(formData.receivedDate, "YYYY-MM-DD")
                    : null
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
              <Autocomplete
                options={allSuppliers}
                value={selectedSupplier}
                loading={loading.supplier}
                isOptionEqualToValue={(o, v) => o.id === v?.id}
                getOptionLabel={(o) =>
                  o?.supplierName ? `${o.supplierName} - ${o.city || ""}` : ""
                }
                onChange={(e, value) => {
                  setSelectedSupplier(value);
                  setFormData(prev => ({
                    ...prev,
                    supplierId: value ? value.id : null
                  }));
                  setErrors(prev => ({ ...prev, supplierName: "" }));
                }}
                renderInput={(params) => (
                  <CustomTextField
                    {...params}
                    label="Supplier"
                    error={!!errors.supplierName}
                    helperText={errors.supplierName || ""}
                  />
                )}
              />
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
              <Autocomplete
                options={allCustomers}
                value={selectedCustomer}
                loading={loading.customer}
                isOptionEqualToValue={(o, v) => o.id === v?.id}
                getOptionLabel={(o) =>
                  o?.customerName ? `${o.customerName} - ${o.city || ""}` : ""
                }
                onChange={(e, value) => {
                  setSelectedCustomer(value);
                  setFormData(prev => ({
                    ...prev,
                    customerId: value ? value.id : null
                  }));
                  setErrors(prev => ({ ...prev, customerName: "" }));
                }}
                renderInput={(params) => (
                  <CustomTextField
                    {...params}
                    label="Customer"
                    error={!!errors.customerName}
                    helperText={errors.customerName || ""}
                  />
                )}
              />
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

          {/* DYNAMIC EDITABLE ITEMS TABLE WITH ADD/DELETE */}
          <div className="border p-6 rounded-lg border-gray-300 bg-gray-50">
            <div className="flex justify-between items-center mb-6">
              <h3 className="text-xl font-bold text-blue-700">Bill Items</h3>
              <button
                onClick={() => {
                  setItems([...items, {
                    pieces: "",
                    grossAmount: "",
                    discountPercent: "",
                    discountAmount: "0.00",
                    addOnAmount: "",
                    ecrAmount: "",
                    gstPercent: "",
                    gstAmount: "0.00",
                  }]);
                }}
                className="px-4 py-2 bg-green-600 text-white rounded hover:bg-green-700 flex items-center gap-2"
              >
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
                </svg>
                Add Bill Item
              </button>
            </div>

            <div className="overflow-x-auto">
              <table className="min-w-full border border-gray-300">
                <thead className="bg-blue-100">
                  <tr>
                    <th className="px-4 py-2 text-left">Pieces</th>
                    <th className="px-4 py-2 text-left">Gross</th>
                    <th className="px-4 py-2 text-left">Disc %</th>
                    <th className="px-4 py-2 text-left">Disc Amt</th>
                    <th className="px-4 py-2 text-left">Add-On</th>
                    <th className="px-4 py-2 text-left">ECR</th>
                    <th className="px-4 py-2 text-left">GST %</th>
                    <th className="px-4 py-2 text-left">GST Amt</th>
                    <th className="px-4 py-2 text-left">Action</th>
                  </tr>
                </thead>
                <tbody>
                  {items.length === 0 ? (
                    <tr>
                      <td colSpan="9" className="text-center py-8 text-gray-500">
                        No items added yet. Click "Add Row" to start.
                      </td>
                    </tr>
                  ) : (
                    items.map((item, index) => (
                      <tr key={index} className="border-t hover:bg-gray-100">
                        <td className="px-4 py-2">
                          <input
                            type="number"
                            value={item.pieces || ""}
                            onChange={(e) => handleItemChange(index, "pieces", e.target.value)}
                            className="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
                            placeholder="0"
                          />
                        </td>
                        <td className="px-4 py-2">
                          <input
                            type="number"
                            value={item.grossAmount || ""}
                            onChange={(e) => handleItemChange(index, "grossAmount", e.target.value)}
                            className="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
                            placeholder="0.00"
                          />
                        </td>
                        <td className="px-4 py-2">
                          <input
                            type="number"
                            value={item.discountPercent || ""}
                            onChange={(e) => handleItemChange(index, "discountPercent", e.target.value)}
                            className="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
                            placeholder="0"
                          />
                        </td>
                        <td className="px-4 py-2">
                          <input
                            type="text"
                            value={item.discountAmount || "0.00"}
                            readOnly
                            className="w-full px-3 py-2 bg-gray-200 border rounded"
                          />
                        </td>
                        <td className="px-4 py-2">
                          <input
                            type="number"
                            value={item.addOnAmount || ""}
                            onChange={(e) => handleItemChange(index, "addOnAmount", e.target.value)}
                            className="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
                            placeholder="0.00"
                          />
                        </td>
                        <td className="px-4 py-2">
                          <input
                            type="number"
                            value={item.ecrAmount || ""}
                            onChange={(e) => handleItemChange(index, "ecrAmount", e.target.value)}
                            className="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
                            placeholder="0.00"
                          />
                        </td>
                        <td className="px-4 py-2">
                          <input
                            type="number"
                            value={item.gstPercent || ""}
                            onChange={(e) => handleItemChange(index, "gstPercent", e.target.value)}
                            className="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
                            placeholder="0"
                          />
                        </td>
                        <td className="px-4 py-2">
                          <input
                            type="text"
                            value={item.gstAmount || "0.00"}
                            readOnly
                            className="w-full px-3 py-2 bg-gray-200 border rounded"
                          />
                        </td>
                        <td className="px-4 py-2 text-center">
                          <button
                            onClick={() => {
                              if (items.length > 1) {
                                setItems(items.filter((_, i) => i !== index));
                              } else {
                                showSnackbar("At least one item is required", "warning");
                              }
                            }}
                            className="text-red-600 hover:text-red-800"
                            title="Delete row"
                          >
                            <Trash2 className="w-5 h-5" />
                          </button>
                        </td>
                      </tr>
                    ))
                  )}
                </tbody>
              </table>
            </div>

            {/* Final Totals */}
            <div className="mt-8 grid grid-cols-2 gap-8 text-lg font-bold">
              <div className="text-right">
                <span className="text-gray-600">Taxable Value:</span> ₹{formData.taxableValue || "0.00"}
              </div>
              <div className="text-right text-blue-700">
                <span className="text-gray-600">Bill Amount:</span> ₹{formData.billAmount || "0.00"}
              </div>
            </div>
          </div>

          {/* --- Section: Transport --- */}
          <h3 className="text-lg font-semibold mb-3">
            Transport & Logistics Information
          </h3>
          <div className="grid grid-cols-2 gap-4">
            <div ref={transportSearchRef} className="relative w-full">
              <Autocomplete
                options={allTransports}
                value={selectedTransport}
                loading={loading.transport}
                isOptionEqualToValue={(o, v) => o.id === v?.id}
                getOptionLabel={(o) => o?.name || ""}
                renderOption={(props, option) => (
                  <li {...props} key={option.id}>
                    {option.name} – {option.city}
                  </li>
                )}
                onChange={(e, value) => {
                  setSelectedTransport(value);
                  setFormData(prev => ({
                    ...prev,
                    transport: value ? value.name : null
                  }));
                  setErrors(prev => ({ ...prev, transport: "" }));
                }}
                renderInput={(params) => (
                  <CustomTextField
                    {...params}
                    label="Transport"
                    placeholder="Select transport"
                    error={!!errors.transport}
                    helperText={errors.transport || ""}
                  />
                )}
              />
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
            onClick={handleUpdate}
            className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
          >
            Save Changes
          </button>
        </div>

        {/* Simple Custom Confirmation Popup */}
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
                    saveBill();
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

export default EditBillDetail;