import { createContext, useContext, useState } from "react";

const UnsavedContext = createContext();

export const UnsavedProvider = ({ children }) => {
  const [isDirty, setIsDirty] = useState(false);

  return (
    <UnsavedContext.Provider value={{ isDirty, setIsDirty }}>
      {children}
    </UnsavedContext.Provider>
  );
};

export const useUnsaved = () => useContext(UnsavedContext);