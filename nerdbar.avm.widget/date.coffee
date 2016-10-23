#
# stack
#

_widget = null
widget = [1, 80, true]

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
  "#{output}"

afterRender: (domEl) ->
  _widget.domEl domEl
  $(domEl).css({ right: _widget.getRight() + "px", width: _widget.getWidth() + "px" })

style: """
  color: #ee6aa0
  font: 12px -apple-system, Osaka-Mono, Hack, Inconsolata
  top: 0
  height: 26px
  line-height: 26px
  text-align: center

  &.hidden
    display: none
"""
