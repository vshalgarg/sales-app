import { useState, useRef, useEffect } from "react";
import { Search } from "lucide-react";
import {
  SEARCH_CLEAR_CLASS,
  SEARCH_ICON_CLASS,
  SEARCH_INPUT_CLASS,
  SEARCH_WRAPPER_CLASS,
  SURFACE_BORDER,
} from "../theme/appTheme";

export default function UniversalSearch({
  placeholder = "Search...",
  query,
  setQuery,
  searchFn,
  onResult,
  searchOnType = false,
  minChars = 1,
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
  // True after Enter search; used so emptying restores default only when needed
  const hasActiveSearchRef = useRef(false);

  useEffect(() => {
    const handler = (e) => {
      if (searchRef.current && !searchRef.current.contains(e.target)) {
        setIsDropdownOpen(false);
      }
    };
    document.addEventListener("mousedown", handler);
    return () => document.removeEventListener("mousedown", handler);
  }, []);

  useEffect(() => {
    return () => {
      if (timeoutRef.current) clearTimeout(timeoutRef.current);
    };
  }, []);

  const restoreDefaultView = () => {
    if (!hasActiveSearchRef.current) return;
    hasActiveSearchRef.current = false;
    if (onClear) {
      onClear();
    } else if (onResult) {
      onResult({ content: [], totalPages: 0 }, "");
    }
  };

  const runSearch = async (searchTerm) => {
    if (timeoutRef.current) {
      clearTimeout(timeoutRef.current);
    }

    if (searchOnType) {
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
    }

    try {
      setIsLoading(true);
      return await searchFn(searchTerm, 0, pageSize);
    } catch (err) {
      console.error(err);
      return { content: [], totalPages: 0 };
    } finally {
      setIsLoading(false);
    }
  };

  const applySuggestions = (response) => {
    if (!showSuggestions) return;

    const results = response.content || response || [];
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
    setIsDropdownOpen(suggestionValues.length > 0);
  };

  const handleChange = async (e) => {
    const value = e.target.value;
    setQuery(value);
    setSuggestions([]);
    setIsDropdownOpen(false);

    // Backspace/clear text until empty → restore default list
    if (!value.trim()) {
      restoreDefaultView();
      return;
    }

    // Typing (non-empty) never triggers API unless searchOnType
    if (!searchOnType) return;

    if (value.length < minChars) return;

    const response = await runSearch(value);
    applySuggestions(response);
    if (onResult) onResult(response, value);
  };

  const handleClearInput = () => {
    setQuery("");
    setSuggestions([]);
    setIsDropdownOpen(false);
    inputRef.current?.focus();
    restoreDefaultView();
  };

  const handleKeyDown = async (e) => {
    if (e.key !== "Enter") return;

    e.preventDefault();
    const trimmed = query.trim();

    // Empty Enter → no API
    if (!trimmed || trimmed.length < minChars) {
      setIsDropdownOpen(false);
      setSuggestions([]);
      return;
    }

    try {
      const response = await runSearch(trimmed);
      hasActiveSearchRef.current = true;
      if (onResult) onResult(response, trimmed);
      setIsDropdownOpen(false);
      setSuggestions([]);
    } catch (err) {
      console.error(err);
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

      hasActiveSearchRef.current = true;
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
    <div className="flex items-center">
      <div className={SEARCH_WRAPPER_CLASS} ref={searchRef}>
        <div className="relative">
          <div className="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-4">
            <Search className={SEARCH_ICON_CLASS} strokeWidth={1.75} />
          </div>

          <input
            ref={inputRef}
            type="text"
            placeholder={placeholder || "Search..."}
            value={query}
            onChange={handleChange}
            onKeyDown={handleKeyDown}
            onFocus={() => showSuggestions && setIsDropdownOpen(true)}
            onBlur={() => setTimeout(() => setIsDropdownOpen(false), 200)}
            className={SEARCH_INPUT_CLASS}
            autoComplete="off"
            spellCheck="false"
          />

          <div className="absolute inset-y-0 right-0 flex items-center pr-3 gap-1">
            {isLoading && (
              <div className="h-4 w-4 animate-spin rounded-full border-2 border-brand-search-muted border-t-transparent" />
            )}

            {query.length > 0 && (
              <button
                type="button"
                onClick={handleClearInput}
                className={SEARCH_CLEAR_CLASS}
                aria-label="Clear search"
              >
                <svg
                  className="h-4 w-4"
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

        {showSuggestions && isDropdownOpen && (
          <>
            {suggestions.length > 0 ? (
              <ul
                className={`absolute z-20 mt-2 w-full overflow-hidden rounded-xl border ${SURFACE_BORDER} bg-white shadow-lg dark:bg-zinc-900 max-h-72 overflow-y-auto divide-y divide-brand-surface-border/80 dark:divide-zinc-700/40`}
              >
                {suggestions.map((name, index) => (
                  <li
                    key={index}
                    onClick={() => handleSuggestionClick(name)}
                    className="cursor-pointer px-4 py-3 text-sm text-brand-navy transition-colors hover:bg-brand-tab-inactive dark:text-gray-100 dark:hover:bg-zinc-800"
                  >
                    {name}
                  </li>
                ))}
              </ul>
            ) : (
              query.trim().length > 1 &&
              !isLoading &&
              searchOnType && (
                <div
                  className={`absolute z-50 mt-2 w-full rounded-xl border ${SURFACE_BORDER} bg-white px-4 py-3 text-sm text-brand-search-muted shadow-lg dark:bg-zinc-900`}
                >
                  No results found for{" "}
                  <span className="font-medium text-brand-navy dark:text-gray-200">
                    "{query}"
                  </span>
                </div>
              )
            )}
          </>
        )}
      </div>
    </div>
  );
}
