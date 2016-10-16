command: "pmset -g batt | egrep '([0-9]+\%).*' -o --colour=auto | cut -f1 -d';'"

refreshFrequency: 150000 # ms

render: (output) ->
  "<i>⚡</i>#{output}"

style: """
  font: 12px Osaka-Mono
  top: 4px
  right: 140px
  color: #FABD2F
  span
    color: #9C9486
"""
