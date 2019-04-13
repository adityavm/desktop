#
# Shows the date and time
# Shows big datetime in the top left when no windows are
# active otherwise shows small datetime in the top right
#

#
# stack
#

_widget = null
widget = [0, 170, true]
DAY_BG = ""
NIGHT_BG = ""

#
# widget
#

command: (cb) ->
  self = this
  cmd = "osascript lib/window_title.scpt" # """date +%H:%M"""

  $.getScript "lib/cfg.js", () ->
    $.getScript "lib/dynamic.js", () ->
      DAY_BG = cfg.DAY_BG
      NIGHT_BG = cfg.NIGHT_BG
      _widget = nbWidget(widget[0], widget[1], widget[2])

      self.run(cmd, cb)

refreshFrequency: 5000 # ms

getDate: (isBig) ->
  out = new Date()
  day = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"][out.getDay()].substr(0, 3)
  date = out.getDate();
  month = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"][out.getMonth()]
  monthOutput = if isBig then month else month.substr(0, 3)
  fmt = """<span class="day #{day.toLowerCase()}">#{day}</span> #{date} #{monthOutput}"""

getTime: (isBig) ->
  time = new Date()
  hrs = time.getHours()
  min = time.getMinutes()

  suffix = if hrs > 11 then "p" else "a"
  hrs = if hrs > 12 then hrs - 12 else hrs
  min = if min < 10 then "0#{min}" else min

  hrs = if hrs == 0 then 12 else hrs
  fmt = """#{hrs}:#{min}<span class="suffix">#{suffix}#{if isBig then "m" else ""}</span>"""

getGreeting: ->
  time = (new Date()).getHours()

  if time >= 0 and time < 6
    greet = "You should sleep"

  if time >= 6 and time < 12
    greet = "Good Morning"

  if time >= 12 and time < 17
    greet = "Good Afternoon"

  if time >= 17 and time < 24
    greet = "Good Evening"

  out = "#{greet}, Aditya!"

getFullHtml: (isBig) ->
  """
  <div class="time">#{@getTime(isBig)}</div>
  <div class="date">#{@getDate(isBig)}</div>
  """

setWallpaper: (current, run) ->
  currentHour = (new Date()).getHours()
  currentWallpaper = (current || "").substr("Macintosh HD:Users:aditya:Pictures:Wallpapers:".length).trim()

  if current >= 7 and current < 18
    if currentWallpaper == NIGHT_BG
      return DAY_BG
    else
      return null

  if currentHour >= 18
    if currentWallpaper == DAY_BG
      return NIGHT_BG
    else
      return null

  return DAY_BG

render: (output) ->
  split = output.match /([^,]+),(.+)/
  win = split[1].trim()
  title = split[2].trim()
  isBig = if win == "Finder" and title == "" then true else false

  _widget.update not isBig

  # """
  # <div class="big-time">
  #   #{@getFullHtml(isBig)}
  #   <span class="greeting">#{@getGreeting()}</span>
  # </div>
  """
  <div class="big-time"><span class="greeting">#{@getGreeting()}</span></div>
 	<div class="small-time">#{@getFullHtml(false)}</div>
  """

afterRender: (domEl) ->
  _widget.domEl domEl
  $(domEl).css({ right: _widget.getRight() + "px", width: _widget.getWidth() + "px" })

  # @run "osascript lib/background_image.scpt", (err, stdout) =>
  #   wallpaper = @setWallpaper stdout
  #   if wallpaper
  #     @run """osascript lib/background_image.scpt "#{wallpaper}" """

style: """
  font: 12px "Dank Mono", -apple-system, Osaka-Mono, Hack, Inconsolata
  bottom: 17px
  height: 26px
  line-height: 26px
  text-align: center
  color: #aaa

  .date,
  .time,
  .greeting
    line-height: 1em

  .big-time
    display: flex
    flex-direction: column
    align-items: flex-start
    font-family: "Helvetica Neue"
    font-weight: 300
    position: fixed
    bottom: 23px
    /*
    bottom: 17px;
    */
    left: 25px
    font-size: 96px
    opacity: 0
    transition: opacity 0.4s

    .suffix
      opacity: 0.5
      font-size: 48px

    .time
      height: 90px

    .date
      margin-top: 20px

    .date
      font-size: 48px

    .greeting
      /*
      margin-top: 5px
      font-size: 24px
      */

      font: 12px "Dank Mono", -apple-system, Osaka-Mono, Hack, Inconsolata

  .small-time
    color: #aaa
    display: inline-flex
    justify-content: space-between
    width: 75%;
    opacity: 0
    transition: opacity 0.4s

    .date
      order: -1

    .time
      display: inline-flex
      align-items: center
      justify-content: center
      background-color: #f4484d
      border-radius: 0 5px 5px 0
      position: relative
      top: -14px
      right: -21px
      color: #111
      width: 60px
      height: 40px

  &.hidden
    .big-time
      opacity: 1

    .small-time
      opacity: 0

  &:not(.hidden)
    .big-time
      opacity: 0

    .small-time
      opacity: 1

  span.day
    &.fri
      color: #ecb512

    &.sat,
    &.sun
      color: #88c625
"""
