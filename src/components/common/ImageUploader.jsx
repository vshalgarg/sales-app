import { useRef, useState, useEffect } from "react";
import ImagePreviewDialog from "./ImagePreviewDialog";

const ImageUploader = ({
    value = [],
    onChange,
    maxImages = 2,
    label = "Upload Images",
    onError,
}) => {
    const fileInputRef = useRef(null);
    const [previewIndex, setPreviewIndex] = useState(null);
    const [previewUrl, setPreviewUrl] = useState(null);

    const isLimitReached = value.length >= maxImages;

    const handleUpload = (e) => {
        const files = Array.from(e.target.files);

        if (isLimitReached || value.length + files.length > maxImages) {
            onError?.(`Maximum ${maxImages} images allowed`);
            e.target.value = null;
            return;
        }

        onChange([...value, ...files]);
        e.target.value = null; 
    };

    const removeImage = (index) => {
        onChange(value.filter((_, i) => i !== index));
    };

    // preview URL handling
    useEffect(() => {
        if (previewIndex !== null) {
            const url = URL.createObjectURL(value[previewIndex]);
            setPreviewUrl(url);
            return () => URL.revokeObjectURL(url);
        }
    }, [previewIndex, value]);

    return (
        <>
            {/* Upload Button */}
            <button
                type="button"
                disabled={isLimitReached}
                onClick={() => !isLimitReached && fileInputRef.current.click()}
                className={`
          px-4 py-2 rounded-lg
          text-sm sm:text-base font-medium
          w-full sm:w-auto
          transition
          ${isLimitReached
                        ? "bg-gray-200 text-gray-400 cursor-not-allowed"
                        : "bg-blue-600 text-white hover:bg-blue-700"
                    }
        `}
            >
                {label}
            </button>

            <input
                ref={fileInputRef}
                type="file"
                accept="image/*"
                multiple
                hidden
                onChange={handleUpload}
            />

            {/* Images Grid */}
            {value.length > 0 && (
                <div className="
          grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4
          gap-3 sm:gap-4 mt-4
        ">
                    {value.map((img, idx) => (
                        <div key={idx} className="relative">
                            <img
                                src={URL.createObjectURL(img)}
                                alt=""
                                onClick={() => setPreviewIndex(idx)}
                                className="
                  h-20 sm:h-24
                  w-full object-cover
                  rounded-lg border
                  cursor-pointer
                "
                            />

                            {/* Remove */}
                            <button
                                onClick={() => removeImage(idx)}
                                className="
                  absolute -top-2 -right-2
                  bg-red-600 text-white
                  rounded-full
                  w-5 h-5 sm:w-6 sm:h-6
                  text-xs
                "
                            >
                                ✕
                            </button>
                        </div>
                    ))}
                </div>
            )}

            {/* Preview Dialog */}
            <ImagePreviewDialog
                open={previewIndex !== null}
                images={value.map((file) => URL.createObjectURL(file))}
                index={previewIndex}
                onChangeIndex={setPreviewIndex}
                onClose={() => setPreviewIndex(null)}
            />

        </>
    );
};

export default ImageUploader;
