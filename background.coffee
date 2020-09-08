refreshFrequency: false

render: (output) ->
  """<div class="background" />"""

afterRender: (el) ->
  kirokaze = [
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
  ]
  
  faxdoc = [
    "cacao_and_coffee_shop",
    "comition_sky_left_to_right",
    "flower_shop",
    "lullaby",
    "midnight_melancholy",
    "mountain_mote",
    "nero_land",
    "sideshop",
    "stacking_houses_on_a_windy_day",
  ]

  landscapes = [
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
  ]

  valenberg = [
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
  ]

  bgAuthor = [
    ["kirokaze", kirokaze],
    ["faxdoc", faxdoc],
    ["valenberg", valenberg],
    ["landscapes", landscapes],
  ][[Math.floor(Math.random() * Math.floor(4))]]

  bg = bgAuthor[1][Math.floor(Math.random() * Math.floor(bgAuthor[1].length))]

  $(el)
    .find(".background")
    .css({
      backgroundImage: """url("./lib/8bitdash/#{bgAuthor[0]}/#{bg}.gif")"""
    })
  
  setTimeout (() -> $(el).find(".background").addClass("show")), 100

style: """
  top: 0
  left: 0 
  width: 100%
  height: 100%
  position: fixed
  z-index: -1
  background-color: #000

  .background
    width: 100%
    height: 100%
    border: 0
    background-size: cover
    opacity: 0
    transition: opacity 0.3s
    border-radius: 4px

    &.show
      opacity: 1
"""
