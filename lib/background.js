const seedrandom = require("seedrandom");
const fs = require("fs");
const path = require("path");

const kirokaze = [
  "amp_prob",
  "attack",
  "bad_landing",
  "bluebalcony",
  "cemetry",
  "citymirror",
  "coffeeinrain",
  "dark_pillar",
  "droidcrime",
  "elderorc",
  "factory5",
  "familydinner",
  "horse",
  "iplayoldgames",
  "last_dance",
  "metro_final",
  "nightlytraining",
  "pilot",
  "player2",
  "reddriver",
  "robot_alley",
  "sandcastle",
  "shootingstars",
  "spacecommander",
  "spaceport",
  "thieves",
  "train",
  "train_city",
  "troll_cave",
  "wild_boy",
  "windyday",
  "youngatnight",
  "zombies",
];

const faxdoc = [
  "cacao_and_coffee_shop",
  "comition_sky_left_to_right",
  "flower_shop",
  "lullaby",
  "midnight_melancholy",
  "mountain_mote",
  "nero_land",
  "sideshop",
  "stacking_houses_on_a_windy_day",
];

const landscapes = [
  "bridge",
  "bridge_raining",
  "castle",
  "cave",
  "coast",
  "dawn",
  "falls",
  "fire",
  "forrest",
  "fortress",
  "grandcanyon",
  "lake",
  "mountain",
  "nature",
  "northlights",
  "rain",
  "sea",
  "snow",
  "swamp",
  "swirling",
  "temple",
  "tower",
  "town",
  "underwater",
];

const valenberg = [
  "bicycle",
  "blade",
  "controlroom",
  "daftpunk",
  "drift",
  "echoesfromneals",
  "exodus",
  "future",
  "girlinrain",
  "highfloor",
  "highlands",
  "highsoceity",
  "jazznight",
  "lowlands",
  "moon.png",
  "motorcycle",
  "nighttrain",
  "redbicycle",
  "ride",
  "shop",
  "skate",
  "streets",
  "sushi",
  "tv",
  "virtuaverse",
];

const date = new Date();
const seed = `${date.getFullYear()}-${date.getMonth()}-${date.getDate()}`;
const random = seedrandom(seed);

const bgAuthor = [
  ["kirokaze", kirokaze],
  ["faxdoc", faxdoc],
  ["valenberg", valenberg],
  ["landscapes", landscapes],
][[Math.floor(random() * Math.floor(4))]]

const bg = bgAuthor[1][Math.floor(random() * Math.floor(bgAuthor[1].length))];
const bgUrl = `/lib/8bitdash/${bgAuthor[0]}/${bg}.gif`;

fs.writeFile("./lib/backgroundFile", bgUrl, () => null);

console.log(bgUrl);