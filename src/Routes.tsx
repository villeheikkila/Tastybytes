import {
  Navigate,
  PathRouteProps,
  Route,
  Routes,
  useLocation,
} from "react-router-dom";
import { useAuth } from "./hooks/useAuth";
import Account from "./pages/Account";
import CheckInTable from "./pages/check-in-table";
import Login from "./pages/Login";
import SignUp from "./pages/SignUp";

export default () => {
  return (
    <Routes>
      <Route path="/login" element={<Login />} />
      <Route path="/sign-up" element={<SignUp />} />
      <Route path="/check-ins" element={<CheckInTable />} />
      <Route
        path="/"
        element={
          <RequireAuth>
            <Account />
          </RequireAuth>
        }
      />
    </Routes>
  );
};

function RequireAuth({ children }: { children: JSX.Element }) {
  let { user } = useAuth();
  console.log("user: ", user);
  let location = useLocation();

  if (!user) {
    return <Navigate to="/login" state={{ from: location }} replace />;
  }

  return children;
}
