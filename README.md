Visualize.m2
========

A [Macaulay2](https://github.com/Macaulay2/M2) package to help visualize algebraic objects in the browser using javascript. This package is still in development.

Usage
=====

Assuming [Macaulay2](https://github.com/Macaulay2/M2) is installed on your machine, the following directions will help in the downloading and running of `Visualize.m2`.


First Clone the Repository
------

The easiest way to download the needed files is to clone the entire repository. You will need to install [Git](https://help.github.com/articles/set-up-git) for this.

```
git clone https://github.com/b-stone/Visualize-M2.git
cd Visualize-M2
```

You only need the `Visualize.m2` file and the folder `/Visualize/` but the other stuff is bonus. 


Running in M2
----

First make sure that the file `Visualize.m2` is on the load [path](http://www.math.uiuc.edu/Macaulay2/doc/Macaulay2-1.6/share/doc/Macaulay2/Macaulay2Doc/html/_path.html). To run, execute the following. (This is assuming that `Visualize.m2` is on the path)

```
loadPackage "Visualize"
openPort "8080" -- opens the port for the browser to communicate with M2

-- Define your favorite supported object. 
G = graph({{0,1},{0,3},{0,4},{1,3},{2,3}},Singletons => {5}) 

-- Start visualizing! 
H = visualize G

-- At this point you can edit the graph in the browser (add/delete vertices or edges). 
-- Your new graph is exported to M2 when you click `End Session`.
-- You can now perform more operations to it.
K = spanningForest H
J = visualize K

-- Once you are done, click `End Session` once again in the browser.
-- To finish, either close M2 or run `closePort()`. Either one will
-- close the port you opened earlier.
closePort()
```


At this point your browser should open and you should have an interactive image of the lower boundary of the ideals exponent set (as can bee seen [here](http://math.bard.edu/bstone/visideal/)). As is, the `html` file that is created is saved in the `./Visualize-M2/temp-files/` directory. If you wish to create the file elsewhere, change the path, but make sure the JavaScript files are moved to your target directory.

For visualization of graphs, use the following command. (An example is found [here])(http://math.bard.edu/~bstone/visgraph/))

```
loadPackage"Graphs"
G = graph({{x_0,x_1},{x_0,x_3},{x_0,x_4},{x_1,x_3},{x_2,x_3}},Singletons => {x_5})
visGraph( G, Path => "./temp-files/" )
```


Javascript Packages Used
----

Built on the shoulders of giants, this package utilizes a variety of existing javascript packages

* [D3.js](http://d3js.org/)
* [three.js](http://threejs.org/)
* [Three.OrbitControls](https://gist.github.com/mrflix/8351020)
* [requestAnimationFrame](http://www.paulirish.com/2011/requestanimationframe-for-smart-animating/)
* [THREEx.FullScreen.js](http://learningthreejs.com/data/THREEx/docs/THREEx.FullScreen.html)
* [THREEx.KeyboardState.js](http://learningthreejs.com/data/THREEx/docs/THREEx.KeyboardState.html)
* [THREEx.WindowResize.js](https://github.com/jeromeetienne/threex.windowresize)
* [Underscore.js](http://underscorejs.org/)
* [Detector.js](https://code.google.com/p/webgl-globe/source/browse/globe/Three/Detector.js?r=167cd00544424b26d90f76d56ea22d53aa02bb1a)


