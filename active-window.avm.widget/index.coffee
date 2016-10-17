# public

options =
  refresh: 1000
  cutOff: 60

# internal

outputFmt = (output) ->
  split = output.match /([^,]+),(.+)/
  win = split[1].trim()
  title = split[2].trim()
  titleSubs = if title.length > options.cutOff then "&hellip;" + title.substr title.length - options.cutOff, title.length else title

  windowSpan = "<span class='window'>#{win}</span>"
  titleSpan = "<span class='title'>#{titleSubs}</span>"

  out = "#{windowSpan}"
  if titleSubs
    out += " / #{titleSpan}"

  return [win, title, titleSubs, out]

# widget

command: "osascript active-window.avm.widget/lib/window_title.scpt"

refreshInterval: 1000,

render: (output) ->
  "<div class='content empty'></div>"

update: (output, domEl) ->
  [win, title, titleSubs, html] = outputFmt output

  el = $(domEl).find(".content")

  if (win == "Finder" and title == "")
    el.addClass("empty").html("")
  else
    el.removeClass("empty").html(html)

style: """
  .content
    position: absolute
    top: 0
    left: 10px
    font: 13px Osaka-Mono
    color: #555
    z-index: 2
    height: 26px
    background-color: #111
    line-height: 26px
    min-width: 200px
    white-space: nowrap
    opacity: 1
    transition: opacity 0.4s

  .empty
    opacity: 0

  span.window
    color: #aaa
    min-width: 200px
"""
