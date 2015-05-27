needsPackage "EdgeIdeals"

newPackage(
	"GraphsToLatex",
	Version => "0.1",
	Date => "June 6, 2011",
	Authors => {
	     	{Name => "Gwyneth Whieldon", Email => "whieldon@math.cornell.edu", HomePage => "http://www.math.cornell.edu/~whieldon/Main_Details.html"}
	},
	Headline => "Creates latexed picture output of graphs",
	Configuration => { },
	DebuggingMode => true
)

needsPackage "EdgeIdeals"


export {
     texGraph,
     outTexGraph,
     drawGraph
};

texGraph=method()

--Inputs:  Graph G, scaling factor for labels r, radius of graph s.

texGraph(Graph,Thing,Thing):=(G,r,s)->(
vertindex:=apply(vertices G, i-> index i);
vertnum:=toList(0..(# vertices G)-1);
vertpos:=apply(vertnum, i-> concatenate("(",toString (360*i/(# vertices G)),":",toString s,")"));
edgepairs:=apply(edges G, i-> {index first i,index last i});
edgelist:=toString apply(edgepairs, i-> concatenate(toString first i,"/",toString last i));
print "\\begin{tikzpicture}";
print concatenate("[scale=",toString r,", vertices/.style={draw, fill=black, circle, inner sep=1pt}]");
for v in vertnum do (
print concatenate("\\node [vertices] (",toString vertindex_v,") at ",toString vertpos_v,"{};");
	  );
print concatenate("\\foreach \\to/\\from in ",edgelist);
print "\\draw [-] (\\to)--(\\from);";
print "\\end{tikzpicture}";
)

outTexGraph=method()

outTexGraph(Graph,Thing,Thing,String):=(G,r,s,name)->(
vertindex:=apply(vertices G, i-> index i);
vertnum:=toList(0..(# vertices G)-1);
vertpos:=apply(vertnum, i-> concatenate("(",toString (360*i/(# vertices G)),":",toString s,")"));
edgepairs:=apply(edges G, i-> {index first i,index last i});
edgelist:=toString apply(edgepairs, i-> concatenate(toString first i,"/",toString last i));
fn:=openOut name;
fn << "\\documentclass[12pt]{article}"<< endl;
fn << "\\usepackage{tikz}" << endl;
fn << "\\begin{document}" << endl;
fn << "\\begin{tikzpicture}" << endl;
fn << concatenate("[scale=",toString r,", vertices/.style={draw, fill=black, circle, inner sep=1pt}]")<< endl;
for v in vertnum do (
fn << concatenate("\\node [vertices] (",toString vertindex_v,") at ",toString vertpos_v,"{};") << endl;
	  );
fn << concatenate("\\foreach \\to/\\from in ",edgelist) << endl;
fn << "\\draw [-] (\\to)--(\\from);" << endl;
fn << "\\end{tikzpicture}" << endl;
fn << "\\end{document}" << endl;
close fn
)

drawGraph=(G)->(
     name:=temporaryFileName();
     outTexGraph(G,1,4,concatenate(name,".tex"));
     run concatenate("pdflatex ",name);
     run concatenate("open ", replace("/tmp/","",name),".pdf");
     )


beginDocumentation()


--*******************************************************
-- DOCUMENTATION FOR PACKAGE
--*******************************************************

doc ///
	Key
		GraphsToLatex
       	Headline
		A package for drawing graphs, posets and Betti tables in M2 via Tikz.
	Description
		Text
			{@EM "GraphToLatex"@ is a package that produces latex code for graphs using the tikz graphics package for Latex.}
     	SeeAlso
	        texGraph
		outTexGraph
		drawGraph
///


doc///
        Key
	        texGraph
	Headline
	        prints tikz code to display a graph in a latex file
        Description
              Text
	        	This produces LaTeX code for a graph with the assumption that the TikZ package is called in the header file.
              Example
	        	R=QQ[x_1..x_7]
	     	        G=antiCycle R
	                texGraph G		  
     SeeAlso
              outTexGraph
	      drawGraph

///

end;
