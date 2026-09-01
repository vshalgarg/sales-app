import { Suspense, lazy } from "react";
import { Routes, Route, Navigate } from "react-router-dom";
import PublicLayout from "../layouts/PublicLayout";
import AppLayout from "../layouts/AppLayout";
import PrivateRoute from "./PrivateRoute";

const Login = lazy(() => import("@/features/auth/Login"));
const SupplierDashboard = lazy(() => import("@/features/suppliers/SupplierDashboard"));
const CustomerDashboard = lazy(() => import("@/features/customers/CustomerDashboard"));
const StaffDashboard = lazy(() => import("@/features/staff/StaffDashboard"));
const Users = lazy(() => import("@/features/users/Users"));
const TransportDashboard = lazy(() => import("@/features/transports/TransportDashboard"));
const Configurations = lazy(() => import("@/features/configurations/Configurations"));
const BillEntry = lazy(() => import("@/features/bills/BillEntry"));
const CreditEntryForm = lazy(() => import("@/features/credits/CreditEntry"));
const PurchaseEntry = lazy(() => import("@/features/purchases/PurchaseEntry"));
const RetailEntry = lazy(() => import("@/features/retail/RetailEntry"));
const Bills = lazy(() => import("@/features/bills/Bills"));
const BillHistory = lazy(() => import("@/features/bills/BillHistory"));
const Credit = lazy(() => import("@/features/credits/Credit"));
const Purchase = lazy(() => import("@/features/purchases/Purchase"));
const Retail = lazy(() => import("@/features/retail/Retail"));
const Ledger = lazy(() => import("@/features/ledger/Ledger"));
const Reports = lazy(() => import("@/features/reports/Reports"));

const RouteFallback = () => (
  <div className="p-4 text-gray-500">Loading...</div>
);

export default function AppRoutes() {
  return (
    <Suspense fallback={<RouteFallback />}>
      <Routes>
        <Route path="/" element={<PublicLayout />}>
          <Route index element={<Login />} />
        </Route>

        <Route path="/" element={<PrivateRoute />}>
          <Route element={<AppLayout />}>
            <Route path="suppliers" element={<SupplierDashboard />} />
            <Route path="customers" element={<CustomerDashboard />} />
            <Route path="staff" element={<StaffDashboard />} />
            <Route path="users" element={<Users />} />
            <Route path="bill-entry" element={<BillEntry />} />
            <Route path="retail-entry" element={<RetailEntry />} />
            <Route path="bills" element={<Bills />} />
            <Route path="bill-history" element={<BillHistory />} />
            <Route path="credit-entry" element={<CreditEntryForm />} />
            <Route path="credits" element={<Credit />} />
            <Route path="/purchase-entry" element={<PurchaseEntry />} />
            <Route path="/purchase" element={<Purchase />} />
            <Route path="/retail" element={<Retail />} />
            <Route path="/graph" element={<Reports />} />
            <Route path="/reports" element={<Navigate to="/graph" replace />} />
            <Route path="/transports" element={<TransportDashboard />} />
            <Route path="/configurations" element={<Configurations />} />
            <Route path="/ledger" element={<Ledger />} />
          </Route>
        </Route>

        <Route path="*" element={<div>Page Not Found</div>} />
      </Routes>
    </Suspense>
  );
}
