#
# stack
#

_widget = null
widget = [5, 80, true]

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
    if type != "message" or msg.user == cfg.SLACK_SELF_ID or msg.bot_id
      @updateOnMsg()
      return

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

    unreadChannelsCount = if chn then chn else @unreadChannelsCount()
    unreadChannelsList = @unreadChannelsList()
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
        .setUnreadChannels(unreadChannelsCount, unreadChannelsList)
        .setUnreadMessages unreadMsgsCount
        .show()
      _widget.update true
    else
      Widget.hide()
      _widget.update false


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
  unreadChannelsCount: () ->
    sum = 0
    for ch, val of impChannelsID
      sum += if val.unread_count > 0 then 1 else 0
    return sum


  # get unread channels list
  unreadChannelsList: () ->
    list = []
    for ch, val of impChannelsID
      if val.unread_count > 0
        list.push if val.name then val.name else "im"
    return list.join ","


  # get unread messages count
  unreadMsgs: () ->
    sum = 0
    for ch, val of impChannelsID
      sum += if val.unread_count > 0 then val.unread_count else 0
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
    el = @getEl()
    @retry = 0

    el.removeClass "disconnected trying"
    if (wasDead == true)
      @hide()
      el.addClass "connected"
      setTimeout () ->
        el.removeClass "connected"
      , 3000

    if (retry)
      console.log "%cconnected", "color: #7aab7e", "cleared interval (was #{retry}, is #{@retry}), continuing ..."

    return this

  #
  # set trying
  isTrying: () ->
    @getEl().removeClass("disconnected connected").addClass("trying")

  #
  # set disconnected
  isDisconnected: () ->
    @getEl().removeClass("disconnected trying").addClass("disconnected")

    return """
      slck
      <span class="unread">
        <span class="status">
          <span class="bad">!</span>
        </span>
      </span>
    """

  #
  # set unread channels
  setUnreadChannels: (count, channels) ->
    @getEl().find(".channels")
      .text count
      .attr("unread-channels", channels)
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
    @getEl().find(".unread")
      .removeClass("busy very-busy important")
      .attr("unread-channels", null)
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
  json = {}

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

  if (!Slack?) then Slack = new SlackConnection constant.SLACK.CONNECTED

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
    <span class="status">
      <span class="good">&#10084;</span>
      <span class="bad">!</span>
      <span class="ok">&bull;</span>
    </span>
  </span>
  """

afterRender: (el) ->

  # save el
  _widget.domEl el
  Widget.setEl el

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
  color: #333
  opacity: 0
  transition: opacity 0.2s
  -webkit-user-select: none
  cursor: pointer

  .channels,
  .count,
  .status
    opacity: 0
    transition: opacity 0.2s
    display: none

  &.hidden
    display: none

  &.show,
  &.disconnected,
  &.connected,
  &.trying
    opacity: 1

  .unread
    color: #aaa

    .channels
      color: #aaaaaa
      font-size: 14px
      display: none

    &.very-busy .channels
      color: #ff8000

    &.busy .channels
      color: #ecb512

    &.important .channels
      color: #df1d1d

    .count
      font-size: 10px
      color: #aaa
      display: none

    .status
      display: none

  &.disconnected .status
    color: #df1d1d

  &.trying .status
    color: #53d1ed

  &.connected .status
    color: #88c625

  /*
   * show hide conditions
   */

  &.show
    .channels,
    .count
      opacity: 1
      display: inline-block

  &.disconnected,
  &.trying,
  &.connected
    .channels,
    .count
      opacity: 0
      display: none

    .status
      opacity: 1
      display: inline-block

  &.connected .status
    .good
      opacity: 1
      display: inline-block

    .bad, .ok
      display: none

  &.disconnected .status
    .bad
      opacity: 1
      display: inline-block

    .good, .ok
      display: none

  &.trying .status
    .ok
      opacity: 1
      display: inline-block

    .good, .bad
      display: none
"""
