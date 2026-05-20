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
import ArrowBackIcon from "@mui/icons-material/ArrowBack";
import FormFooter from "../components/common/FormFooter";
import AppButton from "../components/common/AppButton";
import ConfirmDialog from "../components/common/ConfirmDialog";
import useUnsavedChanges from "../customHooks/useUnsavedChanges";


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
    const [isSaving, setIsSaving] = useState(false);
    const [isLoaded, setIsLoaded] = useState(false);
    const { isDirty } = useUnsavedChanges(form, open && isLoaded);
    const [confirmOpen, setConfirmOpen] = useState(false);

    /* ---------------- FETCH SUPPLIER ---------------- */

    useEffect(() => {
        if (!supplierId || !open) return;

        const fetchSupplier = async () => {
            try {
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
                    bankName: data.bankName || "",
                    ifscCode: data.ifscCode || "",
                    branchName: data.branchName || "",
                    accountName: data.accountName || "",
                    accountNumber: data.accountNumber || "",
                    contacts: data.contacts?.length
                        ? data.contacts
                        : [{ contactPerson: "", mobileNumber: "", type: "" }],
                });

                // 🔹 Transport auto-select safe
                setSelectedTransports(data.preferredTransports || []);
                setIsLoaded(true);

            } catch (err) {
                showSnackbar("Failed to load supplier", "error");
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

    const handleClose = () => {
        if (isDirty()) {
            setConfirmOpen(true);
            return;
        }

        setOpen(false);
    };

    const handleConfirmLeave = () => {
        setConfirmOpen(false);
        setOpen(false);
    };

    const handleStay = () => {
        setConfirmOpen(false);
    };

    /* ---------------- HANDLERS ---------------- */

    const handleChange = (e) => {
        const { name, value } = e.target;
        if (name === "pinCode" && !/^\d{0,6}$/.test(value)) return;
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

    const handleMobileChange = (index, e) => {
        const value = e.target.value;

        if (/^[0-9-\s]*$/.test(value)) {
        handleContactChange(index, e);
        }
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
    if (!isLoaded) return null;

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
                <div className="p-4 md:p-6 border-b flex items-center gap-3">
                    <IconButton
                        onClick={handleClose}
                        className="md:hidden"
                    >
                        <ArrowBackIcon />
                    </IconButton>

                    <h2 className="text-lg md:text-xl font-semibold">
                        Update Supplier
                    </h2>
                </div>

                    {/* Body */}
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

                        {/* BANK DETAILS */}
                        <div>
                            <h3 className="text-lg font-semibold mb-4 border-b pb-2">Bank Details</h3>
                            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <CustomTextField
                                    name="bankName"
                                    value={form.bankName || ""}
                                    onChange={handleChange}
                                    label="Bank Name"
                                />
                                <CustomTextField
                                    name="ifscCode"
                                    value={form.ifscCode || ""}
                                    onChange={handleChange}
                                    label="IFSC Code"
                                />
                                <CustomTextField
                                    name="branchName"
                                    value={form.branchName || ""}
                                    onChange={handleChange}
                                    label="Branch Name"
                                />
                                <CustomTextField
                                    name="accountName"
                                    value={form.accountName || ""}
                                    onChange={handleChange}
                                    label="Account Holder Name"
                                />
                                <CustomTextField
                                    name="accountNumber"
                                    value={form.accountNumber || ""}
                                    onChange={handleChange}
                                    label="Account Number"
                                    type="number"
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
                                <div key={index} className="mb-6">

                                    {/* Mobile Card Layout */}
                                    <div className="md:hidden border rounded-xl p-4 space-y-4 bg-gray-50">

                                        <div className="flex justify-between items-center">
                                            <h4 className="text-sm font-semibold text-gray-700">
                                                Contact {index + 1}
                                            </h4>

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

                                        <CustomTextField
                                            name="contactPerson"
                                            value={contact.contactPerson || ""}
                                            onChange={(e) => handleContactChange(index, e)}
                                            label="Contact Person"
                                        />

                                        <CustomTextField
                                            name="mobileNumber"
                                            value={contact.mobileNumber || ""}
                                            onChange={(e) => handleMobileChange(index, e)}
                                            label="Mobile Number"
                                        />

                                        <CustomTextField
                                            name="type"
                                            value={contact.type || ""}
                                            onChange={(e) => handleContactChange(index, e)}
                                            label="Type"
                                        />
                                    </div>

                                    {/* Desktop Layout */}
                                    <div className="hidden md:grid grid-cols-12 gap-4 items-start">

                                        <div className="col-span-4">
                                            <CustomTextField
                                                name="contactPerson"
                                                value={contact.contactPerson || ""}
                                                onChange={(e) => handleContactChange(index, e)}
                                                label="Contact Person"
                                            />
                                        </div>

                                        <div className="col-span-4">
                                            <CustomTextField
                                                name="mobileNumber"
                                                value={contact.mobileNumber || ""}
                                                onChange={(e) => handleMobileChange(index, e)}
                                                label="Mobile Number"
                                            />
                                        </div>

                                        <div className="col-span-3">
                                            <CustomTextField
                                                name="type"
                                                value={contact.type || ""}
                                                onChange={(e) => handleContactChange(index, e)}
                                                label="Type"
                                            />
                                        </div>

                                        <div className="col-span-1 flex justify-center">
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

                {/* Footer */}
                <FormFooter>

                    {/* Update */}
                    <AppButton
                        type="primary"
                        loading={isSaving}
                        onClick={handleUpdate}
                        sx={{ minWidth: "140px" }}
                    >
                        Update Supplier
                    </AppButton>

                    {/* Cancel */}
                    <AppButton
                        type="cancel"
                        disabled={isSaving}
                        onClick={handleClose}
                    >
                        Cancel
                    </AppButton>

                </FormFooter>

                <ConfirmDialog
                    open={confirmOpen}
                    onConfirm={handleConfirmLeave}
                    onCancel={handleStay}
                />

            </div>
        </div>
    );
};

export default UpdateSupplierModal;
