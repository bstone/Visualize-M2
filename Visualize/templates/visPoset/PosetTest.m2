loadPackage "Posets"

P = poset {{1,2}, {1,3}, {3,4}, {2,5}, {4,5}}
isRanked P
rankFunction P -- Doesn't return anything since P isn't ranked.
rankPoset P
height P
heightFunction P -- Creates a list that assigns levels to elements even if the poset isn't ranked.
coveringRelations P -- Use this to generate the edges in the diagram.
allRelations P
filtration P
P.GroundSet
texPoset P

P = poset {{1,2},{2,3},{3,4},{5,6},{6,7},{3,6}}
nodes = P_*
maxChains = maximalChains P
heightList = heightFunction P
maxChainList = apply(nodes, j -> delete(null,apply(maxChains, L -> (if any(L, i -> i == j) == true then L else null))))
chainLengthList = apply(maxChainList, i -> apply(i, j -> #j))
relHeightList = apply(chainLengthList, i -> max i - 1)
totalHeight = lcm relHeightList
apply(#nodes, i -> (totalHeight / relHeightList#i) * heightList#i)

P = poset {{1,2},{2,3},{3,4},{5,6},{6,7}}
heightFunction P
relHeightFunction P

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
