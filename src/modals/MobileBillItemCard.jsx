import React from "react";
import { Trash2 } from "lucide-react";

const Input = ({ label, value, onChange }) => (
  <div>
    <label className="block text-xs font-medium mb-1">{label}</label>
    <input
      type="number"
      value={value ?? ""}
      onChange={(e) => onChange(e.target.value)}
      className="w-full px-3 py-2 border rounded focus:ring-2 focus:ring-blue-500"
    />
  </div>
);

const ReadOnly = ({ label, value }) => (
  <div>
    <label className="block text-xs font-medium mb-1">{label}</label>
    <input
      type="text"
      value={value ?? "0.00"}
      readOnly
      className="w-full px-3 py-2 bg-gray-100 border rounded"
    />
  </div>
);


const MobileBillItemCard = React.memo(
  ({ item, index, onChange, onDelete }) => {
    return (
      <div className="border rounded-lg p-4 bg-white shadow-sm space-y-3">
        <div className="flex justify-between items-center">
          <h4 className="font-semibold text-sm text-gray-700">
            Item #{index + 1}
          </h4>
          <button onClick={() => onDelete(index)} className="text-red-600">
            <Trash2 className="w-4 h-4" />
          </button>
        </div>

        <Input label="Pieces" value={item.pieces}
          onChange={(v) => onChange(index, "pieces", v)}
        />

        <Input label="Gross Amount" value={item.grossAmount}
          onChange={(v) => onChange(index, "grossAmount", v)}
        />

        <Input label="Discount %" value={item.discountPercent}
          onChange={(v) => onChange(index, "discountPercent", v)}
        />

        <ReadOnly label="Discount Amount" value={item.discountAmount} />

        <Input label="Add-On Amount" value={item.addOnAmount}
          onChange={(v) => onChange(index, "addOnAmount", v)}
        />

        <Input label="ECR Amount" value={item.ecrAmount}
          onChange={(v) => onChange(index, "ecrAmount", v)}
        />

        <Input label="GST %" value={item.gstPercent}
          onChange={(v) => onChange(index, "gstPercent", v)}
        />

        <ReadOnly label="GST Amount" value={item.gstAmount} />
      </div>
    );
  }
);

export default MobileBillItemCard;
