import Dialog from "@mui/material/Dialog";
import IconButton from "@mui/material/IconButton";
import CloseIcon from "@mui/icons-material/Close";
import ChevronLeftIcon from "@mui/icons-material/ChevronLeft";
import ChevronRightIcon from "@mui/icons-material/ChevronRight";
import { useRef } from "react";

const ImagePreviewDialog = ({
  open,
  images = [],
  files = [],
  index = 0,
  onClose,
  onChangeIndex,
}) => {
  const touchStartX = useRef(0);
  const touchEndX = useRef(0);

  if (!images.length) return null;

  const handleTouchStart = (e) => {
    touchStartX.current = e.touches[0].clientX;
  };

  const handleTouchEnd = (e) => {
    touchEndX.current = e.changedTouches[0].clientX;
    handleSwipe();
  };

  const handleSwipe = () => {
    const diff = touchStartX.current - touchEndX.current;

    // swipe threshold
    if (Math.abs(diff) < 50) return;

    if (diff > 0) {
      // swipe left → next
      onChangeIndex((index + 1) % images.length);
    } else {
      // swipe right → prev
      onChangeIndex(
        (index - 1 + images.length) % images.length
      );
    }
  };

  return (
    <Dialog
      open={open}
      onClose={onClose}
      maxWidth="lg"
      fullWidth
    >
      {/* Close */}
      <IconButton
        onClick={onClose}
        sx={{
          position: "absolute",
          top: 8,
          right: 8,
          zIndex: 10,
          backgroundColor: "white",
        }}
      >
        <CloseIcon />
      </IconButton>

      {/* Left Arrow (desktop) */}
      {images.length > 1 && (
        <IconButton
          onClick={() =>
            onChangeIndex(
              (index - 1 + images.length) % images.length
            )
          }
          sx={{
            position: "absolute",
            top: "50%",
            left: 8,
            zIndex: 10,
            display: { xs: "none", sm: "flex" },
          }}
        >
          <ChevronLeftIcon fontSize="large" />
        </IconButton>
      )}

      {/* Right Arrow */}
      {images.length > 1 && (
        <IconButton
          onClick={() =>
            onChangeIndex((index + 1) % images.length)
          }
          sx={{
            position: "absolute",
            top: "50%",
            right: 8,
            zIndex: 10,
            display: { xs: "none", sm: "flex" },
          }}
        >
          <ChevronRightIcon fontSize="large" />
        </IconButton>
      )}

      {/* Image */}
      <div
        onTouchStart={handleTouchStart}
        onTouchEnd={handleTouchEnd}
        style={{
          padding: 16,
          display: "flex",
          justifyContent: "center",
        }}
      >
        {(() => {
          const isPdf =
            files[index]?.type === "application/pdf" ||
            images[index]?.endsWith(".pdf");

          if (isPdf) {
            return (
              <div className="text-center p-6">
                <p className="text-gray-600 mb-3">PDF Preview</p>
                <button
                  onClick={() => window.open(images[index], "_blank")}
                  className="px-4 py-2 bg-blue-600 text-white rounded-lg"
                >
                  Open PDF
                </button>
              </div>
            );
          }
          return (
            <img
              src={images[index]}
              alt="preview"
              style={{
                width: "100%",
                maxHeight: "80vh",
                objectFit: "contain",
                borderRadius: 8,
              }}
            />
          );
        })()}
      </div>
    </Dialog>
  );
};

export default ImagePreviewDialog;
