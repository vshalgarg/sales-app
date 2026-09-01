import { BrowserRouter } from "react-router-dom";
import "./App.css";
import AppRoutes from "./routes/AppRoutes";

import { SnackbarProvider } from "./contexts/SnackbarContext";
import { AuthProvider } from "./contexts/AuthContext";
import { UnsavedProvider } from "./contexts/UnsavedChangesContext";
import { LoaderProvider, useLoader } from "./contexts/LoaderContext";

import { setLoader } from "./api/api";
import { useEffect } from "react";
import GlobalLoader from "./components/GlobalLoader";
import { ConfigProvider } from "./contexts/ConfigContext";

// handles loader + interceptor
function AppInitializer({ children }) {
  const loader = useLoader();

  useEffect(() => {
    setLoader(loader);
  }, [loader]);

  return (
    <>
      {loader.loading && <GlobalLoader />}
      {children}
    </>
  );
}

// All providers
function AppProviders({ children }) {
  return (
    <UnsavedProvider>
      <LoaderProvider>
        <SnackbarProvider>
          <AuthProvider>
            <ConfigProvider>{children}</ConfigProvider>
          </AuthProvider>
        </SnackbarProvider>
      </LoaderProvider>
    </UnsavedProvider>
  );
}

// App
function App() {
  return (
    <BrowserRouter>
      <AppProviders>
        <AppInitializer>
          <div className="min-h-screen bg-white text-black dark:bg-gray-900 dark:text-white transition-colors">
            <AppRoutes />
          </div>
        </AppInitializer>
      </AppProviders>
    </BrowserRouter>
  );
}

export default App;