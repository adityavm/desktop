command: "pmset -g batt | egrep '([0-9]+\%).*' -o --colour=auto | cut -f1 -d';'"

refreshFrequency: 150000 # ms

render: (output) ->
  widthCls = ""
  outputInt = parseInt output

  if outputInt >= 0   then widthCls = "w0"
  if outputInt >= 25 then widthCls = "w25"
  if outputInt >= 50 then widthCls = "w50"
  if outputInt >= 75 then widthCls = "w75"
  if outputInt == 100 then widthCls = "w100"

  """
  <span class='content'>
    <span class='label text'>
      <span class='battery icon #{widthCls}'></span>
      <span class='text'>bat</span>
    </span>
    <span class='charge'>#{output}</span>
  </span>
  """

afterRender: (domEl) ->
  out = ""

  @run "pmset -g batt", (err, resp) ->
    out = resp.split ";"
    $(domEl).find(".content").addClass(out[1])

style: """
  font: 12px -apple-system, Osaka-Mono, Hack, Inconsolata
  top: 0
  right: 140px
  height: 26px

  span.content
    display: inline-block
    line-height: 26px
    height: 26px
    color: #8EC620
    padding: 0 3px 0 5px

    &.discharging
      background-color: #ecb512
      color: #333

      .label
        background-color: #ecb512
        color: rgba(#000, 0.25)

    &.charging
      color: #ecb512

    &.finishing.charge
      color: #b5c625

    &.charged
      color: #88c625

  span.label
    width: 15px
    display: inline-block
    position: relative
    color: #555

    &.text
      margin-right: 3px

      .icon
        display: none

    &.icon
      .text
        display: none

    .battery.icon
      position: absolute
      margin-left: -2px
      margin-top: -8px
      width: 13px
      height: 7px
      border-radius: 2px
      border: solid 1px currentColor

      &:before
        content: ''
        position: absolute
        right: -3px
        top: 1px
        width: 2px
        height: 3px
        border-radius: 0 2px 2px 0
        border-top: solid 1px currentColor
        border-right: solid 1px currentColor
        border-bottom: solid 1px currentColor

      &:after
        content: ''
        position: absolute
        left: 1px
        top: 1px
        width: 11px
        height: 5px
        background-color: currentColor

      &.w0:after
        width: 1px

      &.w25:after
        width: 3px

      &.w50:after
        width: 5.5px

      &.w75:after
        width: 8px

      &.w100:after
        width: 11px

"""
