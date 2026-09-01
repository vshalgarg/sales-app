import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { loginUser } from "@/services/LoginService";
import { useSnackbar } from "@/contexts/SnackbarContext";
import { useAuth } from "@/contexts/AuthContext";

const Login = () => {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState("");
  const [isLoading, setIsLoading] = useState(false);

  const navigate = useNavigate();
  const { showSnackbar } = useSnackbar();
  const { login, auth, setAuth } = useAuth();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");
    setIsLoading(true);

    try {
      const data = await loginUser(email, password);
      console.log("auth", auth);
      login({
        token: data.token,
        role: data.roles,
        userId: data.userId,
        username: data.username,
      });

      showSnackbar("Login successful!", "success");
      navigate("/suppliers", { replace: true });
    } catch (err) {
      console.error("Login error:", err);
      const errorMsg = err.message || "Login failed. Please try again.";
      setError(errorMsg);
      showSnackbar(errorMsg, "error");
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="flex min-h-dvh flex-col md:flex-row">
      {/* Left decorative side */}
      <div className="hidden md:flex md:flex-1 bg-[#6c63ff] items-center justify-center">
        <h1 className="text-white text-5xl font-extrabold tracking-wide drop-shadow-lg">
          Hisabio
        </h1>
      </div>

      {/* Right - Form */}
      <div className="flex-1 flex items-center justify-center bg-gray-50 px-6 py-10 md:px-12">
        <div className="w-full max-w-md bg-white rounded-2xl shadow-lg p-8 md:p-10">
          <div className="text-center mb-8">
            <div className="flex justify-center">
              <img
                src="/logo.png"
                alt="Hisabio Logo"
                className="w-36 md:w-64 h-auto object-contain"
              />
            </div>
          </div>

          <form onSubmit={handleSubmit} className="space-y-5">
            {/* Email */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Username
              </label>
              <input
                type="text"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="Enter your username"
                className="w-full px-4 py-3 border border-gray-300 rounded-lg 
                         focus:outline-none focus:ring-2 focus:ring-[#6c63ff]/40 
                         focus:border-[#6c63ff] transition-colors"
                required
                autoFocus
              />
            </div>

            {/* Password with eye icon */}
            <div className="relative">
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Password
              </label>
              <input
                type={showPassword ? "text" : "password"}
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="Enter your password"
                className="w-full px-4 py-3 border border-gray-300 rounded-lg 
                         focus:outline-none focus:ring-2 focus:ring-[#6c63ff]/40 
                         focus:border-[#6c63ff] transition-colors pr-12"
                required
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className="absolute right-3 top-[42px] text-gray-500 hover:text-gray-700 focus:outline-none"
              >
                {showPassword ? (
                  // Eye off icon
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    fill="none"
                    viewBox="0 0 24 24"
                    strokeWidth={2}
                    stroke="currentColor"
                    className="w-5 h-5"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      d="M3.98 8.223A10.477 10.477 0 001.934 12C3.226 16.338 7.244 19.5 12 19.5c4.756 0 8.773-3.162 10.065-7.5a10.477 10.477 0 00-2.047-3.777m-3.018-1.5A9.98 9.98 0 0112 4.5c1.58 0 3.056.403 4.335 1.11M9 9l6 6m-6-6l6-6"
                    />
                  </svg>
                ) : (
                  // Eye icon
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    fill="none"
                    viewBox="0 0 24 24"
                    strokeWidth={2}
                    stroke="currentColor"
                    className="w-5 h-5"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"
                    />
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"
                    />
                  </svg>
                )}
              </button>
            </div>

            {error && (
              <div className="text-red-600 text-sm text-center bg-red-50 py-2 rounded-md">
                {error}
              </div>
            )}

            <button
              type="submit"
              disabled={isLoading}
              className={`w-full py-3 px-4 bg-[#6c63ff] text-white font-medium 
                       rounded-lg shadow-sm transition-all duration-200
                       ${isLoading
                  ? "opacity-70 cursor-not-allowed"
                  : "hover:bg-[#5a53d6] active:scale-[0.98]"
                }`}
            >
              {isLoading ? "Signing in..." : "Login →"}
            </button>
          </form>
        </div>
      </div>
    </div>
  );
};

export default Login;
