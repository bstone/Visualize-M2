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

code texPoset

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

