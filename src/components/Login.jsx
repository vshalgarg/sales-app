import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { loginUser } from "../service/LoginService";
import { useSnackbar } from "../context/SnackbarContext";
const Login = () => {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const navigate = useNavigate();

  const { showSnackbar } = useSnackbar();
  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");

    try {
      const data = await loginUser(email, password);
        
      localStorage.setItem("token", data.token);
      localStorage.setItem("username", data.username);
      localStorage.setItem("user", JSON.stringify(data.user));
      navigate("/suppliers", { replace: true });
    } catch (err) {
      console.error("API Error:", err);
      setError(err.message || "Login failed. Please try again.");
      showSnackbar(err.message, "error");
    }
  };

  return (
    <div className="flex h-screen">
      {/* Left */}
      <div className="flex flex-1 bg-[#6c63ff] items-center justify-center">
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          strokeWidth={2}
          stroke="white"
          className="w-24 h-24"
        >
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            d="M12 4l6 8H6l6-8zM6 20h12"
          />
        </svg>
      </div>

      {/* Right */}
      <div className="flex flex-1 items-center justify-center bg-white">
        <div className="w-full max-w-sm">
          <div className="flex justify-center mb-6">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
              strokeWidth={2}
              stroke="#6c63ff"
              className="w-10 h-10"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                d="M12 4l6 8H6l6-8zM6 20h12"
              />
            </svg>
          </div>

          <h2 className="text-center text-2xl font-bold mb-1">
            Management Portal
          </h2>
          <p className="text-center text-gray-500 mb-6">
            Simplified Billing, Streamlined Business.
          </p>

          <form className="space-y-4" onSubmit={handleSubmit}>
            <div>
              <label className="block text-sm font-medium text-gray-700">
                Email
              </label>
              <input
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                type="email"
                placeholder="Enter your email"
                className="mt-1 block w-full px-3 py-2 border rounded-md shadow-sm focus:outline-none focus:ring-[#6c63ff] focus:border-[#6c63ff]"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700">
                Password
              </label>
              <input
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                type="password"
                placeholder="Enter your password"
                className="mt-1 block w-full px-3 py-2 border rounded-md shadow-sm focus:outline-none focus:ring-[#6c63ff] focus:border-[#6c63ff]"
              />
            </div>

            {error && (
              <p className="text-red-500 text-sm text-center">{error}</p>
            )}

            <button
              type="submit"
              className="w-full bg-[#6c63ff] text-white py-2 rounded-md hover:bg-[#5a53d6]"
            >
              Login →
            </button>
          </form>
        </div>
      </div>
    </div>
  );
};

export default Login;
