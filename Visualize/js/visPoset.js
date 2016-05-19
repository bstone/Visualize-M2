  // Initialize variables.
  var width  = null,
      height = null,
      colors = null;

  var svg = null;
  var nodes = null,
    lastNodeId = null,
    links = null;

  var constrString = null;
  var incMatrix = null;
  var adjMatrix = null;
  var incMatrixString = null;
  var adjMatrixString = null;

  var width  = window.innerWidth-10;
  var height = window.innerHeight-10;
  var colors = d3.scale.category10();

  var maxGroup = 1;
  var rowSep = 20;
  var hPadding = 30;
  var vPadding = 30;

  var force = null;

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

 // Helps determine what menu button was clicked.
  var clickTest = null; 

  var scriptSource = (function(scripts) {
    var scripts = document.getElementsByTagName('script'),
        script = scripts[scripts.length - 1];

    if (script.getAttribute.length !== undefined) {
        return script.src
    }

    return script.getAttribute('src', -1)
    }());
    
    // Just get the current directory that contains the html file.
    scriptSource = scriptSource.substring(0, scriptSource.length - 16);
      
    console.log(scriptSource);

function initializeBuilder() {
  // Set up SVG for D3.
  
  svg = d3.select('body')
    .append('svg')
    .attr('width', width)
    .attr('height', height)
    .attr('id', 'canvasElement2d');

  // Set up initial nodes and links
  //  - nodes are known by 'id', not by index in array.
  //  - reflexive edges are indicated on the node (as a bold black circle).
  //  - links are always source < target; edge directions are set by 'left' and 'right'.
  //var data = dataData;
  //var names = labelData;

  nodes = dataNodes;
  links = dataLinks;
  
  // Compute the maximum level of the nodes in the poset.
  maxGroup = d3.max(nodes, function(d) {return d.group;});
  // Compute the distance between levels in the poset.
  rowSep = (height-2*vPadding)/maxGroup;
  var groupFreq = [];
  var groupCount = [];
  for (var i=0; i<maxGroup+1; i++){
    groupFreq.push(0);
    groupCount.push(0);
  }
    
  console.log("maxGroup: " + maxGroup);

  nodes.forEach(function(d){groupFreq[d.group]=groupFreq[d.group]+1;});
  
  for(var i=0; i < nodes.length;i++){
      // Set the nodes as fixed by default and specify their initial x and y values to be evenly spaced along their level.
      nodes[i].fixed = true;
      nodes[i].id = i;
	  nodes[i].y = height-vPadding-nodes[i].group*rowSep;
      groupCount[nodes[i].group]=groupCount[nodes[i].group]+1; 
      nodes[i].x = groupCount[nodes[i].group]*((width-2*hPadding)/(groupFreq[nodes[i].group]+1));
  }

  /*
  lastNodeId = data.length;
  nodes = [];
  links = [];
  for (var i = 0; i<data.length; i++) {

      nodes.push( {name: names[i], id: i, reflexive:false, highlighted:false } );

  }
  for (var i = 0; i<data.length; i++) {
      for (var j = 0; j < i ; j++) {
          if (data[i][j] != 0) {
              links.push( { source: nodes[i], target: nodes[j], left: false, right: false, highlighted:false} );
          }
      }
  }
  */
    
  //constrString = graph2M2Constructor(nodes,links);
    
  // (Brett) Removing incidence and adjacency matrices.
  /*incMatrix = getIncidenceMatrix(nodes,links);
  adjMatrix = getAdjacencyMatrix(nodes,links);
  incMatrixString = arraytoM2Matrix(incMatrix);
  adjMatrixString = arraytoM2Matrix(adjMatrix);*/

  // Add a paragraph containing the Macaulay2 graph constructor string below the svg.
  /* d3.select("body").append("p")
  	.text("Macaulay2 Constructor: " + constrString)
  	.attr("id","constructorString");
  */

  // (Brett) Removing incidence and adjacency matrices.
    
/*  d3.select("body").append("p")
  	.text("Incidence Matrix: " + incMatrixString)
  	.attr("id","incString");

  d3.select("body").append("p")
  	.text("Adjacency Matrix: " + adjMatrixString)
  	.attr("id","adjString");*/

  // Initialize D3 force layout.
  force = d3.layout.force()
      .nodes(nodes)
      .links(links)
      .size([width, height])
      .linkDistance(150)
      .charge(-500)
      .on('tick', tick);

  // When a node begins to be dragged by the user, call the function dragstart.
  drag = force.drag()
    .on("dragstart", dragstart);

  // Line displayed when dragging new nodes.
  drag_line = svg.append('svg:path')
    .attr('class', 'link dragline hidden')
    .attr('d', 'M0,0L0,0');

  // Handles to link and node element groups.
  path = svg.append('svg:g').selectAll('path');
  circle = svg.append('svg:g').selectAll('g');

  // Mouse event variables.
  selected_node = null;
  selected_link = null;
  mousedown_link = null;
  mousedown_node = null;
  mouseup_node = null;
    
  // Define which functions should be called for various mouse events on the svg.
  svg.on('mousedown', mousedown)
    .on('mousemove', mousemove)
    .on('mouseup', mouseup);

  // Define which functions should be called when a key is pressed and released.
  d3.select(window)
    .on('keydown', keydown)
    .on('keyup', keyup);
    
  // The restart() function updates the graph.
  restart();
  
  // Brett: Need to fix this.
  /*
  var maxLength = d3.max(nodes, function(d) { return d.name.length; });

  console.log("maxLength: " + maxLength + "\n");

  if(maxLength < 4){
        document.getElementById("nodeText").style.fill = 'white';
  } else {
        document.getElementById("nodeText").style.fill = 'black';
  }
  */

}

function resetPoset() {
  
  // Set the x-coordinate of each node to the original fixed layout.
  var groupFreq = [];
  var groupCount = [];
  for (var i=0; i<maxGroup+1; i++){
    groupFreq.push(0);
    groupCount.push(0);
  }
  nodes.forEach(function(d){groupFreq[d.group]=groupFreq[d.group]+1;});
  for( var i = 0; i < nodes.length; i++ ){
    groupCount[nodes[i].group]=groupCount[nodes[i].group]+1;
    nodes[i].x = groupCount[nodes[i].group]*((width-2*hPadding)/(groupFreq[nodes[i].group]+1));
    nodes[i].px = groupCount[nodes[i].group]*((width-2*hPadding)/(groupFreq[nodes[i].group]+1));
  }
   
  setAllNodesFixed();
  
  // Calling tick() here is crucial so that the locations of the nodes are updated.
  tick();
    
  // Update the side menu bar to reflect that all nodes are now fixed in their original positions.
  if(forceOn) toggleForce();
  
  restart();
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
  
  // Make sure all nodes stay at the height corresponding to their group.
  for( var i = 0; i < nodes.length; i++ ){
    nodes[i].y = height-vPadding-(nodes[i].group)*rowSep;
    nodes[i].py = height-vPadding-(nodes[i].group)*rowSep;
  }
    
    // Restrict the nodes to be contained within a 15 pixel margin around the svg.
  circle.attr('transform', function(d) {
    if (d.x > width - 15) {
      d.x = width - 15;
    }
    else if (d.x < 15) {
      d.x = 15;
    }
    /*
    if (d.y > height - 15) {
      d.y = height - 15;
    }
    else if (d.y < 15) {
      d.y = 15;
    }*/
    
    // Visually update the locations of the nodes based on the force simulation.
    return 'translate(' + d.x + ',' + d.y + ')';
  });
    
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

}

// Update graph (called when needed).
function restart() {
  // Construct the group of edges from the 'links' array.
  path = path.data(links);

  // Update existing links.
  // If a link is currently selected, set 'selected: true'.  If a link should be highlighted, set 'highlighted: true'.
  path.classed('highlighted', function(d) {return d.highlighted; })
    .classed('selected', function(d) { return d === selected_link; })
    // If the edge is directed towards the source or target, attach an arrow.
    .style('marker-start', function(d) { return d.left ? 'url(#start-arrow)' : ''; })
    .style('marker-end', function(d) { return d.right ? 'url(#end-arrow)' : ''; });

  // Add new links.
  path.enter().append('svg:path')
    .attr('class', 'link')
    // If a link should be highlighted, set 'highlighted: true'.
    .classed('highlighted', function(d) {return d.highlighted; })
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
      // If highlighting neighbors is turned on, un-highlight all nodes and links since there is no currently selected node.
      if(curHighlight) unHighlightAll();
      
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
    //.classed('reflexive', function(d) { return d.reflexive; });
    .classed('highlighted', function(d) { return d.highlighted; })
    .attr('group', function(d) {return d.group;});

  // Add new nodes.
  var g = circle.enter().append('svg:g');

  g.append('svg:circle')
    .attr('class', 'node')
    .attr('r', 12)
    .style('fill', function(d) { return (d === selected_node) ? d3.rgb(colors(d.id)).brighter().toString() : colors(d.id); })
    .style('stroke', function(d) { return d3.rgb(colors(d.id)).darker().toString(); })
    .classed('reflexive', function(d) { return d.reflexive; })
    .classed('highlighted',function(d) {return d.highlighted;})
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
      // Brett: Add back in the following line if we don't want selected nodes brightened in non-editing mode.
      //if(d3.event.shiftKey || !curEdit) return;
      if(d3.event.shiftKey) return;

      // Otherwise, select node.
      mousedown_node = d;
      
      // If the node that the user clicked was already selected, then unselect it.
      if(mousedown_node === selected_node) { selected_node = null; 
            if(curHighlight) unHighlightAll(); }
      //Brett: Add the following line back in if we don't want nodes to be brightened in non-editing mode.
      //else if(curEdit) { selected_node = mousedown_node;
      else {selected_node = mousedown_node;
            if(curHighlight) highlightAllNeighbors(selected_node);
      };
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

      // Graph Changed :: adding new links
      if(link) {
        link[direction] = false;
      } else {
        link = {source: source, target: target, left: false, right: false};
        link[direction] = false;
        links.push(link);
        // Graph is updated here so we change some items to default.
        menuDefaults();
      }

      //document.getElementById("constructorString").innerHTML = "Macaulay2 Constructor: " + graph2M2Constructor(nodes,links);
      
      // (Brett) Removing incidence and adjacency matrices for now.
      /*document.getElementById("incString").innerHTML = "Incidence Matrix: " + arraytoM2Matrix(getIncidenceMatrix(nodes,links));
      document.getElementById("adjString").innerHTML = "Adjacency Matrix: " + arraytoM2Matrix(getAdjacencyMatrix(nodes,links));*/

      // select new link
      if (curEdit) selected_link = link;
      selected_node = null;
      if (curHighlight) unHighlightAll();
      restart();
    })

  .on('dblclick', function(d) {
      name = "";
      var letters = /^[0-9a-zA-Z]+$/;
      while (name=="") {
        name = prompt('Enter new label name.', d.name);
        // Check whether the user has entered any illegal characters (including spaces).
        if (!(letters.test(name))) {
            alert('Please input alphanumeric characters only with no spaces.');
            name = "";
        }
        if (name==d.name) {
          return;
        }
        else if (checkName(name)) {
          alert('Sorry, a node with that name already exists.')
          name = "";
        }
      }
      
      if(name != null) {
        d.name = name;
        d3.select(this.parentNode).select("text").text(function(d) {return d.name});          
      }

      //document.getElementById("constructorString").innerHTML = "Macaulay2 Constructor: " + graph2M2Constructor(nodes,links);

    });

  // show node IDs
  g.append('svg:text')
      .attr('x', 0)
      .attr('y', 4)
      .attr('class', 'id noselect')
      .attr("pointer-events", "none")
      .text(function(d) { return d.name; });

  /*
  var maxLength = d3.max(nodes, function(d) {
        return d.name.length;
  });
      
  if(maxLength < 4){
        document.getElementById("nodeText").style.fill = 'white';
  } else {
        document.getElementById("nodeText").style.fill = 'black';
  }
  */

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

  // Graph Changed :: adding nodes
  node = {id: lastNodeId++, group: 0, name: curName, reflexive: false, highlighted: false};
  node.x = point[0];
  node.y = point[1];
  nodes.push(node);
  // Graph is updated here so we change some items to default 
  // d3.select("#isCM").html("isCM");
  menuDefaults();

  //document.getElementById("constructorString").innerHTML = "Macaulay2 Constructor: " + graph2M2Constructor(nodes,links);
    
  // (Brett) Removing incidence and adjacency matrices for now.
  /*document.getElementById("incString").innerHTML = "Incidence Matrix: " + arraytoM2Matrix(getIncidenceMatrix(nodes,links));
  document.getElementById("adjString").innerHTML = "Adjacency Matrix: " + arraytoM2Matrix(getAdjacencyMatrix(nodes,links));*/

  restart();
}

function mousemove() {
  if(!mousedown_node) return;

  // update drag line
  if(curEdit){
  drag_line.attr('d', 'M' + mousedown_node.x + ',' + mousedown_node.y + 'L' + d3.mouse(this)[0] + ',' + d3.mouse(this)[1]);
  }
    
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
        if(curHighlight) unHighlightAll();
      } else if(curEdit && selected_link) {

        links.splice(links.indexOf(selected_link), 1);
        if(curHighlight) unHighlightAll();
      }
      selected_link = null;
      if(curEdit) {selected_node = null;}

      // Graph Changed :: deleted nodes and links
      // as a result we change some items to default
      // d3.select("#isCM").html("isCM");      
      menuDefaults();

      //document.getElementById("constructorString").innerHTML = "Macaulay2 Constructor: " + graph2M2Constructor(nodes,links);
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

function disableEditing() {
  circle.call(drag);
  svg.classed('shift', true);
  selected_node = null;
  selected_link = null;
  if(curHighlight) unHighlightAll();

  /*
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
  */

  restart();
}

function enableEditing() {
  circle
      .on('mousedown.drag', null)
      .on('touchstart.drag', null);
  svg.classed('shift', false);
}

function enableHighlight() {
  // If there is no currently selected node, then just return (negating the value of curHighlight).
  if(selected_node == null) return;
  highlightAllNeighbors(selected_node);
  console.log("curHighlight: "+curHighlight);
}

function unHighlightAll() {
    // Un-highlight all nodes.
    for (var i = 0; i<nodes.length; i++) {
       nodes[i].highlighted = false;
    }
    
    // Un-highlight all links.
    for (var i = 0; i<links.length; i++) {
       links[i].highlighted = false;
    }
    
    // Update graph based on changes to nodes and links.
    restart();
}

function highlightAllNeighbors(n) {
    // Highlight all nodes that are neighbors with the given node n.
    for (var i = 0; i<nodes.length; i++) {
       console.log(areNeighbors(nodes[i],n));
       nodes[i].highlighted = areNeighbors(nodes[i],n);
    }
    
    // Highlight all links that have the given node n as a source or target.
    for (var i = 0; i<links.length; i++) {
       links[i].highlighted = ((links[i].source === n) || (links[i].target === n));
    }
    
    // Update graph based on changes to nodes and links.
    restart();
}

function areNeighbors(node1,node2) {
    return links.some( function(l) {return (((l.source === node1) && (l.target === node2)) || ((l.target === node1) && (l.source === node2)));});
}

function setAllNodesFixed() {
  for (var i = 0; i<nodes.length; i++) {
    nodes[i].fixed = true;
  }
}

function setAllNodesUnfixed() {
  for (var i = 0; i<nodes.length; i++) {
    nodes[i].fixed = false;
  }
}

function updateWindowSize2d() {
    console.log("resizing window");
    //var svg = document.getElementById("canvasElement2d");
    
    // get width/height with container selector (body also works)
    // or use other method of calculating desired values
    width = window.innerWidth-10;
    height = window.innerHeight-10;
    rowSep = (height-2*vPadding)/maxGroup;

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

function poset2M2Constructor( labels, relMatrix ){
  var covRel = idRelationsToLabelRelations(minimalPosetRelations(relMatrix),labels);
  var relString = nestedArraytoM2List(covRel);
  var labelString = "{";
  var m = labels.length;
  for( var i = 0; i < m; i++ ){
    if(i != (m-1)){
      labelString = labelString + labels[i].toString() + ", ";
    }
    else{
      labelString = labelString + labels[i].toString() + "}";
    }
  }
  return "poset("+labelString+","+relString+")";
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

// Takes a rectangular array of arrays and returns a string which can be copy/pasted into M2.
function nestedArraytoM2List (arr){
  var str = "{{";
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

// ----------- Functions for computations with posets ---------

// Still need: heightFunction, relHeightFunction
// reflexiveClosure, transitiveClosure?

// Given the relation matrix for a poset, this function returns null if the poset is not ranked and otherwise returns a list of the ranks of the elements.  This algorithm is taken from Posets.m2, which was in turn taken from John Stembridge's Maple package for computations with posets.
function posetRankFunction(relMatrix){
    var rk = [];
    for(var i=0; i < relMatrix.length; i++){
        rk.push([i,0]);
    }
    var covRel = minimalPosetRelations(relMatrix);
    for(var i=0; i < covRel.length; i++){
        var tmp = rk[covRel[i][1]][rk[covRel[i][1]].length-1] - rk[covRel[i][0]][rk[covRel[i][1]].length-1] - 1;
        if(tmp == 0){continue;}
        var u = rk[covRel[i][0]][0];
        var v = rk[covRel[i][1]][0];
        if(u == v){return null;};
        var temprk = [];
        if(tmp > 0){
            for(var j=0; j < rk.length; j++){
                if(rk[j][0] == u){
                    temprk.push([v,rk[j][rk[j].length-1] + tmp]);
                } else {
                    temprk.push(rk[j]);
                }
            }
        } else {
            for(var j=0; j < rk.length; j++){
                if(rk[j][0] == v){
                    temprk.push([u,rk[j][rk[j].length-1] - tmp]);
                } else {
                    temprk.push(rk[j]);
                }
            }
        }
        rk = temprk;
    }
    var rkOutput = [];
    for(var i=0; i < temprk.length; i++){
        rkOutput.push(temprk[i][1]);
    }
    return rkOutput;
}

// Given the relation matrix for a poset, this function determines whether the poset is ranked or not.
function posetIsRanked(relMatrix){
    return posetRankFunction(relMatrix) != null;
}

// Given the relation matrix for a poset, this function computes a filtration of the poset of the form [F_0,F_1,...].  F_0 consists of the minimal elements of the poset, F_1 consists of the minimal elements of P - F_0, and so on.  This algorithm is taken from Posets.m2, which was in turn taken from John Stembridge's Maple package for computations with posets.
function posetFiltration(relMatrix){
    var covRel = minimalPosetRelations(relMatrix);
    var cnt = [];
    var cvrby = [];
    // For each element of the poset, determine how many times it occurs as the larger element in any minimal covering relation (listed in cnt).  Also, for each element of the poset, determine the minimal elements that cover it (listed in cvrby).
    for(var i=0; i < relMatrix.length; i++){
        var tempCount = 0;
        var tempCvrs = [];
        for(var j=0; j < covRel.length; j++){
            if(covRel[j][1] == i){tempCount = tempCount+1;}
            if(covRel[j][0] == i){tempCvrs.push(covRel[j][1]);}
        }
        cnt.push(tempCount);
        cvrby.push(tempCvrs);
    }
    // Find indices of all elements that do not minimally cover any element (i.e., the minimal elements in the poset).
    var neu = [];
    for(var i=0; i < cnt.length; i++){
        if(cnt[i] == 0){neu.push(i)};        
    }
    // We need neu.slice() here so that the neu array is cloned and ret points to the new occurrence of neu;
    var ret = [neu.slice()];
    while(neu.length > 0){
        var tempMinCvrs = [];
        for(var i=0; i < neu.length; i++){
            tempMinCvrs.push(cvrby[neu[i]]);
        }
        tempMinCvrs = flattenArray(tempMinCvrs);
        var tempArr = [];
        for(var i=0; i < tempMinCvrs.length; i++){
            if(cnt[tempMinCvrs[i]] == 1){
                tempArr.push(tempMinCvrs[i]);
            } else {
                cnt[tempMinCvrs[i]] = cnt[tempMinCvrs[i]] - 1;
                continue;
            }
        }
        neu = tempArr.slice();
        ret.push(tempArr.slice());
    }
    ret.splice(ret.length-1,1);
    return ret;
}

// Given the relation matrix for a poset, compute the "height" of each element, which is simply the corresponding level of the filtration of the poset that contains it.  This is meant to be used in place of a rank function is the poset is not ranked.
function posetHeightFunction(relMatrix){
    var filt = posetFiltration(relMatrix);
    var ht = [];
    for(var i=0; i < relMatrix.length; i++){
        for(var j=0; j < filt.length; j++){
            for(var k=0; k < filt[j].length; k++){
                if(filt[j][k] == i){ht.push(j);}
            }
        }
    }
    return ht;
}

// Given the relation matrix for a poset, compute the minimal elements.
function posetMinimalElements(relMatrix){
    var output = [];
    for(var i=0; i < relMatrix.length; i++){
        var isMin = true;
        for(var j=0; j < relMatrix.length; j++){
            // If the ith element covers another element, then it is not minimal.
            if((relMatrix[j][i] == 1) && (i != j)){isMin = false;}
        }
        if(isMin){output.push(i)};
    }
    return output;
}

// Given the relation matrix for a poset, compute the maximal elements.
function posetMaximalElements(relMatrix){
    var output = [];
    for(var i=0; i < relMatrix.length; i++){
        var isMax = true;
        for(var j=0; j < relMatrix.length; j++){
            // If the ith element is covered by another element, then it is not maximal.
            if((relMatrix[i][j] == 1) && (i != j)){isMax = false;}
        }
        if(isMax){output.push(i)};
    }
    return output;
}

// Given the relation matrix for a poset, compute the maximal chains.
function posetMaximalChains(relMatrix){
    var minElt = posetMinimalElements(relMatrix);
    var nonMaximalChains = [];
    for(var i=0; i < minElt.length; i++){
        nonMaximalChains.push([minElt[i]]);
    }
    var covRel = minimalPosetRelations(relMatrix);
    var cvrby = [];
    for(var i=0; i < relMatrix.length; i++){
        var tempCvrs = [];
        for(var j=0; j < covRel.length; j++){
            if(covRel[j][0] == i){tempCvrs.push(covRel[j][1]);}
        }
        cvrby.push(tempCvrs);
    }
    var maxChains = [];
    while(nonMaximalChains.length > 0){
        var tempArr2 = [];
        for(var i=0; i < nonMaximalChains.length; i++){
            var tempArr = [];
            tempCvrs = cvrby[nonMaximalChains[i][nonMaximalChains[i].length-1]];
            if(tempCvrs.length == 0){
                // If a maximal chain is found, add it to maxChains.
                maxChains.push(nonMaximalChains[i].slice());
                continue;
            } else {
                // Otherwise, the chain can be extended further.  Create all possible extensions of the current chain with minimal covering elements.
                for (var j=0; j < tempCvrs.length; j++){
                    tempArr.push(nonMaximalChains[i].concat(tempCvrs[j]));
                }
                tempArr2.push(tempArr.slice());
            }
        }
        nonMaximalChains = flattenArray(tempArr2.slice());
    }
    return maxChains;
}

// // Given the relation matrix for a poset, compute the "relative height" of each element, which tries to keep elements evenly spaced relative to the length of the maximal chains in the poset.  This is meant to be used in place of a rank function is the poset is not ranked.
function posetRelHeightFunction(relMatrix){
    var maxChains = posetMaximalChains(relMatrix);
    var heightList = posetHeightFunction(relMatrix);
    // For each element of the poset, create a list of all maximal chains that involve that element.
    var maxChainList = [];
    for(var i=0; i < relMatrix.length; i++){
        var tempArr = [];
        for(var j=0; j < maxChains.length; j++){
            for(var k=0; k < maxChains[j].length; k++){
                // If the ith element appears in the jth maximal chain, then push the jth maximal chain to tempArr.
                if(maxChains[j][k] == i){tempArr.push(maxChains[j]);}
            }
        }
        maxChainList.push(tempArr.slice());
    }
    // For each element of the poset, find the lengths of all maximal chains that involve it.
    var chainLengthList = [];
    for(var i=0; i < maxChainList.length; i++){
        tempArr = [];
        for(var j=0; j < maxChainList[i].length; j++){
            tempArr.push(maxChainList[i][j].length);
        }
        chainLengthList.push(tempArr.slice());
    }
    var relHeightList = [];
    for(var i=0; i < chainLengthList.length; i++){
        relHeightList.push(d3.max(chainLengthList[i]) - 1);
    }
    var totalHeight = lcm(relHeightList);
    var output = [];
    for(var i=0; i < relMatrix.length; i++){
        output.push((totalHeight/relHeightList[i])*heightList[i]);
    }
    return output;
}

// Given the relation matrix for a set under a binary relation, this function determines whether the relation is antisymmetric (required for a poset) or not.
function posetIsAntisymmetric(relMatrix){
    var n = relMatrix.length;
    for(var i=0; i < n-1; i++){
        for(var j=i+1; j < n; j++){
            if((relMatrix[i][j] == 1) && (relMatrix[j][i] == 1)){
                return false;
            }            
        }
    }
    return true;
}

// Given the relation matrix for a poset, this function returns an array consisting of all relations in the poset (with nodes labeled by id).  This assumes that the rows and columns in the relation matrix are indexed according to the id of the nodes.  The relMatrix is given such that relMatrix[i][j] == 1 if and only if node_j <= node_i in the partial order.
function allPosetRelations (relMatrix){
    var tempArr = [];
    var n = relMatrix.length;
    for(var i=0; i < n; i++){
        for(var j=i; j < n; j++){
            // relMatrix[i][j] and relMatrix[j][i] can't both be 1 if i != j or else the poset would not be antisymmetric.
            if(relMatrix[i][j] == 1){tempArr.push([i,j]);}
            else {
                if(relMatrix[j][i] == 1){tempArr.push([j,i]);}
            }
        }
    }
    
    return tempArr;
}

// Given the relation matrix for a poset, this function returns an array consisting of minimal covering relations in the poset (with nodes labeled by id).  This assumes that the rows and columns in the relation matrix are indexed according to the id of the nodes.  The relMatrix is given such that relMatrix[i][j] == 1 if and only if node_j <= node_i in the partial order.  This algorithm is the same as the one used in Posets.m2.
function minimalPosetRelations (relMatrix){
    var n = relMatrix.length;
    var outputArr = [];
    var gtp = [];
    for(var i=0; i < n; i++){
        var temp = [];
        for(var j=0; j < n; j++){
            if((i != j) && (relMatrix[i][j] == 1)){temp.push(j)};
        }
        gtp.push(temp);
    }
    for(var i=0; i < n; i++){
        var gtgtp = [];
        var tempIndices = gtp[i];
        for(var j=0; j < tempIndices.length; j++){
            gtgtp.push(gtp[tempIndices[j]]);            
        }
        gtgtp = eliminateDuplicates(flattenArray(gtgtp));
        var trimIndices = setDifference(tempIndices,gtgtp);
        for(var j=0; j < trimIndices.length; j++){
            outputArr.push([i,trimIndices[j]]);            
        }        
    }
    
    return outputArr;    
}

// Given a list of relations labeled by node id, return the corresponding list of relations labeled by the name of the corresponding node.
function idRelationsToLabelRelations (relArr,labelArr){
    var out = [];
    for(var i=0; i < relArr.length; i++){
        out.push([labelArr[relArr[i][0]],labelArr[relArr[i][1]]]);
    }
    return out;
}

// ----------- Helper functions for dealing with arrays. ----------

// Given a nested array of arrays, this flattens the array by one level.
function flattenArray (arr) {
    return [].concat.apply([], arr);
}

// Eliminate all duplicate entries in an array.
function eliminateDuplicates(arr) {
  var i,
      len=arr.length,
      out=[],
      obj={};

  for (i=0;i<len;i++) {
    obj[arr[i]]=0;
  }
  for (i in obj) {
    out.push(i);
  }
  return out;
}

// Take the set-theoretic difference of two arrays.  (i.e., Return the result of removing from the first array all common elements of the second array.)
function setDifference(arr1,arr2) {
    var len1 = arr1.length;
    var len2 = arr2.length;
    var delIndices = [];
    for(var i =0; i < len1; i++){
        for(var j=0; j < len2; j++){
            // If j[i] appears in arr2, then delete it.
            if(arr1[i] == arr2[j]){delIndices.push(i);}            
        }
    }
    delIndices = eliminateDuplicates(delIndices);
    var offset = 0;
    // Remove all elements of arr1 where common elements with arr2 were found.
    for(var i=0; i < delIndices.length; i++){
        arr1.splice(delIndices[i]-offset,1);
        offset = offset+1;        
    }
    
    return arr1;
}

// Compute the lcm of an array of integers.
function lcm(A) {
    var n = A.length, a = Math.abs(A[0]);
    for (var i = 1; i < n; i++)
     { var b = Math.abs(A[i]), c = a;
       while (a && b){ a > b ? a %= b : b %= a; } 
       a = Math.abs(c*A[i])/(a+b);
     }
    return a;
}


function exportTikz (event){
  var points = [];
  for(var i = 0; i < nodes.length; i++){
    points[i] = [nodes[i].x.toString()+"/"+nodes[i].y.toString()+"/"+nodes[i].id+"/"+nodes[i].name];
  }

  var edges = [];
  for(var j = 0; j < links.length; j++){
    edges[j] = [ links[j].source.id.toString()+"/"+links[j].target.id.toString() ];
  }

  var tikzTex = "";
//  tikzTex =  "\\begin{tikzpicture}\n          % Point set in the form x-coord/y-coord/node ID/node label\n          \\newcommand*\\points{"+points+"}\n          % Edge set in the form Source ID/Target ID\n          \\newcommand*\\edges{"+edges+"}\n          % Scale to make the picture able to be viewed on the page\n          \\newcommand*\\scale{0.02}\n          % Creates nodes\n          \\foreach \\x/\\y/\\z/\\w in \\points {\n          \\node (\\z) at (\\scale*\\x,-\\scale*\\y) [circle,draw] {$\\w$};\n          }\n          % Creates edges\n          \\foreach \\x/\\y in \\edges {\n          \\draw (\\x) -- (\\y);\n          }\n      \\end{tikzpicture}";
  tikzTex =  "\\begin{tikzpicture}\n         \\newcommand*\\points{"+points+"}\n          \\newcommand*\\edges{"+edges+"}\n          \\newcommand*\\scale{0.02}\n          \\foreach \\x/\\y/\\z/\\w in \\points {\n          \\node (\\z) at (\\scale*\\x,-\\scale*\\y) [circle,draw] {$\\w$};\n          }\n          \\foreach \\x/\\y in \\edges {\n          \\draw (\\x) -- (\\y);\n          }\n      \\end{tikzpicture}\n      % \\points is point set in the form x-coord/y-coord/node ID/node label\n     % \\edges is edge set in the form Source ID/Target ID\n      % \\scale makes the picture able to be viewed on the page\n";  
    
  if(!tikzGenerated){
    var tikzDiv = document.createElement("div");
    tikzDiv.id = "tikzHolder";
    tikzDiv.className = "list-group-item";
    var tikzInput = document.createElement("input");
    tikzInput.value = "";
    tikzInput.id = "tikzTextBox";
    tikzInput.size = "15";
    tikzInput.style = "vertical-align:middle;";
    var tikzButton = document.createElement("button");
    tikzButton.id = "copyButton";
    tikzButton.style = "vertical-align:middle;";
    //tikzButton.dataClipboardTarget = "#tikzTextBox";
    tikzButton.type = "button";
    var clipboardImg = document.createElement("img");
    clipboardImg.src = scriptSource+"images/32px-Octicons-clippy.png";
    clipboardImg.alt = "Copy to clipboard";
    clipboardImg.style = "width:19px;height:19px;";
    tikzButton.appendChild(clipboardImg);
    tikzDiv.appendChild(tikzInput);
    tikzDiv.appendChild(tikzButton);
    var listGroup = document.getElementById("menuList");
    listGroup.insertBefore(tikzDiv,listGroup.childNodes[10]);
    document.getElementById("copyButton").setAttribute("data-clipboard-target","#tikzTextBox");
    clipboard = new Clipboard('#copyButton');
    clipboard.on('error', function(e) {
        window.alert("Press enter, then CTRL-C or CMD-C to copy")
    });  
    tikzGenerated = true;
  }
  document.getElementById("tikzTextBox").value = tikzTex;
  /*  
  var tikzTextArea = document.createElement("textarea");
  tikzTextArea.setAttribute("type", "hidden"); 
  document.getElementById("body").appendChild(tikzTextArea);
  tikzTextArea.value += tikzTex;
    
  event.preventDefault();
  tikzTextArea.select(); // Select the input node's contents
  var succeeded;
  try {
    // Copy it to the clipboard
    succeeded = document.execCommand("copy");
  } catch (e) {
    succeeded = false;
  }
  if (succeeded) {
    console.log("Copy successful.");
  } else {
    console.log("Copy failed.");
  }
  */
    
// tikzTextArea.select().focus();
//  $('#container').append('To copy emails to clipboard, press: Ctrl+C, then Enter <br />  <textarea id="tikzTex">'+tikzTex+'</textarea>');
//  $('#tikzTex').select().focus();

//console.log(tikzTex.length);
//  if (tikzTex.length < 2001){
//    window.prompt("Copy this text the best way you can.", tikzTex );
//  } else {
//    alert("Feeling ambitious? Your TikZ code is "+tikzTex.length.toString()+" characters. The maximum amount of characters is 2000.");
//  }
    
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
