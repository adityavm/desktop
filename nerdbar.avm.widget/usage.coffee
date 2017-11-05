#
# stack
#

_widget = null
widget = [4, 70, true]
AVERAGE = 16

#
# widget
#

command: (cb) ->
  self = this
  cmd = "/usr/local/bin/node ~/dev/bitbar-plugins/node/usage.uebersicht.js"

  $.getScript "nerdbar.avm.widget/lib/dynamic.js", (stack) ->
    _widget = nbWidget.apply null, widget
    self.run cmd, () ->
      output = arguments[1]
      try
        json = JSON.parse output
      catch e
        console.log "[usage] host is probably down, got", output
        return

      cb.apply null, arguments

refreshFrequency: "1h"

render: (output) ->
  json = JSON.parse output
  cls = ""

  if json.usageLeft < AVERAGE
    cls = "low"

  if json.usageLeft >= AVERAGE
    cls = "ok"

  if json.usageLeft > (AVERAGE * 1.6)
    cls = "high"

  "<span class='label'>gbs</span><span class='usage #{cls}'>#{json.symbol}</span><span class='usage-value'>#{json.usageLeft} gbs/day</span>"

afterRender: (domEl) ->
  _widget.domEl domEl

  $(domEl).css({ right: _widget.getRight() + "px", width: _widget.getWidth() + "px" })

  _widget.update !$(domEl).find(".usage").hasClass("high") # hide if usage in control

style: """
  font: 12px -apple-system, Osaka-Mono, Hack, Inconsolata
  height: 26px
  line-height: 26px
  top: 0
  color: #333
  display: flex
  justify-content: center
  -webkit-user-select: none

  &.hidden
    display: none

  .usage-value
    position: absolute
    right: 0
    bottom: -40px
    width: 80px
    text-align: right
    background-color: #111
    padding: 0 10px
    display: inline-block
    opacity: 0
    transition: opacity 0.2s

    &:before
      border: 5px solid #111
      border-color: transparent transparent #111
      content: " "
      position: absolute
      top: -10px
      right: 5px

  &:active .usage-value
    opacity: 1

  span.usage
    color: #aaa
    font-size: 10px
    position: relative
    top: -1px
    left: 3px

    &.low
      color: #ec3f1d

    &.ok
      color: #888573

    &.high
      color: #88c625
"""
