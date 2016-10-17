command: "date +%H"

refreshInterval: "30m"

render: (output) ->
  time = parseInt output

  if time >= 0 and time < 6
    greet = "You should sleep"

  if time >= 6 and time < 12
    greet = "Good Morning"

  if time >= 12 and time < 17
    greet = "Good Afternoon"

  if time >= 17 and time < 24
    greet = "Good Evening"

  out = "#{greet}, Aditya!"

style: """
  font: 13px Osaka-Mono
  color: #aaa
  top: 6px
  left: 10px
  z-index: 1
"""
