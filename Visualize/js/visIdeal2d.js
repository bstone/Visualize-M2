
    $('#side').BootSideMenu({side:"right", autoClose: false});

    $(document).ready(function(){

    // display convex hull when clicked
    $("#convexToggle").on("click", function(){
        if(curConvex) {
          $(this).html("Convex Hull: on");
          curConvex = !curConvex;
            hull.attr("opacity",1);
            innerLattice.attr("opacity",0);
            innerLatticeConvex.attr("opacity",1);
        } else {
          $(this).html("Convex Hull: off");
          curConvex = !curConvex;
            hull.attr("opacity",0);
            innerLattice.attr("opacity",1);
            innerLatticeConvex.attr("opacity",0);
        }
      });

    // show the ideal generators when clicked
    $("#idealGens").on("click", function(){
    	if(curGens) {
          $(this).html("Convex Hull: on");
          $(this).html("Ideal Generators: "  + labels);
          curGens = !curGens;
            gens.attr("opacity",1);
        } else {
          $(this).html("Convex Hull: off");
          $(this).html("Ideal Generators: ");
          curGens = !curGens;
            gens.attr("opacity",0);
        }
      });
    });
     
        dataset.sort(function(a,b) {return a[0]-b[0]});

        svg = d3.select("body")
                        .append("svg")
                        .attr("height", h)
                        .attr("width", w)
                        .attr("id", "svgMain");

        // find largest x and y exponents
        xMax = 0;
        yMax = 0;
        for (i = 0; i < dataset.length; i++) {
                if (dataset[i][0] > xMax) {
                        xMax = dataset[i][0];
                }
                if (dataset[i][1] > yMax) {
                        yMax = dataset[i][1];
                }
        }

        // make the lattice go one unit beyond max x and y values
        // looks like chart is an array of arrays of 1's
        chart = [];
        for (i = 0; i < yMax+1; i++) {
                chart.push([]);
                for (j = 0; j < xMax+1; j++) {
                        chart[i].push(1);
                }
        }

        // determine the size of each unit square
        sq = Math.ceil(Math.min(h/(yMax+2), w/(xMax+2)));

        // datum will be a coordinate in the plane and blankout will 
        // put a 0 in every lattice point above and to the right
        var blankOut = function(datum, chart) {
                for (i = 0; i < chart.length; i++) {
                        if (i >= datum[1]) {
                                for (j = 0; j < chart[0].length; j++) {
                                        if (j >= datum[0]) {
                                                chart[i][j] = 0;
                                        }
                                }
                        }
                }
                return chart;
        }

        // put 0 in coordinates for elements of ideal
        for (k = 0; k < dataset.length; k++) {
                chart = blankOut(dataset[k], chart);
                }


        // the lattice points not in the ideal
        var makeDatFromChart = function(chart) {
                dat = [];
                for (i = 0; i < chart.length; i++) {
                        for (j = 0; j < chart[0].length; j++) {
                                if (chart[i][j] === 1) {
                                        dat.push([i, j]);
                                }
                        }
                }
                return dat;
        }

        // the coordinates of the points not in the ideal
        dat = makeDatFromChart(chart);


        
        // i'm not sure but i think the lines we get when switching
        // between convex hull are coming from the scale
        var xScale = d3.scale.linear();
        xScale.domain([0,xMax+1]);
        xScale.range([sq/2, (xMax+1.5)*sq]);

        var yScale = d3.scale.linear();
        yScale.domain([0, yMax+1]);
        yScale.range([h-1.5*sq, h-(yMax+2.5)*sq]);




        // list of triangles from generator to another generator to
        // the point with (x max, y max)
        tri = [];

        for (i = 0; i < dataset.length-1; i++) {
                for(j = i+1; j < dataset.length; j++) {
                        tri.push((2+xScale(dataset[i][0])).toString() + "," +
                        yScale(dataset[i][1]-1).toString() + " " +
                        (2+xScale(dataset[j][0])).toString() + "," +
                        yScale(dataset[j][1]-1).toString() + " " +
                        (2+xScale(Math.max(dataset[i][0],
                        dataset[j][0]))).toString() + "," +
                        yScale(Math.max(dataset[i][1],
                        dataset[j][1])-1).toString());
                }
        }



        console.log(tri);

        var xAxis = d3.svg.axis()
                        .scale(xScale)
                        .ticks(xMax)
                        .orient("bottom");

        var yAxis = d3.svg.axis()
                        .scale(yScale) 
                        .ticks(yMax)
                        .orient("left");

        var latticePoints= [];
        for (i = 0; i <= yMax; i++) {
                for (j = 1; j <= xMax+1; j++) {
                        latticePoints.push([i,j]);
                }
        }

        // shades all the squares not in the ideal
        ideal = svg.selectAll("rect")
                        .data(dat)
                        .enter()
                        .append("rect")
                        .attr("x", function(d) { return Math.ceil(xScale(d[1])); })
                        .attr("y", function(d) { return Math.ceil(yScale(d[0])); })
                        .attr("width", sq+1) // add 1 to get rid of potential line
                        .attr("height", sq+1) // add 1 to get rid of potential line
                        .attr("fill", "#f5deb3");
                                        

        // shades all the triangles. default is transparent
        hull = svg.selectAll("polygon")
                        .data(tri)
                        .enter()
                        .append("polygon")
                        .attr("points", function(d) { return d; })
                        .attr("fill", "#FFFFFF")
                        .attr("opacity", 0);

        // shades all the lattice points
        lattice = svg.selectAll("circle.lattice")
                        .data(latticePoints)
                        .enter()
                        .append("circle")
                        .attr("cx", function(d) { return Math.floor(xScale(d[1])); })
                        .attr("cy", function(d) { return Math.floor(yScale(d[0])); })
                        .attr("r", 4) 
                        .attr("fill", "#b3caf5");

        // shades all the generators
        gens = svg.selectAll("circle.lattice")
                        .data(dataset)
                        .enter()
                        .append("circle")
                        .attr("cx", function(d) { return Math.floor(xScale(d[0])); })
                        .attr("cy", function(d) { return Math.floor(yScale(d[1]-1)); })
                        .attr("r", 6) 
                        .attr("fill", "#FF3307")
                        .attr("opacity", 0);


        svg.append("g")
                .attr("class", "axis")
                .attr("transform", "translate(0," + (h-sq/2) + ")")
                .call(xAxis);

        svg.append("g")
                .attr("class", "axis")
                .attr("transform", "translate(" + sq/2 + "," + sq + ")")
                .call(yAxis);


        var makeXYstring = function(x,y) {
                if (x === 0) { xstr = ""; }
                else if (x === 1) { xstr = "x"; }
                else { xstr = "x<sup>" + x.toString() + "</sup>"; }
                if (y === 0) { ystr = ""; }
                else if (y === 1) { ystr = "y"; }
                else { ystr = "y<sup>" + y.toString() + "</sup>"; }
                xystr = xstr + ystr;
                return xystr;
        }

        var labels = []
        for (i = 0; i < dataset.length; i++) {
                labels.push(makeXYstring(dataset[i][0],dataset[i][1]));
        }


        var pointsBelowConvex = function (point1, point2, extX, extY) {
                if (point1[0] < point2[0]) {
                        first = point1;
                        second = point2;
                }
                else { first = point2; second = point1; }
                xMin = first[0];
                xMax = second[0];
                yMin = 0;
                yMax = Math.max(point1[1], point2[1]);
                points = []

                // given line from (x1,y1) to (x2,y2) with x1<x2, y1>y2
                // this finds all lattice points below that line
                for (x = xMin; x <= xMax; x++) {
                        for (y = yMin; y <= yMax; y++) {
                                t = (x - xMin)/(xMax - xMin);
                                l = first[1]*(1-t) + second[1]*(t);
                                if (y < l) { points.push([x,y]); }
                        }
                }
                for (x = 0; x < xMin; x++) {
                        for (y = 0; y <= extY; y++) {
                                points.push([x,y]);
                        }
                }
                for (x = xMax+1; x <= extX; x++) {
                        for (y = 0; y <= extY; y++) {
                                points.push([x,y]);
                        }
                }
                return points;
        }

        var pointsBelow = function (point1, point2) {
                /*if (point1[0] < point2[0]) {
                        first = point1;
                        second = point2;
                }
                else { first = point2; second = point1; }*/
                xMin = Math.min(point1[0],point2[0]);
                xMax = Math.max(point1[0],point2[0]);//second[0];
                yMin = 0;
                yMax = Math.max(point1[1], point2[1]);
                points = []

                // given line from (x1,y1) to (x2,y2) with x1<x2, y1>y2
                // this finds all lattice points below that line
                for (x = xMin; x < xMax; x++) {
                        for (y = yMin; y < yMax; y++) {
                                //t = (x - xMin)/(xMax - xMin);
                                //l = first[1]*(1-t) + second[1]*(t);
                                //if (y < yMax) { 
                                	points.push([x,y]); //}
                        }
                }
                /*for (x = 0; x < xMin; x++) {
                        for (y = 0; y <= extY; y++) {
                                points.push([x,y]);
                        }
                }
                for (x = xMax+1; x <= extX; x++) {
                        for (y = 0; y <= extY; y++) {
                                points.push([x,y]);
                        }
                }*/
                return points;
        }

        var comparePoints = function(point1, point2) {
                if (point1[0] === point2[0] && point1[1] === point2[1]) { return true; }
                else { return false; }
        }

        // i think this is defined earlier
        extX = 0
        extY = 0
        for (i = 0; i < dataset.length; i++) {
                if (dataset[i][0] > extX) { extX = dataset[i][0]; }
                if (dataset[i][1] > extY) { extY = dataset[i][1]; }
        }

        pointListConvex = []
        for (i = 0; i <= extX; i++) {
                for (j = 0; j <= extY; j++) {
                        pointListConvex.push([i,j])
                }
        }

        for (i = 0; i < dataset.length-1; i++) {
                for (j = i+1; j < dataset.length; j++) {
                        pointsUnder = pointsBelowConvex(dataset[i], dataset[j], extX, extY);
                        newPointListConvex = []
                        for (a = 0; a < pointsUnder.length; a++) {
                                for (b = 0; b < pointListConvex.length; b++) {
                                        if (comparePoints(pointsUnder[a], pointListConvex[b])) { newPointListConvex.push(pointsUnder[a]); }
                                }
                        }
                        pointListConvex = newPointListConvex;
                }
        }

        innerLatticeConvex = svg.selectAll("circle.inner")
                        .data(pointListConvex)
                        .enter()
                        .append("circle")
                        .attr("cx", function(d) { return Math.floor(xScale(d[0])); })
                        .attr("cy", function(d) { return Math.floor(yScale(d[1]-1)); })
                        .attr("r", 3) 
                        .attr("fill", "#002BF7")
                        .attr("opacity", 0);

        pointList = []
        for (i = 0; i <= extX; i++) {
                for (j = 0; j <= extY; j++) {
                        pointList.push([i,j])
                }
        }

        testPoints = []
        for (i = 0; i < dataset.length-1; i++) {
                //for (j = i+1; j < dataset.length; j++) {
                        //pointsUnder = pointsBelow(dataset[i], dataset[i+1]);//, extX, extY);
                xMin = Math.min(dataset[i][0],dataset[i+1][0]);
                xMax = Math.max(dataset[i][0],dataset[i+1][0]);//second[0];
                yMin = 0;
                yMax = Math.max(dataset[i][1], dataset[i+1][1]);
                for (j = xMin; j < xMax; j++){
                	for (k = yMin; k < yMax; k++){
                		testPoints.push([j,k]);
                	}
                }
                        /*
                        newPointList = []
                        for (a = 0; a < pointsUnder.length; a++) {
                                for (b = 0; b < pointList.length; b++) {
                                        if (comparePoints(pointsUnder[a], pointList[b])) 
                                        	 { newPointList.push(pointsUnder[a]); }
                                }
                        }
                        pointList = newPointList;*/
                //}
        }

        innerLattice = svg.selectAll("circle.inner")
                        .data(testPoints)
                        .enter()
                        .append("circle")
                        .attr("cx", function(d) { return Math.floor(xScale(d[0])); })
                        .attr("cy", function(d) { return Math.floor(yScale(d[1]-1)); })
                        .attr("r", 3) 
                        .attr("fill", "#002BF7")
                        .attr("opacity", 1);
