#
# stack
#

_widget = null
widget = [3, 80, true]
maxHeight = 13

#
# widget
#

command: (cb) ->
  self = this
  cmd = "echo $(ps -A -o %mem | awk '{s+=$1} END {print \"\" s}'),$(ps -A -o %cpu | awk '{s+=$1} END {printf(\"%.2f\",s/8);}')"

  $.getScript "nerdbar.avm.widget/lib/dynamic.js", (stack) ->
    _widget = nbWidget(widget[0], widget[1], widget[2])
    self.run(cmd, cb)

refreshFrequency: 5000 # ms

render: (output) ->
  [mem, cpu] = output.trim().split(",").map(parseFloat)

  cpuC = switch
    when cpu > 25 then "high"
    when cpu > 50 then "veryhigh"
    else "low"
  memC = switch
    when mem > 70 then "high"
    when mem > 90 then "veryhigh"
    else "low"

  """
  stat
  <span class="#{cpuC}" style="height:#{cpu*0.4}%"></span>
  <span class="#{memC}" style="height:#{mem*0.4}%"></span>
  """

afterRender: (domEl) ->
  _widget.domEl domEl
  $(domEl).css({ right: _widget.getRight() + "px", width: _widget.getWidth() + "px" })

style: """
  color: #333
  font: 12px -apple-system, Osaka-Mono, Hack, Inconsolata
  top: 0
  height: 26px
  line-height: 26px
  text-align: center
  display: flex
  align-items: flex-end
  justify-content: center

  &.hidden
    display: none

  span
    margin-bottom: 10px
    width: 4px
    background-color: #888573
    margin-left: 5px

    &.high
      background-color: #ff8000

    &.veryhigh
      background-color: #ec3f1d

    & + span
      margin-left: 2px
"""
