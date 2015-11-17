# Query Explorer
## D3.js backed visualization of search queries in a tree fashion to uncover user query formulation strategies and improve search experience. 

## Tech Stack
* D3.js (tree visualization)
* Python & Pandas (for json creation using recursion)

## Input Format (Search Terms)
bluetooth speakers
bluetooth headphones below 100rs
bluetooth supported earphone
.....

## Creating JSON as understood by D3.js tree layout. (Using python recursive implementation to create the json)
{"name":"bags","children":[{"name":"for","children":[{"name":"boys","children":[{"name":"and","children":[{"name":"gents","children":[]}]},{"name":"american","children":[{"name":"tourister","children":[]}]}]},{"name":"men","children":[]},{"name":"mens","children":[]},{"name":"girls","children":[]},{"name":"carrying","children":[{"name":"jym","children":[{"name":"things","children.....
