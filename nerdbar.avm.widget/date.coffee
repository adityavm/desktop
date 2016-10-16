command: "date +\"%a %d %b\""

refreshFrequency: 10000

render: (output) ->
  "#{output}"

style: """
  color: #B16286
  font: 12px Osaka-Mono
  right: 60px
  top: 6px
"""
