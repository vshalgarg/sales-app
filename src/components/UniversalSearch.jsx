import { useState, useRef, useEffect } from "react";

export default function UniversalSearch({
  placeholder = "Search...",
  query,
  setQuery,
  searchFn,
  onResult,
  searchOnType = true,
  minChars = 2,
  pageSize = 8,
  suggestionKey = "name",
  onClear,
  showSuggestions = true,
}) {
  const [suggestions, setSuggestions] = useState([]);
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const searchRef = useRef(null);
  const timeoutRef = useRef(null);
  const inputRef = useRef(null);

  useEffect(() => {
    const handler = (e) => {
      if (searchRef.current && !searchRef.current.contains(e.target)) {
        setIsDropdownOpen(false);
      }
    };
    document.addEventListener("mousedown", handler);
    return () => document.removeEventListener("mousedown", handler);
  }, []);

  // Debounced search function
  const debouncedSearch = async (searchTerm) => {
    if (timeoutRef.current) {
      clearTimeout(timeoutRef.current);
    }

    return new Promise((resolve) => {
      timeoutRef.current = setTimeout(async () => {
        try {
          setIsLoading(true);
          const results = await searchFn(searchTerm, 0, pageSize);
          resolve(results);
        } catch (err) {
          console.error(err);
          resolve({ content: [], totalPages: 0 });
        } finally {
          setIsLoading(false);
        }
      }, 300);
    });
  };

  const handleChange = async (e) => {
    const value = e.target.value;
    console.log(value);
    setQuery(value);

    if (!value.trim()) {
      setSuggestions([]);
      setIsDropdownOpen(false);

      if (onClear) {
        onClear();
      }

      if (onResult) {
        onResult({ content: [], totalPages: 0 }, "");
      }

      return;
    }

    if (searchOnType && value.length >= minChars) {
      const response = await debouncedSearch(value);
      const results = response.content || response || [];

      if (showSuggestions) {
        const suggestionValues = results
          .map(
            (item) =>
              item[suggestionKey] ||
              item.name ||
              item.supplierName ||
              item.customerName ||
              "",
          )
          .filter(Boolean);
        setSuggestions(suggestionValues);
        setIsDropdownOpen(true);
      }

      if (onResult) onResult(response, value);
    } else {
      setSuggestions([]);
    }
  };

  const handleKeyDown = async (e) => {
    if (e.key === "Enter") {
      e.preventDefault();
      if (!query.trim()) {
        if (onResult) onResult({ content: [], totalPages: 0 }, "");
        setIsDropdownOpen(false);
        return;
      }

      try {
        setIsLoading(true);
        const response = await searchFn(query.trim(), 0, pageSize);
        if (onResult) onResult(response, query.trim());
        setIsDropdownOpen(false);
        setSuggestions([]);
      } catch (err) {
        console.error(err);
      } finally {
        setIsLoading(false);
      }
    }
  };

  const handleSuggestionClick = async (selectedName) => {
    setQuery(selectedName);
    setIsDropdownOpen(false);

    try {
      const response = await searchFn(selectedName, 0, pageSize);
      const results = response.content || response || [];
      const selected = results.find(
        (item) =>
          item[suggestionKey] === selectedName ||
          item.name === selectedName ||
          item.supplierName === selectedName ||
          item.customerName === selectedName,
      );

      if (onResult)
        onResult(
          { content: selected ? [selected] : [], totalPages: 1 },
          selectedName,
        );
    } catch (err) {
      console.error(err);
    }
  };

  return (
    <div className="flex items-center w-full">
      <div className="relative w-full max-w-md lg:max-w-lg">
        {/* Input Container */}
        <div className="relative group">
          {/* Search Icon (left) */}
          <div className="absolute inset-y-0 left-0 flex items-center pl-3.5 pointer-events-none">
            <svg
              className="w-5 h-4 md:h-5 text-gray-400 group-focus-within:text-blue-500 transition-colors duration-200"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
              />
            </svg>
          </div>

          <input
            ref={inputRef}
            type="text"
            placeholder={placeholder || "Search staff, name, phone..."}
            value={query}
            onChange={handleChange}
            onKeyDown={handleKeyDown}
            onFocus={() => setIsDropdownOpen(true)}
            onBlur={() => setTimeout(() => setIsDropdownOpen(false), 200)}
            className={`
            w-full 
            pl-11 pr-28 
            py-2
            md:py-2.5
            bg-white dark:bg-gray-900
            border border-gray-300 dark:border-gray-600
            rounded-full
            text-gray-900 dark:text-gray-100
            placeholder-gray-500 dark:placeholder-gray-400
            focus:outline-none 
         focus:border-black
            transition-all duration-200
            shadow-sm hover:shadow
          `}
            autoComplete="off"
            spellCheck="false"
          />

          {/* Right side buttons (clear + loading) */}
          <div className="absolute inset-y-0 right-0 flex items-center pr-3 space-x-2">
            {isLoading && (
              <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-black" />
            )}

            {query.length > 0 && (
              <button
                type="button"
                onClick={() => {
                  handleChange({ target: { value: "" } });
                  inputRef.current?.focus();
                }}
                className="p-1.5 rounded-full hover:bg-gray-200 dark:hover:bg-gray-700 
                       text-gray-400 hover:text-gray-700 dark:hover:text-gray-300 
                       transition-colors"
              >
                <svg
                  className="w-4 h-4"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M6 18L18 6M6 6l12 12"
                  />
                </svg>
              </button>
            )}
          </div>
        </div>

        {/* Suggestions Dropdown */}
        {showSuggestions && isDropdownOpen && (
          <>
            {suggestions.length > 0 ? (
              <ul
                className={`
                absolute z-20 w-full mt-1.5
                bg-white dark:bg-gray-900
                border border-gray-200 dark:border-gray-700
                rounded-xl shadow-2xl
                overflow-hidden
                max-h-72 overflow-y-auto
                backdrop-blur-sm
                divide-y divide-gray-100 dark:divide-gray-800
              `}
              >
                {suggestions.map((name, index) => (
                  <li
                    key={index}
                    onClick={() => handleSuggestionClick(name)}
                    className={`
                    px-5 py-3
                    cursor-pointer
                    transition-colors duration-150
                    ${
                      index === activeSuggestionIndex
                        ? "bg-blue-50 dark:bg-blue-900/40 text-blue-800 dark:text-blue-200"
                        : "hover:bg-gray-50 dark:hover:bg-gray-800/60 text-gray-900 dark:text-gray-100"
                    }
                  `}
                  >
                    {highlightMatch ? highlightMatch(name, query) : name}
                  </li>
                ))}
              </ul>
            ) : (
              query.trim().length > 1 &&
              !isLoading && (
                <div className="absolute z-50 w-full mt-1.5 px-5 py-4 bg-white dark:bg-gray-900 border border-gray-200 dark:border-gray-700 rounded-xl shadow-xl text-sm text-gray-500 dark:text-gray-400">
                  No results found for{" "}
                  <span className="font-medium">"{query}"</span>
                </div>
              )
            )}
          </>
        )}
      </div>
    </div>
  );
}
