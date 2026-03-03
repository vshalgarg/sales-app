import { Button } from "@mui/material";
import DownloadIcon from "@mui/icons-material/Download";
import VisibilityIcon from "@mui/icons-material/Visibility";
import dayjs from "dayjs";
import { useState } from "react";
import ImagePreviewDialog from "../components/common/ImagePreviewDialog";
import ArrowBackIcon from "@mui/icons-material/ArrowBack";
import { IconButton } from "@mui/material";

const PurchaseView = ({ data, open, onClose }) => {
    const [previewOpen, setPreviewOpen] = useState(false);
    const [previewIndex, setPreviewIndex] = useState(0);

    if (!open) return null;

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
                <div className="bg-white dark:bg-gray-900 w-full h-screen md:max-w-4xl md:max-h-[90vh] md:rounded-lg shadow-lg flex flex-col">

                    {/* HEADER*/}
                    <div className="px-4 md:px-6 py-3 md:py-6 border-b border-gray-300 flex items-center gap-3 sticky top-0 bg-white z-10">

                        <IconButton
                            onClick={onClose}
                            className="md:hidden"
                        >
                            <ArrowBackIcon />
                        </IconButton>

                        <h2 className="text-lg md:text-xl font-semibold">
                            Purchase Details
                        </h2>
                    </div>

                    {/* BODY */}
                    <div className="px-6 py-2 md:py-4 overflow-y-auto flex-1 space-y-4 md:space-y-6">

                        {/* Basic Information*/}
                        <h3 className="md:text-lg font-semibold md:mb-3">
                            Basic Information
                        </h3>
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-2 md:gap-4">
                            <div>
                                <label className="block text-sm font-medium mb-1">Date</label>
                                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                                    {data.date ? dayjs(data.date).format("DD-MM-YYYY") : "-"}
                                </div>
                            </div>
                            <div>
                                <label className="block text-sm font-medium mb-1">Staff</label>
                                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                                    {data.staffName || "-"}
                                </div>
                            </div>
                            <div>
                                <label className="block text-sm font-medium mb-1">Customer</label>
                                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                                    {data.customerName || "-"}
                                </div>
                            </div>
                            <div>
                                <label className="block text-sm font-medium mb-1">Amount</label>
                                <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm h-9">
                                    ₹ {Number(data.purchaseAmount).toFixed(2)}
                                </div>
                            </div>
                        </div>

                        {/* Suppliers Section */}
                        <h3 className="md:text-lg font-semibold mb-3">Suppliers</h3>
                        <div className="bg-gray-100 border border-gray-300 rounded px-3 py-2 text-sm min-h-9">
                            {data.supplierNames?.length ? (
                                <div className="flex flex-wrap gap-2">
                                    {data.supplierNames.map((name, i) => (
                                        <span
                                            key={i}
                                            className="bg-blue-100 text-blue-800 px-3 py-1 rounded-full text-xs"
                                        >
                                            {name}
                                        </span>
                                    ))}
                                </div>
                            ) : (
                                <span className="text-gray-500">-</span>
                            )}
                        </div>

                        {/* Attachments Section*/}
                        <h3 className="md:text-lg font-semibold mb-3">
                            Attachments ({data.publicUrls?.length || 0})
                        </h3>

                        {data.publicUrls?.length ? (
                            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                                {data.publicUrls.map((url, index) => {
                                    const fileName = url.split('/').pop() || 'attachment';
                                    const displayName = fileName.length > 25
                                        ? fileName.substring(0, 20) + '...'
                                        : fileName;

                                    return (
                                        <div
                                            key={index}
                                            className="bg-gray-100 border border-gray-300 rounded-lg p-3 flex items-center gap-3 hover:shadow-md transition-shadow"
                                        >

                                            {/* File Info */}
                                            <div className="flex-1 min-w-0">
                                                <p className="text-sm font-medium text-gray-700 truncate" title={fileName}>
                                                    {displayName}
                                                </p>
                                            </div>

                                            {/* Actions */}
                                            <div className="flex gap-1">
                                                <button
                                                    onClick={() => {
                                                        setPreviewIndex(index);
                                                        setPreviewOpen(true);
                                                    }}
                                                    className="p-1.5 hover:bg-blue-100 rounded-full text-blue-600 transition-colors"
                                                    title="View"
                                                >
                                                    <VisibilityIcon className="!text-lg" />
                                                </button>
                                                <button
                                                    onClick={() => handleDownload(url)}
                                                    className="p-1.5 hover:bg-green-100 rounded-full text-green-600 transition-colors"
                                                    title="Download"
                                                >
                                                    <DownloadIcon className="!text-lg" />
                                                </button>
                                            </div>
                                        </div>
                                    );
                                })}
                            </div>
                        ) : (
                            <div className="bg-gray-100 border border-gray-300 rounded px-3 py-8 text-center">
                                <VisibilityIcon className="!text-4xl text-gray-400 mb-2" />
                                <p className="text-gray-500">No attachments</p>
                            </div>
                        )}
                    </div>

                    {/* FOOTER*/}
                    <div className="p-2 md:p-4 border-t border-gray-300 flex justify-end">
                        <button
                            onClick={onClose}
                            className="px-4 py-2 text-sm md:text-base bg-blue-600 text-white rounded-lg hover:bg-blue-700"
                        >
                            Close
                        </button>
                    </div>
                </div>
            </div>

            <ImagePreviewDialog
                open={previewOpen}
                images={data.publicUrls || []}
                index={previewIndex}
                onClose={() => setPreviewOpen(false)}
                onChangeIndex={setPreviewIndex}
            />
        </>
    );
};

export default PurchaseView;