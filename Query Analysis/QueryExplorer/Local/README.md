# Query Explorer
 D3.js backed visualization of search queries in a tree fashion to uncover user query formulation strategies and improve search experience. Link to the public version of tool <a href="http://bl.ocks.org/prdeepakbabu/raw/c7e490a7550e24182b8a" target="_blank">here</a>.<br />
 URL : http://bl.ocks.org/prdeepakbabu/raw/c7e490a7550e24182b8a/

## Tech Stack
* D3.js (tree visualization)
* Python & Pandas (for json creation using recursion)

## Input Format (Search Terms)
bluetooth speakers<br />
bluetooth headphones below 100rs<br />
bluetooth supported earphone<br />
.....<br />

## [getJSON/makeJSON.py]Creating JSON as understood by D3.js tree layout. (Using python recursive implementation to create the json)
{"name":"bags","children":[{"name":"for","children":[{"name":"boys","children":[{"name":"and","children":[{"name":"gents","children":[]}]},{"name":"american","children":[{"name":"tourister","children":[]}]}]},{"name":"men","children":[]},{"name":"mens","children":[]},{"name":"girls","children":[]},{"name":"carrying","children":[{"name":"jym","children":[{"name":"things","children.....

