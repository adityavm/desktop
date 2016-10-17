command: "ESC=`printf \"\e\"`; ps -A -o %cpu | awk '{s+=$1} END {printf(\"%.2f\",s/8);}'"

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

style: """
  color: #555
  font: 12px -apple-system, Osaka-Mono, Hack, Inconsolata
  right: 280px
  top: 0
  height: 26px
  line-height: 26px

  span.green
    color: #7AAB7E

  span.orange
    color: #b6711f

  span.red
    color: #d11c1c
"""
