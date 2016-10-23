#
# stack
#

_widget = null
widget = [5, 60, true]

#
# widget
#

command: (cb) ->
  self = this
  cmd = "ESC=`printf \"\e\"`; ps -A -o %cpu | awk '{s+=$1} END {printf(\"%.2f\",s/8);}'"

  $.getScript "nerdbar.avm.widget/lib/dynamic.js", (stack) ->
    _widget = nbWidget(widget[0], widget[1], widget[2])
    self.run(cmd, cb)

refreshFrequency: 2000

render: (output) ->
  floatVal = parseFloat output
  str = ""

  if floatVal > 75
    str = "cpu <span class='red'>#{output}</span>"
  else if floatVal > 45
    str = "cpu <span class='orange'>#{output}</span>"
  else if floatVal > 0
    str = "cpu <span class='green'>#{output}</span>"

  str

afterRender: (domEl) ->
  _widget.domEl domEl
  $(domEl).css({ right: _widget.getRight() + "px", width: _widget.getWidth() + "px" })

style: """
  color: #555
  font: 12px -apple-system, Osaka-Mono, Hack, Inconsolata
  top: 0
  height: 26px
  line-height: 26px
  text-align: center

  span.green
    color: #88c625

  span.orange
    color: #ff8000

  span.red
    color: #ec3f1d
"""
