import { useEffect, useState } from "react";
import CustomTextField from "../components/CustomTextField";
import Autocomplete from "@mui/material/Autocomplete";
import { LocalizationProvider } from "@mui/x-date-pickers/LocalizationProvider";
import { AdapterDayjs } from "@mui/x-date-pickers/AdapterDayjs";
import { DatePicker } from "@mui/x-date-pickers/DatePicker";
import dayjs from "dayjs";
import { useSnackbar } from "../context/SnackbarContext";
import SupplierService from "../service/SupplierService";
import CustomerService from "../service/CustomerService";
import { getAllActiveStaffs } from "../service/StaffService";
import { updatePurchaseApi } from "../service/purchaseService";

const EditPurchaseDetail = ({
    open,
    selectedPurchaseDetail,
    setOpen,
    onUpdateSuccess,
}) => {
    const { showSnackbar } = useSnackbar();

    const [allSuppliers, setAllSuppliers] = useState([]);
    const [allCustomers, setAllCustomers] = useState([]);
    const [allStaffs, setAllStaffs] = useState([]);

    const [selectedSupplier, setSelectedSupplier] = useState(null);
    const [selectedCustomers, setSelectedCustomers] = useState([]);
    const [selectedStaff, setSelectedStaff] = useState(null);

    const [formData, setFormData] = useState({
        date: "",
        purchaseAmount: "",
    });

    const [saving, setSaving] = useState(false);

    /* ================= LOAD MASTER DATA ================= */
    useEffect(() => {
        Promise.all([
            SupplierService.getAllSuppliers(),
            CustomerService.getAllCustomers(),
            getAllActiveStaffs(),
        ]).then(([suppliers, customers, staffs]) => {
            setAllSuppliers(suppliers || []);
            setAllCustomers(customers || []);
            setAllStaffs(staffs || []);
        });
    }, []);

    /* ================= PREFILL DATA ================= */
    useEffect(() => {
        if (!selectedPurchaseDetail) return;

        setFormData({
            date: selectedPurchaseDetail.date || "",
            purchaseAmount:
                selectedPurchaseDetail.purchaseAmount != null
                    ? String(selectedPurchaseDetail.purchaseAmount)
                    : "",
        });

        if (allSuppliers.length > 0) {
            setSelectedSupplier(
                allSuppliers.find(
                    s => s.id === Number(selectedPurchaseDetail.supplierId)
                ) || null
            );
        }

        if (allCustomers.length > 0) {
            const selected = allCustomers.filter(c =>
                selectedPurchaseDetail.customerIds?.includes(c.id)
            );
            setSelectedCustomers(selected);
        }


        if (allStaffs.length > 0) {
            setSelectedStaff(
                allStaffs.find(
                    s => s.staffId === Number(selectedPurchaseDetail.staffId)
                ) || null
            );
        }
    }, [selectedPurchaseDetail, allSuppliers, allCustomers, allStaffs]);

    if (!open) return null;

    const handleAmountChange = (e) => {
        const value = e.target.value;

        // only numbers + max 2 decimals
        if (/^\d*\.?\d{0,2}$/.test(value)) {
            setFormData(p => ({ ...p, purchaseAmount: value }));
            setErrors(p => ({ ...p, purchaseAmount: "" }));
        }
    };
    /* ================= UPDATE ================= */
    const handleUpdate = async () => {

        try {
            setSaving(true);

            const payload = {
                date: formData.date || null,
                staffId: selectedStaff?.staffId || null,
                supplierId: selectedSupplier?.id || null,
                customerIds: selectedCustomers.map(c => c.id),
                purchaseAmount: Number(formData.purchaseAmount),
            };

            await updatePurchaseApi(selectedPurchaseDetail.id, payload);

            showSnackbar("Purchase updated successfully", "success");
            onUpdateSuccess();
        } catch (err) {
            showSnackbar(err.message || "Failed to update purchase", "error");
        } finally {
            setSaving(false);
        }
    };

    /* ================= UI ================= */
    return (
        <div className="fixed inset-0 bg-black bg-opacity-40 flex items-center justify-center z-50">
            <div
                className="
        bg-white flex flex-col
        w-full h-full sm:h-auto
        sm:max-w-2xl sm:max-h-[90vh]
        sm:rounded-xl shadow-xl
      "
            >
                {/* Header */}
                <div className="px-4 sm:px-6 py-4 border-b">
                    <h2 className="text-lg sm:text-xl font-semibold">Edit Purchase</h2>
                </div>

                {/* Body */}
                <div className="flex-1 overflow-y-auto px-4 sm:px-6 py-4 space-y-4">

                    {/* BASIC INFO */}
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                        <CustomTextField
                            label="Purchase ID"
                            value={selectedPurchaseDetail.id}
                            disabled
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
                                onChange={(v) =>
                                    setFormData(p => ({
                                        ...p,
                                        date: v ? dayjs(v).format("YYYY-MM-DD") : "",
                                    }))
                                }
                                slotProps={{
                                    textField: { size: "small", fullWidth: true },
                                }}
                            />
                        </LocalizationProvider>
                    </div>

                    {/* STAFF + AMOUNT */}
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                        <Autocomplete
                            options={allStaffs}
                            value={selectedStaff}
                            isOptionEqualToValue={(o, v) => o.staffId === v?.staffId}
                            getOptionLabel={(o) => o?.staffName || ""}
                            onChange={(e, v) => setSelectedStaff(v)}
                            renderInput={(p) => (
                                <CustomTextField {...p} label="Staff" />
                            )}
                        />

                        <CustomTextField
                            label="Purchase Amount"
                            value={formData.purchaseAmount}
                            onChange={handleAmountChange}
                        />
                    </div>

                    {/* SUPPLIER + CUSTOMER */}
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                        <Autocomplete
                            options={allSuppliers}
                            value={selectedSupplier}
                            isOptionEqualToValue={(o, v) => o.id === v?.id}
                            getOptionLabel={(o) => o?.supplierName || ""}
                            onChange={(e, v) => setSelectedSupplier(v)}
                            renderInput={(p) => (
                                <CustomTextField {...p} label="Supplier" />
                            )}
                        />
                        <Autocomplete
                            multiple
                            options={allCustomers}
                            value={selectedCustomers}
                            isOptionEqualToValue={(o, v) => o.id === v.id}
                            getOptionLabel={(o) => o?.customerName || ""}
                            onChange={(e, values) => setSelectedCustomers(values)}
                            renderInput={(p) => (
                                <CustomTextField {...p} label="Customer(s)" />
                            )}
                        />

                    </div>
                </div>
                {/* Footer */}
                <div className="px-4 sm:px-6 py-4 border-t flex flex-col sm:flex-row gap-3 sm:justify-end">
                    <button
                        onClick={() => setOpen(false)}
                        className="px-4 py-2 border rounded-lg"
                    >
                        Cancel
                    </button>
                    <button
                        onClick={handleUpdate}
                        disabled={saving}
                        className="w-full sm:w-auto px-4 py-2 rounded-lg bg-blue-600 text-white"
                    >
                        {saving ? "Saving..." : "Update"}
                    </button>
                </div>
            </div>
        </div>
    );
};

export default EditPurchaseDetail;
