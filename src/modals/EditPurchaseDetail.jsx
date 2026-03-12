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
import ArrowBackIcon from "@mui/icons-material/ArrowBack";
import { IconButton } from "@mui/material";
import FormFooter from "../components/common/FormFooter";
import AppButton from "../components/common/AppButton";
import ImageUploader from "../components/common/ImageUploader";
import Dialog from "@mui/material/Dialog";
import DialogTitle from "@mui/material/DialogTitle";
import DialogContent from "@mui/material/DialogContent";
import DialogActions from "@mui/material/DialogActions";
import { CheckCircleIcon } from "lucide-react";

const EditPurchaseDetail = ({
    open,
    purchaseId,
    setOpen,
    onUpdateSuccess,
}) => {

    const { showSnackbar } = useSnackbar();

    /* ================= STATES ================= */
    const [allSuppliers, setAllSuppliers] = useState([]);
    const [allCustomers, setAllCustomers] = useState([]);
    const [allStaffs, setAllStaffs] = useState([]);

    const [selectedCustomer, setSelectedCustomer] = useState(null);
    const [selectedStaff, setSelectedStaff] = useState(null);

    const [formData, setFormData] = useState({
        date: "",
        amount: "",
    });

    const [saving, setSaving] = useState(false);
    const [detail, setDetail] = useState(null);
    const [openUploader, setOpenUploader] = useState(false);
    const [tempImages, setTempImages] = useState([]);
    const [selectedSupplier, setSelectedSupplier] = useState(null);
    const [images, setImages] = useState([]);

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
        if (!detail || !allSuppliers.length || !allCustomers.length || !allStaffs.length) return;

        setFormData({
            date: detail.date || "",
            amount:
                detail.purchaseAmount != null
                    ? String(detail.purchaseAmount)
                    : "",
        });

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
        setSelectedSupplier(
            allSuppliers.find(s => s.id === detail.supplier?.supplierId) || null
        );

        setImages(
            (detail.supplier?.images || []).map(img => ({
                key: img.key,
                url: img.url
            }))
        );

    }, [detail, allSuppliers, allCustomers, allStaffs]);

    const handleAmountChange = (e) => {
        const value = e.target.value;

        if (/^\d*\.?\d{0,2}$/.test(value)) {
            setFormData(p => ({ ...p, amount: value }));
        }
    };

    const handleImageSave = () => {

        setImages(tempImages);

        setOpenUploader(false);
        setTempImages([]);

    };

    const handleImageCancel = () => {

        setOpenUploader(false);
        setTempImages([]);

    };

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
                staffId: selectedStaff?.staffId || null,
                customerId: selectedCustomer?.id || null,
                supplierId: selectedSupplier?.id || null,
                amount: formData.amount ? Number(formData.amount) : null,

                existingImageKeys: (images || [])
                    .filter(img => img.key)
                    .map(img => img.key)
            };

            formDataObj.append(
                "data",
                new Blob([JSON.stringify(payload)], {
                    type: "application/json"
                })
            );

            const supplierId = selectedSupplier?.id;
            images.forEach(img => {
                if (img instanceof File && supplierId) {
                    formDataObj.append(
                        `supplier_${supplierId}_images`,
                        img
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

    /* ================= UI ================= */
    return (
        <div className="fixed inset-0 bg-black bg-opacity-40 flex items-center justify-center z-50">
            <div
                className="
        bg-white flex flex-col
        w-full h-full sm:h-auto
        sm:w-[95%] md:w-[90%] lg:w-[960px] xl:w-[1080px]
        sm:max-w-4xl lg:max-w-5xl xl:max-w-6xl
        sm:max-h-[96vh]
        sm:rounded-2xl shadow-2xl overflow-hidden
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
                <div className="flex-1 overflow-y-auto px-4 sm:px-6 py-4 space-y-6">

                    {/* Information */}
                    <div className="border border-gray-200 p-4 sm:p-6 rounded-xl bg-white">

                        <div className="flex items-start mb-5">
                            <div className="w-1 h-10 bg-gradient-to-b from-green-500 to-green-700 rounded-full mr-3"></div>
                            <div>
                                <h3 className="text-lg font-semibold text-gray-800">
                                    Information
                                </h3>
                            </div>
                        </div>

                        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">

                            {/* Customer */}
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

                            {/* Staff */}
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

                            {/* Date */}
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

                        </div>

                    </div>


                    <div className="border border-gray-200 p-6 rounded-xl bg-white shadow-sm">

                        <div className="flex items-start justify-between mb-5">

                            <div className="flex items-start">

                                <div className="w-1 h-10 bg-gradient-to-b from-purple-500 to-purple-700 rounded-full mr-3"></div>

                                <h3 className="text-lg font-semibold text-gray-800">
                                    Suppliers
                                </h3>

                            </div>
                        </div>

                        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">

                            {/* Supplier */}
                            <Autocomplete
                                options={allSuppliers}
                                value={selectedSupplier}
                                isOptionEqualToValue={(o, v) => o.id === v?.id}
                                getOptionLabel={(o) => o?.supplierName || ""}
                                onChange={(e, v) => setSelectedSupplier(v)}
                                renderInput={(p) => (
                                    <CustomTextField {...p} label="Supplier *" />
                                )}
                            />

                            {/* Amount */}
                            <CustomTextField
                                label="Purchase Amount"
                                value={formData.amount}
                                onChange={handleAmountChange}
                            />

                            {/* Upload */}
                            <button
                                type="button"
                                onClick={() => {
                                    setTempImages(images);
                                    setOpenUploader(true);
                                }}
                                className="h-[40px] mt-[2px] px-4 bg-blue-600 text-white rounded-lg flex items-center justify-center gap-2"
                            >
                               Upload Order Form

                                {images.length > 0 && (
                                    <>
                                        <span className="bg-white text-blue-600 text-xs px-2 rounded-full">
                                            {images.length}
                                        </span>
                                        <CheckCircleIcon size={18} />
                                    </>
                                )}
                            </button>

                        </div>

                    </div>
                </div>

                {/* Footer */}
                <FormFooter background="bg-white">

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
                        onClick={() => setOpen(false)}
                    >
                        Cancel
                    </AppButton>

                </FormFooter>

                <Dialog
                    open={openUploader}
                    onClose={handleImageCancel}
                    maxWidth="sm"
                    fullWidth
                >

                    <DialogTitle>
                        Upload Order Form
                    </DialogTitle>

                    <DialogContent>

                        <ImageUploader
                            value={tempImages}
                            onChange={setTempImages}
                            maxImages={2}
                            label="Order Form Images"
                            onError={(msg) => showSnackbar(msg, "error")}
                        />

                    </DialogContent>

                    <DialogActions>

                        <button
                            onClick={handleImageCancel}
                            className="px-4 py-2 border rounded"
                        >
                            Cancel
                        </button>

                        <button
                            onClick={handleImageSave}
                            className="px-5 py-2 bg-blue-600 text-white rounded"
                        >
                            Save
                        </button>

                    </DialogActions>

                </Dialog>

            </div>
        </div>
    );
};

export default EditPurchaseDetail;