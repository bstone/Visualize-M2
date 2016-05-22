
root = exports ? this

Plot = () ->
  width = 600
  height = 600
  data = []
  points = null
  margin = {top: 20, right: 20, bottom: 50, left: 50}
  minScale = 0
  maxScale = 10
  pointData = []
  rectData = []
  xScale = d3.scale.linear().domain([minScale,maxScale]).range([0,width])
  #yScale = d3.scale.linear().domain([0,10]).range([0,height])
  yScale = d3.scale.linear().domain([minScale,maxScale]).range([height,0])
  xValue = (d) -> parseFloat(d.x)
  yValue = (d) -> parseFloat(d.y)
  svg = null
  g = null
  mouseCircle = null
  mouseLineX = null
  mouseLineY = null
  lineMode = 'Guide'
  history = []
  countHistory = []
  scale = d3.scale.category10()

  xAxis = d3.svg.axis()
    .scale(xScale)
    .orient('bottom')

  yAxis = d3.svg.axis()
    .scale(yScale)
    .orient('left')

  chart = (selection) ->
    selection.each (rawData) ->

      data = rawData

      [minScale..maxScale].forEach (x) ->
        [minScale..maxScale].forEach (y) ->
          pointData.push([x,y])

      svg = d3.select(this).selectAll("svg").data([data])
      gEnter = svg.enter().append("svg").append("g")
      
      svg.attr("width", width + margin.left + margin.right )
      svg.attr("height", height + margin.top + margin.bottom )

      rect = svg.append("rect")
        .attr("id", "background_rect")
        .attr("width",  width + margin.left + margin.right )
        .attr("height", height + margin.top + margin.bottom )

      g = svg.select("g")
        .attr("transform", "translate(#{margin.left},#{margin.top})")

      svg.on("mousemove", hoverCircle)

      svg.on("click", clicker)

      g.append('g')
        .attr("class", "x axis")
        .attr("transform", "translate(0," + height + ")")
        .call(xAxis)
     
      g.append('g')
        .attr("class", "y axis")
        .call(yAxis)

      svg.append('text')
        .attr('class', 'axis_text')
        .attr('x', 10)
        .attr('y', height + margin.top)
        .attr('dy', 5)
        .text('Y')

      svg.append('text')
        .attr('class', 'axis_text')
        .attr('x', 40)
        .attr('y', height + margin.top + margin.bottom )
        .text('X')

      dots = g.append('g')
        .attr("class", 'dots')

      dots.selectAll('.dot')
        .data(pointData).enter()
        .append('circle')
        .attr('class', 'dot')
        .attr('cx', (d) -> xScale(d[0]))
        .attr('cy', (d) -> yScale(d[1]))
        .attr('r', 4)


      mouseLineX = g.append("line")
        .attr("class", "mouse_line")
      mouseLineY = g.append("line")
        .attr("class", "mouse_line")

      mouseCircle = g.append("circle")
        .attr("r", 6)
        .style("fill", "steelblue")


      points = g.append("g").attr("id", "vis_points")
      update()


  guideCount = (x,y) ->
    summed = x + y
    filteredData = pointData.filter (d) ->
      match = (d[0] + d[1] == summed)
      if match
        rectData.forEach (r) ->
          if d[0] >= r[0] and d[1] >= r[1]
            match = false
      match

    size = filteredData.length
    size

  updateGuideCount = (x,y) ->
    el = d3.select('#guide_count')
    if x >= 0
      size = guideCount(x,y)
      el.text(size)
    else
      el.text('')

  clicker = (e) ->
    if lineMode == 'Guide'
      makeRectangle(e, this)
    else
      addCount(e, this)

  addCount = (e, that) ->
    m = d3.mouse(that)
    roundedX = Math.round(xScale.invert(m[0] - margin.left ))
    roundedY = Math.round(yScale.invert(m[1] - margin.top))
    count = guideCount(roundedX, roundedY)

    updateHistoryCount(count)

  makeRectangle = (e, that) ->
    m = d3.mouse(that)
    roundedX = Math.round(xScale.invert(m[0] - margin.left ))
    roundedY = Math.round(yScale.invert(m[1] - margin.top))
    rectData.push([roundedX, roundedY])
    rHeight = (height + margin.top)

    #rHeight = 20
    # rWidth = width - xScale(roundedX)
    rWidth = width

    rY = yScale(roundedY) - height

    updateHistory(roundedX,roundedY)

    # TODO: why is this scale not 
    #  the same as the circles? why - 10 ??
    svg.append("rect")
      .attr("x",xScale(roundedX) + margin.left)
      .attr("y", rY)
      .attr("width", rWidth)
      .attr("height", rHeight)
      .style("fill", (d) -> scale(roundedX + roundedY))
      .style("opacity", 0.6)

  hoverCircle = (e) ->
    m = d3.mouse(this)
    roundedX = Math.round(xScale.invert(m[0] - margin.left))
    roundedY = Math.round(yScale.invert(m[1] - margin.top))

    mouseCircle
      .attr("cx", xScale(roundedX))
      .attr("cy", yScale(roundedY))

    if lineMode == 'Guide'
      mouseLineX
        .attr("x1", 0)
        .attr("x2", xScale(roundedX))
        .attr('y1', yScale(roundedY))
        .attr('y2', yScale(roundedY))

      mouseLineY
        .attr("x1", xScale(roundedX))
        .attr("x2", xScale(roundedX))
        .attr('y1', yScale(roundedY))
        .attr('y2', height)

      updateGuideCount(-1, -1)
    else
      updateGuideCount(roundedX, roundedY)
      d = roundedX + roundedY

      mouseLineX
        .attr("x1", 0)
        .attr('y1', yScale(d))
        .attr("x2", xScale(d))
        .attr('y2', height)

      mouseLineY
        .attr("x1", 0)
        .attr("x2", 0)
        .attr('y1', 0)
        .attr('y2', 0)


    updateDisplay(roundedX, roundedY)

  update = () ->
    points.selectAll(".point")
      .data(data).enter()
      .append("circle")
      .attr("cx", (d) -> xScale(xValue(d)))
      .attr("cy", (d) -> yScale(yValue(d)))
      .attr("r", 4)
      .attr("fill", "steelblue")


  monize = (a, v) ->
    display ="#{a}<sup>#{v}</sup>"
    if v == 1
      display =  "#{a}"
    if v == 0
      display = ""
    display

  displayValues = (x,y) ->
    xd = monize('x', x)
    yd = monize('y', y)
    divider = "  "
    if xd.length == 0 or yd.length == 0
      divider = ""
    "#{xd}#{divider}#{yd}"

  updateDisplay = (x,y) ->
    d3.select("#display").html(displayValues(x,y))


  showHistoryCount = () ->
    dis = ""
    countHistory.forEach (h) ->
      dd = ""
      dd = "<p><span class=\"\">#{h}</span></p>"
      dis += dd
    d3.select("#history").html(dis)

  updateHistoryCount = (c) ->
    countHistory.push(c)
    showHistoryCount()


  showHistory = (x,y) ->
    dis = ""
    history.forEach (d) ->
      dd = ""
      covered = d[2]
      if x >= 0 and x <= d[0] and y <= d[1]
        covered = true

      if covered
        dd = "<p><span class=\"covered\">#{displayValues(d[0], d[1])}</span></p>"
      else
        dd = "<p>#{displayValues(d[0], d[1])}</p>"

      d[2] = covered
      dis += dd

    if x >= 0
      dis += "<p><span class=\"current\">#{displayValues(x,y)}</span></p>"
    d3.select("#history").html(dis)

  updateHistory = (x,y) ->
    showHistory(x,y)
    history.push([x,y,false])

  chart.height = (_) ->
    if !arguments.length
      return height
    height = _
    chart

  chart.width = (_) ->
    if !arguments.length
      return width
    width = _
    chart

  chart.mode = (_) ->
    if !arguments.length
      return lineMode
    lineMode = _
    if lineMode == 'Guide'
      showHistory(-1,-1)
    else
      showHistoryCount()
    chart

  chart.margin = (_) ->
    if !arguments.length
      return margin
    margin = _
    chart

  chart.x = (_) ->
    if !arguments.length
      return xValue
    xValue = _
    chart

  chart.y = (_) ->
    if !arguments.length
      return yValue
    yValue = _
    chart

  return chart

root.Plot = Plot

root.plotData = (selector, data, plot) ->
  d3.select(selector)
    .datum(data)
    .call(plot)



$ ->

  plot = Plot()

  switchGuide = () ->
    curr = d3.select(this).text()
    next = if (curr == 'Guide') then 'Line' else 'Guide'
    d3.select(this).text(next)
    plot.mode(next)
  
    d3.event.preventDefault()

  display = (error, data) ->
    plotData("#vis", data, plot)

  d3.select('#guide_toggle').on('click', switchGuide)

  d3.csv("data/test.csv", display)

