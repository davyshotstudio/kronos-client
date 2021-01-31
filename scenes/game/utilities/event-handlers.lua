-- onUserActionEvent is a custom wrapper that provides functionality
-- to handle multiple user interactions including TAP and HOLD in a generic way

-- actions are a table of callback functions executed for each action
-- {
--   tap = function(name) print('hello ' .. name) end,
--   hold = function(name) print('idiot .. ' name) end,
-- }
--
-- options are a table containing customizable settings
-- {
--   -- holdTime represents how long before hold action kicks in (ms)
--   holdTime = 500,
--   -- scrollView is a reference to the parent scroll widget.
--   -- This is needed to allow swiping to work if this event is called
--   -- within a scroller
--   scrollView = 500,
-- }
--

local holdStartTime = 0
local isHeld = false

local function onUserActionEvent(event, actions, options)
  -- Pull out options or assign defaults
  local holdTime = options.holdTime or 150
  local scrollView = options.scrollView or nil

  if (event.phase == "began") then
    holdStartTime = event.time
    isHeld = false
  end

  -- If the user is swiping, pass off focus to the scroll widget to allow scrolling
  if (event.phase == "moved") then
    if (event.time - holdStartTime > holdTime) then
      if (isHeld) then
        return
      end

      isHeld = true

      if (actions["hold"] == nil) then
        return
      end

      actions["hold"]()
      return
    end

    -- Ignore scroll option if not available
    -- This is for compatiblity with the scroller widget to allow
    -- scrolling when you swipe on a button in the scroller
    if (scrollView == nil) then
      return
    end

    local dx = math.abs((event.x - event.xStart))
    if (dx > 10) then
      scrollView:takeFocus(event)
    end
  end

  if (event.phase == "ended") then
    -- If user is holding down on the card, don't trigger hold action
    if (isHeld) then
      return
    end

    if (actions["tap"] == nil) then
      return
    end

    actions["tap"]()
  end
end

return {
  onUserActionEvent = onUserActionEvent
}
