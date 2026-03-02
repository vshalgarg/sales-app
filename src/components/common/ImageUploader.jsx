import { useRef, useState, useMemo, useEffect } from "react";
import ImagePreviewDialog from "./ImagePreviewDialog";
import CloseIcon from "@mui/icons-material/Close";

const ImageUploader = ({
  value = [],
  onChange,
  maxImages = 2,
  label = "Images",
  onError,
}) => {
  const fileInputRef = useRef(null);
  const [previewIndex, setPreviewIndex] = useState(null);

  const totalImages = value.length;
  const isLimitReached = totalImages >= maxImages;

  const previewUrls = useMemo(() => {
    return value.map((file) => URL.createObjectURL(file));
  }, [value]);

  // Cleanup URLs to prevent memory leak
  useEffect(() => {
    return () => {
      previewUrls.forEach((url) => URL.revokeObjectURL(url));
    };
  }, [previewUrls]);

  const handleUpload = (e) => {
    const files = Array.from(e.target.files || []);
    if (!files.length) return;

    if (totalImages + files.length > maxImages) {
      onError?.(`Maximum ${maxImages} images allowed`);
      e.target.value = "";
      return;
    }

    onChange([...value, ...files]);
    e.target.value = "";
  };

  const removeImage = (index) => {
    onChange(value.filter((_, i) => i !== index));
  };

  return (
    <>
      <div className="bg-white border rounded-2xl p-6 shadow-sm">
        <div className="flex justify-between items-center mb-5">
          <h3 className="text-sm font-semibold text-gray-800">
            {label}
          </h3>
          <span className="text-xs text-gray-500">
            {totalImages}/{maxImages}
          </span>
        </div>

        <div className="grid grid-cols-2 sm:grid-cols-3 gap-5">
          {previewUrls.map((url, index) => (
            <div
              key={index}
              className="relative group rounded-2xl overflow-hidden border bg-gray-100 shadow-sm"
            >
              <img
                src={url}
                alt=""
                onClick={() => setPreviewIndex(index)}
                className="h-28 w-full object-cover transition duration-300 group-hover:scale-105 cursor-pointer"
              />

              {/* Overlay */}
              <div className="absolute inset-0 bg-black/0 group-hover:bg-black/40 transition duration-300 pointer-events-none" />

              {/* Delete */}
              <button
                type="button"
                onClick={() => removeImage(index)}
                className="absolute top-2 right-2 bg-white text-red-600 rounded-full w-8 h-8 flex items-center justify-center shadow-md opacity-0 group-hover:opacity-100 transition hover:bg-red-600 hover:text-white"
              >
                <CloseIcon fontSize="small" />
              </button>
            </div>
          ))}

          {!isLimitReached && (
            <label className="flex flex-col items-center justify-center h-28 border-2 border-dashed border-gray-300 rounded-2xl cursor-pointer hover:border-blue-500 hover:bg-blue-50 transition">
              <span className="text-3xl text-gray-400">+</span>
              <span className="text-xs text-gray-500 mt-1">
                Add Image
              </span>

              <input
                ref={fileInputRef}
                type="file"
                accept="image/*"
                multiple
                hidden
                onChange={handleUpload}
              />
            </label>
          )}
        </div>
      </div>

      {/*PREVIEW DIALOG */}
      <ImagePreviewDialog
        open={previewIndex !== null}
        images={previewUrls}
        index={previewIndex}
        onChangeIndex={setPreviewIndex}
        onClose={() => setPreviewIndex(null)}
      />
    </>
  );
};

export default ImageUploader;