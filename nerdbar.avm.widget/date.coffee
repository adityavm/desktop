#
# stack
#

_widget = null
widget = [1, 100, true]

#
# widget
#

command: (cb) ->
  self = this
  cmd = "date +\"%a %d %b\""

  $.getScript "nerdbar.avm.widget/lib/dynamic.js", (stack) ->
    _widget = nbWidget(widget[0], widget[1], widget[2])
    self.run(cmd, cb)

refreshFrequency: 10000

render: (output) ->
  out = output.split " "
  day = out[0].toLowerCase()
  """<span class="day #{day}">#{out[0]}</span> #{out[1..2].join(" ")}"""

afterRender: (domEl) ->
  _widget.domEl domEl
  $(domEl).css({ right: _widget.getRight() + "px", width: _widget.getWidth() + "px" })

style: """
  color: #888573
  font: 12px -apple-system, Osaka-Mono, Hack, Inconsolata
  top: 0
  height: 26px
  line-height: 26px
  text-align: center

  &.hidden
    display: none

  span.day
    &.fri
      color: #ecb512

    &.sat,
    &.sun
      color: #b5c625
"""
