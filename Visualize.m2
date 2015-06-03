---------------------------------------------------------------------------
-- PURPOSE : Visualize package for Macaulay2 provides the ability to 
-- visualize various algebraic objects in java script using a 
-- modern browser.
--
-- Copyright (C) 2013 Branden Stone and Jim Vallandingham
--
-- This program is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License version 2
-- as published by the Free Software Foundation.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--------------------------------------------------------------------------


newPackage(
	"Visualize",
    	Version => "0.3", 
    	Date => "June 1, 2015",
    	Authors => {       
     	     {Name => "Brett Barwick", Email => "Brett@barwick.edu", HomePage => "http://math.bard.edu/~bstone/"},	     
-- Contributing Author	     {Name => "Elliot Korte", Email => "ek2872@bard.edu"},	     
-- Contributing Author	     {Name => "Will Smith", Email => "smithw12321@gmail.com"},		
	     {Name => "Branden Stone", Email => "bstone@adelphi.edu", HomePage => "http://math.adelpi.edu/~bstone/"},
-- Contributing Author	     {Name => "Julio Urenda", Email => "jcurenda@nmsu.edu"},	     
	     {Name => "Jim Vallandingham", Email => "vlandham@gmail.com", HomePage => "http://vallandingham.me/"}
	     },
    	Headline => "Visualize",
    	DebuggingMode => false,
	PackageExports => {"Graphs", "Posets", "SimplicialComplexes"},
	AuxiliaryFiles => true,
	Configuration => {"DefaultPath" => null } 
    	)

export {
    
    -- Options
     "VisPath",
     "VisTemplate",
     "Warning",
     "FixExtremeElements",
    
    -- Methods
     "visualize",
     
    -- Helpers 
--     "runServer",
     "toArray", 
     "getCurrPath", 
     "copyTemplate",
     "replaceInFile",
     "heightFunction",
     "relHeightFunction",
     
    -- Server
     "openPort",
     "closePort",
     "outPutPortTest", -- Just for testing, delete in final version.
     "outPutInOutPort" -- Just for testing, delete in final version.
     

}


defaultPath = (options Visualize).Configuration#"DefaultPath"

-- (options Visualize).Configuration

portTest = false -- Used to test if ports are open or closed.
inOutPort = null -- Actual file the listener is opened to.
inOutPortNum = null -- The port number that is being opened. This is passed to the browser.

-- used for testing, will not be in final package
outPutPortTest = method()
outPutPortTest Boolean := B -> return portTest;

-- used for testing, will not be in final package
outPutInOutPort = method()
outPutInOutPort Boolean := B -> return inOutPort;

-- used for testing, will not be in final package
outPutInOutPortNum = method()
outPutInOutPortNum Boolean := B -> return inOutPort;


------------------------------------------------------------
-- METHODS
------------------------------------------------------------

-- Input: None.
-- Output: String containing current path.

getCurrPath = method()
installMethod(getCurrPath, () -> (local currPath; currPath = get "!pwd"; substring(currPath,0,(length currPath)-1)|"/"))


--input: A list of lists
--output: an array of arrays
--
-- would be nice if we could use this on any nesting of lists/seq
-- we could make the input a BasicList
--
toArray = method() 
toArray(List) := L -> (
     return new Array from apply(L, i -> new Array from i);
     )
    


--input: A path
--output: runs a server for displaying objects
--
-- runServer = method(Options => {VisPath => currentDirectory()})
-- runServer(String) := opts -> (visPath) -> (
--     return run visPath;
--    )

--- add methods for output here:
--

--replaceInFile
--	replaces a given pattern by a given patter in a file
--	input: string containing the pattern
--	       string containing the replacement
--	       string containing the file name, 
replaceInFile = method()
replaceInFile(String, String, String) := (patt, repl, fileName) -> (
		local currFile; 
		local currStr; 
		
		currFile = openIn fileName; 
		currStr = get currFile;
	      
		
		currStr = replace(patt, repl, currStr);

		currFile = openOut fileName; 

		currFile << currStr << close;
		
		return fileName;
)	


--input: Three Stings. The first is a key word to look for.  The second
--    	 is what to replace the key word with. The third is the path 
--    	 where template file is located.
--output: A file with visKey replaced with visString.
--
visOutput = method(Options => {VisPath => currentDirectory()})
visOutput(String,String,String) := opts -> (visKey,visString,visTemplate) -> (
    local fileName; local openFile; local PATH;
    
    fileName = (toString currentTime() )|".html";
    PATH = opts.VisPath|fileName;
    openOut PATH << 
    	replace(visKey, visString , get visTemplate) << 
	close;
                  
    return (show new URL from { "file://"|PATH }, fileName);
    )

-- input: path to an html file
-- output: a copy of the input file in a temporary folder
--
copyTemplate = method()
copyTemplate String := src -> (
    local fileName; local dirPath;
    
    fileName = (toString currentTime() )|".html";
    
    dirPath = temporaryFileName();
    makeDirectory dirPath;
    dirPath = concatenate(dirPath,"/",fileName);
    
    copyFile( src, dirPath);
    
    return dirPath;
)

-- input: A source path to an html file and a destination directory
-- output: a copy of the source file in the destination directory
--
copyTemplate(String,String) := (src,dst) -> (
    local fileName; local dirPath;
    
    fileName = (toString currentTime() )|".html";
    
--    dirPath = temporaryFileName();
--    makeDirectory dirPath;
    dirPath = concatenate(dst,fileName);

-- test to see if users directory exists    
    if (fileExists dst) 
    then (
	copyFile( src, dirPath);
	return dirPath;
	)
    else error "Path does not exist. Please check the path and try again.";

)

-- input:
-- output:
searchReplace = method(Options => {VisPath => currentDirectory()})
searchReplace(String,String,String) := opts -> (oldString,newString,visSrc) -> (
    local visFilePathTemp;
    
    visFilePathTemp = temporaryFileName();
    copyFile(visSrc,visFilePathTemp);
    openOut visSrc << 
    	replace(oldString, newString , get visFilePathTemp) << 
	close;
	
    return visSrc;
    )


heightFunction = method()
heightFunction(Poset) := P -> (
    local F; local G; local tempList;
    F = filtration P;
    G = P.GroundSet;
    tempList = new MutableList from apply(#G,i -> null);
    -- The next line creates a list in which the ith entry is the
    -- height of the ith element in P.GroundSet.
    scan(#F, i -> scan(F#i, j -> (tempList#(position(G, k -> k == j)) = i)));
    return toList tempList;
)

relHeightFunction = method()
relHeightFunction(Poset) := P -> (
    local nodes; local maxChains;
    local heightList; local maxChainList; local chainLengthList;
    local relHeightList; local totalHeight;
    
    nodes = P_*;
    maxChains = maximalChains P;
    heightList = heightFunction P;
    maxChainList = apply(nodes, j -> delete(null,apply(maxChains, L -> (if any(L, i -> i == j) == true then L else null))));
    chainLengthList = apply(maxChainList, i -> apply(i, j -> #j));
    relHeightList = apply(chainLengthList, i -> max i - 1);
    totalHeight = lcm relHeightList;
    return apply(#nodes, i -> (totalHeight / relHeightList#i) * heightList#i);    
)

--input: A monomial ideal of a polynomial ring in 2 or 3 variables.
--output: The newton polytope of the of the ideal.
--
visualize = method(Options => true)

visualize(Ideal) := {VisPath => defaultPath, VisTemplate => currentDirectory() |"Visualize/templates/visIdeal/visIdeal", Warning => true} >> opts -> J -> (
    local R; local arrayList; local arrayString; local numVar; local visTemp;
    local varList;
    -- local A;
    
    R = ring J;
    numVar = rank source vars R;
    varList = flatten entries vars R;
        
    if ((numVar != 2) and (numVar != 3)) then (error "Ring needs to have either 2 or 3 variables.");
    
    if numVar == 2 
    then (
	if opts.VisPath =!= null 
	then (
	    	visTemp = copyTemplate(opts.VisTemplate|"2D.html",opts.VisPath);
	    	copyJS(opts.VisPath, Warning => opts.Warning);	    
	    )
	else (
	    	visTemp = copyTemplate(opts.VisTemplate|"2D.html");
	    	copyJS(replace(baseFilename visTemp, "", visTemp), Warning => opts.Warning);	    
	    );
	
	arrayList = apply( flatten entries gens J, m -> flatten exponents m);	
	arrayList = toArray arrayList;
	arrayString = toString arrayList;
	
	searchReplace("visArray",arrayString, visTemp);
--	searchReplace("XXX",toString(varList_0), visTemp);
--	searchReplace("YYY",toString(varList_1), visTemp);
--	searchReplace("ZZZ",toString(varList_2), visTemp)
    )
    else (
	
	if opts.VisPath =!= null 
	then (
	    	visTemp = copyTemplate(opts.VisTemplate|"3D.html",opts.VisPath);
	    	copyJS(opts.VisPath, Warning => opts.Warning);	    
	    )
	else (
	    	visTemp = copyTemplate(opts.VisTemplate|"3D.html");
	    	copyJS(replace(baseFilename visTemp, "", visTemp), Warning => opts.Warning);	    
	    );
	    
    	arrayList = apply(flatten entries basis(0,infinity, R/J), m -> flatten exponents m );
    	arrayList = toArray arrayList;
    	arrayString = toString arrayList;
	
	searchReplace("visArray",arrayString, visTemp);
	searchReplace("XXX",toString(varList_0), visTemp);
	searchReplace("YYY",toString(varList_1), visTemp);
	searchReplace("ZZZ",toString(varList_2), visTemp)
    );
    
    show new URL from { "file://"|visTemp };
--    A = visOutput( "visArray", arrayString, visTemp, VisPath => opts.VisPath );
    
    return visTemp;--opts.VisPath|A_1;
    )

--input: A graph
--output: the graph in the browswer
--
visualize(Graph) := {VisPath => defaultPath, VisTemplate => currentDirectory() | "Visualize/templates/visGraph/visGraph-template.html", Warning => true} >> opts -> G -> (
    local A; local arrayString; local vertexString; local visTemp;
    local keyPosition; local vertexSet; local browserOutput;
    
    
    A = adjacencyMatrix G;
    arrayString = toString toArray entries A; -- Turn the adjacency matrix into a nested array (as a string) to copy to the template html file.
    
    -- Add this back in when we figure out how to deal with the old
    -- Graphs package not knowing what G.vertexSet means.

-- !!!! Need to deal with version numbers here    
--  if value((options Graphs).Version) == 0.3.1 then (
    if .1 == 1 then (	
	 vertexString = toString new Array from apply(keys(G#graph), i -> "\""|toString(i)|"\""); -- Create a string containing an ordered list of the vertices in the older Graphs package.
    ) else (
    
    	 -- This is a workaround for finding and referring to the key vertexSet in the hash table for G.
         -- Would be better to be able to refer to G.vertexSet, but the package
	 -- seems not to load if we try this.
	 keyPosition = position(keys G, i -> toString i == "vertexSet");
	 vertexString = toString new Array from apply((values G)#keyPosition, i -> "\""|toString(i)|"\""); -- Create a string containing an ordered list of the vertices in the newer Graphs package
	 
	 --vertexSet = symbol vertexSet;
	 --vertexString = toString new Array from apply(G.vertexSet, i -> "\""|toString(i)|"\""); -- Create a string containing an ordered list of the vertices in the newer Graphs package.
	 -- vertexString = toString new Array from apply((values G)#0, i -> "\""|toString(i)|"\""); -- Create a string containing an ordered list of the vertices in the newer Graphs package.
    );

    if opts.VisPath =!= null 
    then (
	visTemp = copyTemplate(opts.VisTemplate, opts.VisPath); -- Copy the visGraph template to a temporary directory.
    	copyJS(opts.VisPath, Warning => opts.Warning); -- Copy the javascript libraries to the temp folder.
--	visTemp = copyTemplate(opts.VisTemplate|"3D.html",opts.VisPath);
--	copyJS(opts.VisPath, Warning => opts.Warning);	    
      )
    else (
	visTemp = copyTemplate(opts.VisTemplate); -- Copy the visGraph template to a temporary directory.
    	copyJS(replace(baseFilename visTemp, "", visTemp), Warning => opts.Warning); -- Copy the javascript libraries to the temp folder.
      );
    
    searchReplace("visArray",arrayString, visTemp); -- Replace visArray in the visGraph html file by the adjacency matrix.
    searchReplace("visLabels",vertexString, visTemp); -- Replace visLabels in the visGraph html file by the ordered list of vertices.
    searchReplace("visPort",inOutPortNum, visTemp); -- Replace visPort in the visGraph html file by the user port number.
    
    show new URL from { "file://"|visTemp };
    
    browserOutput = openGraphServer(inOutPort);
        
    return browserOutput;
)

visualize(Digraph) := {VisPath => defaultPath, VisTemplate => currentDirectory()|"Visualize/templates/visDigraph/visDigraph-template.html", Warning => true} >> opts -> G -> (
    local A; local arrayString; local vertexString; local visTemp;
    local keyPosition; local vertexSet;
    
    A = adjacencyMatrix G;
    arrayString = toString toArray entries A; -- Turn the adjacency matrix into a nested array (as a string) to copy to the template html file.
    
    -- Add this back in when we figure out how to deal with the old
    -- Graphs package not knowing what G.vertexSet means.
    
    --if value((options Graphs).Version) == 0.1 then (
    if 1 == .1 then (
	 vertexString = toString new Array from apply(keys(G#graph), i -> "\""|toString(i)|"\""); -- Create a string containing an ordered list of the vertices in the older Graphs package.
    ) else (
    
    	 -- This is a workaround for finding and referring to the key vertexSet in the hash table for G.
         -- Would be better to be able to refer to G.vertexSet, but the package
	 -- seems not to load if we try this.
	 keyPosition = position(keys G, i -> toString i == "vertexSet");
	 vertexString = toString new Array from apply((values G)#keyPosition, i -> "\""|toString(i)|"\""); -- Create a string containing an ordered list of the vertices in the newer Graphs package
	 
	 --vertexSet = symbol vertexSet;
	 --vertexString = toString new Array from apply(G.vertexSet, i -> "\""|toString(i)|"\""); -- Create a string containing an ordered list of the vertices in the newer Graphs package.
	 -- vertexString = toString new Array from apply((values G)#0, i -> "\""|toString(i)|"\""); -- Create a string containing an ordered list of the vertices in the newer Graphs package.
    );
    
--    visTemp = copyTemplate(currentDirectory()|"Visualize/templates/visDigraph/visDigraph-template.html"); -- Copy the visDigraph template to a temporary directory.
--    copyJS(replace(baseFilename visTemp, "", visTemp)); -- Copy the javascript libraries to the temp folder.    

    if opts.VisPath =!= null 
    then (
	visTemp = copyTemplate(opts.VisTemplate, opts.VisPath); -- Copy the visDigraph template to a temporary directory.
    	copyJS(opts.VisPath, Warning => opts.Warning); -- Copy the javascript libraries to the temp folder.
--	visTemp = copyTemplate(opts.VisTemplate|"3D.html",opts.VisPath);
--	copyJS(opts.VisPath, Warning => opts.Warning);	    
      )
    else (
	visTemp = copyTemplate(opts.VisTemplate); -- Copy the visDigraph template to a temporary directory.
    	copyJS(replace(baseFilename visTemp, "", visTemp), Warning => opts.Warning); -- Copy the javascript libraries to the temp folder.
      );

    searchReplace("visArray",arrayString, visTemp); -- Replace visArray in the visDigraph html file by the adjacency matrix.
    searchReplace("visLabels",vertexString, visTemp); -- Replace visLabels in the visDigraph html file by the ordered list of vertices.
    
    show new URL from { "file://"|visTemp };
    
    return visTemp;
)


--input: A poset
--output: The poset in the browswer
--
visualize(Poset) := {FixExtremeElements => false, VisPath => defaultPath, VisTemplate => currentDirectory() | "Visualize/templates/visPoset/visPoset-template.html", Warning => true} >> opts -> P -> (
    local labelList; local groupList; local relList; local visTemp;
    local numNodes; local nodeString; local relationString;
    
    labelList = P_*;
    if isRanked P then groupList = rankFunction P else groupList = heightFunction P;
    relList = coveringRelations P;
    numNodes = #labelList;
    
    if opts.FixExtremeElements == true then (
	    groupList = relHeightFunction P;
    ) else (
	    if isRanked P then groupList = rankFunction P else groupList = heightFunction P;
    );

    nodeString = toString new Array from apply(numNodes, i -> {"\"name\": \""|toString(labelList#i)|"\" , \"group\": "|toString(groupList#i)});
    relationString = toString new Array from apply(#relList, i -> {"\"source\": "|toString(position(labelList, j -> j === relList#i#0))|", \"target\": "|toString(position(labelList, j -> j === relList#i#1))});

    if opts.VisPath =!= null 
    then (
	visTemp = copyTemplate(opts.VisTemplate, opts.VisPath); -- Copy the visPoset template to a temporary directory.
    	copyJS(opts.VisPath, Warning => opts.Warning); -- Copy the javascript libraries to the temp folder.
      )
    else (
	visTemp = copyTemplate(opts.VisTemplate); -- Copy the visPoset template to a temporary directory.
    	copyJS(replace(baseFilename visTemp, "", visTemp), Warning => opts.Warning); -- Copy the javascript libraries to the temp folder.
    );
    
    searchReplace("visNodes",nodeString, visTemp); -- Replace visNodes in the visPoset html file by the ordered list of vertices.
    searchReplace("visRelations",relationString, visTemp); -- Replace visRelations in the visPoset html file by the list of minimal covering relations.
    
    show new URL from { "file://"|visTemp };
    
    return visTemp;
)
--input: A SimplicialComplex
--output: The SimplicialComplex in the browswer
--
visualize(SimplicialComplex) := {VisPath => defaultPath, VisTemplate => currentDirectory() | "Visualize/templates/visSimplicialComplex/visSimplicialComplex2d-template.html", Warning => true} >> opts -> D -> (
    local vertexSet; local edgeSet; local face2Set; local face3Set; local visTemp;
    local vertexList; local edgeList; local face2List; local face3List;
    local vertexString; local edgeString; local face2String; local face3String;
    local visTemplate;
    
    
    vertexSet = flatten entries faces(0,D);
    edgeSet = flatten entries faces(1,D);
    face2Set = flatten entries faces(2,D);
    vertexList = apply(vertexSet, v -> apply(new List from factor v, i -> i#0));
    edgeList = apply(edgeSet, e -> apply(new List from factor e, i -> i#0));
    face2List = apply(face2Set, f -> apply(new List from factor f, i -> i#0));

    vertexString = toString new Array from apply(#vertexList, i -> {"\"name\": \""|toString(vertexList#i#0)|"\""});
    edgeString = toString new Array from apply(#edgeList, i -> {"\"source\": "|toString(position(vertexSet, j -> j === edgeList#i#1))|", \"target\": "|toString(position(vertexSet, j -> j === edgeList#i#0))});
    face2String = toString new Array from apply(#face2List, i -> {"\"v1\": "|toString(position(vertexSet, j -> j == face2List#i#2))|",\"v2\": "|toString(position(vertexSet, j -> j == face2List#i#1))|",\"v3\": "|toString(position(vertexSet, j -> j == face2List#i#0))});

    if dim D>2 then (
	error "3-dimensional simplicial complexes not implemented yet.";
 	visTemplate = currentDirectory() | "Visualize/templates/visSimplicialComplex/visSimplicialComplex3d-template.html"
    )
    else (
	visTemplate = currentDirectory() | "Visualize/templates/visSimplicialComplex/visSimplicialComplex2d-template.html"
    );
   
    if opts.VisPath =!= null 
    then (
	visTemp = copyTemplate(visTemplate, opts.VisPath); -- Copy the visSimplicialComplex template to a temporary directory.
    	copyJS(opts.VisPath, Warning => opts.Warning); -- Copy the javascript libraries to the temp folder.
      )
    else (
	visTemp = copyTemplate(visTemplate); -- Copy the visSimplicialComplex template to a temporary directory.
    	copyJS(replace(baseFilename visTemp, "", visTemp), Warning => opts.Warning); -- Copy the javascript libraries to the temp folder.
    );
    
    searchReplace("visNodes",vertexString, visTemp); -- Replace visNodes in the visSimplicialComplex html file by the ordered list of vertices.
    searchReplace("visEdges",edgeString, visTemp); -- Replace visEdges in the visSimplicialComplex html file by the list of edges.
    searchReplace("vis2Faces",face2String, visTemp); -- Replace vis2Faces in the visSimplicialComplex html file by the list of faces. 
    
    if dim D>2 then (
	error "3-dimensional simplicial complexes not implemented yet.";
	face3Set = flatten entries faces(3,D);
	face3List = apply(face3Set, f -> apply(new List from factor f, i -> i#0));
       	face3String = toString new Array from apply(#face3List, i -> {"\"v1\": "|toString(position(vertexSet, j -> j == face3List#i#3))|",\"v2\": "|toString(position(vertexSet, j -> j == face3List#i#2))|",\"v3\": "|toString(position(vertexSet, j -> j == face3List#i#1))|",\"v4\": "|toString(position(vertexSet, j -> j == face3List#i#0))});
	searchReplace("vis3Faces",face3String, visTemp); -- Replace vis3Faces in the visSimplicialComplex html file by the list of faces. 
    );
    show new URL from { "file://"|visTemp };
    
    return visTemp;
)


--input: A parameterized surface in RR^3
--output: The surface in the browswer
--
visualize(List) := {VisPath => defaultPath, VisTemplate => currentDirectory() | "Visualize/templates/visSurface/Graphulus-Surface.html", Warning => true} >> opts -> P -> (
    local visTemp; local stringList;
        
    if opts.VisPath =!= null 
    then (
	visTemp = copyTemplate(opts.VisTemplate, opts.VisPath); -- Copy the visSimplicialComplex template to a temporary directory.
    	copyJS(opts.VisPath, Warning => opts.Warning); -- Copy the javascript libraries to the temp folder.
      )
    else (
	visTemp = copyTemplate(opts.VisTemplate); -- Copy the visSimplicialComplex template to a temporary directory.
    	copyJS(replace(baseFilename visTemp, "", visTemp), Warning => opts.Warning); -- Copy the javascript libraries to the temp folder.
    );
    
    stringList = apply(P, i -> "\""|toString i|"\"");

    searchReplace("visP1", stringList#0, visTemp); -- Replace visNodes in the visSimplicialComplex html file by the ordered list of vertices.
    searchReplace("visP2", stringList#1, visTemp); -- Replace visEdges in the visSimplicialComplex html file by the list of edges.
    searchReplace("visP3", stringList#2, visTemp); -- Replace vis2Faces in the visSimplicialComplex html file by the list of faces. 
    
    show new URL from { "file://"|visTemp };
    
    return visTemp;
)

--input: a String of a path to a directory
--output: Copies the js library to path
--
--caveat: Checks to see if files exist. If they do exist, the user
--        must give permission to continue. Continuing will overwrite
--        current files and cannont be undone.
copyJS = method(Options => {Warning => true} )
copyJS(String) := opts -> dst -> (
    local jsdir; local ans; local quest;
    local cssdir; local fontdir; local imagedir;
    
    -- Brett: I removed this so that we can add all three
    -- folders (js, css, and fonts) in the one method.
    -- dst = dst|"js/";    
    
    -- get list of filenames in js/
    jsdir = delete("..",delete(".",
	    readDirectory(currentDirectory()|"Visualize/js/")
	    ));
    
    -- get list of filenames in js/
    cssdir = delete("..",delete(".",
	    readDirectory(currentDirectory()|"Visualize/css/")
	    ));
    
    -- get list of filenames in js/
    fontdir = delete("..",delete(".",
	    readDirectory(currentDirectory()|"Visualize/fonts/")
	    ));
    
    imagedir = delete("..",delete(".",
	    readDirectory(currentDirectory()|"Visualize/images/")
	    ));
    
    if opts.Warning == true
    then(
    -- test to see if files exist in target
    if (scan(jsdir, j -> if fileExists(dst|"js/"|concatenate(dst,j)) then break true) === true) or (scan(cssdir, j -> if fileExists(dst|"css/"|concatenate(dst,j)) then break true) === true) or (scan(fontdir, j -> if fileExists(dst|"fonts/"|concatenate(dst,j)) then break true) === true)
    then (
    	   quest = concatenate(" -- Some files in ",dst," will be overwritten.\n -- This action cannot be undone.");
	   print quest;
	   ans = read "Would you like to continue? (y or n):  ";
	   while (ans != "y" and ans != "n") do (
	       ans = read "Would you like to continue? (y or n):  ";
	       );  
	   if ans == "n" then (
	       error "Process was aborted."
	       );
    	);
    );
    
    copyDirectory(currentDirectory()|"Visualize/js/",dst|"js/");
    copyDirectory(currentDirectory()|"Visualize/css/",dst|"css/");
    copyDirectory(currentDirectory()|"Visualize/fonts/",dst|"fonts/");
    copyDirectory(currentDirectory()|"Visualize/images/",dst|"images/");
    
    return "Created directories at "|dst;
)

-- The idea here is to open a port using a number from the config file. 
-- Then we assign a global varable portTest = true. This way we can test
-- if the port is open or not. Ideally this method would not have a input
-- but would pull the info from the config file. 
-- 
-- The work flow would be, 
-- 0. Load Visualize.m2
-- 1. User opens port :: openPort("$:8000")
--                    :: maybe this is in visualize method?
--                    :: if so how can we tell if a port is open?
--                    :: if a port is open already, then M2
--                    :: goes into debugger. 
-- 2. Define graph :: G = graph(....)
-- 3. Run visualize :: H = visualize G
--                  :: This will open the website and start
--                  :: communication with the server. 
--                  :: When the user ends session, output is 
--                  :: sent back to M2 and assigned to H.
-- 4. End session to export info to browser;
-- 5. closePort() (or restart M2; not sure if this works) to end.
--
-- At first I thought it would probably be better to have 2 and 4 in all 
-- the methods and have a test to see if 2 needs an action (with global 
-- var portTest), and an option that lets the user decide if the port 
-- should stay open. But now I think it would be better if the user actually
-- opens the port. This would give more control to the user. 
--

-- input: String, a port number the user wants to open.
-- output: None, a port is open and a message is displayed.
--
openPort = method()
openPort String := F -> (    
    if (portTest == true)
    then (
	error ("--Port "| toString inOutPort | " is currently open. To use a different port, you must first close this port with closePort().");
	)
    else(
	portTest = true;
	inOutPortNum = F;
	F = "$:"|F;
	inOutPort = openListener F;
	print("--Port " | toString inOutPort | " is now open.");    
	);  
--    return inOutPort;
)


-- Need to make this a method without an input.
closePort = method()
closePort String := F -> (
     portTest = false;
     close inOutPort;
     print("--Port " | toString inOutPort | " is now closing. This could take a few seconds.");
)

openGraphServer = method()
openGraphServer File := S -> (
 
local listener; local verbose; local hexdigits; local hext; 
local hex1; local hex2; local toHex1; local toHex;
local server; local fun; local s;
local ev; local fcn1; local fcn2; local httpHeader;
local testKey; local cmTest; local cmTestOut;

testKey = " ";

listener = S;
--listener = openListener ("$:"|S);
verbose = true; -- make this an option

-- hexdigits = "0123456789ABCDEF";
-- hext = new HashTable from for i from 0 to 15 list hexdigits#i => i;
-- hex1 = c -> if hext#?c then hext#c else 0;
-- hex2 = (c,d) -> 16 * hex1 c + hex1 d;
-- toHex1 = asc -> ("%",hexdigits#(asc>>4),hexdigits#(asc&15));
-- toHex = str -> concatenate apply(ascii str, toHex1);

server = () -> (
    stderr << "-- Visualizing graph. Your browser should open automatically." << endl <<  "-- Click 'End Session' in the browser when finished." << endl;
    while true do (
        wait {listener};
--	viewHelp wait
        g := openInOut listener;				    -- this should be interruptable!
        r := read g;
--	<< "r0 " << r << endl;	
        if verbose then stderr << "request: " << stack lines r << endl;
--	<< "------------------------" << endl;
--        S := read g;
--	<< "S0 " << S << endl;	
--        if verbose then stderr << "request: " << stack lines S << endl;
--	<< "------------------------" << endl;	
--	<< "r1 " << r << endl;
        r = lines r;
	<< "r2 " << r << endl;	
        if #r == 0 then (close g; continue);
	data := last r;
	<< "here is 1 data " << data << endl;
--	<< "r3 " << r << endl;	
--	<< "data=" << data << endl;
        r = first r;
        if match("^GET /fcn1/",r) then (
            s = first select("^GET /fcn1/(.*) ", "\\1", r);
            fun = fcn1;
            )
	  else if match("^GET /fcn2/(.*) ",r) then (
--	       s = first select("^GET /fcn2/(.*) ", "\\1", r);
    	    	s = "I can answer all of your questions!"|"12345678901";
	       fun = fcn2;
	       )
	  else if match("^POST /isCM/(.*) ",r) then (
   	    	s = "isCM stuff."|"12345678901";
	<< "here is 2 data " << data << endl;
               testKey = "isCM";
	       fun = identity;
	       )	   
	  else if match("^GET /end/(.*) ",r) then (
	       close listener;
    	       return;
	       )
	  else if match("^POST /end/(.*) ",r) then (
--	       close listener;
	       print"end tesst";
--	       print data;
--	       value "QQ[x]"
	       R := value data;
    	       return R;
	       )	   
	  else if match("^POST /eval/(.*) ",r) then (
	       s = data; 
	       -- s = first select("^POST /eval/(.*) ", "\\1", r);
	       fun = ev;
	       )
	  else if match("^HEAD /(.*) ",r) then (
	       s = first select("^HEAD /(.*) ", "\\1", r);
	       fun = identity;
	       )
	  else (
	       s = "";
	       fun = identity;
	       );
--	  t := select(".|%[0-9A-F]{2,2}", s); --data);
--	  u := apply(t, x -> if #x == 1 then x else ascii hex2(x#1, x#2));
--	  u = concatenate u;
--	  << u << endl;
	<< "here is 3 data " << data << endl;
	<< "here is 3 value data " << value data << endl;
	<< "here is 3 cmTest value data " << cmTest value data << endl;		
	  if (testKey == "isCM") then ( u := toString( cmTest value data ) );
	  << "here is u " << u << endl;
	  << "here is fun u " << fun u << endl;
	  send := httpHeader fun u; 
	  << send << endl;
      	  g << send << close;
	  );
     );

--ev = x -> "called POST ev on " | x;
--fcn1 = x -> "called fcn1 on " | x;
--fcn2 = x -> "Hey Brett! " | x;
cmTestOut = x -> "Is the graph CM? " | x;

-- Need Ata's code here
cmTest = G -> ( -- fix so this takes any graph with any lable.
    	if (class(G.vertexSet)_0 === ZZ) then (isCM G) else (
	    R := QQ[G.vertexSet];
	    H := G;
	    isCM H
	    )    
    );

-- getJSfile = get "graph-test.html"

httpHeader = ss -> concatenate(
     -- for documentation of http protocol see http://www.w3.org/Protocols/rfc2616/rfc2616.html
     "HTTP/1.1 200 OK
Server: Macaulay2
Access-Control-Allow-Origin: *
Connection: close
Content-Length: ", toString length ss, "
Content-type: text/html; charset=utf-8

", ss);

H := server();

--print"the end";

return H;
)


--------------------------------------------------
-- DOCUMENTATION
--------------------------------------------------


beginDocumentation()
needsPackage "SimpleDoc"
debug SimpleDoc

multidoc ///
  Node
     Key
     	 Visualize
     Headline 
     	 A package to help visualize algebraic objects in the browser using javascript.
     Description
       Text
     	 We use really rediculusly cools things to do really cool things.
     Caveat
     	 Let's see.
  Node
    Key
       visualize
    Headline
       Creates staircase diagram for an ideal
    Usage
       visIdeal I
    Inputs
       I: Ideal
         An ideal in a ring with 2 or 3 variables.
    Outputs
       visTemp: String
         Path to html containg polytope.
    Description
     Text
       We are able to see the interactive staircase diagram. More stuff
       should be here about the convext hull and other stuff.	    
///


end

doc ///
  Key
    (visIdeal, Ideal)
  Headline
    Creates staircase diagram for an ideal
  Usage
    visIdeal I
--  Inputs
--    I:Ideal
--      An ideal in a ring with 2 or 3 variables.
  Outputs
    An interactive html file that is opened in the user's default browser.
  Description
    Text
      We are able to see the interactive staircase diagram. More stuff
      should be here about the convext hull and other stuff. 
///

end


-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------

end

-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------

-----------------------------
-----------------------------
-- Tests
-----------------------------
-----------------------------

-- brett

-- Graphs
restart
loadPackage "Graphs"
loadPackage"Visualize"
G = graph({{x_0,x_1},{x_0,x_3},{x_0,x_4},{x_1,x_3},{x_2,x_3}},Singletons => {x_5})
visualize G
G2 = cocktailParty 10
visualize G2

G1 = barbellGraph 6
visualize G1
G3 = barycenter completeGraph 6
visualize G3

-- Digraphs
restart
loadPackage"Graphs"
loadPackage"Visualize"
G = digraph({ {1,{2,3}} , {2,{3}} , {3,{1}}})
visualize G

D1 = digraph ({{a,{b,c,d,e}}, {b,{d,e}}, {e,{a}}}, EntryMode => "neighbors")
visualize D1
D2 = digraph {{1,{2,3}}, {2,{4,5}}, {3,{5,6}}, {4,{7}}, {5,{7}},{6,{7}},{7,{}}}
visualize D2

-- Posets
restart
loadPackage "Posets"
loadPackage "Visualize"
P = poset {{abc,2}, {1,3}, {3,4}, {2,5}, {4,5}}
visualize P
P2 = poset {{1,2},{2,3},{3,4},{5,6},{6,7},{3,6}}
visualize P2
visualize(P2,FixExtremeElements => true)
R = QQ[x,y,z]
I = ideal(x*y^2,x^2*z,y*z^2)
P = lcmLattice I
visualize P

P = diamondProduct(chain 4, chain 4)
visualize P

-- Simplicial Complexes
restart
loadPackage "SimplicialComplexes"
loadPackage "Visualize"
R = ZZ[a..f]
D = simplicialComplex monomialIdeal(a*b*c,a*b*f,a*c*e,a*d*e,a*d*f,b*c*d,b*d*e,b*e*f,c*d*f,c*e*f)
visualize D

R = ZZ[a..g]
D2 = simplicialComplex {a*b*c,a*b*d,a*e*f,a*g}
visualize D2

R = ZZ[a..f]
L =simplicialComplex {d*e*f, b*e*f, c*d*f, b*c*f, a*d*e, a*b*e, a*c*d, a*b*c}
visualize L

-- Splines
restart
loadPackage "Splines"
loadPackage "QuillenSuslin"
loadPackage "Visualize"
-- 2D Star of Vertex Example
V = {{0,0},{1,0},{1,1},{-1,1},{-2,-1},{0,-1}};
F = {{0,2,1},{0,2,3},{0,3,4},{0,4,5},{0,1,5}};
E = {{0,1},{0,2},{0,3},{0,4},{0,5},{1,2},{2,3},{3,4},{4,5},{1,5}};
M1 = splineModule(V,F,E,1)
syz gens M -- Already gives free generating set.

-- Schlegel Diagram Triangular Prism (nonsimplicial)
V={{-1,-1},{0,1},{1,-1},{-2,-2},{0,2},{2,-2}};
F={{0,1,2},{0,1,3,4},{1,2,4,5},{0,2,3,5}};
E={{0,1},{0,2},{1,2},{0,3},{1,4},{2,5},{3,4},{4,5},{3,5}};
M2 = splineModule(V,F,E,1)
isProjective M2 -- M2 is projective.
syz gens M2 -- Already gives free generating set.

isProjective M
computeFreeBasis M

-- Parameterized Surfaces
restart
loadPackage "Visualize"
R = ZZ[u,v]
S = {u,v,u^2+v^2}
visualize S

S = {"u^2 + sin(v)","u^2 + sin(v)","u^2 + sin(v)"}
visualize S

----------------

-----------------------------
-----------------------------
-- Stable Tests
-----------------------------
-----------------------------

-- branden
restart
loadPackage"Visualize"
(options Visualize).Configuration

--Graphs test
restart
loadPackage"Visualize"
G = graph({{x_0,x_1},{x_0,x_3},{x_0,x_4},{x_1,x_3},{x_2,x_3}},Singletons => {x_5})
visualize G
visGraph G
visGraph( G, VisPath => "/Users/bstone/Desktop/Test/")
y
visGraph( G, VisPath => "/Users/bstone/Desktop/Test/", Warning => false)

H = graph({{x_1, x_0}, {x_3, x_0}, {x_3, x_1}, {x_4, x_0}}, Singletons => {x_2, x_5, 6, cat_sandwich})
visGraph H

L = graph({{1,2}})
visGraph L

-- ideal tests
restart
loadPackage"Visualize"
R = QQ[a,b,c]
I = ideal"a2,ab,b2c,c5,b4"
-- I = ideal"x4,xyz3,yz,xz,z6,y5"
visIdeal I
visIdeal( I, VisPath => "/Users/bstone/Desktop/Test/", Warning => false)
visIdeal( I, VisPath => "/Users/bstone/Desktop/Test/")
y

S = QQ[x,y]
I = ideal"x4,xy3,y5"
visIdeal I
visIdeal( I, VisPath => "/Users/bstone/Desktop/Test/", Warning => false)
visIdeal( I, VisPath => "/Users/bstone/Desktop/Test/")

-- Server Tests

get "!netstat"

restart
loadPackage"Visualize"
outPutPortTest true
outPutInOutPort true
openPort("$:8888")
outPutPortTest true
outPutInOutPort true
closePort("")
outPutPortTest true
outPutInOutPort true
listener = openListener ("$:8888")
close listener


restart
loadPackage"Visualize"
listener = openPort("$:8001")
openServer(listener)
closePort("")


-- workflow testing
restart
loadPackage"Visualize"
openPort "8080"
G = graph({{0,1},{0,3},{0,4},{1,3},{2,3}},Singletons => {5})
H = visualize G
isCM H
K = visualize H
isCM K
closePort("")
restart



-- Bug
visualize( G, VisPath => "/Users/bstone/Desktop/Test/")





H = openServer(listener)
viewHelp wait

HHH = openListener ("$:8888")
close HHH
toString(close HHH) == "$:8888"
code methods close

close listener

loadPackage"EdgeIdeals"
code methods httpHeaders

viewHelp openInOut

viewHelp Graphs
G = graph({{x_0,x_1},{x_0,x_3},{x_0,x_4},{x_1,x_3},{x_2,x_3}},Singletons => {x_5})
cmTest L
G.vertexSet
class(L.vertexSet)_0
L = graph({{1,2}})
visualize L
L.vertexSet
R = QQ[L.vertexSet]

restart
loadPackage"Visualize"
G = graph({{x_0,x_1},{x_0,x_3},{x_0,x_4},{x_1,x_3},{x_2,x_3}},Singletons => {x_5})
G = graph({{1,2}})
if (class(G.vertexSet)_0 === ZZ) then (print"first";isCM G) else (
R = QQ[G.vertexSet];
G = graph({{x_0,x_1},{x_0,x_3},{x_0,x_4},{x_1,x_3},{x_2,x_3}},Singletons => {x_5});
print"here";
isCM G
)    

peek G

-- Random Tests

copyTemplate(currentDirectory() | "Visualize/templates/visGraph/visGraph-template.html", "/Users/bstone/Desktop/Test/")



-----------------------------
-----------------------------
-- Demo
-----------------------------
-----------------------------

restart
uninstallPackage"Graphs"
restart
loadPackage"Graphs"
loadPackage"Visualize"

-- Old Graphs
G = graph({{x_0,x_1},{x_0,x_3},{x_0,x_4},{x_1,x_3},{x_2,x_3}},Singletons => {x_5})
visGraph G
H = graph({{Y,c},{1, 0}, {3, 0}, {3, 1}, {4, 0}}, Singletons => {A, x_5, 6, cat_sandwich})
visGraph H

restart
loadPackage"Graphs"
loadPackage"Visualize"
-- New Graphs
G = graph(toList(0..5),{{0,1},{0,3},{0,4},{1,3},{2,3}},Singletons => {5},EntryMode => "edges")
visGraph G
cycleGraph 9
visGraph oo
wheelGraph 8
visGraph oo
generalizedPetersenGraph(3,4)
visGraph oo
completeGraph(70)
visGraph oo
cocktailParty(70)
visGraph oo


R = QQ[a,b,c]
I = ideal"a2,ab,b2c,c5,b4"
I = ideal"x4,xyz3,yz,xz,z6,y5"
visIdeal I
copyJS "/Users/bstone/Desktop/Test/"
yes
visIdeal( I, VisPath => "/Users/bstone/Desktop/Test/")

S = QQ[x,y]
I = ideal"x4,xy3,y5"
visIdeal I
visIdeal( I, VisPath => "/Users/bstone/Desktop/Test/")


copyJS "/Users/bstone/Desktop/Test/"
yes




restart
uninstallPackage"Graphs"
loadPackage"Graphs"
peek Graphs
loadPackage"Visualize"

-- Creates staircase diagram 
-- 2 variables
S = QQ[x,y]
I = ideal"x4,xy3,y5"
visIdeal I

-- User can choose where to place files
visIdeal( I, VisPath => "/Users/bstone/Desktop/Test/")

-- 3 variables
R = QQ[x,y,z]
J = ideal"x4,xyz3,yz2,xz3,z6,y5"
visIdeal J
visIdeal( J, VisPath => "/Users/bstone/Desktop/Test/")

restart
needsPackage"Graphs"
loadPackage"Visualize"

-- we are also focusing on graphs
G = graph({{x_0,x_1},{x_0,x_3},{x_0,x_4},{x_1,x_3},{x_2,x_3}},Singletons => {x_5})
-- displayGraph A
visGraph G

M = 
A = graph M
visGraph A


--isCM 
loadPackage "Graphs"
G = graph({{x_1,x_2},{x_1,x_3},{x_1,x_4},{x_2,x_5},{x_5,x_3},{x_3,x_2}})
E = apply (edges G, i->toList i)
varList = unique flatten E
E1 = apply(E, i->apply(i,j->position(varList,k -> k===j)))
G1 = graph (E1) 
isCM G1
