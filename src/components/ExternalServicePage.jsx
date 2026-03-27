import { useState } from "react";
import api from "../api/api";

export default function ExternalServicePage() {
  const [url, setUrl] = useState("");
  const [response, setResponse] = useState(null);
  const [loading, setLoading] = useState(false);

  const handleSend = async () => {
    if (!url) {
      alert("URL required");
      return;
    }

    setLoading(true);

    try {
      const res = await api.get(url);

      setResponse({
        status: res.status,
        data: res.data,
      });

    } catch (err) {
      setResponse({
        status: err?.response?.status || 500,
        data: err?.response?.data || err.message,
      });
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="p-6 max-w-4xl mx-auto">

      <h1 className="text-2xl font-bold mb-4">
        External Service
      </h1>

      <div className="flex gap-2 mb-4">

        <input
          value={url}
          onChange={(e) => setUrl(e.target.value)}
          placeholder="https://api.example.com/users?id=1"
          className="flex-1 border p-2 rounded"
        />

        <button
          onClick={handleSend}
          disabled={loading}
          className="bg-blue-600 text-white px-5 py-2 rounded hover:bg-blue-700 whitespace-nowrap"
        >
          {loading ? "Loading..." : "Send"}
        </button>

      </div>

      {/* RESPONSE */}
      {response && (
        <div className="mt-6 border rounded p-4 bg-gray-50 dark:bg-zinc-900">

          <div className="flex justify-between mb-2">
            <span className="font-semibold">
              Status: {response.status}
            </span>
          </div>

          <div className="border rounded bg-white dark:bg-zinc-800 p-2">
            <pre className="text-sm overflow-auto max-h-[400px] whitespace-pre-wrap break-words">
              {JSON.stringify(response.data, null, 2)}
            </pre>
          </div>

        </div>
      )}
    </div>
  );
}