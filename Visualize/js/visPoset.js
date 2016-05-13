  // Initialize variables.
  var width  = null,
      height = null,
      colors = null;

  var svg = null;
  nodes = null;
  var lastNodeId = null,
    links = null;

  var constrString = null;
  var incMatrix = null;
  var adjMatrix = null;
  var incMatrixString = null;
  var adjMatrixString = null;

  //var force = null;

  var drag_line = null;

  // Handles to link and node element groups.
  var path = null,
      circle = null;

  // Mouse event variables.
  var selected_node = null,
      selected_link = null,
      mousedown_link = null,
      mousedown_node = null,
      mouseup_node = null;

  var drag = null;

function initializeBuilder() {
  // Set up SVG for D3.

    width = window.innerWidth - 20,
    height = window.innerHeight - 20,
    hPadding = 20,
    vPadding = 20;

var color = d3.scale.category20();

 svg = d3.select("body").append("svg")
    .attr("width", width)
    .attr("height", height)
    .attr("id", "canvasElement2d");

    nodes = dataNodes;
    links = dataLinks;
    
    var maxGroup = d3.max(nodes, function(d) {return d.group;});
    var rowSep = (height-2*vPadding)/maxGroup;
    var groupFreq = [];
    var groupCount = [];
    for (var i=0; i<maxGroup+1; i++){
      groupFreq.push(0);
      groupCount.push(0);
    }
    
    console.log("maxGroup: " + maxGroup);

    nodes.forEach(function(d) {groupFreq[d.group]=groupFreq[d.group]+1;});

    for(var i=0; i<nodes.length;i++){
      nodes[i].fixed = true;
    nodes[i].y = height-vPadding-nodes[i].group*rowSep;
      groupCount[nodes[i].group]=groupCount[nodes[i].group]+1; 
      nodes[i].x = groupCount[nodes[i].group]*((width-2*hPadding)/(groupFreq[nodes[i].group]+1));
    }
 
  force = d3.layout.force()
    .charge(-700)
    .linkDistance(240)
    .size([width, height])
    .nodes(nodes)
    .links(links)
    .start();
    
  drag = force.drag()
    .on("dragstart", dragstart);
    
  link = svg.selectAll(".link")
      .data(links)
    .enter().append("line")
      .attr("class", "link")
      .attr("y1", function(d) {return d.source.y;})
      .attr("y2", function(d) {return d.target.y;})
      .style("stroke-width", function(d) { return Math.sqrt(d.value); });
  
  node = svg.selectAll(".node")
      .data(nodes)
    .enter().append("circle")
      .attr("class", "node")
      .attr("r", 10)
      .attr("cx", function(d) {return d.x;})
      .attr("cy", function(d) {return d.y;})
      .style("fill", function(d) { return color(d.group); })
      .call(force.drag);
  
  // Brett: Need to fix this.

 /* var maxLength = d3.max(nodes, function(d) { return d.name.length; });

  console.log("maxLength: " + maxLength + "\n");

  if(maxLength < 4){
    d3.selectAll("text").classed("fill", "White");
  } else {
    d3.selectAll("text").classed("fill", "White");
  }*/

  // constrString = graph2M2Constructor(nodes,links);

  // Add a paragraph containing the Macaulay2 poset constructor string below the svg.
/*  d3.select("body").append("p")
    .text("Macaulay2 Constructor: " + constrString)
    .attr("id","constructorString");*/

force.on("tick", function() {
    link.attr("x1", function(d) { return d.source.x; })
        .attr("x2", function(d) { return d.target.x; });
    
    node.attr("cx", function(d) { return d.x; })
        .attr("cy", function(d) { return d.y =  height-vPadding-d.group*rowSep;});
});
}

function resetGraph() {
  // Set the 'fixed' attribute to false for all nodes and then restart the force layout.
  nodes.forEach(function(d) {d.fixed = false;});
    
  force.start();
}

function dragstart(d) {
  // When dragging a node, set it to be fixed so that the user can give it a static position.
  d3.select(this).classed(d.fixed = true);
}

function resetMouseVars() {
  // Reset all mouse variables.
  mousedown_node = null;
  mouseup_node = null;
  mousedown_link = null;
}

// Update force layout (called automatically by the force layout simulation each iteration).
function tick() {
  // Draw directed edges with proper padding from node centers.
  path.attr('d', function(d) {
    // For each edge, calculate the distance from the source to the target
    // then normalize the x- and y-distances between the source and target.
    var deltaX = d.target.x - d.source.x,
        deltaY = d.target.y - d.source.y,
        dist = Math.sqrt(deltaX * deltaX + deltaY * deltaY),
        normX = deltaX / dist,
        normY = deltaY / dist,
        // If the edge is directed towards the source, then create extra padding (17) away from the source node to show the arrow,
        // else set the sourcePadding to 12.
        sourcePadding = d.left ? 17 : 12,
        // If the edge is directed towards the target, then create extra padding (17) away from the target node to show the arrow,
        // else set the targetPadding to 12.
        targetPadding = d.right ? 17 : 12,
        // Create new x and y coordinates for the source and the target based on whether extra padding was needed
        // to account for directed edges.
        sourceX = d.source.x + (sourcePadding * normX),
        sourceY = d.source.y + (sourcePadding * normY),
        targetX = d.target.x - (targetPadding * normX),
        targetY = d.target.y - (targetPadding * normY);
    
    // Restrict the padded x and y coordinates of the source and target to be within a 15 pixel margin around the svg.
    if (sourceX > width - 15) {
      sourceX = width - 15;
    }
    else if (sourceX < 15) {
      sourceX = 15;
    }
    if (targetX > width - 15) {
      targetX = width -15;
    }
    else if (targetX < 15) {
      targetX = 15;
    }
    if (sourceY > height - 15) {
      sourceY = height - 15;
    }
    else if (sourceY < 15) {
      sourceY = 15;
    }
    if (targetY  > height - 15) {
      targetY = height - 15;
    }
    else if (targetY  < 15) {
      targetY = 15;
    }
    // For each edge, set the attribute 'd' to have the form "MsourcexCoord,sourceyCoord LtargetxCoord,targetyCoord".
    // Then the appropriate coordinates to use for padding the directed edges away from the nodes can be obtained by
    // the 'd' attribute.
    return 'M' + sourceX + ',' + sourceY + 'L' + targetX + ',' + targetY;
  });

  // Restrict the nodes to be contained within a 15 pixel margin around the svg.
  circle.attr('transform', function(d) {
    if (d.x > width - 15) {
      d.x = width - 15;
    }
    else if (d.x < 15) {
      d.x = 15;
    }
    if (d.y > height - 15) {
      d.y = height - 15;
    }
    else if (d.y < 15) {
      d.y = 15;
    }
    
    // Visually update the locations of the nodes based on the force simulation.
    return 'translate(' + d.x + ',' + d.y + ')';
  });
}

// Update graph (called when needed).
function restart() {
  // Construct the group of edges from the 'links' array.
  path = path.data(links);

  // Update existing links.
  // If a link is currently selected, set 'selected: true'.
  path.classed('selected', function(d) { return d === selected_link; })
    // If the edge is directed towards the source or target, attach an arrow.
    .style('marker-start', function(d) { return d.left ? 'url(#start-arrow)' : ''; })
    .style('marker-end', function(d) { return d.right ? 'url(#end-arrow)' : ''; });

  // Add new links.
  path.enter().append('svg:path')
    .attr('class', 'link')
    // If a link is currently selected, set 'selected: true'.
    .classed('selected', function(d) { return d === selected_link; })
    // If the edge is directed towards the source or target, attach an arrow.
    .style('marker-start', function(d) { return d.left ? 'url(#start-arrow)' : ''; })
    .style('marker-end', function(d) { return d.right ? 'url(#end-arrow)' : ''; })
    .on('mousedown', function(d) {
      // If the user clicks on a path while either the shift key is pressed or curEdit is false, do nothing.
      if(d3.event.shiftKey || !curEdit) return;

      // If the user clicks on a path while the shift key is not pressed and curEdit is true, set mousedown_link
      // to be the path that the user clicked on.
      mousedown_link = d;
      
      // If the link was already selected, then unselect it.
      if(mousedown_link === selected_link) selected_link = null;
      
      // (Brett) Isn't 'if (curEdit)' redundant since we already checked it above?  Remove this line?
//      else if (curEdit) selected_link = mousedown_link;
      
      // If the link was not already selected, then select it.
      else selected_link = mousedown_link;
      
      // Since we selected or unselected a link, set all nodes to be unselected.
      selected_node = null;
      
      // Update all properties of the graph.
      restart();
    });

  // Remove old links.
  path.exit().remove();

  // Create the circle (node) group.
  // Note: the function argument is crucial here!  Nodes are known by id, not by index!
  circle = circle.data(nodes, function(d) { return d.id; });

  // Update existing nodes (reflexive & selected visual states).
  circle.selectAll('circle')
    // If a node is currently selected, then make it brighter.
    .style('fill', function(d) { return (d === selected_node) ? d3.rgb(colors(d.id)).brighter().toString() : colors(d.id); })
    // Set the 'reflexive' attribute to true for all reflexive nodes.
    .classed('reflexive', function(d) { return d.reflexive; });

  // Add new nodes.
  var g = circle.enter().append('svg:g');

  g.append('svg:circle')
    .attr('class', 'node')
    .attr('r', 12)
    .style('fill', function(d) { return (d === selected_node) ? d3.rgb(colors(d.id)).brighter().toString() : colors(d.id); })
    .style('stroke', function(d) { return d3.rgb(colors(d.id)).darker().toString(); })
    .classed('reflexive', function(d) { return d.reflexive; })
    .on('mouseover', function(d) {
      // If no node has been previously clicked on or if the user has not dragged the cursor to a different node after clicking,
      // then do nothing.
      if (!mousedown_node || d === mousedown_node) return;
      // Otherwise enlarge the target node.
      d3.select(this).attr('transform', 'scale(1.1)');
    })
    .on('mouseout', function(d) {
      // If no node has been previously clicked on or if the user has not dragged the cursor to a different node after clicking,
      // then do nothing.
      if (!mousedown_node || d === mousedown_node) return;
      // Otherwise unenlarge the target node.  (The user has chosen to not create an edge to this node and has moved the cursor elsewhere.)
      d3.select(this).attr('transform', '');
    })
    .on('mousedown', function(d) {
      // If either the shift key is held down or editing is disabled, do nothing.
      if(d3.event.shiftKey || !curEdit) return;

      // Otherwise, select node.
      mousedown_node = d;
      
      // If the node that the user clicked was already selected, then unselect it.
      if(mousedown_node === selected_node) selected_node = null;
      else if(curEdit) selected_node = mousedown_node;
      selected_link = null;

      // reposition drag line
      drag_line
        .style('marker-end', 'url(#end-arrow)')
        .classed('hidden', false)
        .attr('d', 'M' + mousedown_node.x + ',' + mousedown_node.y + 'L' + mousedown_node.x + ',' + mousedown_node.y);

      restart();
    })

    .on('mouseup', function(d) {
      if(!mousedown_node) return;

      // needed by FF
      drag_line
        .classed('hidden', true)
        .style('marker-end', '');

      // check for drag-to-self
      mouseup_node = d;
      if(mouseup_node === mousedown_node) { resetMouseVars(); return; }

      // unenlarge target node
      d3.select(this).attr('transform', '');

      // add link to graph (update if exists)
      // NB: links are strictly source < target; arrows separately specified by booleans
      var source, target, direction;
      if(mousedown_node.id < mouseup_node.id) {
        source = mousedown_node;
        target = mouseup_node;
        direction = 'right';
      } else {
        source = mouseup_node;
        target = mousedown_node;
        direction = 'left';
      }

      var link;
      link = links.filter(function(l) {
        return (l.source === source && l.target === target);
      })[0];

      if(link) {
        link[direction] = false;
      } else {
        link = {source: source, target: target, left: false, right: false};
        link[direction] = false;
        links.push(link);
      }

      document.getElementById("constructorString").innerHTML = "Macaulay2 Constructor: " + poset2M2Constructor(nodes,links);
      
      // (Brett) Removing incidence and adjacency matrices for now.
      /*document.getElementById("incString").innerHTML = "Incidence Matrix: " + arraytoM2Matrix(getIncidenceMatrix(nodes,links));
      document.getElementById("adjString").innerHTML = "Adjacency Matrix: " + arraytoM2Matrix(getAdjacencyMatrix(nodes,links));*/

      // select new link
      if (curEdit) selected_link = link;
      selected_node = null;
      restart();
    })

  .on('dblclick', function(d) {
      name = "";
      while (name=="") {
        name = prompt('enter new label name', d.name);
        if (name==d.name) {
          return;
        }
        else if (checkName(name)) {
          alert('sorry a node with that name already exists')
          name = "";
        }
      }
      if(name != null) {
        d.name = name;
        d3.select(this.parentNode).select("text").text(function(d) {return d.name});
      }

      document.getElementById("constructorString").innerHTML = "Macaulay2 Constructor: " + poset2M2Constructor(nodes,links);

      var maxLength = d3.max(nodes, function(d) {
        return d.name.length;
      });

      if(maxLength < 4){
        d3.selectAll("text").classed("fill", 0xfefcff);
      } else {
        d3.selectAll("text").classed("fill", 0x000000);
      }

    });

  // show node IDs
  g.append('svg:text')
      .attr('x', 0)
      .attr('y', 4)
      .attr('class', 'id noselect')
      .attr("pointer-events", "none")
      .text(function(d) { return d.name; });

  // remove old nodes
  circle.exit().remove();

  // set the graph in motion
  force.start();
}

function checkName(name) {
  for (var i = 0; i<nodes.length; i++) {
    if (nodes[i].name == name) {
      return true;
    }
  }
  return false;
}

function getNextAlpha(alpha) {
  return String.fromCharCode(alpha.charCodeAt(0) + 1);
}

function mousedown() {
  // prevent I-bar on drag
  //d3.event.preventDefault();

  // because :active only works in WebKit?
  svg.classed('active', true);

  if(!curEdit || d3.event.shiftKey || mousedown_node || mousedown_link) return;

  // insert new node at point

  var point = d3.mouse(this);
  var curName = (lastNodeId + 1).toString();
  if (checkName(curName)) {
    curName += 'a';
  }
  while (checkName(curName)) {
    curName = curName.substring(0, curName.length - 1) + getNextAlpha(curName.slice(-1));
  }

  node = {id: lastNodeId++, name: curName, reflexive: false};
  node.x = point[0];
  node.y = point[1];
  nodes.push(node);

  document.getElementById("constructorString").innerHTML = "Macaulay2 Constructor: " + poset2M2Constructor(nodes,links);
    
  // (Brett) Removing incidence and adjacency matrices for now.
  /*document.getElementById("incString").innerHTML = "Incidence Matrix: " + arraytoM2Matrix(getIncidenceMatrix(nodes,links));
  document.getElementById("adjString").innerHTML = "Adjacency Matrix: " + arraytoM2Matrix(getAdjacencyMatrix(nodes,links));*/

  restart();
}

function mousemove() {
  if(!mousedown_node) return;

  // update drag line
  drag_line.attr('d', 'M' + mousedown_node.x + ',' + mousedown_node.y + 'L' + d3.mouse(this)[0] + ',' + d3.mouse(this)[1]);

  restart();
}

function mouseup() {
  if(mousedown_node) {
    // hide drag line
    drag_line
      .classed('hidden', true)
      .style('marker-end', '');
  }

  // because :active only works in WebKit?
  svg.classed('active', false);

  // clear mouse event vars
  resetMouseVars();

  restart();

}

function spliceLinksForNode(node) {
  var toSplice = links.filter(function(l) {
    return (l.source === node || l.target === node);
  });
  toSplice.map(function(l) {
    links.splice(links.indexOf(l), 1);
  });
}

// only respond once per keydown
var lastKeyDown = -1;

function keydown() {
  //d3.event.preventDefault();

  if(lastKeyDown !== -1) return;
  lastKeyDown = d3.event.keyCode;

  // shift
  if(d3.event.keyCode === 16) {
    circle.call(drag);
    svg.classed('shift', true);
  }

  if(!selected_node && !selected_link) return;
  switch(d3.event.keyCode) {
    case 8: // backspace
    case 46: // delete
      if(curEdit && selected_node) {
        nodes.splice(nodes.indexOf(selected_node), 1);
        spliceLinksForNode(selected_node);
      } else if(curEdit && selected_link) {

        links.splice(links.indexOf(selected_link), 1);
      }
      selected_link = null;
      selected_node = null;

      document.getElementById("constructorString").innerHTML = "Macaulay2 Constructor: " + poset2M2Constructor(nodes,links);
      // (Brett) Removing incidence and adjacency matrices for now.
      /*document.getElementById("incString").innerHTML = "Incidence Matrix: " + arraytoM2Matrix(getIncidenceMatrix(nodes,links));
      document.getElementById("adjString").innerHTML = "Adjacency Matrix: " + arraytoM2Matrix(getAdjacencyMatrix(nodes,links));*/

      restart();
      break;
  }
  restart();
}

function keyup() {
  lastKeyDown = -1;

  // shift
  if(d3.event.keyCode === 16) {
    circle
      .on('mousedown.drag', null)
      .on('touchstart.drag', null);
    svg.classed('shift', false);
  }
}

/*function disableEditing() {
  //circle.call(drag);
  svg.classed('shift', true);
  selected_node = null;
  selected_link = null;

  for (var i = 0; i<nodes.length; i++) {
    nodes[i].selected = false;
  }
  for (var i = 0; i<links.length; i++) {
    links[i].selected = false;
  }
  path = path.data(links);

  // update existing links
  path.classed('selected', false)
    .style('marker-start', function(d) { return d.left ? 'url(#start-arrow)' : ''; })
    .style('marker-end', function(d) { return d.right ? 'url(#end-arrow)' : ''; });

  restart();
}*/

function enableEditing() {
  circle
      .on('mousedown.drag', null)
      .on('touchstart.drag', null);
  svg.classed('shift', false);
}

function setAllNodesFixed() {
  nodes.forEach(function(d) {d.fixed = true;});
  force.start();
}

/*this is the old update window function
function updateWindowSize2d() {
        var svg = document.getElementById("canvasElement2d");
        svg.attr("width", window.innerWidth-20).attr("height", window.innerHeight-20);
        /*svg.style.width = window.innerWidth;
        svg.style.height = window.innerHeight - 20;
        svg.width = window.innerWidth;
        svg.height = window.innerHeight - 20;*/
//}


// this function is copied from the visGraph2d.js file
function updateWindowSize2d() {
    console.log("resizing window");
    //var svg = document.getElementById("canvasElement2d");
    
    // get width/height with container selector (body also works)
    // or use other method of calculating desired values
    var width = window.innerWidth-10;
    var height = window.innerHeight-10;

    // set attrs and 'resume' force 
    //svg.attr('width', width);
    //svg.attr('height', height);
    svg.style.width = width;
    svg.style.height = height;
    svg.width = width;
    svg.height = height;
    force.size([width, height]).resume();
}


// Functions to construct M2 constructors for poset, incidence matrix, and adjacency matrix.

function poset2M2Constructor( nodeSet, edgeSet ){
  var strEdges = "{";
  var e = edgeSet.length;
  var t = nodeSet.length;
  var strVerts = "{";
  for( var i = 0; i < e; i++ ){
    if(i != (e-1)){
      strEdges = strEdges + "{" + (edgeSet[i].source.name).toString() + ", " + (edgeSet[i].target.name).toString() + "}, ";
    }
    else{
      strEdges = strEdges + "{" + (edgeSet[i].source.name).toString() + ", " + (edgeSet[i].target.name).toString() + "}}";
    }
  }

  for( var i = 0; i < t; i++ ){
    if(i != (t-1)){
      strVerts = strVerts + (nodeSet[i].name).toString() +  ", ";
    }
    else{
      strVerts = strVerts + (nodeSet[i].name).toString() + "}";
    }
  }
  // determine if the singleton set is empty
 /*       var card = 0
  var singSet = singletons(nodeSet, edgeSet);
  card = singSet.length; // cardinality of singleton set
  if ( card != 0 ){
    var strSingSet = "{";
    for(var i = 0; i < card; i++ ){
      if(i != (card - 1) ){
        strSingSet = strSingSet + "" + (singSet[i]).toString() + ", ";
      }
      else{
        strSingSet = strSingSet + "" + (singSet[i]).toString();
      }
    }
    strSingSet = strSingSet + "}";
    return "poset(" + strEdges + ", Singletons => "+ strSingSet + ")";
  }*/
  //else{
    return "poset(" + strVerts + "," + strEdges + ")";
  //}

}

// determines if a graph contains singletons, if it does it returns an array containing their id, if not returns empty array
function singletons(nodeSet, edgeSet){

  var singSet = [];
  var n = nodeSet.length;
        var e = edgeSet.length;
  var curNodeName = -1;
  var occur = 0;
  for( var i = 0; i < n; i++){
    curNodeName = (nodeSet[i]).name;
    for( var j = 0; j < e; j++ ){
      if ( (edgeSet[j].source.name == curNodeName) || (edgeSet[j].target.name == curNodeName) ){
        occur=1;
        break;
      }
    }//end for
    if (occur == 0){
      singSet.push(curNodeName); // add node id to singleton set
    }
    occur = 0; //reset occurrences for next node id
  }
  return singSet;
}

// Brett working code - figuring out data loops in JS - ignore this

// d3.select("body").selectAll("p").data(links).enter().append("p").text(function(d) {return [d.source.id,d.target.id]});

// var vertices = [];
// var edges = [];

// for (var i = 0; i < nodes.length; i++) {
//     vertices.push(nodes[i].id);          //Add new node to 'vertices' array
// }

// for (var i = 0; i < links.length; i++) {
//     edges.push({source: links[i].source.id , target: links[i].target.id});      //Add new edge pair to 'edges' array
// }

// Constructs the incidence matrix for a graph as a multidimensional array.
function getIncidenceMatrix (nodeSet, edgeSet){

  var incMatrix = [];

  // The next two loops create an initial (nodes.length) x (links.length) matrix of zeros.
  for(var i = 0;i < nodeSet.length; i++){
    incMatrix[i] = [];

    for(var j = 0; j < edgeSet.length; j++){
      incMatrix[i][j] = 0;
    }
  }

  for (var i = 0; i < edgeSet.length; i++) {
    incMatrix[(edgeSet[i].source.id)][i] = 1; // Set matrix entries corresponding to incidences to 1.
    incMatrix[(edgeSet[i].target.id)][i] = 1;
  }

  return incMatrix;
}

// Constructs the adjacency matrix for a graph as a multidimensional array.
function getAdjacencyMatrix (nodeSet, edgeSet){
  var adjMatrix = []; // The next two loops create an initial (nodes.length) x (nodes.length) matrix of zeros.
  for(var i = 0; i < nodeSet.length; i++){
    adjMatrix[i] = [];
    for(var j = 0; j < nodeSet.length; j++){
      adjMatrix[i][j] = 0;
    }
  }

  for (var i = 0; i < edgeSet.length; i++) {
    adjMatrix[edgeSet[i].source.id][edgeSet[i].target.id] = 1; // Set matrix entries corresponding to adjacencies to 1.
    adjMatrix[edgeSet[i].target.id][edgeSet[i].source.id] = 1;
  }

  return adjMatrix;
}

// Takes a rectangular array of arrays and returns a string which can be copy/pasted into M2.
function arraytoM2Matrix (arr){
  var str = "matrix{{";
  for(var i = 0; i < arr.length; i++){
    for(var j = 0; j < arr[i].length; j++){
      str = str + arr[i][j].toString();
      if(j == arr[i].length - 1){
        str = str + "}";
            } else {
        str = str + ",";
      }
    }
    if(i < arr.length-1){
      str = str + ",{";
    } else {
      str = str + "}";
    }
  }

  return str;
}

function exportTikz (nodeSet, edgeSet){
  var points = [];
  for(var i = 0; i < nodeSet.length; i++){
    points[i] = [nodeSet[i].x,nodeSet[i].y];
  }

  var edges = [];
  for(var j = 0; j < edgeSet.length; j++){
    edges[j] = [ edgeSet[j].source.id , edgeSet[j].target.id ];
  }

console.log(points);
console.log(links[0].source.id);
console.log(links.length);
console.log(edgeSet);
console.log(links);
console.log(points);

  alert(edges);
}

// -----------------------------------------
// Begin Server Stuff
// -----------------------------------------


// Add a response for each id from the side menu
function onclickResults(m2Response) {
    
    if (clickTest == "hasEulerianTrail"){
      d3.select("#hasEulerianTrail").html("&nbsp;&nbsp; hasEulerianTrail :: <b>"+m2Response+"</b>");
    } 
    
    if (clickTest == "hasOddHole"){
      d3.select("#hasOddHole").html("&nbsp;&nbsp; hasOddHole :: <b>"+m2Response+"</b>");
    } 
    
    if (clickTest == "isBipartite"){
      d3.select("#isBipartite").html("&nbsp;&nbsp; isBipartite :: <b>"+m2Response+"</b>");
    } 

    else if (clickTest == "isChordal") {
      d3.select("#isChordal").html("&nbsp;&nbsp; isChordal :: <b>"+m2Response+"</b>");    
    } 

    else if (clickTest == "isCM") {
      d3.select("#isCM").html("&nbsp;&nbsp; isCM :: <b>"+m2Response+"</b>");    
    }

    else if (clickTest == "isConnected") {
      d3.select("#isConnected").html("&nbsp;&nbsp; isConnected :: <b>"+m2Response+"</b>");    
    }    

    else if (clickTest == "isCyclic") {
      d3.select("#isCyclic").html("&nbsp;&nbsp; isCyclic :: <b>"+m2Response+"</b>");    
    }    

    else if (clickTest == "isEulerian") {
      d3.select("#isEulerian").html("&nbsp;&nbsp; isEulerian :: <b>"+m2Response+"</b>");    
    }    

    else if (clickTest == "isForest") {
      d3.select("#isForest").html("&nbsp;&nbsp; isForest :: <b>"+m2Response+"</b>");    
    }    

    else if (clickTest == "isPerfect") {
      d3.select("#isPerfect").html("&nbsp;&nbsp; isPerfect :: <b>"+m2Response+"</b>");    
    }    

    else if (clickTest == "isRegular") {
      d3.select("#isRegular").html("&nbsp;&nbsp; isRegular :: <b>"+m2Response+"</b>");    
    }    

    else if (clickTest == "isSimple") {
      d3.select("#isSimple").html("&nbsp;&nbsp; isSimple :: <b>"+m2Response+"</b>");    
    }    

    else if (clickTest == "isTree") {
      d3.select("#isTree").html("&nbsp;&nbsp; isTree :: <b>"+m2Response+"</b>");    
    }
    
    else if (clickTest == "chromaticNumber") {
      d3.select("#chromaticNumber").html("&nbsp;&nbsp; chromaticNumber :: <b>"+m2Response+"</b>");    
    }  
    
    else if (clickTest == "independenceNumber") {
      d3.select("#independenceNumber").html("&nbsp;&nbsp; independenceNumber :: <b>"+m2Response+"</b>");    
    }  
    
    else if (clickTest == "cliqueNumber") {
      d3.select("#cliqueNumber").html("&nbsp;&nbsp; cliqueNumber :: <b>"+m2Response+"</b>");    
    }  
    
    else if (clickTest == "degeneracy") {
      d3.select("#degeneracy").html("&nbsp;&nbsp; degeneracy :: <b>"+m2Response+"</b>");    
    }  
    
    else if (clickTest == "density") {
      d3.select("#density").html("&nbsp;&nbsp; density :: <b>"+m2Response+"</b>");    
    }  
    
    else if (clickTest == "diameter") {
      d3.select("#diameter").html("&nbsp;&nbsp; diameter :: <b>"+m2Response+"</b>");    
    }  
    
    else if (clickTest == "edgeConnectivity") {
      d3.select("#edgeConnectivity").html("&nbsp;&nbsp; edgeConnectivity :: <b>"+m2Response+"</b>");    
    }  
    
    else if (clickTest == "minimalDegree") {
      d3.select("#minimalDegree").html("&nbsp;&nbsp; minimalDegree :: <b>"+m2Response+"</b>");    
    }  
    
    else if (clickTest == "numberOfComponents") {
      d3.select("#numberOfComponents").html("&nbsp;&nbsp; numberOfComponents :: <b>"+m2Response+"</b>");    
    }  
    
    else if (clickTest == "numberOfTriangles") {
      d3.select("#numberOfTriangles").html("&nbsp;&nbsp; numberOfTriangles :: <b>"+m2Response+"</b>");    
    }  
    
    else if (clickTest == "radius") {
      d3.select("#radius").html("&nbsp;&nbsp; radius :: <b>"+m2Response+"</b>");    
    }  
    
    else if (clickTest == "vertexConnectivity") {
      d3.select("#vertexConnectivity").html("&nbsp;&nbsp; vertexConnectivity :: <b>"+m2Response+"</b>");    
    }  
    
    else if (clickTest == "vertexCoverNumber") {
      d3.select("#vertexCoverNumber").html("&nbsp;&nbsp; vertexCoverNumber :: <b>"+m2Response+"</b>");    
    }  
    
}


// Anytime the graph is edited by user we call this function.
// It changes the menu items to default.
function menuDefaults() {
  d3.select("#hasEulerianTrail").html("&nbsp;&nbsp; hasEulerianTrail");
  d3.select("#hasOddHole").html("&nbsp;&nbsp; hasOddHole");
  d3.select("#isCM").html("&nbsp;&nbsp; isCM");
  d3.select("#isChordal").html("&nbsp;&nbsp; isChordal");
  d3.select("#isBipartite").html("&nbsp;&nbsp; isBipartite");
  d3.select("#isConnected").html("&nbsp;&nbsp; isConnected");  
  d3.select("#isCyclic").html("&nbsp;&nbsp; isCyclic");  
  d3.select("#isEulerian").html("&nbsp;&nbsp; isEulerian");  
  d3.select("#isForest").html("&nbsp;&nbsp; isForest");  
  d3.select("#isPerfect").html("&nbsp;&nbsp; isPerfect");  
  d3.select("#isRegular").html("&nbsp;&nbsp; isRegular");  
  d3.select("#isSimple").html("&nbsp;&nbsp; isSimple");  
  d3.select("#isTree").html("&nbsp;&nbsp; isTree");
  d3.select("#chromaticNumber").html("&nbsp;&nbsp; chromaticNumber");
  d3.select("#independenceNumber").html("&nbsp;&nbsp; independenceNumber");
  d3.select("#cliqueNumber").html("&nbsp;&nbsp; cliqueNumber");
  d3.select("#degeneracy").html("&nbsp;&nbsp; degeneracy");
  d3.select("#density").html("&nbsp;&nbsp; density");
  d3.select("#diameter").html("&nbsp;&nbsp; diameter");
  d3.select("#edgeConnectivity").html("&nbsp;&nbsp; edgeConnectivity");
  d3.select("#minimalDegree").html("&nbsp;&nbsp; minimalDegree");
  d3.select("#numberOfComponents").html("&nbsp;&nbsp; numberOfComponents");
  d3.select("#numberOfTriangles").html("&nbsp;&nbsp; numberOfTriangles");
  d3.select("#radius").html("&nbsp;&nbsp; radius");
  d3.select("#vertexConnectivity").html("&nbsp;&nbsp; vertexConnectivity");
  d3.select("#vertexCoverNumber").html("&nbsp;&nbsp; vertexCoverNumber");
}


// Create the XHR object.
function createCORSRequest(method, url) {
  var xhr = new XMLHttpRequest();                    
  if ("withCredentials" in xhr) {
    // XHR for Chrome/Firefox/Opera/Safari.
    xhr.open(method, url, true);
  } else if (typeof XDomainRequest != "undefined") {
    // XDomainRequest for IE.
    xhr = new XDomainRequest();
    xhr.open(method, url);
  } else {
    // CORS not supported.
    xhr = null;
  }

  return xhr;
}
 
// Make the actual CORS request.
function makeCorsRequest(method,url,browserData) {
  // All HTML5 Rocks properties support CORS.
  // var url ='http://localhost:8000/fcn2/';
 
  var xhr = createCORSRequest(method, url);
  if (!xhr) {
    alert('CORS not supported');
    return;
  }
 
  // Response handlers.
  xhr.onload = function() {
    var responseText = xhr.responseText;

    onclickResults(responseText);      

  };
 
  //xhr.onerror = function() {
  //  alert('Woops, there was an error making the request.');
  //};

  xhr.send(browserData);
}

// -----------------------------------------
// End Server Stuff
// -----------------------------------------



function stopForce() {
  force.stop();
}
function startForce() {
  force.start();
}
