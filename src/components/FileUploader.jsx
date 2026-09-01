import { useMemo, useState, useEffect } from "react";
import CloseIcon from "@mui/icons-material/Close";
import { FileText } from "lucide-react";
import ImagePreviewDialog from "./ImagePreviewDialog";

const FileUploader = ({
  value = [],
  onChange,
  maxFiles = 3,
  accept = "image/*,application/pdf",
  label = "Upload Files",
  onError,
  showHeader = true
}) => {
  const [previewIndex, setPreviewIndex] = useState(null);
  const [isDragging, setIsDragging] = useState(false);

  const previewUrls = useMemo(() => {
    return value.map((file) => {
      if (file instanceof File) return URL.createObjectURL(file);
      return file.url;
    });
  }, [value]);

  // cleanup
  useEffect(() => {
    return () => {
      previewUrls.forEach((url) => {
        if (url.startsWith("blob:")) URL.revokeObjectURL(url);
      });
    };
  }, [previewUrls]);

  const handleDrop = (e) => {
    e.preventDefault();
    setIsDragging(false);

    const files = Array.from(e.dataTransfer.files || []);
    handleUpload({ target: { files } });
  };

  const handleDragOver = (e) => {
    e.preventDefault();
    setIsDragging(true);
  };

  const handleDragLeave = () => {
    setIsDragging(false);
  };

  const handleUpload = (e) => {
    const files = Array.from(e.target.files || []);
    if (!files.length) return;

    // validation
    const allowed = files.filter(
      (f) =>
        f.type.startsWith("image/") ||
        f.type === "application/pdf"
    );

    if (allowed.length !== files.length) {
      onError?.("Only images and PDFs allowed");
      return;
    }

    if (value.length + allowed.length > maxFiles) {
      onError?.(`Max ${maxFiles} files allowed`);
      return;
    }

    onChange([...value, ...allowed]);
    e.target.value = "";
  };

  const removeFile = (index) => {
    const updated = value.filter((_, i) => i !== index);
    onChange(updated);
  };

  return (
    <>
      <div className="bg-white border rounded-2xl p-5 shadow-sm hover:shadow-md transition-all duration-200">
        {showHeader && (
          <div className="flex justify-between items-center mb-5">
            <div>
              <h3 className="text-sm font-semibold text-gray-900">
                {label}
              </h3>
              <p className="text-xs text-gray-500 mt-0.5">
                Upload images or PDFs
              </p>
            </div>

            <span className="text-xs font-medium px-2 py-1 bg-gray-100 rounded-md text-gray-600">
              {value.length}/{maxFiles}
            </span>
          </div>
        )}

        <div className="space-y-3">

          {/* FILE LIST */}
          {value.map((file, index) => {
            const url = previewUrls[index];
            const isPdf = file.type === "application/pdf";

            return (
              <div
                key={index}
                onClick={() => {
                  setPreviewIndex(index);
                }}
                className="group flex items-center justify-between bg-white border border-gray-200 rounded-xl px-4 py-3 hover:border-blue-400 hover:bg-blue-50/30 hover:shadow-sm transition-all cursor-pointer"
              >
                <div className="flex items-center gap-3 min-w-0">

                  {/* ICON / PREVIEW */}
                  <div className="relative w-11 h-11 flex items-center justify-center rounded-lg bg-gray-100 overflow-hidden">
                    {isPdf ? (
                      <FileText className="w-5 h-5 text-red-500" />
                    ) : (
                      <img
                        src={url}
                        className="w-full h-full object-cover"
                      />
                    )}

                    {/* TYPE BADGE */}
                    <span className="absolute bottom-0 right-0 text-[9px] px-1.5 py-[1px] bg-black/70 text-white rounded">
                      {isPdf ? "PDF" : "IMG"}
                    </span>
                  </div>

                  {/* TEXT */}
                  <div className="flex flex-col min-w-0">
                    <span className="text-sm font-medium text-gray-800 truncate">
                      {file.name}
                    </span>

                    <div className="flex items-center gap-2 text-xs text-gray-400 mt-0.5">
                      <span>{isPdf ? "PDF Document" : "Image File"}</span>
                    </div>
                  </div>
                </div>

                {/* DELETE */}
                <button
                  onClick={(e) => {
                    e.stopPropagation();
                    removeFile(index);
                  }}
                  className="opacity-0 group-hover:opacity-100 transition p-1.5 rounded-md hover:bg-red-100 text-red-500"
                >
                  <CloseIcon fontSize="small" />
                </button>
              </div>
            );
          })}

          {value.length < maxFiles && (
            <label
              onDrop={handleDrop}
              onDragOver={handleDragOver}
              onDragLeave={handleDragLeave}
              className={`flex flex-col items-center justify-center text-center border-2 border-dashed rounded-xl py-10 cursor-pointer transition-all
    ${isDragging
                  ? "border-blue-500 bg-blue-50 scale-[1.02]"
                  : "border-gray-300 bg-gray-50 hover:bg-blue-50/40 hover:border-blue-400"
                }
  `}
            >

              {/* ICON */}
              <div className="w-12 h-12 flex items-center justify-center rounded-full bg-blue-100 mb-3">
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  className="w-6 h-6 text-blue-600"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                  strokeWidth={2}
                >
                  <path strokeLinecap="round" strokeLinejoin="round" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6H16a4 4 0 010 8h-1m-4-4v8m0 0l-3-3m3 3l3-3" />
                </svg>
              </div>

              {/* TEXT */}
              <p className="text-sm font-medium text-gray-700">
                {isDragging ? "Drop files here" : "Drag & drop files here"}
              </p>

              <p className="text-xs text-gray-500 mt-1">
                or <span className="text-blue-600 font-medium">Browse Files</span>
              </p>

              {/* INFO */}
              <p className="text-xs text-gray-400 mt-3">
                Supports JPG, PNG, PDF • Max {maxFiles} files
              </p>

              <input
                type="file"
                accept={accept}
                multiple
                hidden
                onChange={handleUpload}
              />
            </label>
          )}
        </div>
      </div>

      {/* PREVIEW */}
      <ImagePreviewDialog
        open={previewIndex !== null}
        images={previewUrls}
        files={value}
        index={previewIndex || 0}
        onChangeIndex={setPreviewIndex}
        onClose={() => setPreviewIndex(null)}
      />
    </>
  );
};

export default FileUploader;