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
    const [selectedCustomer, setSelectedCustomer] = useState(null);
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
            setSelectedCustomer(
                allCustomers.find(
                    c => c.id === Number(selectedPurchaseDetail.customerId)
                ) || null
            );
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
        if (!formData.purchaseAmount || Number(formData.purchaseAmount) <= 0) {
            showSnackbar("Purchase amount must be greater than 0", "error");
            return;
        }

        try {
            setSaving(true);

            const payload = {
                date: formData.date || null,
                staffId: selectedStaff?.staffId || null,
                supplierId: selectedSupplier?.id || null,
                customerId: selectedCustomer?.id || null,
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
            <div className="bg-white rounded-xl shadow-xl w-full max-w-2xl p-6">
                <h2 className="text-lg font-semibold mb-4">Edit Purchase</h2>

                {/* BASIC INFO */}
                <div className="grid grid-cols-2 gap-4 mb-4">
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
                <div className="grid grid-cols-2 gap-4 mb-4">
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
                <div className="grid grid-cols-2 gap-4 mb-4">
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
                        options={allCustomers}
                        value={selectedCustomer}
                        isOptionEqualToValue={(o, v) => o.id === v?.id}
                        getOptionLabel={(o) => o?.customerName || ""}
                        onChange={(e, v) => setSelectedCustomer(v)}
                        renderInput={(p) => (
                            <CustomTextField {...p} label="Customer" />
                        )}
                    />
                </div>

                {/* ACTIONS */}
                <div className="flex justify-end gap-3 mt-6">
                    <button
                        onClick={() => setOpen(false)}
                        className="px-4 py-2 border rounded-lg"
                    >
                        Cancel
                    </button>
                    <button
                        onClick={handleUpdate}
                        disabled={saving}
                        className="px-4 py-2 rounded-lg bg-blue-600 text-white"
                    >
                        {saving ? "Saving..." : "Update"}
                    </button>
                </div>
            </div>
        </div>
    );
};

export default EditPurchaseDetail;
