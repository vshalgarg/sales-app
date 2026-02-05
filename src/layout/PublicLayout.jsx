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
  return <Outlet />;
};

export default PublicLayout;
