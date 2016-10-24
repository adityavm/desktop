/**
 * usage
 *
 * $.getScript "nerdbar.avm.widget/lib/dynamic.js", (stack) ->
 *    _widget = nbWidget.apply(null, widget)
 *    self.run(cmd, cb)
 */
var nbWidget = (function(){
  if (!window.nerdbarStack)
    window.nerdbarStack = [];

  var
    nerdbarStack = window.nerdbarStack,
    widget = {
      props: [], // idx, width, visible
      get el() {
        return document.querySelector("#" + this._el);
      },
      _el: null,
    };

  // update right pos of all widgets
  function updateAll(){
    for(var i = 0; i < nerdbarStack.length; i++) {
      var wdgt = nerdbarStack[i];

      if (!wdgt) continue;
      if (!wdgt.el) {
        console.log("el not found " + wdgt.props[0]);
        continue;
      }

      wdgt.el.style.right = getRight(wdgt.props[0]) + "px";

      if (wdgt.props[2] === false) {
        wdgt.el.classList.add("hidden");
      } else {
        wdgt.el.classList.remove("hidden");
      }
    }
  }

  // set visibility
  function update(visible) {
    console.info("updating " + widget.props[0] + " setting " + visible);

    visible = visible !== undefined ? visible : true;
    widget.props[2] = visible
    nerdbarStack[widget.props[0]] = widget
  }

  // calculate right offset
  function getRight(idx) {
    var right = 0;

    idx = idx !== undefined ? idx : widget.props[0]

    for (var i = 0; i < nerdbarStack.length; i++) {
      var wdgt = nerdbarStack[i]
      if (!wdgt) continue;

      var props = wdgt.props;

      // only matter if it's visible, we can see and
      // it's to the right of the current widget
      if (props[2] == true && wdgt.el && props[0] < idx) {
        right += props[1];
      }
    }

    return right
  }

  // get widget width
  function getWidth() {
    return widget.props[1];
  }

  // save domEl for future manip
  function addDomEl(el) {
    widget._el = el.getAttribute("id");
  }

  // set up timer to update position of all
  // widgets
  if (!window.nerdbarInterval) {
    window.nerdbarInterval = setInterval(updateAll, 100);
  }

  return function(idx, width, visible){

    // if widget already exists, keep visibility
    visible = nerdbarStack[idx] ? nerdbarStack[idx].props[2] : visible;

    widget.props = [idx, width, visible];

    if (!nerdbarStack[idx]) {
      nerdbarStack[idx] = widget;
    }

    return {
      update: update,
      getRight: getRight,
      getWidth: getWidth,
      domEl: addDomEl,
    };
  }
})();
