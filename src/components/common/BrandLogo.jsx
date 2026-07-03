import { BRAND_TITLE_CLASS } from "../../theme/appTheme";

const BrandMark = ({ className = "h-7 w-7 text-brand-primary" }) => (
  <svg
    xmlns="http://www.w3.org/2000/svg"
    viewBox="0 0 24 24"
    fill="none"
    className={className}
    aria-hidden="true"
  >
    <path
      d="M12 3.5 18.5 12 12 20.5 5.5 12 12 3.5Z"
      stroke="currentColor"
      strokeWidth="1.75"
    />
    <path
      d="M12 8v8M8.5 12h7"
      stroke="currentColor"
      strokeWidth="1.75"
      strokeLinecap="round"
    />
  </svg>
);

const BrandLogo = ({ showTitle = true, className = "" }) => (
  <div className={`flex items-center gap-2 ${className}`}>
    <BrandMark />
    {showTitle && <span className={BRAND_TITLE_CLASS}>Hisabio</span>}
  </div>
);

export { BrandMark };
export default BrandLogo;
