import DownloadIcon from "@mui/icons-material/Download";
import VisibilityIcon from "@mui/icons-material/Visibility";
import dayjs from "dayjs";
import { useState } from "react";
import ImagePreviewDialog from "../components/common/ImagePreviewDialog";
import ArrowBackIcon from "@mui/icons-material/ArrowBack";
import { IconButton } from "@mui/material";
import AppButton from "../components/common/AppButton";
import FormFooter from "../components/common/FormFooter";

const PurchaseView = ({ data, open, onClose }) => {
    const [previewOpen, setPreviewOpen] = useState(false);
    const [previewIndex, setPreviewIndex] = useState(0);

    if (!open) return null;

    const images = data?.supplier?.images || [];

    const handleDownload = async (url) => {
        const response = await fetch(url);
        const blob = await response.blob();

        const blobUrl = window.URL.createObjectURL(blob);
        const link = document.createElement("a");
        link.href = blobUrl;
        link.download = url.split("/").pop() || "download";
        document.body.appendChild(link);
        link.click();
        link.remove();
        window.URL.revokeObjectURL(blobUrl);
    };

    return (
        <>
            <div className="fixed inset-0 bg-black bg-opacity-50 z-50 md:flex md:items-center md:justify-center">
                <div className="bg-white w-full h-screen md:max-w-4xl md:max-h-[90vh] md:rounded-lg shadow-lg flex flex-col">

                    {/* HEADER */}
                    <div className="px-4 md:px-6 py-3 md:py-6 border-b flex items-center gap-3 sticky top-0 bg-white z-10">

                        <IconButton onClick={onClose} className="md:hidden">
                            <ArrowBackIcon />
                        </IconButton>

                        <h2 className="text-lg md:text-xl font-semibold">
                            Purchase Details
                        </h2>

                    </div>

                    {/* BODY */}
                    <div className="px-6 py-4 overflow-y-auto flex-1 space-y-6">

                        {/* BASIC INFO */}
                        <h3 className="text-lg font-semibold">
                            Basic Information
                        </h3>

                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">

                            <div>
                                <label className="block text-sm font-medium mb-1">
                                    Date
                                </label>
                                <div className="bg-gray-100 border rounded px-3 py-2 text-sm">
                                    {data.date
                                        ? dayjs(data.date).format("DD-MM-YYYY")
                                        : "-"}
                                </div>
                            </div>

                            <div>
                                <label className="block text-sm font-medium mb-1">
                                    Staff
                                </label>
                                <div className="bg-gray-100 border rounded px-3 py-2 text-sm">
                                    {data.staffName || "-"}
                                </div>
                            </div>

                            <div>
                                <label className="block text-sm font-medium mb-1">
                                    Customer
                                </label>
                                <div className="bg-gray-100 border rounded px-3 py-2 text-sm">
                                    {data.customerName || "-"}
                                </div>
                            </div>

                            <div>
                                <label className="block text-sm font-medium mb-1">
                                    Amount
                                </label>
                                <div className="bg-gray-100 border rounded px-3 py-2 text-sm">
                                    {data.purchaseAmount != null
                                        ? Number(data.purchaseAmount).toFixed(2)
                                        : "-"}
                                </div>
                            </div>

                            <div>
                                <label className="block text-sm font-medium mb-1">
                                    Supplier
                                </label>
                                <div className="bg-gray-100 border rounded px-3 py-2 text-sm">
                                    {data.supplier?.supplierName || "-"}
                                </div>
                            </div>

                        </div>

                        {/* ATTACHMENTS */}
                        <h3 className="text-lg font-semibold">
                            Attachments ({images.length})
                        </h3>

                        {images.length ? (

                            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">

                                {images.map((img, index) => {

                                    const url = img.url;
                                    const fileName =
                                        url.split("/").pop() || "attachment";

                                    return (

                                        <div
                                            key={index}
                                            className="bg-gray-100 border rounded-lg p-3 flex items-center gap-3"
                                        >

                                            <div className="flex-1 truncate text-sm">
                                                {fileName}
                                            </div>

                                            <div className="flex gap-1">

                                                <button
                                                    onClick={() => {
                                                        setPreviewIndex(index);
                                                        setPreviewOpen(true);
                                                    }}
                                                    className="p-1.5 hover:bg-blue-100 rounded text-blue-600"
                                                >
                                                    <VisibilityIcon fontSize="small" />
                                                </button>

                                                <button
                                                    onClick={() =>
                                                        handleDownload(url)
                                                    }
                                                    className="p-1.5 hover:bg-green-100 rounded text-green-600"
                                                >
                                                    <DownloadIcon fontSize="small" />
                                                </button>

                                            </div>

                                        </div>

                                    );
                                })}

                            </div>

                        ) : (

                            <div className="bg-gray-100 border rounded px-3 py-8 text-center">
                                <VisibilityIcon className="!text-4xl text-gray-400 mb-2" />
                                <p className="text-gray-500">
                                    No attachments
                                </p>
                            </div>

                        )}

                    </div>

                    {/* FOOTER */}
                    <FormFooter background="bg-white">

                        <AppButton
                            type="primary"
                            onClick={onClose}
                            sx={{ minWidth: "140px" }}
                        >
                            Close
                        </AppButton>

                    </FormFooter>

                </div>
            </div>

            <ImagePreviewDialog
                open={previewOpen}
                images={images.map(i => i.url)}
                index={previewIndex}
                onClose={() => setPreviewOpen(false)}
                onChangeIndex={setPreviewIndex}
            />
        </>
    );
};

export default PurchaseView;