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
}) => {
  const [previewIndex, setPreviewIndex] = useState(null);

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
      <div className="bg-white border rounded-2xl p-4 shadow-sm">
        <div className="flex justify-between items-center mb-4">
          <h3 className="text-sm font-semibold text-gray-800">
            {label}
          </h3>
          <span className="text-xs text-gray-500">
            {value.length}/{maxFiles}
          </span>
        </div>

        <div className="space-y-3">

          {/* FILE LIST */}
          {value.map((file, index) => {
            const url = previewUrls[index];
            const isPdf = file.type === "application/pdf";

            return (
              <div
                key={index}
                onClick={() => setPreviewIndex(index)}
                className="flex items-center justify-between bg-gray-50 border rounded-xl px-3 py-2.5 hover:bg-gray-100 transition cursor-pointer"
              >
                <div className="flex items-center gap-2 truncate">
                  {isPdf ? (
                    <FileText className="w-4 h-4 text-red-500" />
                  ) : (
                    <img
                      src={url}
                      className="w-8 h-8 object-cover rounded"
                    />
                  )}

                  <span className="text-sm text-gray-700 truncate">
                    {file.name}
                  </span>
                </div>

                <button
                  onClick={(e) => {
                    e.stopPropagation();
                    removeFile(index);
                  }}
                  className="p-1 rounded-md hover:bg-red-100 text-red-500 hover:text-red-700 transition"
                >
                  <CloseIcon fontSize="small" />
                </button>
              </div>
            );
          })}

          {/* EMPTY */}
          {value.length === 0 && (
            <div className="text-sm text-gray-400 border border-dashed rounded-xl py-6 text-center">
              No files uploaded
            </div>
          )}

          {/* ADD BUTTON */}
          {value.length < maxFiles && (
            <label className="flex items-center justify-center h-12 border-2 border-dashed border-gray-300 rounded-xl cursor-pointer hover:border-blue-500 hover:bg-blue-50 transition text-sm text-gray-600 font-medium">
              + Add File
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