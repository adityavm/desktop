import { run, css } from "uebersicht";
import * as Icons from "./lib/icons";
const Vibrant = require("node-vibrant");

const options = {
  cutOff: 60,
  display: 1,
};

export const refreshFrequency = false;

const outputFmt = ({ app, title }) => {
  if (!app && !title) return ["", ""];

  // Make window title useful
  title = title.replace(new RegExp(`\s?-?.?${app}.?-?\s?`, "ig"), ""); // remove app name
  title = title.length > options.cutOff
    ? "..." + title.substr(title.length - options.cutOff, title.length)
    : title;

  // Get window name from app
  if (app === "Electron") {
    const titleRegexp = /(\w+)(\s-\s)/g;
    const windowName = title.match(titleRegexp);
    if (windowName) {
      app = windowName[0].replace(/\s-\s/, "");
      title = title.replace(titleRegexp, "");
    }
  }

  return [app, title];
};

const getGreeting = () => {
  const time = (new Date()).getHours();
  let greet;

  if (time >= 0 && time < 6) {
    greet = "You should sleep"
  }

  if (time >= 6 && time < 12) {
    greet = "Good Morning";
  }

  if (time >= 12 && time < 17) {
    greet = "Good Afternoon";
  }

  if (time >= 17 && time < 24) {
    greet = "Good Evening"
  }

  return `${greet}, Aditya!`;
};

export const command = async dispatch => {
  let windowJSON;
  try {
    const windows = await run(`/usr/local/bin/yabai -m query --windows | /usr/local/bin/jq '.[] | [{app: .app, display: .display, title: .title, focused: .focused}] | select(.[].focused == 1 and .[].display == ${options.display}) | .[0]'`);
    windowJSON = JSON.parse(windows);
  } catch (e) {
    console.log(e);
    windowJSON = {};
  }

  let spacesJSON;
  let activeSpace;
  try {
    const spaces = await run("/usr/local/bin/yabai -m query --spaces");
    spacesJSON = JSON.parse(spaces);
  } catch (e) {
    spacesJSON = [];
  }

  let windowsJSON;
  try {
    const windows = await run("/usr/local/bin/yabai -m query --windows");
    windowsJSON = JSON.parse(windows);
  } catch (e) {
    windowsJSON = [];
  }

  const fileName = await run("cat ./lib/backgroundFile");
  Vibrant.from(fileName).getPalette().then(palette => {
    dispatch({
      type: "SET_STATE",
      app: windowJSON.app,
      title: windowJSON.title,
      spaces: spacesJSON,
      visibleWindows: windowsJSON,
      emptyBackground: palette.LightVibrant._rgb || [255, 255, 255],
    });
  });
}

export const updateState = (event, prevState) => {
  if (event.type === "SET_STATE") {
    return {
      app: event.app,
      title: event.title,
      spaces: event.spaces,
      visibleWindows: event.visibleWindows,
      emptyBackground: event.emptyBackground,
    };
  }
  return prevState;
};

export const GetAppIcons = ({ visibleWindows, isFocused }) => {
  const seen = [];
  return visibleWindows.map(win => {
    const app = win.app.replaceAll(" ", "");
    const isFront = win.focused === 1;
    if (seen.indexOf(app) > -1) return () => null;
    seen.push(app);
    return (
      <RenderIcon
        app={app}
        className={`${isFocused ? activeAppIcon : null} ${isFront ? frontAppIcon : null}`}
      />
    )
  });
}

export const RenderIcon = ({ className, app }) => {
  app = app.replaceAll(" ", "");
  const Icon = Icons[app] ? Icons[app] : () => null;
  return <Icon className={`${appIcon} ${app} ${className}`} />
};

export const render = ({ app, title, spaces, visibleWindows, emptyBackground }) => {
  const [fmtApp, fmtTitle] = outputFmt({ app, title });
  const isEmpty = !fmtApp && !fmtTitle;

  if (!spaces || typeof spaces === "undefined") return null;

  const spacesArr = spaces.filter(spc => spc.display === options.display);
  const Icon = Icons[app] ? Icons[app] : () => null;

  return (
    <div className={parent}>
      <div className={spacesContainer}>
        {spacesArr.map((spc, i) => {
          const label = spc.label || String(spc.index);
          const windows = visibleWindows.filter(win => win.space === spc.index);
          const isStacked = spc.type === "stack";
          return (
            <span key={spc.id} className={`${space} ${spc.focused ? activeSpace : null}`}>
              <span className={`${spaceLabel} ${spc.focused ? spaceActiveLabel : ``}`}>
                {spc.focused ? label : label.charAt(0)}
                {isStacked && <span>°</span>}
              </span>
              <span className={appIcons}>
                <GetAppIcons visibleWindows={windows} isFocused={spc.focused === 1} />
              </span>
            </span>
          );
        })}
      </div>
      <div className={`${contentStyles} ${isEmpty ? emptyStyles(emptyBackground) : ``}`}>
        {!isEmpty
          ? (
            <div className={activeWindowTitleContainer}>
              <span className={windowStyles}>
                <RenderIcon app={app} className={windowAppIcon} />
                {fmtApp}
              </span>
              {fmtTitle && (
                <span className={titleStyles}>
                  <span className={dividerStyles}>/</span>
                  {fmtTitle}
                </span>
              )}
            </div>
          )
          : (
            getGreeting()
          )}
      </div>
    </div>
  );
};

export const className = `
  left: 0;
  top: 0;
  position: absolute;
  width: 100%;
  height: 100%;
`;

const parent = css({
  display: "flex",
});

const spacesContainer = css({
  font: `12px "Dank Mono", -apple-system, Osaka-Mono, Hack, Inconsolata`,
  display: "flex",
  backgroundColor: "#222",
  backdropFilter: "blur(10px)",
  borderRadius: "4px",
  overflow: "hidden",
  position: "absolute",
  bottom: "5px",
  left: "50px",
  height: "35px",
});

const space = css({
  display: "inline-flex",
  alignItems: "center",
  justifyContent: "center",
  height: "35px",
  transition: "0.3s",
  position: "relative",
  flex: "none",
  padding: "0 7px",
  ":first-child": {
    borderRadius: "4px 0 0 4px",
  },
  ":last-child": {
    borderRadius: "0 4px 4px 0",
  },
  "&:before": {
    position: "absolute",
    top: 0,
    left: 0,
    width: "100%",
    height: "100%",
    zIndex: -1,
    transition: "color 0.3s, background-color 0.3s",
  },
});

const activeSpace = css({
  "&:before": {
    content: '""',
    backgroundColor: "#333",
    color: "transparent",
  },
});

const spaceDivider = css({});

const spaceLabel = css({
  color: "rgba(160, 160, 160, 0.5)",
  backgroundColor: "transparent",
  display: "inline-flex",
  alignItems: "center",
  lineHeight: "16px",
  height: "20px",
  borderRadius: "50%",
  transition: "0.3s",
});

const spaceActiveLabel = css({
  color: "#b79dc4",
});

const appIcons = css({
  display: "flex",
  marginLeft: "5px",
});

const appIcon = css({
  width: "12px",
  opacity: 0.5,
  path: {
    fill: "#777",
  },
  "&.FirefoxDeveloperEdition": {
    path: {
      fill: "#94d5e4",
    }
  },
  padding: "4px",
  height: "12px",
});

const windowAppIcon = css({
  marginRight: "10px",
  marginLeft: "0",
  path: {
    fill: "#aaa",
  },
});

const activeAppIcon = css({
  path: {
    fill: "#b79dc4",
  },
  "&.FirefoxDeveloperEdition": {
    path: {
      fill: "#94d5e4",
    }
  },
  opacity: 1,
});

const frontAppIcon = css({
  backgroundColor: "#262626",
  borderRadius: "4px",
});

const activeWindowTitleContainer = css({
  display: "flex",
});

const windowStyles = css({
  color: "rgba(#aaa, 0.75)",
  opacity: "0.75",
  color: "#aaa",
  display: "inline-flex",
  alignItems: "center",
  height: "100%",
});

const titleStyles = css({});

const contentStyles = css({
  font: `12px "Dank Mono", -apple-system, Osaka-Mono, Hack, Inconsolata`,
  color: "#aaa",
  zIndex: 2,
  height: "26px",
  lineHeight: "26px",
  whiteSpace: "nowrap",
  opacity: 1,
  transition: "opacity 0.2s, background-color 0.2s, color 0.2s",
  backgroundColor: "#232021",
  height: "35px",
  borderRadius: "5px",
  display: "flex",
  alignItems: "center",
  justifyContent: "flex-start",
  padding: "0px 10px",
  position: "absolute",
  left: "10px",
  top: "5px",
});

const dividerStyles = css({
  color: "rgba(170, 170, 170, 0.5)",
  opacity: 0.25,
  margin: "0 5px",
});

const emptyStyles = color => css({
  backdropFilter: "blur(10px)",
  backgroundColor: `rgba(${color.join(",")}, 0.5)`,
  color: "#fff",
});