function generateTimestamps(startTime::DateTime, increment, len::Int)
  """
  Return a pandas Series containing the specified list of timestamps.
  @param startTime      (datetime)    Start time
  @param increment  (timedelta)   Time increment
  @param len     (int)         Number of datetime objects
  """
  timestamps = collect(startTime:increment:startTime+len*increment-increment)
  return timestamps
end


function generateWindows(timestamps::Array{DateTime}, numWindows::Int, windowSize::Int)
  """
  Returns a list of numWindows windows, where each window is a pair of
  timestamps. Each window contains windowSize intervals. The windows are roughly
  evenly spaced throughout the list of timestsamps.
  @param timestamps  (Series) Pandas Series containing list of timestamps.
  @param numWindows  (int)    Number of windows to return
  @param windowSize  (int)    Number of 'intervals' in each window. An interval
                              is the duration between the first two timestamps.
  """
  startTime = timestamps[1]
  delta = timestamps[2] - timestamps[1]
  diff = round(Int, (length(timestamps) - numWindows * windowSize) / float(numWindows + 1))
  windows = Array(Tuple{DateTime,DateTime},0)
  for i in 1:numWindows
    t1 = startTime + delta * diff * i + (delta * windowSize * (i - 1))
    t2 = t1 + delta * (windowSize - 1)
    if !(any(timestamps .== t1)) || !(any(timestamps .== t2))
      error("You got the wrong times from the window generator")
    end
    push!(windows, (t1, t2))
  end
  return windows
end

function generateLabels(timestamps::Array{DateTime}, windows)
  """
  Returns a pandas Series of integers containing a 1 for every window and 0
  everywhere else.
  @param timestamps (Series)   Pandas Series containing list of timestamps.
  @param windows    (list)     List of datetime pairs corresponding to each
                               time window.
  """
  labels = zeros(Int, length(timestamps))
  for (t1, t2) in windows
    subset = t2 .>= timestamps .>= t1
    labels[subset] = 1
  end
  return labels
end