import { BrowserRouter } from "react-router-dom";
import "./App.css";
import AppRoutes from "./routes/AppRoutes";
import { SnackbarProvider } from "./context/SnackbarContext";
import { AuthProvider } from "./context/AuthContext";
import { UnsavedProvider } from "./context/UnsavedChangesContext";

function App() {
  return (
    <UnsavedProvider>
      
      <BrowserRouter>
        <SnackbarProvider>
          <AuthProvider>
            <div className="min-h-screen bg-white text-black dark:bg-gray-900 dark:text-white transition-colors">
              <AppRoutes />
            </div>
          </AuthProvider>
        </SnackbarProvider>
      </BrowserRouter>

    </UnsavedProvider>

  );
}

export default App;
