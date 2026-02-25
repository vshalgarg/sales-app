import {
    Button,
    IconButton,
    CircularProgress,
} from "@mui/material";
import DeleteOutlineIcon from "@mui/icons-material/DeleteOutline";
import AddIcon from "@mui/icons-material/Add";
import Autocomplete from "@mui/material/Autocomplete";
import Chip from "@mui/material/Chip";
import { useEffect, useState } from "react";
import BasicSelect from "../components/BasicSelect";
import CustomTextField from "../components/CustomTextField";
import SupplierService from "../service/SupplierService";
import TransportService from "../service/TransportService";
import { useSnackbar } from "../context/SnackbarContext";
import validate from "../validations/Validation";
import { sanitizePayload } from "../utils/sanitizePayload";
import StateAutocomplete from "../components/common/StateAutocomplete";


const UpdateSupplierModal = ({
    supplierId,
    open,
    setOpen,
    fetchSuppliers,
}) => {

    const { showSnackbar } = useSnackbar();

    const [form, setForm] = useState({});
    const [errors, setErrors] = useState({ contacts: [{}] });
    const [allTransports, setAllTransports] = useState([]);
    const [selectedTransports, setSelectedTransports] = useState([]);
    const [loading, setLoading] = useState(false);
    const [isSaving, setIsSaving] = useState(false);

    /* ---------------- FETCH SUPPLIER ---------------- */

    useEffect(() => {
        if (!supplierId || !open) return;

        const fetchSupplier = async () => {
            try {
                setLoading(true);

                const response = await SupplierService.getSupplierById(supplierId);
                const data = response.data || response;

                // mapping
                setForm({
                    supplierName: data.supplierName || "",
                    email: data.email || "",
                    groupName: data.groupName || "",
                    gstNo: data.gstNo || "",
                    msme: data.msme || "",
                    city: data.city || "",
                    pinCode: data.pinCode || "",
                    state: data.state || "",
                    addressLine1: data.addressLine1 || "",
                    addressLine2: data.addressLine2 || "",
                    commissionRate: data.commissionRate || "",
                    commissionScheme: data.commissionScheme || "",
                    referenceBy: data.referenceBy || "",
                    remark: data.remark || "",
                    contacts: data.contacts?.length
                        ? data.contacts
                        : [{ contactPerson: "", mobileNumber: "", type: "" }],
                });

                // 🔹 Transport auto-select safe
                setSelectedTransports(data.preferredTransports || []);

            } catch (err) {
                showSnackbar("Failed to load supplier", "error");
            } finally {
                setLoading(false);
            }
        };

        fetchSupplier();
    }, [supplierId, open]);

    /* ---------------- FETCH TRANSPORTS ---------------- */

    useEffect(() => {
        const fetchTransports = async () => {
            try {
                const transports = await TransportService.getAllTransports();
                setAllTransports(transports || []);
            } catch (err) {
                console.error(err);
            }
        };

        fetchTransports();
    }, []);

    /* ---------------- RESET WHEN CLOSED ---------------- */

    useEffect(() => {
        if (!open) {
            setForm({});
            setSelectedTransports([]);
            setErrors({ contacts: [{}] });
        }
    }, [open]);

    /* ---------------- HANDLERS ---------------- */

    const handleChange = (e) => {
        const { name, value } = e.target;

        setForm(prev => ({
            ...prev,
            [name]: value,
        }));

        setErrors(prev => ({
            ...prev,
            [name]: validate(name, value),
        }));
    };

    const handleContactChange = (index, e) => {
        const { name, value } = e.target;

        const updatedContacts = [...form.contacts];
        updatedContacts[index][name] = value;

        setForm(prev => ({
            ...prev,
            contacts: updatedContacts,
        }));
    };

    const addContact = () => {
        setForm(prev => ({
            ...prev,
            contacts: [
                ...(prev.contacts || []),
                { contactPerson: "", mobileNumber: "", type: "" },
            ],
        }));
    };

    const deleteContact = (index) => {
        if (index === 0) return;

        const updated = form.contacts.filter((_, i) => i !== index);

        setForm(prev => ({
            ...prev,
            contacts: updated,
        }));
    };

    /* ---------------- UPDATE ---------------- */

    const handleUpdate = async () => {

        const nameError = validate("supplierName", form.supplierName);

        if (nameError) {
            showSnackbar(nameError, "error");
            return;
        }

        const payload = sanitizePayload({
            ...form,
            preferredTransportIds: selectedTransports.map(t => t.id),
        });

        try {
            setIsSaving(true);

            await SupplierService.updateSupplier(
                supplierId,
                payload
            );

            showSnackbar("Supplier updated successfully!", "success");

            fetchSuppliers();
            setOpen(false);

        } catch (err) {
            showSnackbar(err.message || "Update failed", "error");
        } finally {
            setIsSaving(false);
        }
    };

    if (!open) return null;

    return (
        <div className="fixed inset-0 bg-black bg-opacity-50 z-50 flex items-center justify-center">

            <div className="
        bg-white 
        w-full 
        h-full 
        sm:h-screen
        md:max-w-4xl 
        md:max-h-[90vh] 
        md:rounded-lg 
        flex 
        flex-col
      ">

                {/* Header */}
                <div className="p-6 border-b">
                    <h2 className="text-xl font-semibold">
                        Update Supplier
                    </h2>
                </div>

                {/* Body */}
                {loading ? (
                    <div className="flex-1 flex items-center justify-center">
                        <CircularProgress />
                    </div>
                ) : (

                    <div className="px-6 py-4 overflow-y-auto flex-1 space-y-8">

                        {/* ================= BASIC INFORMATION ================= */}
                        <div>
                            <h3 className="text-lg font-semibold mb-4 border-b pb-2">
                                Basic Information
                            </h3>

                            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">

                                <CustomTextField
                                    name="supplierName"
                                    value={form.supplierName || ""}
                                    onChange={handleChange}
                                    label="Supplier Name *"
                                    error={!!errors.supplierName}
                                    helperText={errors.supplierName}
                                />

                                <CustomTextField
                                    name="email"
                                    value={form.email || ""}
                                    onChange={handleChange}
                                    label="Email"
                                />

                                <CustomTextField
                                    name="groupName"
                                    value={form.groupName || ""}
                                    onChange={handleChange}
                                    label="Group"
                                />

                                <CustomTextField
                                    name="gstNo"
                                    value={form.gstNo || ""}
                                    onChange={handleChange}
                                    label="GST Number"
                                />

                                <BasicSelect
                                    name="msme"
                                    value={form.msme || ""}
                                    onChange={handleChange}
                                    label="MSME"
                                    options={[
                                        { value: "MICRO", label: "Micro" },
                                        { value: "SMALL", label: "Small" },
                                        { value: "MEDIUM", label: "Medium" },
                                    ]}
                                />

                            </div>
                        </div>

                        {/* ================= COMMISSION DETAILS ================= */}
                        <div>
                            <h3 className="text-lg font-semibold mb-4 border-b pb-2">
                                Commission Details
                            </h3>

                            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">

                                <BasicSelect
                                    name="commissionScheme"
                                    value={form.commissionScheme || ""}
                                    onChange={handleChange}
                                    label="Commission Scheme"
                                    options={[
                                        { value: "Fixed", label: "Fixed" },
                                        { value: "Percentage", label: "Percentage" },
                                        { value: "Tiered", label: "Tiered" },
                                    ]}
                                />

                                <CustomTextField
                                    name="commissionRate"
                                    value={form.commissionRate || ""}
                                    onChange={handleChange}
                                    label="Commission % (Rate)"
                                />

                                <CustomTextField
                                    name="referenceBy"
                                    value={form.referenceBy || ""}
                                    onChange={handleChange}
                                    label="Reference By"
                                />

                            </div>
                        </div>

                        {/* ================= ADDRESS DETAILS ================= */}
                        <div>
                            <h3 className="text-lg font-semibold mb-4 border-b pb-2">
                                Address Details
                            </h3>

                            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">

                                <CustomTextField
                                    name="addressLine1"
                                    value={form.addressLine1 || ""}
                                    onChange={handleChange}
                                    label="Address Line 1"
                                />

                                <CustomTextField
                                    name="addressLine2"
                                    value={form.addressLine2 || ""}
                                    onChange={handleChange}
                                    label="Address Line 2"
                                />

                                <StateAutocomplete
                                    value={form.state}
                                    onChange={(val) =>
                                        setForm((prev) => ({ ...prev, state: val }))
                                    }
                                />

                                <CustomTextField
                                    name="city"
                                    value={form.city || ""}
                                    onChange={handleChange}
                                    label="City"
                                />

                                <CustomTextField
                                    name="pinCode"
                                    value={form.pinCode || ""}
                                    onChange={handleChange}
                                    label="Pin Code"
                                />

                            </div>
                        </div>

                        {/* ================= CONTACT INFORMATION ================= */}
                        <div>
                            <h3 className="text-lg font-semibold mb-4 border-b pb-2">
                                Contact Information
                            </h3>

                            {form.contacts?.map((contact, index) => (
                                <div
                                    key={index}
                                    className="grid grid-cols-1 md:grid-cols-12 gap-4 mb-4 items-start"
                                >
                                    <div className="md:col-span-4">
                                        <CustomTextField
                                            name="contactPerson"
                                            value={contact.contactPerson || ""}
                                            onChange={(e) => handleContactChange(index, e)}
                                            label="Contact Person"
                                        />
                                    </div>

                                    <div className="md:col-span-4">
                                        <CustomTextField
                                            name="mobileNumber"
                                            value={contact.mobileNumber || ""}
                                            onChange={(e) => handleContactChange(index, e)}
                                            label="Mobile Number"
                                        />
                                    </div>

                                    <div className="md:col-span-3">
                                        <CustomTextField
                                            name="type"
                                            value={contact.type || ""}
                                            onChange={(e) => handleContactChange(index, e)}
                                            label="Type"
                                        />
                                    </div>

                                    <div className="md:col-span-1 flex justify-center">
                                        {index > 0 && (
                                            <IconButton
                                                size="small"
                                                color="error"
                                                onClick={() => deleteContact(index)}
                                            >
                                                <DeleteOutlineIcon fontSize="small" />
                                            </IconButton>
                                        )}
                                    </div>
                                </div>
                            ))}

                            <Button
                                variant="outlined"
                                startIcon={<AddIcon />}
                                onClick={addContact}
                            >
                                Add Contact
                            </Button>
                        </div>

                        {/* ================= TRANSPORT & REMARK ================= */}
                        <div>
                            <h3 className="text-lg font-semibold mb-4 border-b pb-2">
                                Transport & Remarks
                            </h3>

                            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">

                                {/* Preferred Transport */}
                                <Autocomplete
                                    multiple
                                    options={allTransports}
                                    value={selectedTransports}
                                    isOptionEqualToValue={(o, v) => o.id === v.id}
                                    getOptionLabel={(o) => o.name}
                                    onChange={(e, values) => setSelectedTransports(values)}
                                    renderTags={(value, getTagProps) =>
                                        value.map((option, index) => (
                                            <Chip
                                                key={option.id}
                                                label={option.name}
                                                {...getTagProps({ index })}
                                            />
                                        ))
                                    }
                                    renderInput={(params) => (
                                        <CustomTextField
                                            {...params}
                                            label="Preferred Transports"
                                        />
                                    )}
                                />

                                {/* Remark */}
                                <CustomTextField
                                    name="remark"
                                    value={form.remark || ""}
                                    onChange={handleChange}
                                    label="Remarks"
                                    multiline
                                    rows={0}
                                />

                            </div>
                        </div>


                    </div>

                )}

                {/* Footer */}
                <div className="p-4 border-t flex flex-col sm:flex-row justify-end gap-3 bg-gray-50">

                    <Button
                        disabled={isSaving}
                        onClick={() => setOpen(false)}
                    >
                        Cancel
                    </Button>

                    <Button
                        variant="contained"
                        disabled={isSaving}
                        onClick={handleUpdate}
                    >
                        {isSaving ? "Updating..." : "Update Supplier"}
                    </Button>

                </div>

            </div>
        </div>
    );
};

export default UpdateSupplierModal;
