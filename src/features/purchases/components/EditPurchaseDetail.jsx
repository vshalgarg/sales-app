import { useEffect, useState } from "react";
import CustomTextField from "@/components/CustomTextField";
import { LocalizationProvider } from "@mui/x-date-pickers/LocalizationProvider";
import { AdapterDayjs } from "@mui/x-date-pickers/AdapterDayjs";
import { DatePicker } from "@mui/x-date-pickers/DatePicker";
import dayjs from "dayjs";
import { useSnackbar } from "@/contexts/SnackbarContext";
import SupplierService from "@/services/SupplierService";
import CustomerService from "@/services/CustomerService";
import { getAllActiveStaffs } from "@/services/StaffService";
import {
    updatePurchaseApi,
    getPurchaseDetailsById
} from "@/services/PurchaseService";
import ArrowBackIcon from "@mui/icons-material/ArrowBack";
import { IconButton } from "@mui/material";
import FormFooter from "@/components/FormFooter";
import AppButton from "@/components/AppButton";
import FormSection from "@/components/FormSection";
import ImagePreviewDialog from "@/components/ImagePreviewDialog";
import { useMemo } from "react";
import GenericAutocomplete from "@/components/GenericAutocomplete";
import { mapToOption } from "@/utils/optionMapper";
import useUnsavedChanges from "@/hooks/useUnsavedChanges";
import ConfirmDialog from "@/components/ConfirmDialog";
import CloseIcon from "@mui/icons-material/Close";
import useResponsive from "@/hooks/useResponsive";
import { PAGE_TITLE_CLASS } from "@/theme/appTheme";
import { FORM_SCROLL_AREA_CLASS } from "@/theme/cardTheme";
import { FileText, Paperclip } from "lucide-react";

const EditPurchaseDetail = ({
    open,
    purchaseId,
    setOpen,
    onUpdateSuccess,
}) => {

    const { showSnackbar } = useSnackbar();
    const { isMobile } = useResponsive();

    /* ================= STATES ================= */
    const [allSuppliers, setAllSuppliers] = useState([]);
    const [allCustomers, setAllCustomers] = useState([]);
    const [allStaffs, setAllStaffs] = useState([]);

    const [selectedCustomer, setSelectedCustomer] = useState(null);
    const [selectedStaff, setSelectedStaff] = useState(null);

    const [formData, setFormData] = useState({
        date: "",
        remarks: "",
    });

    const [saving, setSaving] = useState(false);
    const [detail, setDetail] = useState(null);
    const [selectedSupplier, setSelectedSupplier] = useState(null);
    const [existingImages, setExistingImages] = useState([]);
    const [newImages, setNewImages] = useState([]);
    const [previewIndex, setPreviewIndex] = useState(null);
    const [isLoaded, setIsLoaded] = useState(false);
    const [confirmOpen, setConfirmOpen] = useState(false);
    const { isDirty } = useUnsavedChanges(
        {
            ...formData,
            supplierId: selectedSupplier?.id,
            customerId: selectedCustomer?.id,
            staffId: selectedStaff?.id,
            existingImages,
            newImages
        },
        open && detail
    );

    const customerOptions = mapToOption(allCustomers, "id", "customerName");
    const staffOptions = mapToOption(allStaffs, "staffId", "staffName");
    const supplierOptions = mapToOption(allSuppliers, "id", "supplierName");

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
        if (!detail || !allSuppliers.length || !allCustomers.length || !allStaffs.length || !open) return;
        setIsLoaded(false);
        setFormData({
            date: detail.date || "",
            remarks:
                detail.remarks != null
                    ? detail.remarks
                    : "",
        });

        setSelectedCustomer(
            customerOptions.find(c => c.id === detail.customerId) || null
        );

        setSelectedStaff(
            staffOptions.find(s => s.id === Number(detail.staffId)) || null
        );

        setSelectedSupplier(
            supplierOptions.find(s => s.id === detail.supplier?.supplierId) || null
        );

        setExistingImages(
            (detail.supplier?.images || []).map(img => ({
                key: img.key,
                url: img.url,
                fileName: img.fileName,
                type: img.url.endsWith(".pdf")
                    ? "application/pdf"
                    : "image"
            }))
        );

        setNewImages([]);

    }, [detail, allSuppliers, allCustomers, allStaffs]);

    useEffect(() => {
        if (
            open &&
            detail &&
            selectedSupplier !== null &&
            selectedCustomer !== null &&
            selectedStaff !== null
        ) {
            setIsLoaded(true);
        }
    }, [open, detail, selectedSupplier, selectedCustomer, selectedStaff]);

    const handleClose = () => {
        if (isDirty()) {
            setConfirmOpen(true);
            return;
        }

        setOpen(false);
    };

    const handleChange = (field) => (e) => {
        setFormData(p => ({
            ...p,
            [field]: e.target.value
        }));
    };

    const previewImages = useMemo(() => {
        return [
            ...existingImages.map(img => img.url),
            ...newImages.map(file => URL.createObjectURL(file))
        ];
    }, [existingImages, newImages]);

    useEffect(() => {

        const blobUrls = previewImages.filter(url => url.startsWith("blob:"));
        return () => {
            blobUrls.forEach(url => URL.revokeObjectURL(url));
        };

    }, [previewImages]);

    /* ================= UPDATE ================= */
    const handleUpdate = async () => {

        try {

            setSaving(true);

            if (!selectedSupplier?.id) {
                showSnackbar("Supplier is required", "error");
                setSaving(false);
                return;
            }

            const formDataObj = new FormData();

            const payload = {

                date: formData.date || null,
                staffId: selectedStaff?.id || null,
                customerId: selectedCustomer?.id || null,
                supplierId: selectedSupplier?.id || null,
                remarks: formData.remarks ? formData.remarks : null,
                existingImageKeys: existingImages.map(img => img.key)
            };

            formDataObj.append(
                "data",
                new Blob([JSON.stringify(payload)], {
                    type: "application/json"
                })
            );

            const supplierId = selectedSupplier?.id;
            newImages.forEach(file => {
                if (supplierId) {
                    formDataObj.append(
                        `supplier_${supplierId}_images`,
                        file
                    );
                }
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

    const attachmentCount = existingImages.length + newImages.length;

    /* ================= UI ================= */
    return (
        <div className="fixed inset-0 flex items-center justify-center bg-black/80 z-50 p-0 md:p-4">
            <div
                className={`bg-white dark:bg-gray-900 flex flex-col w-full overflow-hidden shadow-lg ${
                    isMobile ? "h-full" : "max-w-6xl max-h-[90vh] rounded-xl"
                }`}
            >
                <div className="px-4 sm:px-6 py-4 border-b border-brand-surface-border dark:border-zinc-700 flex items-center justify-between gap-3 shrink-0 bg-white dark:bg-gray-900">
                    <div className="flex items-center gap-3 min-w-0">
                        <IconButton
                            onClick={handleClose}
                            className="md:hidden"
                            size="small"
                            aria-label="Go back"
                        >
                            <ArrowBackIcon />
                        </IconButton>

                        <h2 className={`${PAGE_TITLE_CLASS} truncate`}>Edit Purchase</h2>
                    </div>
                    <IconButton
                        onClick={handleClose}
                        size="small"
                        aria-label="Close"
                        className="hidden md:inline-flex border border-brand-surface-border rounded-lg"
                    >
                        <CloseIcon fontSize="small" />
                    </IconButton>
                </div>

                <div
                    className={`flex-1 min-h-0 overflow-y-auto p-4 md:p-6 space-y-4 ${FORM_SCROLL_AREA_CLASS}`}
                >
                    <FormSection
                        title="Basic Information"
                        icon={FileText}
                        variantIndex={0}
                    >
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <GenericAutocomplete
                                options={customerOptions}
                                value={customerOptions.find(c => c.id === selectedCustomer?.id) || null}
                                label="Customer"
                                onChange={(v) => setSelectedCustomer(v)}
                            />

                            <GenericAutocomplete
                                options={staffOptions}
                                value={staffOptions.find(s => s.id === selectedStaff?.id) || null}
                                label="Staff"
                                onChange={(v) => setSelectedStaff(v)}
                            />

                            <LocalizationProvider dateAdapter={AdapterDayjs}>
                                <DatePicker
                                    label="Transaction Date"
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

                            <GenericAutocomplete
                                options={supplierOptions}
                                value={supplierOptions.find(s => s.id === selectedSupplier?.id) || null}
                                label="Supplier"
                                required={true}
                                onChange={(v) => setSelectedSupplier(v)}
                            />

                            <CustomTextField
                                label="Remarks"
                                value={formData.remarks}
                                onChange={handleChange("remarks")}
                            />
                        </div>
                    </FormSection>

                    <FormSection
                        title={`Order Form Attachments (${attachmentCount}/3)`}
                        icon={Paperclip}
                        variantIndex={1}
                    >
                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">

                            {[

                                ...existingImages.map(img => ({
                                    type: img.type,
                                    id: img.key,
                                    key: img.key,
                                    url: img.url,
                                    fileName: img.fileName
                                })),

                                ...newImages.map(file => ({
                                    type: "new",
                                    id: file.name + file.lastModified,
                                    file
                                }))

                            ].map((img, index) => (

                                <div key={img.id || index} className="relative group">

                                    <div
                                        onClick={() => {
                                            let url;
                                            let isPdf = false;

                                            if (img.type === "new") {
                                                url = URL.createObjectURL(img.file);
                                                isPdf = img.file.type === "application/pdf";
                                            } else {
                                                url = img.url;
                                                isPdf = img.type === "application/pdf";
                                            }

                                            if (isPdf) {
                                                window.open(url, "_blank");
                                            } else {
                                                setPreviewIndex(index);
                                            }
                                        }}
                                        className="h-20 rounded-xl border bg-gray-50 flex items-center px-4 
          cursor-pointer hover:bg-gray-100 hover:shadow transition-all"
                                    >

                                        <div className="flex-1">

                                            <p className="text-sm font-medium text-gray-700">
                                                {img.type === "new"
                                                    ? img.file.name
                                                    : (img.fileName || img.key.split("/").pop())}
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
          rounded-full w-7 h-7 flex items-center justify-center shadow"
                                    >
                                        <CloseIcon fontSize="small" />
                                    </button>

                                </div>

                            ))}

                            {(existingImages.length + newImages.length) < 3 && (

                                <label
                                    className="h-20 border-2 border-dashed border-gray-300 rounded-xl 
        flex items-center justify-center cursor-pointer 
        hover:border-blue-500 hover:bg-blue-50 transition"
                                >

                                    <span className="text-sm text-gray-600 font-medium">
                                        + Add Attachment
                                    </span>

                                    <input
                                        type="file"
                                        accept="image/*,application/pdf"
                                        hidden
                                        onChange={(e) => {

                                            const files = Array.from(e.target.files || []);
                                            const validFiles = files.filter(
                                                f =>
                                                    f.type.startsWith("image/") ||
                                                    f.type === "application/pdf"
                                            );

                                            if (validFiles.length !== files.length) {
                                                showSnackbar("Only images & PDFs allowed", "error");
                                                return;
                                            }

                                            if (!files.length) return;

                                            const total =
                                                existingImages.length +
                                                newImages.length +
                                                files.length;

                                            if (total > 3) {

                                                showSnackbar("Maximum  3 files allowed", "error");
                                                return;

                                            }

                                            setNewImages(prev => [...prev, ...validFiles]);

                                        }}
                                    />

                                </label>

                            )}

                        </div>
                    </FormSection>

                    <ImagePreviewDialog
                        open={previewIndex !== null}
                        images={previewImages}
                        files={[
                            ...existingImages,
                            ...newImages
                        ]}
                        index={previewIndex || 0}
                        onChangeIndex={setPreviewIndex}
                        onClose={() => setPreviewIndex(null)}
                    />
                </div>

                <FormFooter background="bg-white dark:bg-gray-900">

                    <AppButton
                        type="primary"
                        onClick={handleUpdate}
                        loading={saving}
                        sx={{ minWidth: "140px" }}
                    >
                        Update
                    </AppButton>

                    <AppButton
                        type="cancel"
                        onClick={handleClose}
                    >
                        Cancel
                    </AppButton>

                </FormFooter>

                <ConfirmDialog
                    open={confirmOpen}
                    onConfirm={() => {
                        setConfirmOpen(false);
                        setOpen(false);
                    }}
                    onCancel={() => setConfirmOpen(false)}
                />

            </div>
        </div>
    );
};

export default EditPurchaseDetail;