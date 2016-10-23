#
# stack
#

_widget = null
widget = [4, 50, true]

#
# widget
#

command: (cb) ->
  self = this
  cmd = "/usr/local/bin/node ~/dev/bitbar-plugins/node/usage.uebersicht.js"

  $.getScript "nerdbar.avm.widget/lib/dynamic.js", (stack) ->
    _widget = nbWidget(widget[0], widget[1], widget[2])
    self.run(cmd, cb)

refreshFrequency: "1h"

render: (output) ->
  json = JSON.parse output
  cls = ""

  if json.usageLeft < 5
    cls = "low"

  if json.usageLeft >= 5
    cls = "ok"

  if json.usageLeft > 8
    cls = "high"

  "<span class='label'>gbs</span><span class='usage #{cls}'>#{json.symbol}</span><span class='usage-value'>#{json.usageLeft} gbs/day</span>"

afterRender: (domEl) ->
  _widget.domEl domEl

  $(domEl).css({ right: _widget.getRight() + "px", width: _widget.getWidth() + "px" })

  _widget.update(!$(domEl).find(".usage").hasClass("high"))

style: """
  font: 12px -apple-system, Osaka-Mono, Hack, Inconsolata
  height: 26px
  line-height: 26px
  top: 0
  color: #555
  display: flex
  justify-content: center
  -webkit-user-select: none

  &.hidden
    display: none

  .usage-value
    position: absolute
    right: 0
    bottom: -60px
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
      font-size: 20px

    span.low
      color: #ec3f1d

    span.ok
      color: #ecb512

    span.high
      color: #88c625
"""
