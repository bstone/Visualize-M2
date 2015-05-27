-- -*- coding: utf-8 -*-

   {*
   Copyright 2011 Gwyneth Whieldon.

   You may redistribute this file under the terms of the GNU General Public
   License as published by the Free Software Foundation, either version 2 of
   the License, or any later version.
   *}
needsPackage"EdgeIdeals"

newPackage("EdgeIdealTex",
     Authors => {
	  {Name => "Gwyneth Whieldon", Email => "whieldon@hood.edu"}
       	  },
     DebuggingMode => true,
     Headline => "Visualization for graphs produced by EdgeIdeals package",
     Version => "0.1"
     )

needsPackage"EdgeIdeals"

export {
     texGraph,
     outputTexGraph,
     "pdfViewer",
     drawGraph
     }

texGraph = method();

texGraph(Graph):=String=>(G)->(
     V:=vertices G;
     idx:=hashTable apply(#V, v-> V_v=> v);
     vertnum:=#V;
     vertpos:=apply(#V, i-> concatenate("(",toString (360*i/(#V)),":",toString 4,")"));
     edgesG := apply(edges G, e-> toList e);
     edgelist := apply(edgesG, r-> concatenate(toString idx#(first r),"/",toString idx#(last r)));
     name:=temporaryFileName();
     fn:=openOut name;
     fn << "\\begin{tikzpicture}" << endl;
     fn << concatenate("[scale=1, vertices/.style={draw, fill=black, circle, inner sep=1pt}]") << endl;
           for v in toList(0..#V-1) do (
     		fn << concatenate("\\node [vertices] (",toString idx#(V_v),") at ",toString vertpos_v,"{};") << endl;
	  	);
     fn << concatenate("\\foreach \\to/\\from in ",toString edgelist) << endl;
     fn << "      \\draw [-] (\\to)--(\\from);" << endl;
     fn << "\\end{tikzpicture}" << endl;
     close fn;
     s:=get name;
     removeFile(name);
     s
     )


outputTexGraph = method();

outputTexGraph(Graph,Thing,Thing,String):=(G,r,s,name)->(
     V:=vertices G;
     idx:=hashTable apply(#V, v-> V_v=> v);
     vertnum:=#V;
     vertpos:=apply(#V, i-> concatenate("(",toString (360*i/(#V)),":",toString s,")"));
     edgesG := apply(edges G, e-> toList e);
     edgelist := apply(edgesG, r-> concatenate(toString idx#(first r),"/",toString idx#(last r)));
     fn:=openOut name;
     fn << "\\documentclass[12pt]{article}"<< endl;
     fn << "\\usepackage{tikz}" << endl;
     fn << "\\begin{document}" << endl;
     fn << "\\begin{tikzpicture}" << endl;
     fn << concatenate("[scale=",toString r, ", vertices/.style={draw, fill=black, circle, inner sep=1pt}]") << endl;
           for v in toList(0..#V-1) do (
     		fn << concatenate("\\node [vertices] (",toString idx#(V_v),") at ",toString vertpos_v,"{};") << endl;
	  	);
     fn << concatenate("\\foreach \\to/\\from in ",toString edgelist) << endl;
     fn << "      \\draw [-] (\\to)--(\\from);" << endl;
     fn << "\\end{tikzpicture}" << endl;
     fn << "\\end{document}" << endl;
     close fn;
     get name
     )

outputTexGraph(Graph,String):=String=>(G,name)->(
     outputTexGraph(G,1,4,name)
     )

drawGraph=method(Options =>{symbol pdfViewer=>"open"})

drawGraph(Graph):=opts -> (G)->(
     if not instance(opts.pdfViewer, String) then error("Option pdfViewer must be a string.");
     name:=temporaryFileName();
     outputTexGraph(G,concatenate(name,".tex"));
     run concatenate("pdflatex -output-directory /tmp ",name, " 1>/dev/null");
     run concatenate(opts.pdfViewer," ", name,".pdf");
     )

end