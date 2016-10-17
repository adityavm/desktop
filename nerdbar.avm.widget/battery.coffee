command: "pmset -g batt | egrep '([0-9]+\%).*' -o --colour=auto | cut -f1 -d';'"

refreshFrequency: 150000 # ms

render: (output) ->
  "<i>⚡</i>#{output}"

style: """
  font: 12px "SFNS Display", Osaka-Mono, Hack, Inconsolata
  top: 6px
  right: 140px
  color: #FABD2F
  span
    color: #9C9486
"""
