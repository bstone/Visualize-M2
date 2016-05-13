needsPackage"Graphs"
export {
    "isRigid"
    }

isRigid = method();
isRigid(Graph) := G->(
    local rigidity;
    local i;
    local j;
    rigidity=true;
    
    if #edges G < 2*#vertices G-3 then rigidity = false
     else (
	 for j from 2 to #vertices G-1 do(
	 for i in subsets(vertices G,j) do(
		if #edges inducedSubgraph(G,i)>2*#i-3  then rigidity = false 
	    );
     );
   );
    return rigidity;
    )

end

G=graph{{1,2},{2,3},{3,4},{1,4},{1,3}}
isRigid G
isRigid completeGraph 4
K4 =completeGraph 4
isRigid K4
H=graph{{1,2},{2,3}}
isRigid H
KB=completeMultipartiteGraph {3,3}
isRigid KB
