const { range } = require("lodash");
import { css } from "uebersicht";

// width class based on output value
const getWidthCls = output => {
  const widthCls = "";
  let outputInt = parseInt(output);

  if (outputInt >= 0) widthCls = "w0";
  if (outputInt >= 20) widthCls = "w20";
  if (outputInt >= 40) widthCls = "w40";
  if (outputInt >= 60) widthCls = "w60";
  if (outputInt >= 80) widthCls = "w80";
  if (outputInt == 100) widthCls = "w100";

  return widthCls;
}

const getMeter = output => {
  const outputInt = parseInt(output);
  return (
    <div className={meter}>
      {range(1, Math.ceil(outputInt / 20)).map(i => (
        <span key={i} className={`${pip} pip-${i}`}>•</span>
      ))}
    </div>
  );
}

const TextMeter = ({ output }) => (
  parseInt(output) < 60
    ? (
      <span className={textMeter}>{output}</span>
    )
    : null
);

export const command = "pmset -g batt | egrep '([0-9]+)\%.*' -o --colour=auto | cut -f1 -d';'";

export const refreshFrequency = 60000;

export const render = ({ output }) => (
  <div className={content}>
    <span className={`${cross} ${crossLeft}`}>
      <svg className={crossSvg} width="3" height="3" viewBox="0 0 3 3" fill="none" xmlns="http://www.w3.org/2000/svg">
        <rect width="1" height="1" fill="#666" />
        <rect x="1" y="1" width="1" height="1" fill="#666" />
        <rect y="2" width="1" height="1" fill="#666" />
        <rect x="2" width="1" height="1" fill="#666" />
        <rect x="2" y="2" width="1" height="1" fill="#666" />
      </svg>
    </span>
    <span className={`${cross} ${crossRight}`}>
      <svg className={crossSvg} width="3" height="3" viewBox="0 0 3 3" fill="none" xmlns="http://www.w3.org/2000/svg">
        <rect width="1" height="1" fill="#666" />
        <rect x="1" y="1" width="1" height="1" fill="#666" />
        <rect y="2" width="1" height="1" fill="#666" />
        <rect x="2" width="1" height="1" fill="#666" />
        <rect x="2" y="2" width="1" height="1" fill="#666" />
      </svg>
    </span>
    {getMeter(output)}
    <TextMeter output={output} />
  </div>
);

export const className = `
  font: 12px -apple-system, Osaka-Mono, Hack, Inconsolata;
  bottom: 10px;
  right: 205px;
  height: 40px;
  text-align: center;
  background-color: #232021;
  border-radius: 5px;
  margin-right: 5px;
  width: 60px;
`;

const pip = css({
  "&.pip-5": {
    color: "#7aab7e",
  },
  "&.pip-4": {
    color: "#88c625"
  },
  "&.pip-3": {
    color: "#ff8000",
  },
  "&.pip-2": {
    color: "#ed612d",
  },
  "&.pip-1": {
    color: "#df1d1d",
  },
});

const meter = css({
  display: "flex",
})

const content = css({
  display: "flex",
  alignItems: "center",
  justifyContent: "center",
  height: "100%",
});

const cross = css({
  position: "absolute",
  zIndex: 1,
  height: "3px",
});

const crossLeft = css({
  display: "none",
  bottom: "4px",
  left: "3px",
});

const crossRight = css({
  display: "none",
  top: "3px",
  right: "7px",
});

const crossSvg = css({
  position: "absolute",
  top: 0,
  left: 0,
});

const textMeter = css({
  marginLeft: "5px",
  color: "#aaa",
  fontFamily: "Dank Mono",
});