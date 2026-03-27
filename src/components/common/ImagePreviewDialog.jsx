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
      fullScreen
      PaperProps={{
        sx: {
          backgroundColor: "rgba(0,0,0,0.9)",
        },
      }}
    >
      {/* CLOSE */}
      <IconButton
        onClick={onClose}
        sx={{
          position: "absolute",
          top: 16,
          right: 16,
          color: "white",
          zIndex: 20,
          backgroundColor: "rgba(255,255,255,0.1)",
          "&:hover": {
            backgroundColor: "rgba(255,255,255,0.2)",
          },
        }}
      >
        <CloseIcon />
      </IconButton>

      {/* LEFT */}
      {images.length > 1 && (
        <IconButton
          onClick={() =>
            onChangeIndex((index - 1 + images.length) % images.length)
          }
          sx={{
            position: "absolute",
            top: "50%",
            left: 16,
            transform: "translateY(-50%)",
            color: "white",
            zIndex: 20,
            backgroundColor: "rgba(255,255,255,0.1)",
            "&:hover": {
              backgroundColor: "rgba(255,255,255,0.2)",
            },
          }}
        >
          <ChevronLeftIcon fontSize="large" />
        </IconButton>
      )}

      {/* RIGHT */}
      {images.length > 1 && (
        <IconButton
          onClick={() =>
            onChangeIndex((index + 1) % images.length)
          }
          sx={{
            position: "absolute",
            top: "50%",
            right: 16,
            transform: "translateY(-50%)",
            color: "white",
            zIndex: 20,
            backgroundColor: "rgba(255,255,255,0.1)",
            "&:hover": {
              backgroundColor: "rgba(255,255,255,0.2)",
            },
          }}
        >
          <ChevronRightIcon fontSize="large" />
        </IconButton>
      )}

      {/* CONTENT */}
      <div
        onTouchStart={handleTouchStart}
        onTouchEnd={handleTouchEnd}
        className="w-full h-full flex items-center justify-center"
      >
        {(() => {
          const isPdf =
            files[index]?.type === "application/pdf" ||
            images[index]?.endsWith(".pdf");

          if (isPdf) {
            return (
              <iframe
                src={images[index]}
                title="PDF Preview"
                className="w-[95vw] h-[90vh] rounded-lg bg-white"
              />
            );
          }

          return (
            <img
              src={images[index]}
              alt="preview"
              className="max-h-[90vh] max-w-[95vw] object-contain rounded-lg shadow-lg"
            />
          );
        })()}
      </div>
    </Dialog>
  );
};

export default ImagePreviewDialog;
