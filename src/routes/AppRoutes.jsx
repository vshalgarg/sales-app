// AppRoutes.jsx
import { Suspense, lazy } from "react";
import { Routes, Route } from "react-router-dom";
import PublicLayout from "../layout/PublicLayout";
import AppLayout from "../layout/AppLayout";
import PrivateRoute from "./PrivateRoute";
import CustomerDashboard from "../components/CustomerDashboard";
import StaffDashboard from "../components/StaffDashboard";
import BillEntry from "../components/BillEntry";
import BillHistory from "../components/BillHistory";
import CreditEntryForm from "../components/CreditEntry";
import Bills from "../components/Bills";
import Credit from "../components/Credit";
import PurchaseEntry from "../components/PurchaseEntry";
import Purchase from "../components/Purchase";
import TransportDashboard from "../components/TransportDashboard";


const SupplierDashboard = lazy(() => import("../components/SupplierDashboard"));
const Users = lazy(() => import("../components/Users"));
const Login = lazy(() => import("../components/Login"));

const FallbackLoader = () => (
  <div className="p-4 text-gray-500">Loading...</div>
);

export default function AppRoutes() {
  return (
    <Suspense fallback={<FallbackLoader />}>
      <Routes>
        {/* Public Route */}
        <Route path="/" element={<PublicLayout />}>
          <Route index element={<Login />} />
        </Route>

        {/* Protected Routes */}
        <Route path="/" element={<PrivateRoute />}>
          <Route element={<AppLayout />}>
            <Route path="suppliers" element={<SupplierDashboard />} />
            <Route path="customers" element={<CustomerDashboard />} />
            <Route path="staff" element={<StaffDashboard />}  />
            <Route path="users" element={<Users />} />
            <Route path="bill-entry" element={<BillEntry />} />
            <Route path="bills" element={<Bills />} />
            <Route path="bill-history" element={<BillHistory />} />
            <Route path="credit-entry" element={<CreditEntryForm />} />
            <Route path="credits" element={<Credit />} />
            <Route path="/purchase-entry" element={<PurchaseEntry />} />
            <Route path="/purchase" element={<Purchase />} />
            <Route path="/transports" element={<TransportDashboard />} />
          </Route>
        </Route>

        {/* Fallback */}
        <Route path="*" element={<div>Page Not Found</div>} />
      </Routes>
    </Suspense>
  );
}
