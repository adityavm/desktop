import { run, css } from "uebersicht";
import * as Icons from "./lib/icons";

const options = {
  refresh: 2500,
  cutOff: 60,
  display: 1,
};

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
    const windows = await run("/usr/local/bin/yabai -m query --windows --window");
    windowJSON = JSON.parse(windows);
  } catch (e) {
    windowJSON = {};
  }
  if (windowJSON.display !== 1) {
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

  dispatch({
    type: "SET_STATE",
    app: windowJSON.app,
    title: windowJSON.title,
    spaces: spacesJSON,
    visibleWindows: windowsJSON,
  });
}

export const updateState = (event, prevState) => {
  if (event.type === "SET_STATE") {
    return {
      app: event.app,
      title: event.title,
      spaces: event.spaces,
      visibleWindows: event.visibleWindows,
    };
  }
  return prevState;
};

export const GetAppIcons = ({ visibleWindows, isFocused }) => {
  const seen = [];
  return visibleWindows.map(win => {
    const app = win.app.replaceAll(" ", "");
    if (seen.indexOf(app) > -1) return () => null;
    seen.push(app);
    const Icon = Icons[app] ? Icons[app] : () => null;
    return <Icon className={`${appIcon} ${isFocused ? activeAppIcon : null} ${app}`} />
  });
}

export const render = ({ app, title, spaces, visibleWindows }) => {
  const [fmtApp, fmtTitle] = outputFmt({ app, title });
  const isEmpty = !fmtApp && !fmtTitle;

  if (!spaces || typeof spaces === "undefined") return null;

  const spacesArr = spaces.filter(spc => spc.display === options.display);

  return (
    <div className={parent}>
      <div className={spacesContainer}>
        {spacesArr.map((spc, i) => {
          const label = spc.label || String(spc.index);
          const windows = visibleWindows.filter(win => win.space === spc.index);
          return (
            <span key={spc.id} className={`${space} ${spc.focused ? activeSpace : null}`}>
              <span className={`${spaceLabel} ${spc.focused ? spaceActiveLabel : ``}`}>
                {spc.focused ? label : label.charAt(0)}
              </span>
              <span className={appIcons}>
                <GetAppIcons visibleWindows={windows} isFocused={spc.focused === 1} />
              </span>
            </span>
          );
        })}
      </div>
      <div className={`${contentStyles} ${isEmpty ? emptyStyles : ``}`}>
        {!isEmpty
          ? (
            <div>
              <span className={windowStyles}>{fmtApp}</span>
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
  position: absolute;
  bottom: 10px;
  left: 50px;
  height: 40px;
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
});

const space = css({
  display: "inline-flex",
  alignItems: "center",
  justifyContent: "center",
  height: "40px",
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
  color: "#ee6aa0",
});

const appIcons = css({
  display: "flex",
});

const appIcon = css({
  width: "12px",
  marginLeft: "5px",
  opacity: 0.5,
  path: {
    fill: "#777",
  },
  "&.FirefoxDeveloperEdition": {
    path: {
      fill: "#94d5e4",
    }
  }
});

const activeAppIcon = css({
  path: {
    fill: "#ee6aa0",
  },
  "&.FirefoxDeveloperEdition": {
    path: {
      fill: "#94d5e4",
    }
  },
  opacity: 1,
});

const windowStyles = css({
  color: "rgba(#aaa, 0.75)",
  opacity: "0.75",
  color: "#aaa",
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
  height: "40px",
  borderRadius: "5px",
  display: "flex",
  alignItems: "center",
  justifyContent: "flex-start",
  padding: "0px 20px",
  marginLeft: "10px",
});

const dividerStyles = css({
  color: "rgba(170, 170, 170, 0.5)",
  opacity: 0.25,
  margin: "0 5px",
});

const emptyStyles = css({
  backdropFilter: "blur(10px)",
  backgroundColor: "rgba(204, 204, 204, 0.5)",
  color: "#fff",
});