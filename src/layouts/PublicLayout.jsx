import { Suspense } from "react";
import { Navigate, Outlet } from "react-router-dom";

const PublicLayout = () => {
  const token = localStorage.getItem("token");
  const lastRoute = localStorage.getItem("lastRoute");
  if (token) {
    return (
      <Navigate
        to={lastRoute && lastRoute !== "/" ? lastRoute : "/suppliers"}
        replace
      />
    );
  }
  return (
    <Suspense fallback={<div className="p-4 text-gray-500">Loading...</div>}>
      <Outlet />
    </Suspense>
  );
};

export default PublicLayout;
