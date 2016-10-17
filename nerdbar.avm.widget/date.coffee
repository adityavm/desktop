command: "date +\"%a %d %b\""

refreshFrequency: 10000

render: (output) ->
  "#{output}"

style: """
  color: #B16286
  font: 12px "SFNS Display", Osaka-Mono, Hack, Inconsolata
  right: 60px
  top: 6px
"""
