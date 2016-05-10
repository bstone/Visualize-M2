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
--     "toArray", -- Don't need to export?
--     "getCurrPath", -- Don't need to export?
--     "copyTemplate",-- Don't need to export?
--     "replaceInFile",-- Don't need to export?
--     "heightFunction",
--     "relHeightFunction",
--     "visOutput", -- do we even use this?

     
    -- Server
     "openPort",
     "closePort"

}


------------------------------------------------------------
-- Global Variables
------------------------------------------------------------

defaultPath = (options Visualize).Configuration#"DefaultPath"
basePath = currentFileDirectory

-- (options Visualize).Configuration

portTest = false -- Used to test if ports are open or closed.
inOutPort = null -- Actual file the listener is opened to.
inOutPortNum = null -- The port number that is being opened. This is passed to the browser.


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
{*
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
*}

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
searchReplace = method() --Options => {VisPath => currentDirectory()}) -- do we use VisPath?
searchReplace(String,String,String) := (oldString,newString,visSrc) -> (
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

visualize(Ideal) := {VisPath => defaultPath, Warning => true, VisTemplate => basePath |"Visualize/templates/visIdeal/visIdeal"} >> opts -> J -> (
    local R; local arrayList; local arrayString; local numVar; local visTemp;
    local varList;
        
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
visualize(Graph) := {VisPath => defaultPath, VisTemplate => basePath | "Visualize/templates/visGraph/visGraph-template.html", Warning => true, Verbose => false} >> opts -> G -> (
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
    
    browserOutput = openGraphServer(inOutPort, Verbose => opts.Verbose);
        
    return browserOutput;
)

visualize(Digraph) := {Verbose => false, VisPath => defaultPath, VisTemplate => basePath |"Visualize/templates/visDigraph/visDigraph-template.html", Warning => true} >> opts -> G -> (
    local A; local arrayString; local vertexString; local visTemp;
    local keyPosition; local vertexSet; local browserOutput;
    
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
    searchReplace("visPort",inOutPortNum, visTemp); -- Replace visPort in the visGraph html file by the user port number.

    show new URL from { "file://"|visTemp };
    
    browserOutput = openGraphServer(inOutPort, Verbose => opts.Verbose);
        
    return browserOutput;
)


--input: A poset
--output: The poset in the browswer
--
visualize(Poset) := {FixExtremeElements => false, VisPath => defaultPath, VisTemplate => basePath | "Visualize/templates/visPoset/visPoset-template.html", Warning => true} >> opts -> P -> (
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
visualize(SimplicialComplex) := {VisPath => defaultPath, VisTemplate => basePath | "Visualize/templates/visSimplicialComplex/visSimplicialComplex2d-template.html", Warning => true} >> opts -> D -> (
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
 	visTemplate = basePath | "Visualize/templates/visSimplicialComplex/visSimplicialComplex3d-template.html"
    )
    else (
	visTemplate = basePath | "Visualize/templates/visSimplicialComplex/visSimplicialComplex2d-template.html"
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
visualize(List) := {VisPath => defaultPath, VisTemplate => basePath | "Visualize/templates/visSurface/Graphulus-Surface.html", Warning => true} >> opts -> P -> (
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
--output: Copies the needed files and libraries to path
--
--caveat: Checks to see if files exist. If they do exist, the user
--        must give permission to continue. Continuing will overwrite
--        current files and cannont be undone.
copyJS = method(Options => {Warning => true})
copyJS(String) := opts -> dst -> (
    local jsdir; local ans; local quest;
    local cssdir; local fontdir; local imagedir;
    local JS; local CSS; local FONT; local IMAGE;
        
    JS = "";
    CSS = "";
    FONT = "";
    IMAGE = "";
            
    -- get list of filenames in js/
    jsdir = delete("..",delete(".",
	    readDirectory(basePath|"Visualize/js/")
	    ));

    -- get list of filenames in css/
    cssdir = delete("..",delete(".",
	    readDirectory(basePath|"Visualize/css/")
	    ));

    -- get list of filenames in fonts/
    fontdir = delete("..",delete(".",
	    readDirectory(basePath|"Visualize/fonts/")
	    ));

    -- get list of filenames in images/    
    imagedir = delete("..",delete(".",
	    readDirectory(basePath|"Visualize/images/")
	    ));

    if opts.Warning == true
    then (
	scan(jsdir, j -> if fileExists(concatenate(dst,"js/",j)) then (JS = "js/"; break)); -- Tests existence of js files
	scan(cssdir, j -> if fileExists(concatenate(dst,"css/",j)) then (CSS = "css/"; break)); -- Tests existence of css files
	scan(fontdir, j -> if fileExists(concatenate(dst,"fonts/",j)) then (FONT ="fonts/"; break)); -- Tests existence of font files
	scan(imagedir, j -> if fileExists(concatenate(dst,"images/",j)) then (IMAGE ="images/"; break)); -- Tests existence of images files
	
	-- test to see if files exist in target
	if (
	    JS == "js/"
	    or CSS == "css/"
	    or FONT == "fonts/"
	    or IMAGE == "images/"
	    )
	then (
		quest = concatenate(
		    " -- Note: You can surpress this message with the 'Warning => false' option.\n",
		    " -- The following folders on the path ",dst," have some files that will be overwritten: ",
		    JS, ", ",
		    CSS, ", ",
		    FONT, ", ",
		    IMAGE,". \n",
		    " -- This action cannot be undone. \n"
		    );
		print quest;
		ans = read " Would you like to continue? (y or n):  ";
		while (ans != "y" and ans != "n") do (
		    ans = read " Would you like to continue? (y or n):  ";
		    );
		if ans == "n" then (
		    error "Process was aborted.";
		    );
		);
	);
    
    copyDirectory(basePath|"Visualize/js/",dst|"js/");
    copyDirectory(basePath|"Visualize/css/",dst|"css/");
    copyDirectory(basePath|"Visualize/fonts/",dst|"fonts/");
    copyDirectory(basePath|"Visualize/images/",dst|"images/");
    
    return "Created directories at "|dst;
)


-- The server workflow is as follows.
-- 0. Load Visualize.m2
-- 1. User opens port :: openPort("8000")
--                    :: If any port is open an error occurs.
--                    :: Sometimes the error is thrown when no port
--                    :: is open. This usually occurs right after a
--                    :: port has been closed. It takes a bit of time
--                    :: for M2 to realize no port is open. 
--                    :: Maybe this is an issue with the garbage collector?
-- 2. Define graph :: G = graph(....)
-- 3. Run visualize :: H = visualize G
--                  :: This will open the website and start
--                  :: communication with the server. 
--                  :: When the user ends session, output is 
--                  :: sent back to M2 and assigned to H.
-- 4. End session to export info to browser;
-- 5. Keep working and visualizeing objects;
-- 6. When finished, user closes port :: closePort() (or restart M2).



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

--getCurrPath = method()
--installMethod(getCurrPath, () -> (local currPath; currPath = get "!pwd"; substring(currPath,0,(length currPath)-1)|"/"))

-- Need to make this a method without an input.
closePort = method()
installMethod(closePort, () -> (
     portTest = false;
     close inOutPort;
     print("--Port " | toString inOutPort | " is now closing. This could take a few seconds.");
     )
)


-- input: File, an in-out port for communicating with the browser
-- output: whatever the browser sends
--
openGraphServer = method(Options =>{Verbose => true})
openGraphServer File := opts -> S -> (
 
local server; local fun; local listener; 
local httpHeader; local testKey; 
local u;


testKey = " ";
listener = S;

server = () -> (
    stderr << "-- Visualizing graph. Your browser should open automatically." << endl <<  "-- Click 'End Session' in the browser when finished." << endl;
    while true do (
        wait {listener};
        g := openInOut listener; -- this should be interruptable! (Dan's Comment, not sure what it means)
        r := read g;
        if opts.Verbose then stderr << "request: " << stack lines r << endl << endl;
        r = lines r;
	
        if #r == 0 then (close g; continue);
	
	data := last r;
        r = first r;
	
	-- Begin handling requests from browser
	---------------------------------------
	
	-- hasEulerianTrail
	if match("^POST /hasEulerianTrail/(.*) ",r) then (
	    testKey = "hasEulerianTrail";
	    fun = identity;
	    u = toString( hasEulerianTrail indexLabelGraph value data );
	)	
	
	-- hasOddHole
	else if match("^POST /hasOddHole/(.*) ",r) then (
	    testKey = "hasOddHole";
	    fun = identity;
	    u = toString( hasOddHole indexLabelGraph value data );
	)	
	
	-- isCM
	else if match("^POST /isCM/(.*) ",r) then (
	    testKey = "isCM";
	    fun = identity;
	    u = toString( isCM indexLabelGraph value data );
	)	

	-- isBipartite
	else if match("^POST /isBipartite/(.*) ",r) then (
	    testKey = "isBipartite";
	    fun = identity;
	    u = toString( isBipartite indexLabelGraph value data );
	)	

	-- isChordal
	else if match("^POST /isChordal/(.*) ",r) then (
	    testKey = "isChordal";
	    fun = identity;
	    u = toString( isChordal indexLabelGraph value data );
	)	
	
	-- isConnected
	else if match("^POST /isConnected/(.*) ",r) then (
	    testKey = "isConnected";
	    fun = identity;
	    print"isConnected else if in M2";
	    u = toString( isConnected indexLabelGraph value data );
	)	

    	-- isCyclic
	else if match("^POST /isCyclic/(.*) ",r) then (
	    testKey = "isCyclic";
	    fun = identity;
	    u = toString( isCyclic indexLabelGraph value data );
	)		

    	-- isEulerian
	else if match("^POST /isEulerian/(.*) ",r) then (
	    testKey = "isEulerian";
	    fun = identity;
	    u = toString( isEulerian indexLabelGraph value data );
	)		

    	-- isForest
	else if match("^POST /isForest/(.*) ",r) then (
	    testKey = "isForest";
	    fun = identity;
	    u = toString( isForest indexLabelGraph value data );
	)		

    	-- isPerfect
	else if match("^POST /isPerfect/(.*) ",r) then (
	    testKey = "isPerfect";
	    fun = identity;
	    u = toString( isPerfect indexLabelGraph value data );
	)		

    	-- isRegular
	else if match("^POST /isRegular/(.*) ",r) then (
	    testKey = "isRegular";
	    fun = identity;
	    u = toString( isRegular indexLabelGraph value data );
	)		

    	-- isSimple
	else if match("^POST /isSimple/(.*) ",r) then (
	    testKey = "isSimple";
	    fun = identity;
	    u = toString( isSimple indexLabelGraph value data );
	)		

    	-- isTree
	else if match("^POST /isTree/(.*) ",r) then (
	    testKey = "isTree";
	    fun = identity;
	    u = toString( isTree indexLabelGraph value data );
	)
    
        -- chromaticNumber
	else if match("^POST /chromaticNumber/(.*) ",r) then (
	    testKey = "chromaticNumber";
	    fun = identity;
	    u = toString( chromaticNumber indexLabelGraph value data );
	)			
	
	-- independenceNumber
	else if match("^POST /independenceNumber/(.*) ",r) then (
	    testKey = "independenceNumber";
	    fun = identity;
	    u = toString( independenceNumber indexLabelGraph value data );
	)			
	
	-- cliqueNumber
	else if match("^POST /cliqueNumber/(.*) ",r) then (
	    testKey = "cliqueNumber";
	    fun = identity;
	    u = toString( cliqueNumber indexLabelGraph value data );
	)			
	
	-- degeneracy
	else if match("^POST /degeneracy/(.*) ",r) then (
	    testKey = "degeneracy";
	    fun = identity;
	    u = toString( degeneracy indexLabelGraph value data );
	)			
	
	-- density
	else if match("^POST /density/(.*) ",r) then (
	    testKey = "density";
	    fun = identity;
	    u = toString( density indexLabelGraph value data );
	)			
	
	-- diameter
	else if match("^POST /diameter/(.*) ",r) then (
	    testKey = "diameter";
	    fun = identity;
	    u = toString( diameter indexLabelGraph value data );
	)			
	
	-- edgeConnectivity
	else if match("^POST /edgeConnectivity/(.*) ",r) then (
	    testKey = "edgeConnectivity";
	    fun = identity;
	    u = toString( edgeConnectivity indexLabelGraph value data );
	)			
	
	-- minimalDegree
	else if match("^POST /minimalDegree/(.*) ",r) then (
	    testKey = "minimalDegree";
	    fun = identity;
	    u = toString( minimalDegree indexLabelGraph value data );
	)			
	
	-- numberOfComponents
	else if match("^POST /numberOfComponents/(.*) ",r) then (
	    testKey = "numberOfComponents";
	    fun = identity;
	    u = toString( numberOfComponents indexLabelGraph value data );
	)			
	
	-- numberOfTriangles
	else if match("^POST /numberOfTriangles/(.*) ",r) then (
	    testKey = "numberOfTriangles";
	    fun = identity;
	    u = toString( numberOfTriangles indexLabelGraph value data );
	)			
	
	-- radius
	else if match("^POST /radius/(.*) ",r) then (
	    testKey = "radius";
	    fun = identity;
	    if not isConnected indexLabelGraph value data then u = "Not connected." else u = toString( radius indexLabelGraph value data );
	)			
	
	-- vertexConnectivity
	else if match("^POST /vertexConnectivity/(.*) ",r) then (
	    testKey = "";
	    fun = identity;
	    u = toString( vertexConnectivity indexLabelGraph value data );
	)			
	
	-- vertexCoverNumber
	else if match("^POST /vertexCoverNumber/(.*) ",r) then (
	    testKey = "vertexCoverNumber";
	    fun = identity;
	    u = toString( vertexCoverNumber indexLabelGraph value data );
	)			
	 
	-- End Session   
	else if match("^POST /end/(.*) ",r) then (
	    R := value data;
	    return R;
	)
	
	-- Error to catch typos and bad requests
	else (
	    error ("There was no match to the request: "|r);
	    );	   
	
	-- Determines the output based on the testKey
--	if (testKey == "isCM") then ( u = toString( cmTest value data ) );
--	if (testKey == "isBipartite") then ( u = toString( isBipartite value data ) );	
--	if (testKey == "isChordal") then ( u = toString( isChordal value data ) );	
--	if (testKey == "isConnected") then ( u = toString( isConnected value data ) );	
--	if (testKey == "isCyclic") then ( u = toString( isCyclic value data ) );			
--	if (testKey == "isEulerian") then ( u = toString( isEulerian value data ) );			
--	if (testKey == "isForest") then ( u = toString( isForest value data ) );			
--	if (testKey == "isPerfect") then ( u = toString( isPerfect value data ) );			
--	if (testKey == "isRegular") then ( u = toString( isRegular value data ) );			
--	if (testKey == "isSimple") then ( u = toString( isSimple value data ) );			
--	if (testKey == "isTree") then ( u = toString( isTree value data ) );			
	
	send := httpHeader fun u; 
	
	if opts.Verbose then stderr << "response: " << stack lines send << endl << endl;	  
	
	g << send << close;
	);
    );

httpHeader = ss -> concatenate(
     -- for documentation of http protocol see http://www.w3.org/Protocols/rfc2616/rfc2616.html
     -- This header is not up to the standards, but I am not sure it matters for local transmissions.
     -- I believe you are supposed to have a different header for different requests.
     "HTTP/1.1 200 OK
Server: Macaulay2
Access-Control-Allow-Origin: *
Connection: close
Content-Length: ", toString length ss, "
Content-type: text/html; charset=utf-8

", ss);

H := server();

return H;
)


--------------------------------------------------
-- DOCUMENTATION
--------------------------------------------------

beginDocumentation()

document {
     Key => Visualize,
     Headline => "A package to help visualize algebraic objects in the browser using javascript",
     
     PARA "Using JavaScript, this package creates interactive visualizations of a variety of objects 
     in a modern browser. While viewing the object, the user has the ability to manipulate and 
     run various tests. Once finished, the user can export the finished result back to the 
     Macaulay2 session.",
     
--     Caveat => {"When in the browser, and editing is on, you can move the nodes of a graph by pressing SHIFT and moving them."}
     
     }


document {
     Key => visualize,
     Headline => "creates an interactive object in a modern browser",
     
     PARA "Given an open port, this method will create an interactive visualization of a variety of objects 
     in a modern browser. While viewing the object, the user has the ability to manipulate the 
     object, and run various tests. Once finished, the user can export the finished result back to the 
     Macaulay2 session.",
               
     PARA "The workflow for this package is as follows:",
     
     UL{ "1. Load or install the package."},
     
     UL{{"2. Open a port with ", TT "openPort", " method for communication with the browser. 
	     It is up to the user to choose port and also to close the port when finished."}},
     
     UL{"3. Define an object you wish to visualize. For example, a graph, poset, digraph, etc."},
     
     UL{{"4. Run ", TT "visualize", " method. This will open the browser with an interactive
	     interface. This session is in communication with Macaulay2 through the open port above.
	     At this point you can edit and manipulate the created object."}},
     
     UL{"5. End the session and export work back to Macaulay2."},
     
     UL{"6. Continue manipulating the object and repeat steps 3-5 as necessary."},
     
     UL{{"7. When finished, close the port with ", TT "closePort()", " or restart Macaulay2."}},
     
     }



document {
     Key => (visualize,Graph),
     Headline => "visualizes a graph in a modern browser",
     Usage => " H = visualize G",
     Inputs => {
	 "G" => Graph => " a graph",
--	 Verbose => Boolean => " prints server communication in the M2 buffer",
--	 VisPath => String => " a path where the visualization will be created and saved",
--	 VisTemplate => String => " a path to a user created/modified template",
--	 Warning => Boolean => " gives a warning if files will be overwritten when using VisPath"
	 },
	 
     
     PARA "Using JavaScript, this method creates interactive visualizations of a variety of objects 
     in a modern browser. While viewing the object, the user has the ability to manipulate and 
     run various tests. Once finished, the user can export the finished result back to the 
     Macaulay2 session.",
     
     
     PARA "The workflow for this package is as follows. Once we have loaded the package, we first 
     open a port for Macaulay2 to communicate with the browser. Once a port is established, define 
     an object to visualize.",

     EXAMPLE {
	 "openPort \"8080\"",
	 "G = graph({{0,1},{1,4},{2,4},{0,3},{0,4},{1,3},{2,3}},Singletons => {5})"
	 },
     
     PARA {"At this point we wish to visualize ", TT "G", ". To do this simply execute ", TT "H = visualize G", " and 
     browser will open with the following interactive image."},
     
     -- make sure this image matches the graph in the example. 
     PARA IMG ("src" => replace("PKG","Visualize",Layout#1#"package")|"images/Visualize/Visualize_Graph1.png", "alt" => "Original graph entered into M2"), 
     
     PARA {"In the browser, you can edit the graph (add/delete vertices or edges) by clicking ", TT "Enable Editing", ". 
     Once finished, your new object can be exported to Macaulay2 when you click ", TT "End Session",". For example,
     if we remove edges ", TT "{0,1}", " and ", TT "{1,3}", "we visually have this."},


     PARA {"Once again we can visualize be executing ", TT "J = visualize K", ". At this point your browser will
     open with a new graph, the spanning forest of ", TT "H", "."},
     
     -- make sure this image matches the graph in the example. 
     PARA IMG ("src" => get "!pwd| tr -d '\n'"|"/Visualize/images/Visualize/Visualize_Graph3.png", "alt" => "Spanning Forest"),      
     
     PARA {"Once you are finished, click ", TT "End Session", ". Once again in the browser. To end your session, either close 
     Macaulay2 or run ", TT "closePort()", ". Either one will close the port you opened earlier."},
     
     EXAMPLE {
	 "closePort()"
	 },
     
--     Caveat => {"When in the browser, and editing is on, you can move the nodes of a graph by pressing SHIFT and moving them."}
     
     }
 
 document {
     Key => VisPath,
     Headline => "an option to define a path save visualizations",
     
     PARA "Using JavaScript, this package creates interactive visualizations of a variety of objects 
     in a modern browser. While viewing the object, the user has the ability to manipulate and 
     run various tests. Once finished, the user can export the finished result back to the 
     Macaulay2 session."
     }

document {
     Key => VisTemplate,
     Headline => "an option to define a path to a user defined template",
     
     PARA "Using JavaScript, this package creates interactive visualizations of a variety of objects 
     in a modern browser. While viewing the object, the user has the ability to manipulate and 
     run various tests. Once finished, the user can export the finished result back to the 
     Macaulay2 session."
     }
 
document {
     Key => Warning,
     Headline => "an option to squelch warnings",
     
     PARA "Using JavaScript, this package creates interactive visualizations of a variety of objects 
     in a modern browser. While viewing the object, the user has the ability to manipulate and 
     run various tests. Once finished, the user can export the finished result back to the 
     Macaulay2 session."
     }

document {
     Key => FixExtremeElements,
     Headline => "an option that brett created",
     
     PARA "Using JavaScript, this package creates interactive visualizations of a variety of objects 
     in a modern browser. While viewing the object, the user has the ability to manipulate and 
     run various tests. Once finished, the user can export the finished result back to the 
     Macaulay2 session."
     }



document {
     Key => [(visualize,Poset),FixExtremeElements],
     Headline => "an option that brett created",
     
     PARA "Using JavaScript, this package creates interactive visualizations of a variety of objects 
     in a modern browser. While viewing the object, the user has the ability to manipulate and 
     run various tests. Once finished, the user can export the finished result back to the 
     Macaulay2 session."
     }
 
document {
     Key => [(visualize,Digraph),VisPath],
     Headline => "an option that brett created",
     
     PARA "Using JavaScript, this package creates interactive visualizations of a variety of objects 
     in a modern browser. While viewing the object, the user has the ability to manipulate and 
     run various tests. Once finished, the user can export the finished result back to the 
     Macaulay2 session."
     }

document {
     Key => [(visualize,Graph),VisPath],
     Headline => "an option that brett created",
     
     PARA "Using JavaScript, this package creates interactive visualizations of a variety of objects 
     in a modern browser. While viewing the object, the user has the ability to manipulate and 
     run various tests. Once finished, the user can export the finished result back to the 
     Macaulay2 session."
     }

document {
     Key => [(visualize,Ideal),VisPath],
     Headline => "an option that brett created",
     
     PARA "Using JavaScript, this package creates interactive visualizations of a variety of objects 
     in a modern browser. While viewing the object, the user has the ability to manipulate and 
     run various tests. Once finished, the user can export the finished result back to the 
     Macaulay2 session."
     }

document {
     Key => [(visualize,Poset),VisPath],
     Headline => "an option that brett created",
     
     PARA "Using JavaScript, this package creates interactive visualizations of a variety of objects 
     in a modern browser. While viewing the object, the user has the ability to manipulate and 
     run various tests. Once finished, the user can export the finished result back to the 
     Macaulay2 session."
     }

document {
     Key => [(visualize,SimplicialComplex),VisPath],
     Headline => "an option that brett created",
     
     PARA "Using JavaScript, this package creates interactive visualizations of a variety of objects 
     in a modern browser. While viewing the object, the user has the ability to manipulate and 
     run various tests. Once finished, the user can export the finished result back to the 
     Macaulay2 session."
     }

document {
     Key => [(visualize,Digraph),VisTemplate],
     Headline => "an option that brett created",
     
     PARA "Using JavaScript, this package creates interactive visualizations of a variety of objects 
     in a modern browser. While viewing the object, the user has the ability to manipulate and 
     run various tests. Once finished, the user can export the finished result back to the 
     Macaulay2 session."
     }

document {
     Key => [(visualize,Graph),VisTemplate],
     Headline => "an option that brett created",
     
     PARA "Using JavaScript, this package creates interactive visualizations of a variety of objects 
     in a modern browser. While viewing the object, the user has the ability to manipulate and 
     run various tests. Once finished, the user can export the finished result back to the 
     Macaulay2 session."
     }

document {
     Key => [(visualize,Ideal),VisTemplate],
     Headline => "an option that brett created",
     
     PARA "Using JavaScript, this package creates interactive visualizations of a variety of objects 
     in a modern browser. While viewing the object, the user has the ability to manipulate and 
     run various tests. Once finished, the user can export the finished result back to the 
     Macaulay2 session."
     }

document {
     Key => [(visualize,Poset),VisTemplate],
     Headline => "an option that brett created",
     
     PARA "Using JavaScript, this package creates interactive visualizations of a variety of objects 
     in a modern browser. While viewing the object, the user has the ability to manipulate and 
     run various tests. Once finished, the user can export the finished result back to the 
     Macaulay2 session."
     }

document {
     Key => [(visualize,SimplicialComplex),VisTemplate],
     Headline => "an option that brett created",
     
     PARA "Using JavaScript, this package creates interactive visualizations of a variety of objects 
     in a modern browser. While viewing the object, the user has the ability to manipulate and 
     run various tests. Once finished, the user can export the finished result back to the 
     Macaulay2 session."
     }

document {
     Key => [(visualize,Digraph),Warning],
     Headline => "an option that brett created",
     
     PARA "Using JavaScript, this package creates interactive visualizations of a variety of objects 
     in a modern browser. While viewing the object, the user has the ability to manipulate and 
     run various tests. Once finished, the user can export the finished result back to the 
     Macaulay2 session."
     }

document {
     Key => [(visualize,Graph),Warning],
     Headline => "an option that brett created",
     
     PARA "Using JavaScript, this package creates interactive visualizations of a variety of objects 
     in a modern browser. While viewing the object, the user has the ability to manipulate and 
     run various tests. Once finished, the user can export the finished result back to the 
     Macaulay2 session."
     }
 
document {
     Key => [(visualize,Ideal),Warning],
     Headline => "an option that brett created",
     
     PARA "Using JavaScript, this package creates interactive visualizations of a variety of objects 
     in a modern browser. While viewing the object, the user has the ability to manipulate and 
     run various tests. Once finished, the user can export the finished result back to the 
     Macaulay2 session."
     }

document {
     Key => [(visualize,Poset),Warning],
     Headline => "an option that brett created",
     
     PARA "Using JavaScript, this package creates interactive visualizations of a variety of objects 
     in a modern browser. While viewing the object, the user has the ability to manipulate and 
     run various tests. Once finished, the user can export the finished result back to the 
     Macaulay2 session."
     }

document {
     Key => [(visualize,SimplicialComplex),Warning],
     Headline => "an option that brett created",
     
     PARA "Using JavaScript, this package creates interactive visualizations of a variety of objects 
     in a modern browser. While viewing the object, the user has the ability to manipulate and 
     run various tests. Once finished, the user can export the finished result back to the 
     Macaulay2 session."
     }



document {
     Key => (visualize,Ideal),
     Headline => "A package to help visualize algebraic objects in the browser using javascript",
     
     PARA "Using JavaScript, this package creates interactive visualizations of a variety of objects 
     in a modern browser. While viewing the object, the user has the ability to manipulate and 
     run various tests. Once finished, the user can export the finished result back to the 
     Macaulay2 session."
     }

document {
     Key => (visualize,Digraph),
     Headline => "A package to help visualize algebraic objects in the browser using javascript",
     
     PARA "Using JavaScript, this package creates interactive visualizations of a variety of objects 
     in a modern browser. While viewing the object, the user has the ability to manipulate and 
     run various tests. Once finished, the user can export the finished result back to the 
     Macaulay2 session."
     }

document {
     Key => (visualize,Poset),
     Headline => "A package to help visualize algebraic objects in the browser using javascript",
     
     PARA "Using JavaScript, this package creates interactive visualizations of a variety of objects 
     in a modern browser. While viewing the object, the user has the ability to manipulate and 
     run various tests. Once finished, the user can export the finished result back to the 
     Macaulay2 session."
     }

document {
     Key => (visualize,SimplicialComplex),
     Headline => "A package to help visualize algebraic objects in the browser using javascript",
     
     PARA "Using JavaScript, this package creates interactive visualizations of a variety of objects 
     in a modern browser. While viewing the object, the user has the ability to manipulate and 
     run various tests. Once finished, the user can export the finished result back to the 
     Macaulay2 session."
     }

document {
     Key => {openPort,(openPort,String)},
     Headline => "opens a port",
     
     PARA "Using JavaScript, this package creates interactive visualizations of a variety of objects 
     in a modern browser. While viewing the object, the user has the ability to manipulate and 
     run various tests. Once finished, the user can export the finished result back to the 
     Macaulay2 session."
     }

document {
     Key => (closePort),
     Headline => "closes and open port",
     
     PARA "Using JavaScript, this package creates interactive visualizations of a variety of objects 
     in a modern browser. While viewing the object, the user has the ability to manipulate and 
     run various tests. Once finished, the user can export the finished result back to the 
     Macaulay2 session."
     }


-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------

end

-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------

restart
run "pwd"
uninstallPackage"Visualize"
restart
installPackage"Visualize"
viewHelp Visualize

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
-- (options Visualize).Configuration

--Graphs test
restart

loadPackage"Visualize"
openPort "8081"
G = graph({{0,1},{0,3},{0,4},{1,3},{2,3}},Singletons => {5})

installPackage"Visualize"
viewHelp Visualize

restart
run "pwd"
path = path|{"~/GitHub/Visualize-M2/"}
loadPackage"Visualize"
openPort "8081"
G = graph({{0,1},{1,4},{2,4},{0,3},{0,4},{1,3},{2,3}},Singletons => {5})

H = visualize (G, Verbose => true)
K = spanningForest H
J = visualize K
closePort()

G = graph({{x_0,x_1},{x_0,x_3},{x_0,x_4},{x_1,x_3},{x_2,x_3}},Singletons => {x_5})
H = visualize ( G, VisPath => "/Users/bstone/Desktop/Test/",Verbose => true)
y
K = spanningForest H
J = visualize K

G = graph({{x_1, x_0}, {x_3, x_0}, {x_3, x_1}, {x_4, x_0}}, Singletons => {x_2, x_5, 6, cat_sandwich})
H = visualize (G, Verbose => true)
K = spanningForest H
J = visualize K

-- Digraphs
restart
loadPackage"Visualize"
openPort "8081"
G = digraph({ {1,{2,3}} , {2,{3}} , {3,{1}}})
visualize G

D1 = digraph ({{a,{b,c,d,e}}, {b,{d,e}}, {e,{a}}}, EntryMode => "neighbors")
visualize D1
D2 = digraph {{1,{2,3}}, {2,{4,5}}, {3,{5,6}}, {4,{7}}, {5,{7}},{6,{7}},{7,{}}}
visualize D2


closePort()

 visGraph

-- visGraph( G, VisPath => "/Users/bstone/Desktop/Test/", Warning => false)
viewHelp Graphs

-- ideal tests
restart
loadPackage"Visualize"
openPort "8081"
R = QQ[a,b,c]
I = ideal"a2,ab,b2c,c5,b4"
-- I = ideal"x4,xyz3,yz,xz,z6,y5"
visualize I
visualize( I, VisPath => "/Users/bstone/Desktop/Test/", Warning => false)
visualize( I, VisPath => "/Users/bstone/Desktop/Test/")
y

S = QQ[x,y]
I = ideal"x4,xy3,y5"
visualize I
visualize( I, VisPath => "/Users/bstone/Desktop/Test/", Warning => false)
visualize( I, VisPath => "/Users/bstone/Desktop/Test/")

closePort()


-- Bug
visualize( G, VisPath => "/Users/bstone/Desktop/Test/")


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

