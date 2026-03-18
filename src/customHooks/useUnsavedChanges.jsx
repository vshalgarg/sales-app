import { useEffect, useRef } from "react";

export default function useUnsavedChanges(data) {
  const initialRef = useRef(null);

 useEffect(() => {
  if (!initialRef.current && data) {
    initialRef.current = JSON.stringify(data);
  }
}, []);

  const isDirty = () => {
    return JSON.stringify(data) !== initialRef.current;
  };

  // browser refresh guard
  useEffect(() => {
    const handleBeforeUnload = (e) => {
      if (!isDirty()) return;

      e.preventDefault();
      e.returnValue = "";
    };

    if (isDirty()) {
      window.addEventListener("beforeunload", handleBeforeUnload);
    }

    return () => {
      window.removeEventListener("beforeunload", handleBeforeUnload);
    };
  }, [data]);

  return { isDirty };
}