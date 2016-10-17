command: "date +\"%a %d %b\""

refreshFrequency: 10000

render: (output) ->
  "#{output}"

style: """
  color: #ee6aa0
  font: 12px -apple-system, Osaka-Mono, Hack, Inconsolata
  right: 65px
  top: 0
  height: 26px
  line-height: 26px
"""
