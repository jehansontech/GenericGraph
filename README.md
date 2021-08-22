# GenericGraph

GenericGraph is a Swift package providing support for labeled directed multigraphs. 
Nodes and edges hold generic values.

----

__The fundamental type of graph is BaseGraph.__

```
/// create a graph with Strings for node values and Ints for edge values
let graph1 = BaseGraph<String, Int>()

let graph2 = BaseGraph<MyNodeValueType, MyEdgeValueType>()

let graph3 = BaseGraph<Any, Any>()
```

__Nodes are created by the BaseGraph that contains them.__

You can set a node's value when it is created and change it anytime thereafter.

```
var node1 = graph1.addNode("my first node")

var node2 = graph1.addNode() // node2's value is nil at this point
node2.value = "another node"
```

__Edges are created in a similar fashion.__

Note that the edge's source and target nodes are specified via node ID.

```
var edge1 = try graph1.addEdge(node1.id, node2.id, 101)

var edge2 = try graph1.addEdge(node2.id, node1.id) 
edge2.value = 102
```

__Edges are directed.__

```
var source1 = edge1.source // = node1
var target1 = edge1.target // = node2
```

__Nodes keep track of their outbound and inbound edges.__

This permits graphs to be treated as undirected.

```
for outEdge in node1.outEdges {
    // do something 
}

for inEdge in node1.inEdges {
    // do something 
}
```

__Graphs are serialized and deserialized using delegates.__

Encoding and decoding of graph's topological structure is supported for all graphs regardless of node and edge value type. 

Node and edge values are encoded/decoded if and only if they are Encodable/Decodable.

```
let encoder = JSONEncoder()
let data = encoder.encode(graph1.makeEncodingDelegate())

let decoder = JSONDecoder()
let decodedGraph = try decoder.decode(BaseGraph<String, Int>.decodingDelegateType(), from: data).graph
```

__You can create a subgraph of any graph, including another subgraph.__

A subgraph provides a view over nodes in a base graph.

The subgraph's nodes are specified by ID and may be given when the subgraph is created or may be added later.

```
let nodeIDs = Set<NodeID>()
nodeIDs.insert(node1.id)
let subgraph1 = graph1.subgraph(nodeIDs)

subgraph1.addNode(node2.id)

let subgraph2 = subgraph1.subgraph() // subgraph2 is empty at this point
subgraph2.addNode(node1.id)
```

__Navigation over the nodes in a graph is done via Steps.__

A step may be "forward" (following the edge direction) or "backward" (counter to it).

You can iterate over the steps with common originating node.

```
for step in node1.steps(.forward) {
    let edgeValue = step.edgeValue
    let downstreamNeighbor = step.destination
    // do something with the edge value and/or the neighbor
}

for step in node1.steps(.backward) {
    let edgeValue = step.edgeValue
    let upstreamNeighbor = step.destination
    // do something with the edge value and/or the neighbor
}

// iterate over all steps in both directions
for step in node1.steps() {
    let edgeValue = step.edgeValue
    let neighbor = step.destination
    // do something with the edge value and/or the neighbor
}
```

__Graph traversal is accomplished via a Neighborhood.__

Traversal is in depth-limited, breadth-first order starting from any given node.

A Neighborhood uses a given node as its origin and provides a sequence of paths.
The first path in the sequence has the given node as destination, i.e., has length 0.

Each path in the neighborhood starts at the origin node and ends at the next unvisited node in the graph. 
From a path you can get the steps that comprise it and the destination of the path as a whole.

```
for path in node1.neighborhood(.max, .forward) {
    let nextNode = path.destination
    // do something with nextNode
} 
```
