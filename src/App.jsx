import { BrowserRouter } from "react-router-dom";
import "./App.css";
import AppRoutes from "./routes/AppRoutes";
import { SnackbarProvider } from "./context/SnackbarContext";
import { AuthProvider } from "./context/AuthContext";
import { UnsavedProvider } from "./context/UnsavedChangesContext";
import { LoaderProvider, useLoader } from "./context/LoaderContext";
import { setLoader } from "./api/api";
import { useEffect } from "react";
import GlobalLoader from "./components/common/GlobalLoader";

function AppContent() {
  const loader = useLoader();

  useEffect(() => {
    setLoader(loader); // connect interceptor with loader
  }, [loader]);

  return (
    <>
      {loader.loading && <GlobalLoader />} {/* GLOBAL LOADER */}
      
      <BrowserRouter>
        <SnackbarProvider>
          <AuthProvider>
            <div className="min-h-screen bg-white text-black dark:bg-gray-900 dark:text-white transition-colors">
              <AppRoutes />
            </div>
          </AuthProvider>
        </SnackbarProvider>
      </BrowserRouter>
    </>
  );
}

function App() {
  return (
    <UnsavedProvider>
      <LoaderProvider>
        <AppContent />
      </LoaderProvider>
    </UnsavedProvider>
  );
}

export default App;