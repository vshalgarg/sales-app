import { useEffect, useState } from "react";
import CustomTextField from "../components/CustomTextField";
import Autocomplete from "@mui/material/Autocomplete";
import { useSnackbar } from "../context/SnackbarContext";
import { updateCreditApi } from "../service/CreditService";
import SupplierService from "../service/SupplierService";
import CustomerService from "../service/CustomerService";
import dayjs from "dayjs";
import { LocalizationProvider } from "@mui/x-date-pickers/LocalizationProvider";
import { AdapterDayjs } from "@mui/x-date-pickers/AdapterDayjs";
import { DatePicker } from "@mui/x-date-pickers/DatePicker";
import MenuItem from "@mui/material/MenuItem";
import ArrowBackIcon from "@mui/icons-material/ArrowBack";
import { IconButton } from "@mui/material";


const PAYMENT_TYPES = [
  "CASH",
  "UPI",
  "NEFT_RTGS",
  "CHEQUE",
];

const DRAW_TYPES = [
  "DRAW",
  "CHEQUE",
];


const EditCreditDetail = ({
  open,
  selectedCreditDetail,
  setOpen,
  onUpdateSuccess,
}) => {
  const { showSnackbar } = useSnackbar();

  const [allSuppliers, setAllSuppliers] = useState([]);
  const [allCustomers, setAllCustomers] = useState([]);

  const [selectedSupplier, setSelectedSupplier] = useState(null);
  const [selectedCustomer, setSelectedCustomer] = useState(null);

  const [formData, setFormData] = useState({
    paymentType: "",
    referenceNumber: "",
    referenceDate: null,
    slipNumber: "",
    drawType: "",
    receivedAmount: "",
    remark: "",
  });

  const [saving, setSaving] = useState(false);

  /* ================= LOAD MASTER DATA ================= */
  useEffect(() => {
    Promise.all([
      SupplierService.getAllSuppliers(),
      CustomerService.getAllCustomers(),
    ]).then(([suppliers, customers]) => {
      setAllSuppliers(suppliers || []);
      setAllCustomers(customers || []);
    });
  }, []);

  /* ================= PREFILL DATA ================= */
  useEffect(() => {
    if (!selectedCreditDetail) return;
    setFormData({
      paymentType: selectedCreditDetail.paymentType || "",
      referenceNumber: selectedCreditDetail.referenceNumber || "",
      referenceDate: selectedCreditDetail.referenceDate
        ? dayjs(selectedCreditDetail.referenceDate)
        : null,
      slipNumber: selectedCreditDetail.slipNumber || "",
      drawType: selectedCreditDetail.drawType || "",
      receivedAmount: selectedCreditDetail.receivedAmount || "",
      remark: selectedCreditDetail.remark || "",
    });

    if (allSuppliers.length > 0) {
      setSelectedSupplier(
        allSuppliers.find(
          s => s.id === Number(selectedCreditDetail.supplierId)
        ) || null
      );
    }

    if (allCustomers.length > 0) {
      setSelectedCustomer(
        allCustomers.find(
          c => c.id === Number(selectedCreditDetail.customerId)
        ) || null
      );
    }

  }, [selectedCreditDetail, allSuppliers, allCustomers]);


  if (!open) return null;

  /* ================= RECEIVED AMOUNT VALIDATION ================= */
  const handleReceivedAmountChange = (e) => {
    const value = e.target.value;

    // only numbers + max 2 decimals
    if (/^\d*\.?\d{0,2}$/.test(value)) {
      setFormData(p => ({ ...p, receivedAmount: value }));
      setErrors(p => ({ ...p, receivedAmount: "" }));
    }
  };

  const handleSlipNumberChange = (e) => {
    const value = e.target.value;

    // letters + numbers only
    if (/^[a-zA-Z0-9]*$/.test(value)) {
      setFormData(p => ({ ...p, slipNumber: value }));
      setErrors(p => ({ ...p, slipNumber: "" }));
    } else {
      setErrors(p => ({
        ...p,
        slipNumber: "Only letters and numbers are allowed",
      }));
    }
  };

  /* ================= HANDLERS ================= */
  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  const handleUpdate = async () => {

    try {
      setSaving(true);

      const payload = {
        supplierId: selectedSupplier?.id || null,
        customerId: selectedCustomer?.id || null,
        paymentType: formData.paymentType,
        referenceNumber: formData.referenceNumber || null,
        referenceDate: formData.referenceDate
          ? dayjs(formData.referenceDate).format("YYYY-MM-DD")
          : null,

        slipNumber: formData.slipNumber || null,
        drawType: formData.drawType || null,
        receivedAmount: Number(formData.receivedAmount),
        remark: formData.remark || null,
      };

      await updateCreditApi(selectedCreditDetail.id, payload);

      showSnackbar("Credit updated successfully", "success");
      onUpdateSuccess();
    } catch (err) {
      showSnackbar(err.message || "Failed to update credit", "error");
    } finally {
      setSaving(false);
    }
  };

  /* ================= UI ================= */
  return (
    <div className="fixed inset-0 bg-black bg-opacity-40 flex items-center justify-center z-50">
      <div
        className="
        bg-white flex flex-col w-full
        h-full sm:h-auto
        sm:max-w-3xl sm:max-h-[90vh]
        sm:rounded-xl
      "
      >
        {/* Header */}
        <div className="px-4 sm:px-6 py-4 border-b flex items-center gap-3">

          <IconButton
            onClick={() => setOpen(false)}
            className="md:hidden"
          >
            <ArrowBackIcon />
          </IconButton>

          <h2 className="text-lg sm:text-xl font-semibold">
            Edit Credit
          </h2>
        </div>

        {/* Body */}
        <div className="flex-1 overflow-y-auto px-4 sm:px-6 py-4 space-y-6">

          {/* ===== BASIC INFO ===== */}
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <CustomTextField
              label="Bill Number"
              value={selectedCreditDetail.billNumber}
              disabled
            />
            <CustomTextField
              label="Date"
              value={dayjs(selectedCreditDetail.date).format("DD-MM-YYYY")}
              InputProps={{ readOnly: true }}
            />
            <CustomTextField
              select
              label="Payment Type"
              name="paymentType"
              value={formData.paymentType}
              onChange={handleChange}
            >
              {PAYMENT_TYPES.map(type => (
                <MenuItem key={type} value={type}>{type}</MenuItem>
              ))}
            </CustomTextField>
          </div>

          {/* ===== PARTY INFO ===== */}
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <Autocomplete
              options={allSuppliers}
              value={selectedSupplier}
              isOptionEqualToValue={(o, v) => o.id === v?.id}
              getOptionLabel={(o) =>
                o?.supplierName ? `${o.supplierName} - ${o.city || ""}` : ""
              }
              onChange={(e, v) => setSelectedSupplier(v)}
              renderInput={(params) => (
                <CustomTextField {...params} label="Supplier" />
              )}
            />

            <Autocomplete
              options={allCustomers}
              value={selectedCustomer}
              isOptionEqualToValue={(o, v) => o.id === v?.id}
              getOptionLabel={(o) =>
                o?.customerName ? `${o.customerName} - ${o.city || ""}` : ""
              }
              onChange={(e, v) => setSelectedCustomer(v)}
              renderInput={(params) => (
                <CustomTextField {...params} label="Customer" />
              )}
            />
          </div>

          {/* ===== TRANSACTION DETAILS ===== */}
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <CustomTextField
              label="Reference Number"
              name="referenceNumber"
              value={formData.referenceNumber}
              onChange={handleChange}
            />

            <LocalizationProvider dateAdapter={AdapterDayjs}>
              <DatePicker
                label="Reference Date"
                value={formData.referenceDate}
                onChange={(newValue) =>
                  setFormData(prev => ({ ...prev, referenceDate: newValue }))
                }
                slotProps={{
                  textField: {
                    fullWidth: true,
                    size: "small",
                  },
                }}
              />
            </LocalizationProvider>

            <CustomTextField
              label="Slip Number"
              name="slipNumber"
              value={formData.slipNumber}
              onChange={handleSlipNumberChange}
            />
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <CustomTextField
              select
              label="Draw Type"
              name="drawType"
              value={formData.drawType}
              onChange={handleChange}
            >
              {DRAW_TYPES.map(type => (
                <MenuItem key={type} value={type}>{type}</MenuItem>
              ))}
            </CustomTextField>

            <CustomTextField
              label="Received Amount"
              name="receivedAmount"
              value={formData.receivedAmount}
              onChange={handleReceivedAmountChange}
            />
          </div>

          <CustomTextField
            label="Remark"
            name="remark"
            value={formData.remark}
            onChange={handleChange}
            multiline
            rows={3}
          />
        </div>

        {/* Footer */}
        <div className="px-4 sm:px-6 py-4 border-t flex flex-col sm:flex-row justify-end gap-3">
          <button
            onClick={() => setOpen(false)}
            disabled={saving}
            className="w-full sm:w-auto px-4 py-2 border rounded-lg"
          >
            Cancel
          </button>
          <button
            onClick={handleUpdate}
            disabled={saving}
            className={`w-full sm:w-auto px-4 py-2 rounded-lg text-white
            ${saving ? "bg-gray-400" : "bg-blue-600 hover:bg-blue-700"}`}
          >
            {saving ? "Saving..." : "Update"}
          </button>
        </div>
      </div>
    </div>
  );

};

export default EditCreditDetail;
