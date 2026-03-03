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
import {
    updatePurchaseApi,
    getPurchaseDetailsById
} from "../service/PurchaseService";
import ImagePreviewDialog from "../components/common/ImagePreviewDialog";
import VisibilityIcon from "@mui/icons-material/Visibility";
import ArrowBackIcon from "@mui/icons-material/ArrowBack";
import { IconButton } from "@mui/material";

const EditPurchaseDetail = ({
    open,
    purchaseId,
    setOpen,
    onUpdateSuccess,
}) => {

    useEffect(() => {
        console.log("OPEN:", open);
        console.log("PURCHASE ID:", purchaseId);
    }, [open, purchaseId]);

    const { showSnackbar } = useSnackbar();

    /* ================= STATES ================= */
    const [allSuppliers, setAllSuppliers] = useState([]);
    const [allCustomers, setAllCustomers] = useState([]);
    const [allStaffs, setAllStaffs] = useState([]);

    const [selectedSuppliers, setSelectedSuppliers] = useState([]);
    const [selectedCustomer, setSelectedCustomer] = useState(null);
    const [selectedStaff, setSelectedStaff] = useState(null);

    const [existingImages, setExistingImages] = useState([]);
    const [newImages, setNewImages] = useState([]);
    const [previewIndex, setPreviewIndex] = useState(null);

    const [formData, setFormData] = useState({
        date: "",
        purchaseAmount: "",
    });

    const [saving, setSaving] = useState(false);
    const [detail, setDetail] = useState(null);

    useEffect(() => {
        if (!open) return;
        const loadMasters = async () => {
            try {
                const [suppliers, customers, staffs] =
                    await Promise.all([
                        SupplierService.getAllSuppliers(),
                        CustomerService.getAllCustomers(),
                        getAllActiveStaffs(),
                    ]);

                setAllSuppliers(suppliers || []);
                setAllCustomers(customers || []);
                setAllStaffs(staffs || []);
            } catch {
                showSnackbar("Failed to load master data", "error");
            }
        };

        loadMasters();
    }, [open]);


    useEffect(() => {
        if (!open || !purchaseId) return;

        const loadDetail = async () => {
            try {
                const res = await getPurchaseDetailsById(purchaseId);
                setDetail(res);
            } catch {
                showSnackbar("Failed to load purchase details", "error");
            }
        };

        loadDetail();
    }, [open, purchaseId]);

    useEffect(() => {
        if (!detail) return;
        if (!allSuppliers.length || !allCustomers.length || !allStaffs.length) return;

        setFormData({
            date: detail.date || "",
            purchaseAmount:
                detail.purchaseAmount != null
                    ? String(detail.purchaseAmount)
                    : "",
        });

        setSelectedSuppliers(
            allSuppliers.filter(s =>
                detail.supplierIds?.includes(s.id)
            )
        );

        setSelectedCustomer(
            allCustomers.find(c =>
                c.id === detail.customerId
            ) || null
        );

        setSelectedStaff(
            allStaffs.find(s =>
                s.staffId === Number(detail.staffId)
            ) || null
        );

        setExistingImages(
            (detail.imageKeys || []).map((key, index) => ({
                id: key,
                key: key,
                url: detail.publicUrls?.[index]
            }))
        );

        setNewImages([]);
    }, [detail, allSuppliers, allCustomers, allStaffs]);

    const handleAmountChange = (e) => {
        const value = e.target.value;

        if (/^\d*\.?\d{0,2}$/.test(value)) {
            setFormData(p => ({ ...p, purchaseAmount: value }));
        }
    };

    /* ================= UPDATE ================= */
    const handleUpdate = async () => {
        try {
            setSaving(true);

            const formDataObj = new FormData();

            const payload = {
                date: formData.date || null,
                staffId: selectedStaff?.staffId || null,
                supplierIds: selectedSuppliers.map(s => s.id),
                customerId: selectedCustomer?.id || null,
                purchaseAmount:
                    formData.purchaseAmount !== ""
                        ? Number(formData.purchaseAmount)
                        : null,
                existingImageKeys:
                    existingImages.map(img => img.key)
            };

            formDataObj.append(
                "data",
                new Blob([JSON.stringify(payload)], {
                    type: "application/json"
                })
            );

            newImages.forEach(file => {
                formDataObj.append("images", file);
            });

            await updatePurchaseApi(purchaseId, formDataObj);

            showSnackbar("Purchase updated successfully", "success");

            onUpdateSuccess();
            setOpen(false);

        } catch {
            showSnackbar("Failed to update purchase", "error");
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
                <div className="px-4 sm:px-6 py-4 border-b flex items-center gap-3">

                    <IconButton
                        onClick={() => setOpen(false)}
                        className="md:hidden"
                    >
                        <ArrowBackIcon />
                    </IconButton>

                    <h2 className="text-lg sm:text-xl font-semibold">
                        Edit Purchase
                    </h2>
                </div>

                {/* Body */}
                <div className="flex-1 overflow-y-auto px-4 sm:px-6 py-4 space-y-4">

                    {/* BASIC INFO */}
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                        <CustomTextField
                            label="Purchase ID"
                            value={purchaseId}
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
                                        date: v
                                            ? dayjs(v).format("YYYY-MM-DD")
                                            : "",
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
                            isOptionEqualToValue={(o, v) =>
                                o.staffId === v?.staffId
                            }
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
                            multiple
                            options={allSuppliers}
                            value={selectedSuppliers}
                            isOptionEqualToValue={(o, v) => o.id === v.id}
                            getOptionLabel={(o) => o?.supplierName || ""}
                            onChange={(e, values) =>
                                setSelectedSuppliers(values)
                            }
                            renderInput={(p) => (
                                <CustomTextField {...p} label="Suppliers" />
                            )}
                        />

                        <Autocomplete
                            options={allCustomers}
                            value={selectedCustomer}
                            isOptionEqualToValue={(o, v) => o.id === v?.id}
                            getOptionLabel={(o) => o?.customerName || ""}
                            onChange={(e, v) =>
                                setSelectedCustomer(v)
                            }
                            renderInput={(p) => (
                                <CustomTextField {...p} label="Customer" />
                            )}
                        />
                    </div>


                    {/* ================= PURCHASE IMAGES ================= */}

                    <div className="bg-white border rounded-2xl p-6 shadow-sm">
                        <div className="flex justify-between items-center mb-5">
                            <h3 className="text-lg font-semibold text-gray-800">
                                OrderForm
                            </h3>
                            <span className="text-sm text-gray-500">
                                {existingImages.length + newImages.length}/2
                            </span>
                        </div>

                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                            {[
                                ...existingImages.map(img => ({
                                    type: "existing",
                                    id: img.id,
                                    key: img.key
                                })),
                                ...newImages.map(file => ({
                                    type: "new",
                                    id: file.name + file.lastModified,
                                    file
                                }))
                            ].map((img, index) => (
                                <div
                                    key={img.id || index}
                                    className="relative group"
                                >
                                    <div
                                        onClick={() => setPreviewIndex(index)}
                                        className="h-20 rounded-xl border bg-gray-50 flex items-center px-4 
                   cursor-pointer hover:bg-gray-100 hover:shadow 
                   transition-all"
                                    >
                                        <VisibilityIcon className="text-gray-500 mr-3" />
                                        <div className="flex-1">
                                            <p className="text-sm font-medium text-gray-700">
                                                Attachment {index + 1}
                                            </p>
                                            <p className="text-xs text-gray-500">
                                                Click to preview
                                            </p>
                                        </div>
                                    </div>

                                    <button
                                        type="button"
                                        onClick={() => {
                                            if (img.type === "new") {
                                                setNewImages(prev =>
                                                    prev.filter(f =>
                                                        (f.name + f.lastModified) !== img.id
                                                    )
                                                );
                                            } else {
                                                setExistingImages(prev =>
                                                    prev.filter(i => i.key !== img.key)
                                                );
                                            }
                                        }}
                                        className="absolute -top-2 -right-2 bg-white border text-red-600 
                   rounded-full w-7 h-7 flex items-center justify-center 
                   shadow hover:bg-red-600 hover:text-white transition"
                                    >
                                        ✕
                                    </button>
                                </div>
                            ))}

                            {(existingImages.length + newImages.length) < 2 && (
                                <label className="h-20 border-2 border-dashed border-gray-300 rounded-xl 
                      flex items-center justify-center cursor-pointer 
                      hover:border-blue-500 hover:bg-blue-50 transition">
                                    <span className="text-sm text-gray-600 font-medium">
                                        + Add Attachment
                                    </span>
                                    <input
                                        type="file"
                                        accept="image/*"
                                        hidden
                                        onChange={(e) => {
                                            const files = Array.from(e.target.files || []);
                                            if (!files.length) return;

                                            const total =
                                                existingImages.length +
                                                newImages.length +
                                                files.length;

                                            if (total > 2) {
                                                showSnackbar("Maximum 2 images allowed", "error");
                                                return;
                                            }

                                            setNewImages(prev => [...prev, ...files]);
                                            e.target.value = "";
                                        }}
                                    />
                                </label>
                            )}
                        </div>
                    </div>

                    <ImagePreviewDialog
                        open={previewIndex !== null}
                        images={[
                            ...existingImages.map(img => img.url),
                            ...newImages.map(file => URL.createObjectURL(file))
                        ]}
                        index={previewIndex || 0}
                        onChangeIndex={setPreviewIndex}
                        onClose={() => setPreviewIndex(null)}
                    />
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