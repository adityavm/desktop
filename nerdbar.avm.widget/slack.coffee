#
# stack
#

_widget = null
widget = [6, 60, true]

#
# globals
#

impTypes = []
impChannels = []
impChannelsID = {}

constant =
  SLACK:
    CONNECTED: 1
    DISCONNECTED: 2
  LEVEL:
    IMPORTANT: 1
    VERYBUSY: 2
    BUSY: 3

#
# slack connection abstraction
#
class SlackConnection

  constructor: (@state, @alive) ->
    @state = constant.SLACK.DISCONNECTED
    console.log("initialised new slack")

  #
  # slack connection state getter / setter
  getState: () -> @state
  setState: (state) -> @state = state

  #
  # open a new connection
  start: (url) ->
    @socket = new WebSocket url

    @socket.onmessage = (ev) =>
      typ = ev.type
      msg = JSON.parse ev.data

      # reset
      clearTimeout(@alive)
      Widget.isConnected(@getState() == constant.SLACK.DISCONNECTED)
      @setState(constant.SLACK.CONNECTED)

      # if no message in 60s, connection is probably dead
      @alive = setTimeout(() =>

        @setState(constant.SLACK.DISCONNECTED)
        Widget.isDisconnected()

      , cfg.DEAD_TIMER)

      @handle typ, msg

  #
  # restart connection
  restart: () ->
    if (@socket?)
      @socket.close()
      @socket = null
      @start json.url

  #
  # handle each socket message
  handle: (type, msg) ->

    console.log msg # quick log

  	# if non-message, message from self or bot
    if type != "message" or msg.user == cfg.SLACK_SELF_ID or msg.bot_id then return

    if msg.type == "message"
      if msg.subtype != "message_deleted" and msg.subtype != "message_changed"
        if !!impChannelsID[msg.channel]
          impChannelsID[msg.channel].unread_count += 1

    if msg.type == "channel_marked" or msg.type == "group_marked"
      console.log """channel #{msg.channel}"""
      if !!impChannelsID[msg.channel]
        console.log """marking #{msg.unread_count}"""
        impChannelsID[msg.channel].unread_count = msg.unread_count
        console.log impChannelsID

    if msg.type == "im_marked"
      console.log """marking im #{msg.dm_count}"""
      impChannelsID[msg.channel].unread_count = msg.dm_count
      console.log impChannelsID

    @updateOnMsg()

    if msg.type != "message" then return

  #
  # update dom
  updateOnMsg: (chn, msg) ->

    unreadChannelsCount = if chn then chn else @unreadChannels()
    unreadMsgsCount = if msg then msg else @unreadMsgs()

    # reset
    Widget.reset()

    # set
    if unreadChannelsCount > 0
      # choose how to highlight
      hlCls = if unreadChannelsCount > 5 or unreadMsgsCount > 20 then constant.LEVEL.VERYBUSY else constant.LEVEL.BUSY
      hlCls = if @haveImportant() then constant.LEVEL.IMPORTANT else hlCls

      Widget
        .setImportance hlCls
        .setUnreadChannels unreadChannelsCount
        .setUnreadMessages unreadMsgsCount
        .show()
    else
      Widget.hide()


  # type channel
  getType: (e) ->
    if e.is_channel then return "channel"
    if e.is_group then return "group"
    if e.is_im then return "im"


  # have important messages?
  haveImportant: () ->
    imp = false
    for ch, val of impChannelsID
      if val.unread_count > 0
        if impTypes.indexOf(val.type) > -1
          imp = true
          break
    return imp


  # get unread channels count
  unreadChannels: () ->
    sum = 0
    for ch, val of impChannelsID
      sum += if val.unread_count > 0 then 1 else 0
    return sum


  # get unread messages count
  unreadMsgs: () ->
    sum = 0
    for ch, val of impChannelsID
      sum += val.unread_count
    return sum


#
# uebersicht element interaction
#
class WidgetElement

  constructor: (@self, @retry) ->
    console.log("initialised new widgetelement")

  #
  # set the uebersicht widget element
  setEl: (el) ->
    @domEl = el
    return this

  #
  # get dom element
  getEl: () -> $(@domEl)

  #
  # set connected
  isConnected: (wasDead) ->
    retry = @retry
    @retry = 0
    unread = @getEl().find ".unread"

    unread.removeClass "disconnected trying"
    if (wasDead == true)
      @hide()
      @show()
      unread.addClass "connected"
      setTimeout () =>
        unread.removeClass "connected"
      , 3000

    if (retry)
      console.log "%cconnected", "color: #7aab7e", "cleared interval (was #{retry}, is #{@retry}), continuing ..."

    return this

  #
  # set trying
  isTrying: () ->
    @show()
    @getEl().find(".unread").removeClass("disconnected connected").addClass("trying")

  #
  # set disconnected
  isDisconnected: () ->
    @show()
    @getEl().find(".unread").removeClass("disconnected trying").addClass("disconnected")

    return """
      slck
      <span class="unread disconnected">
        <span class="status">&bull;</span>
      </span>
    """

  #
  # set unread channels
  setUnreadChannels: (count) ->
    @getEl().find(".channels").text count
    return this

  #
  # set unread messages
  setUnreadMessages: (count) ->
    @getEl().find(".count").text count
    return this

  #
  # set importance
  setImportance: (level) ->
    cls =
      1: "important"
      2: "very-busy"
      3: "busy"

    @getEl().find(".unread").addClass cls[level]
    return this

  #
  # reset all
  reset: () ->
    @getEl().find(".unread").removeClass("disconnected trying busy very-busy important")
    @getEl().find(".channels").text 0
    @getEl().find(".count").text 0
    return this

  #
  # show the widget
  show: () ->
    @getEl().addClass("show")
    return this

  #
  # hide the widget
  hide: () ->
    @getEl().removeClass("show")
    return this

  #
  # refresh the widget
  refresh: () ->
    if (Slack.getState() != constant.SLACK.DISCONNECTED)
      console.error "tried to refresh when not disconnected, stopping"
      return

    console.warn "forcing refresh"
    @isTrying()
    @self.refresh()
    return this

  #
  # retry
  willTry: (long) ->
    waitTime = if long == true then (4 * cfg.RETRY_INTERVAL) else cfg.RETRY_INTERVAL
    console.warn "starting #{waitTime / 1000}s retry timer"

    @retry = setTimeout () =>
      @self.refresh()
    , waitTime # retry

    return this


#
# widget
#

Slack = null
Widget = null

command: (cb) ->
  self = this

  $.getScript "nerdbar.avm.widget/lib/cfg.js", (data) ->
    impTypes = cfg.TYPES
    impChannels = cfg.CHANNELS

    $.getScript "nerdbar.avm.widget/lib/dynamic.js", (stack) ->
      _widget = nbWidget.apply null, widget

      self.run """curl -s https://slack.com/api/rtm.start?token=#{cfg.SLACK_TOKEN}&simple_latest=true""", cb

refreshFrequency: false

render: (output) ->
  console.log """got output, length: #{output.length}"""

  if !Widget? then Widget = new WidgetElement this
  err = false
  retry = false

	# try and parse the response . this will erorr
	# if slack api throws up . keep retrying until
	# we get a successful response .

  try
    json = JSON.parse output
  catch e
    err = true
    console.error "[slack] parse error", e
    Widget.willTry(output.toLowerCase().indexOf("too many requests") > -1)
    return Widget.isDisconnected()

  if !err
    Widget.isConnected()
  else
    return Widget.isDisconnected()

  Slack = new SlackConnection constant.SLACK.CONNECTED

	# assign self
  cfg.SLACK_SELF_ID = json.self.id
  console.log "%cinfo", "color: #53d1ed", "got self, setting #{cfg.SLACK_SELF_ID}"

	# set important channels, ims + unread count
  json.channels
    .concat(json.groups)
    .filter((c) -> (impChannels.indexOf(c.name) > -1))
    .concat(json.ims)
    .map((c) ->
      impChannelsID[c.id] =
        type: Slack.getType(c)
        name: c.name
        unread_count: c.unread_count
    )

	# set initial values from rtm.start json
  unreadChannelsCount = json.channels.filter((c) -> !!impChannelsID[c.id] && c.unread_count > 0).length
  unreadMsgsCount = json.channels
    .filter((c) -> !!impChannelsID[c.id] && c.unread_count > 0)
    .reduce(((a, b) -> a.unread_count + b.unread_count), { unread_count: 0 }).unread_count

	# trigger update with forced values
  Slack.updateOnMsg(unreadChannelsCount, unreadMsgsCount)

	# initialise socket
  if (Slack.getState() == constant.SLACK.DISCONNECTED)
    Slack.start json.url
  else
    Slack.restart()

  """
  slck
  <span class="unread">
    <span class="channels">0</span>
    <span class="count">0</span>
    <span class="status">&bull;</span>
  </span>
  """

afterRender: (el) ->

  # save el
  _widget.domEl el
  Widget.setEl el

  # reflect states
  if (!Slack? or !Slack.getState() == constant.SLACK.DISCONNECTED) then Widget.show()

  # allow quick refresh
  Widget.getEl().unbind("click").bind("click", () -> Widget.refresh())

  Widget.getEl().css({ right: _widget.getRight() + "px", width: _widget.getWidth() + "px" })

style: """
  font: 12px -apple-system, Osaka-Mono, Hack, Inconsolata
  right: 395px
  top: 0
  height: 26px
  line-height: 26px
  text-align: center
  width: 65px
  color: #555
  opacity: 0
  transition: opacity 0.2s
  -webkit-user-select: none
  cursor: pointer

  &.hidden
    display: none

  &.show
    opacity: 1

  .unread
    color: #aaa

    .channels
      color: #aaaaaa
      font-size: 14px

    &.very-busy .channels
      color: #ff8000

    &.busy .channels
      color: #ecb512

    &.important .channels
      color: #df1d1d

    .count
      font-size: 10px
      color: #aaa

    .status
      display: none

    &.disconnected,
    &.trying
    &.connected
      .channels,
      .count
        display: none

      .status
        display: inline-block

    &.disconnected .status
      color: #df1d1d

    &.trying .status
      color: #53d1ed

    &.connected .status
      color: #88c625
"""
