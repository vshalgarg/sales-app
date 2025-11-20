import { BrowserRouter } from "react-router-dom";
import "./App.css";
import AppRoutes from "./routes/AppRoutes";
import { SnackbarProvider } from "./context/SnackbarContext";

function App() {
  return (
    <BrowserRouter>
      <SnackbarProvider>
        <div className="min-h-screen bg-white text-black dark:bg-gray-900 dark:text-white transition-colors">
          <AppRoutes />
        </div>
      </SnackbarProvider>
    </BrowserRouter>
  );
}

export default App;
