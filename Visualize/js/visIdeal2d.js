
$('#side').BootSideMenu({side:"right", autoClose: false});

$(document).ready(function(){

$("#exportTikz").on("click", function() {
exportTikz();
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

// display convex hull when clicked
$("#gridToggle").on("click", function(){
if(curGrid) {
  $(this).html("Grid Lines: on");
    gridLinesH.attr("opacity",1);
    gridLinesV.attr("opacity",1);
    gridLinesT.attr("opacity",1);
    gridLinesR.attr("opacity",1);
    curGrid = !curGrid;
} else {
  $(this).html("Grid Lines: off");
    gridLinesH.attr("opacity",0);
    gridLinesV.attr("opacity",0);
    gridLinesT.attr("opacity",0);
    gridLinesR.attr("opacity",0);
    curGrid = !curGrid;
}
});

// display convex hull when clicked
$("#boundaryToggle").on("click", function(){
if(curBound) {
  $(this).html("Boundary lines: on");
    gridLinesT.attr("opacity",1);
    gridLinesR.attr("opacity",1);
    curBound = !curBound;
} else {
  $(this).html("Boundary lines: off");
    gridLinesT.attr("opacity",0);
    gridLinesR.attr("opacity",0);
    curBound = !curBound;
}
});

$("#hilbToggle").on("click", function(){
if(curHilb) {
  $(this).html("Anti diagonal: on");
  curHilb = !curHilb;
    hilbLines.attr("opacity",1);
} else {
  $(this).html("Anti diagonal: off");
  curHilb = !curHilb;
    hilbLines.attr("opacity",0);
}
});

$("#latticeToggle").on("click", function(){
if(curLattice) {
  $(this).html("Lattice points: on");
  curLattice = !curLattice;
    lattice.attr("opacity",1);
} else {
  $(this).html("Lattice points: off");
  curLattice = !curLattice;
    lattice.attr("opacity",0);
}
});

$("#shadeOutToggle").on("click", function(){
if(curShadeOut) {
  $(this).html("Shade non ideal: on");
  curShadeOut = !curShadeOut;
    outIdeal.attr("opacity",1);
} else {
  $(this).html("Shade non ideal: off");
  curShadeOut = !curShadeOut;
    outIdeal.attr("opacity",0);
}
});

$("#shadeInToggle").on("click", function(){
if(curShadeIn) {
  $(this).html("Shade ideal: on");
  curShadeIn = !curShadeIn;
    inIdeal.attr("opacity",1);
} else {
  $(this).html("Shade ideal: off");
  curShadeIn = !curShadeIn;
    inIdeal.attr("opacity",0);
}
});

// display convex hull when clicked
$("#convexOutToggle").on("click", function(){
if(outIdeal.attr("opacity",1)){
	if(curConvexOut) {
  		$(this).html("&nbsp;&nbsp Convex hull: on");
  		curConvexOut = !curConvexOut;
    	hullOut.attr("opacity",1);
    	innerLattice.attr("opacity",0);
    	innerLatticeConvex.attr("opacity",1);
	} else {
  		$(this).html("&nbsp;&nbsp Convex hull: off");
  		curConvexOut = !curConvexOut;
    	hullOut.attr("opacity",0);
    	innerLattice.attr("opacity",1);
    	innerLatticeConvex.attr("opacity",0);
	}

}});

$("#convexInToggle").on("click", function(){
if(inIdeal.attr("opacity",1)){
	if(curConvexIn) {
  		$(this).html("&nbsp;&nbsp Convex hull: on");
  		curConvexIn = !curConvexIn;
    	hullIn.attr("opacity",1);
    	innerLattice.attr("opacity",0);
    	innerLatticeConvex.attr("opacity",1);
	} else {
  		$(this).html("&nbsp;&nbsp Convex hull: off");
  		curConvexIn = !curConvexIn;
    	hullIn.attr("opacity",0);
    	innerLattice.attr("opacity",1);
    	innerLatticeConvex.attr("opacity",0);
	}

}});

$("#pointsToggle").on("click", function(){
if(curPoints) {
  $(this).html("Points not in ideal: on");
  curPoints = !curPoints;
    innerLattice.attr("opacity",1);
} else {
  $(this).html("Points not in ideal: off");
  curPoints = !curPoints;
    innerLattice.attr("opacity",0);
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
// not sure why this is its own function
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
                                dat.push([j, i]);
                        }
                }
        }
        return dat;
}

// the coordinates of the points not in the ideal
dat = makeDatFromChart(chart);

// the coordinates of the points in the ideal
idealDat = []
for(i=0; i<chart.length; i++) {
	for (j = 0; j < chart[0].length; j++) {
                        if (chart[i][j] === 0) {
                                idealDat.push([j, i]);
                        }
                }
}


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

// the lattice points on the top of the shaded region
topDataset = [];
for(i=0; i<dataset.length-1; i++) {
	for(j=dataset[i][0]; j < dataset[i+1][0]; j++) {
		topDataset.push([j,dataset[i][1]]);
	}
}

// the lattice points on the right of the shaded region
rightDataset = [];
for(i=0; i<dataset.length-1; i++) {
	for(j=dataset[i+1][1]; j < dataset[i][1]; j++) {
		rightDataset.push([dataset[i+1][0],j]);
	}
}

var xAxis = d3.svg.axis()
                .scale(xScale)
                .ticks(xMax)
                .orient("bottom");

var yAxis = d3.svg.axis()
                .scale(yScale) 
                .ticks(yMax)
                .orient("left");

// lattice points of ideal
var latticePoints= [];
for (i = 0; i <= xMax+1; i++) {
        for (j = -1; j <= yMax+1; j++) {
                latticePoints.push([i,j]);
        }
}

// shades all the squares not in the ideal
outIdeal = svg.selectAll("rect.lattice")
                .data(dat)
                .enter()
                .append("rect")
                .attr("x", function(d) { return Math.ceil(xScale(d[0])); })
                .attr("y", function(d) { return Math.ceil(yScale(d[1])); })
                .attr("width", sq+1) // add 1 to get rid of potential line
                .attr("height", sq+1) // add 1 to get rid of potential line
                .attr("fill", "#ffeead")
                .attr("opacity",0);

// shades all the squares in the ideal
inIdeal = svg.selectAll("rect.lattice")
                .data(idealDat)
                .enter()
                .append("rect")
                .attr("x", function(d) { return Math.ceil(xScale(d[0])); })
                .attr("y", function(d) { return Math.ceil(yScale(d[1])); })
                .attr("width", sq+1) // add 1 to get rid of potential line
                .attr("height", sq+1) // add 1 to get rid of potential line
                .attr("fill", "#ffeead")
                .attr("opacity",1);
                                

// shades all the triangles. default is transparent
hullOut = svg.selectAll("polygon.lattice")
                .data(tri)
                .enter()
                .append("polygon")
                .attr("points", function(d) { return d; })
                .attr("fill", "#FFFFFF")
                .attr("opacity", 0);

// shades all the triangles. default is transparent
hullIn = svg.selectAll("polygon.lattice")
                .data(tri)
                .enter()
                .append("polygon")
                .attr("points", function(d) { return d; })
                .attr("fill", "#ffeead")
                .attr("opacity", 0);                

// shades all the lattice points
lattice = svg.selectAll("circle.lattice")
                .data(latticePoints)
                .enter()
                .append("circle")
                .attr("cx", function(d) { return Math.floor(xScale(d[0])); })
                .attr("cy", function(d) { return Math.floor(yScale(d[1])); })
                .attr("r", 4) 
                .attr("fill", "#e06000")
                .attr("opacity",1);

// shades all the generators
gens = svg.selectAll("circle.lattice")
                .data(dataset)
                .enter()
                .append("circle")
                .attr("cx", function(d) { return Math.floor(xScale(d[0])); })
                .attr("cy", function(d) { return Math.floor(yScale(d[1]-1)); })
                .attr("r", 6) 
                .attr("fill", "#9900ac")
                .attr("opacity", 0);

// draw horizontal grid lines inside shaded region
gridLinesH = svg.selectAll("line.lattice")
                .data(dat)
                .enter()
                .append("line")
                .attr("x1", function(d) { return Math.floor(xScale(d[0])); })
                .attr("y1", function(d) { return Math.floor(yScale(d[1]-1)); })
                .attr("x2", function(d) { return Math.floor(xScale(d[0]))+sq; })
                .attr("y2", function(d) { return Math.floor(yScale(d[1]-1)); })
                //.attr("r", 6) 
                .attr("stroke-width",2)
                .attr("stroke", "#0d0018")
                .attr("opacity", 0);

// draw vertical gridlines inside the region
gridLinesV = svg.selectAll("line.lattice")
                .data(dat)
                .enter()
                .append("line")
                .attr("x1", function(d) { return Math.floor(xScale(d[0])); })
                .attr("y1", function(d) { return Math.floor(yScale(d[1]-1)); })
                .attr("x2", function(d) { return Math.floor(xScale(d[0])); })
                .attr("y2", function(d) { return Math.floor(yScale(d[1]-1)-sq); })
                //.attr("r", 6) 
                .attr("stroke-width",2)
                .attr("stroke", "#0d0018")
                .attr("opacity", 0);

// draw the top grid lines of the shaded region
gridLinesT = svg.selectAll("line.lattice")
                .data(topDataset)
                .enter()
                .append("line")
                .attr("x1", function(d) { return Math.floor(xScale(d[0])); })
                .attr("y1", function(d) { return Math.floor(yScale(d[1]-1)); })
                .attr("x2", function(d) { return Math.floor(xScale(d[0])+sq); })
                .attr("y2", function(d) { return Math.floor(yScale(d[1]-1)); })
                //.attr("r", 6) 
                .attr("stroke-width",2)
                .attr("stroke", "#0d0018")
                .attr("opacity", 0);

// draw the right grid lines of the shaded region
gridLinesR = svg.selectAll("line.lattice")
                .data(rightDataset)
                .enter()
                .append("line")
                .attr("x1", function(d) { return Math.floor(xScale(d[0])); })
                .attr("y1", function(d) { return Math.floor(yScale(d[1]-1)); })
                .attr("x2", function(d) { return Math.floor(xScale(d[0])); })
                .attr("y2", function(d) { return Math.floor(yScale(d[1]-1)-sq); })
                //.attr("r", 6) 
                .attr("stroke-width",2)
                .attr("stroke", "#0d0018")
                .attr("opacity", 0);                        

// draw the anti diagonal lines inside the shaded region
hilbLines = svg.selectAll("line.lattice")
                .data(dat)
                .enter()
                .append("line")
                .attr("x1", function(d) { return Math.floor(xScale(d[0])); })
                .attr("y1", function(d) { return Math.floor(yScale(d[1])); })
                .attr("x2", function(d) { return Math.floor(xScale(d[0]+1)); })
                .attr("y2", function(d) { return Math.floor(yScale(d[1]-2)-sq); })
                //.attr("r", 6) 
                .attr("stroke-width",2)
                .attr("stroke", "#000000")
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

// don't think this is necessary
var pointsBelow = function (point1, point2) {
        xMin = Math.min(point1[0],point2[0]);
        xMax = Math.max(point1[0],point2[0]);//second[0];
        yMin = 0;
        yMax = Math.max(point1[1], point2[1]);
        points = []

        // given line from (x1,y1) to (x2,y2) with x1<x2, y1>y2
        // this finds all lattice points below that line
        for (x = xMin; x < xMax; x++) {
                for (y = yMin; y < yMax; y++) {
                        	points.push([x,y]); //}
                }
        }
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

// lattice points not in the convex hull
innerLatticeConvex = svg.selectAll("circle.inner")
                .data(pointListConvex)
                .enter()
                .append("circle")
                .attr("cx", function(d) { return Math.floor(xScale(d[0])); })
                .attr("cy", function(d) { return Math.floor(yScale(d[1]-1)); })
                .attr("r", 4) 
                .attr("fill", "#00a053")
                .attr("opacity", 0);

pointList = []
for (i = 0; i <= extX; i++) {
        for (j = 0; j <= extY; j++) {
                pointList.push([i,j])
        }
}

innerPoints = []
if(dataset[0][0]>0) {
	for(i=0; i<dataset[0][0]; i++) {
		for(j=0; j< chart.length+1; j++) {
			innerPoints.push([i,j]);
		}
	}
}

for (i = 0; i < dataset.length-1; i++) {
        xMin = Math.min(dataset[i][0],dataset[i+1][0]);
        xMax = Math.max(dataset[i][0],dataset[i+1][0]);
        yMin = 0;
        yMax = Math.max(dataset[i][1], dataset[i+1][1]);
        for (j = xMin; j < xMax; j++){
        	for (k = yMin; k < yMax; k++){
        		innerPoints.push([j,k]);
        	}
        }
}

if(dataset[dataset.length-1][1]>0) {
	for(i=dataset.length; i<chart[0].length+1; i++) {
		for(j=0; j<dataset[dataset.length-1][1]; j++) {
			innerPoints.push([i,j]);
		}
	}
}

// highlight points not in ideal
innerLattice = svg.selectAll("circle.inner")
                .data(innerPoints)
                .enter()
                .append("circle")
                .attr("cx", function(d) { return Math.floor(xScale(d[0])); })
                .attr("cy", function(d) { return Math.floor(yScale(d[1]-1)); })
                .attr("r", 4) 
                .attr("fill", "#00a053")
                .attr("opacity", 1);

