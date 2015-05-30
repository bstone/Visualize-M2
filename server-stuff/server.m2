listener = openListener "$:8000"
verbose = true

hexdigits := "0123456789ABCDEF"
hext := new HashTable from for i from 0 to 15 list hexdigits#i => i
hex1 := c -> if hext#?c then hext#c else 0
hex2 = (c,d) -> 16 * hex1 c + hex1 d
toHex1 := asc -> ("%",hexdigits#(asc>>4),hexdigits#(asc&15))
toHex := str -> concatenate apply(ascii str, toHex1)

server = () -> (
    stderr << "listening:" << endl;
    while true do (
        local fun; local s;
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
--	<< "r2 " << r << endl;	
        if #r == 0 then (close g; continue);
	data := last r;
--	<< "r3 " << r << endl;	
--	<< "data=" << data << endl;
        r = first r;
        if match("^GET /fcn1/",r) then (
            s = first select("^GET /fcn1/(.*) ", "\\1", r);
            fun = fcn1;
            )
	  else if match("^GET /fcn2/(.*) ",r) then (
--	       s = first select("^GET /fcn2/(.*) ", "\\1", r);
    	    	s = "Here is some super cool data yo!";
--	       << "this is s" << s << endl;
	       fun = fcn2;
	       )
	  else if match("^GET /end/(.*) ",r) then (
	       close listener;
    	       return;
	       )
--	  else if match("^GET / ",r) then (
--    	       s = getJSfile; 
--	       fun = identity;
--	       )
	  else if match("^GET /js/(.*) ",r) then (
--    	       s = getJSfile; 
	       fun = identity;
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
	  t := select(".|%[0-9A-F]{2,2}", s); --data);
	  u := apply(t, x -> if #x == 1 then x else ascii hex2(x#1, x#2));
	  u = concatenate u;
	  send := httpHeader fun u; 
	  << send << endl;
      	  g << send << close;
	  )
     )

ev = x -> "called POST ev on " | x
fcn1 = x -> "called fcn1 on " | x
fcn2 = x -> "Hey Brett! " | x

-- getJSfile = get "graph-test.html"



httpHeader = s -> concatenate(
     -- for documentation of http protocol see http://www.w3.org/Protocols/rfc2616/rfc2616.html
     "HTTP/1.1 200 OK
Server: Macaulay2
Access-Control-Allow-Origin: *
Connection: close
Content-Length: ", toString length s, "
Content-type: text/html; charset=utf-8

", s) 

end

restart
load"server.m2"
server()
close listener

code methods httpHeaders

viewHelp openInOut
