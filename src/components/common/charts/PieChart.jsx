import { Doughnut } from "react-chartjs-2";

const getChartTotal = (data) => {
  const values = data?.datasets?.[0]?.data || [];
  return values.reduce((sum, value) => sum + Number(value || 0), 0);
};

const centerTotalPlugin = {
  id: "centerTotal",
  afterDraw(chart) {
    const { ctx, chartArea, data } = chart;
    if (!chartArea) return;

    const total = getChartTotal(data);
    const centerX = (chartArea.left + chartArea.right) / 2;
    const centerY = (chartArea.top + chartArea.bottom) / 2;

    ctx.save();
    ctx.textAlign = "center";
    ctx.textBaseline = "middle";

    ctx.fillStyle = "#6b7280";
    ctx.font = "14px sans-serif";
    ctx.fillText("Total", centerX, centerY - 14);

    ctx.fillStyle = "#1e3a8a";
    ctx.font = "bold 24px sans-serif";
    ctx.fillText(String(total), centerX, centerY + 12);

    ctx.restore();
  },
};

export default function PieChart({ options, data }) {
  return (
    <div style={{ width: "100%", height: "250px" }}>
      <Doughnut options={options} data={data} plugins={[centerTotalPlugin]} />
    </div>
  );
}
