export default function GlobalLoader() {
  return (
    <div className="fixed inset-0 flex items-center justify-center bg-black/20 z-[9999]">
      <div className="w-12 h-12 border-4 border-gray-300 border-t-black rounded-full animate-spin"></div>
    </div>
  );
}