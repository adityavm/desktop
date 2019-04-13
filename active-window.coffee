# public

options =
  refresh: 2500
  cutOff: 60

# internal

outputFmt = (output) ->
  split = output.match /([^,]+),(.+)/
  win = split[1].trim()
  title = split[2].trim()

  # Make window title useful
  titleSubs = title.replace(new RegExp("\s?-?.?#{win}.?-?\s?", "ig"), "") # remove app name
  titleSubs = if titleSubs.length > options.cutOff then "..." + titleSubs.substr titleSubs.length - options.cutOff, titleSubs.length else titleSubs
  titleSubs = titleSubs.replace(/🔊/g, "<div class='icon icon-speaker'><div class='lines'></div></div>") # remove speaker icon

  windowSpan = "<span class='window'>#{win}</span>"
  titleSpan = "<span class='title'>#{titleSubs}</span>"

  out = "#{windowSpan}"
  if titleSubs
    out += " <span class='divider'>/</span> #{titleSpan}"

  return [win, title, titleSubs, out]

# widget

command: "osascript lib/window_title.scpt"

refreshInterval: options.refresh,

render: (output) ->
  "<div class='content'></div>"

update: (output, domEl) ->
  [win, title, titleSubs, html] = outputFmt output

  el = $(domEl).find(".content")

  if (win == "Finder" and title == "")
    el.addClass("transit").html("")
    return

  el.removeClass("empty")

  domText = el.text()
  newText = "#{win} / #{titleSubs}"
  oldWin = el.find(".window").text()

  # animate if different window + title is different
  if win != oldWin
    if domText != newText
      el.addClass("transit")

  el.html(html)

  if el.hasClass("transit") then setTimeout (() -> el.removeClass("transit")), 200

style: """
  position: absolute
  bottom: 17px
  left: 25px

  .content
    font: 12px "Dank Mono", -apple-system, Osaka-Mono, Hack, Inconsolata
    color: #aaa
    z-index: 2
    height: 26px
    line-height: 26px
    min-width: 200px
    white-space: nowrap
    opacity: 1
    transition: opacity 0.2s

  .content > span
    opacity: 1
    transition: opacity 0.2s

  .transit > span
    opacity: 0

  .empty
    opacity: 0

  .icon
    width: 10px
    height: 10px
    background-color: currentColor
    position: relative
    top: 8px
    display: inline-block
    transform: scale(0.45)

    &:after
      content: ""
      width: 0px
      height: 0px
      border-width: 10px
      border-style: solid
      border-color: transparent currentColor transparent transparent
      position: absolute
      left: -8px
      top: -5px
      display: inline-block

    .lines
      border-left: 1px solid currentColor
      position: relative
      left: 15px
      height: 10px
      display: inline-block

      &:after
        content: ""
        border-left: 1px solid currentColor
        position: relative
        left: 4px
        top: -4px
        height: 15px
        display: inline-block

  span.window
    color: rgba(#aaa, 0.75)
    min-width: 200px
    opacity: 0.75

  span.divider
    color: rgba(#aaa, 0.5)
    opacity: 0.25
"""
