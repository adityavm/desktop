const Vibrant = require("node-vibrant")

/*
 * Shows the date and time
 * Shows big datetime in the top left when no windows are
 * active otherwise shows small datetime in the top right
*/

import { run, css } from "uebersicht";

export const command = async dispatch => {
  const output = await run("date +%H:%M");
  const fileName = await run("cat ./lib/backgroundFile");

  Vibrant.from(fileName).getPalette().then(palette => {
    dispatch({
      type: "SET_DATA",
      time: output,
      bgColor: palette.DarkMuted.getHex(),
    });
  });
};

export const refreshFrequency = 50000;

const getDate = ({ time, isBig }) => {
  const out = new Date();
  const dayString = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"][out.getDay()].substr(0, 3);
  const dateString = out.getDate();
  const month = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"][out.getMonth()];
  const monthOutput = isBig ? month : month.substr(0, 3);

  return (
    <span className={isBig ? dateBig : dateSmall}>
      <span className={`${isBig ? dayBig : daySmall} ${dayString.toLowerCase()}`}>{dayString}</span> {dateString} {monthOutput}
    </span>
  );
}

const getTime = ({ time, isBig }) => {
  const timeObj = new Date();
  let hrs = timeObj.getHours();
  let min = timeObj.getMinutes();

  const suffixString = hrs > 11 ? "p" : "a";
  hrs = hrs > 12 ? hrs - 12 : hrs;
  min = min < 10 ? `0${min}` : min;
  hrs = hrs == 0 ? 12 : hrs;

  return (
    <span className={isBig ? timeBig : timeSmall}>
      {hrs}:{min}
      <span className={suffix}>{suffixString}{isBig ? "m" : ""}</span>
    </span>
  );
}

const getFullHtml = ({ time, bgColor, isBig }) => (
  <div className={isBig ? bigTime : smallTime}>
    <div className={text}>
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
      {getDate({ time, isBig })}
    </div>
    <div className={`${text} ${bgcolor(bgColor)}`}>
      <span className={`${cross} ${crossLeft}`}>
        <svg className={crossSvg} width="3" height="3" viewBox="0 0 3 3" fill="none" xmlns="http://www.w3.org/2000/svg">
          <rect width="1" height="1" fill="#ffc65baa" />
          <rect x="1" y="1" width="1" height="1" fill="#ffc65baa" />
          <rect y="2" width="1" height="1" fill="#ffc65baa" />
          <rect x="2" width="1" height="1" fill="#ffc65baa" />
          <rect x="2" y="2" width="1" height="1" fill="#ffc65baa" />
        </svg>
      </span>
      <span className={`${cross} ${crossRight}`}>
        <svg className={crossSvg} width="3" height="3" viewBox="0 0 3 3" fill="none" xmlns="http://www.w3.org/2000/svg">
          <rect width="1" height="1" fill="#ffc65baa" />
          <rect x="1" y="1" width="1" height="1" fill="#ffc65baa" />
          <rect y="2" width="1" height="1" fill="#ffc65baa" />
          <rect x="2" width="1" height="1" fill="#ffc65baa" />
          <rect x="2" y="2" width="1" height="1" fill="#ffc65baa" />
        </svg>
      </span>
      {getTime({ time, isBig })}
    </div>
  </div>
);

export const className = `
  font: 12px "Dank Mono", -apple-system, Osaka-Mono, Hack, Inconsolata;
  display: flex;
  bottom: 5px;
  right: 10px;
  height: 35px;
  line-height: 26px;
  text-align: center;
  color: #aaa;
`;

const bgcolor = color => css({
  backgroundColor: color,
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

const text = css({
  position: "relative",
  lineHeight: "1em",
  backgroundColor: "#232021",
  borderRadius: "5px",
  display: "flex",
  "& + &": {
    marginLeft: "10px",
  }
});

const date = css({
  flex: 1,
  display: "flex",
  alignItems: "center",
  justifyContent: "center",
});

const dateSmall = css`
  ${date};
  width: 90px;
`;

const dateBig = css`
  ${date};
  font-size: 48px;
  margin-top: 10px;
`;

const day = css({
  marginRight: "5px",
  "&.fri": {
    color: "#e8c661",
  },
  "&.sat, &.sun": {
    color: "#b0d970",
  },
});

const daySmall = css`
  ${day};
`;

const dayBig = css`
  ${day};
  margin-right: 7px;
`;

const timeSmall = css({
  display: "flex",
  alignItems: "center",
  justifyContent: "center",
  position: "relative",
  color: "#ffc65b",
  width: "70px",
  /* height: "40px", */
  /* borderBottom: "2px solid #ffc65baa", */
  flex: "none",
  borderRadius: "5px",
});

const timeBig = css`
  height: 90px;
`;

const suffix = css({
  position: "static",
});

const suffixBig = css`
  ${suffix};
  opacity: 0.5;
  font-size: 48px;
`;

const bigTime = css({
  display: "flex",
  flexDirection: "column",
  alignItems: "flex-start",
  font: `300 96px "Dank Mono"`,
  letterSpacing: "-10px",
  position: "fixed",
  bottom: "23px",
  left: "25px",
  transition: "opacity 0.4s",
});

const smallTime = css({
  color: "#aaa",
  display: "inline-flex",
  justifyContent: "space-between",
  transition: "opacity 0.4s",
  width: "100%",
});

export const updateState = (event, prevState) => {
  if (event.type === "SET_DATA") {
    return {
      time: event.time,
      bgColor: event.bgColor,
    };
  }
  return prevState;
}

export const render = ({ time, bgColor }) => {
  return getFullHtml({ time, bgColor, isBig: false });
};