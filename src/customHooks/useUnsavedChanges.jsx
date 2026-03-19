import { useEffect, useRef } from "react";

export default function useUnsavedChanges(data, open = true) {
  const initialRef = useRef(null);

  // snapshot set
  useEffect(() => {
    if (open && data && initialRef.current === null) {
      initialRef.current = JSON.stringify(data);
    }
  }, [data, open]);

  // reset only if open is explicitly controlled (modal case)
  useEffect(() => {
    if (open === false) {
      initialRef.current = null;
    }
  }, [open]);

  const isDirty = () => {
    if (!initialRef.current) return false;
    return JSON.stringify(data) !== initialRef.current;
  };

  return { isDirty };
}