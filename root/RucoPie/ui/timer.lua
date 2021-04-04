local timer = {
  list = {}
}

function timer.new(key, delay, times)
  timer.list[key] = {
    delay = delay,
    timerCount = 0,
    count = 1,
    times = times,
    enabled = true
  }
end

function timer.isTimeTo(key, dt)
  local t = timer.list[key]

  if not t or not t.enabled then
    return false
  end

  t.timerCount = t.timerCount + dt

  if t.timerCount >= t.delay then
    t.timerCount = 0
    if t.times then
      t.count = t.count + 1
      if t.count > t.times then
        t.enabled = false
      end
    end

    return true
  end
end

function timer.get(key)
  local t = timer.list[key]

  if t and t.enabled then
    return t
  end
end

function timer.getTimerCount(key)
  local t = timer.list[key]

  if not t then
    return nil
  end

  return t.timerCount
end

function timer.getTimerProportion(key)
  return timer.getTimerCount(key) / timer.getDelay(key)
end

function timer.getDelay(key)
  local t = timer.list[key]

  if not t then
    return nil
  end

  return t.delay
end

function timer.setDelay(key, delay)
  local t = timer.list[key]

  if t then
    t.delay = delay
  end
end

function timer.completeIteration(key)
  local t = timer.list[key]

  if t then
    t.timerCount = t.delay
  end
end

return timer
