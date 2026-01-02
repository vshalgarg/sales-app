// src/routes/PrivateRoute.jsx
import { Navigate, Outlet } from "react-router-dom";

const PrivateRoute = ({ requiredRoles }) => {
  const token = localStorage.getItem("token");
  console.log("token",!token)
  const roles = JSON.parse(localStorage.getItem("roles")); 

  if (token=="undefined" || token == null) {
   return <Navigate to="/" replace />;
  }

  // Optional: role-based access
  if (requiredRoles && !requiredRoles.some(role => user?.roles?.includes(role))) {
    return <div>Unauthorized</div>;
  }

  return <Outlet />;
};

export default PrivateRoute;
