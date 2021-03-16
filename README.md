# GenericGraph

GenericGraph is a Swift package for labeled directed multigraphs in which graph elements may contain user-defined values.

```
let graph1 = Graph<String, Int>()
let graph2 = Graph<MyNodeValueType, MyEdgeValueType>()
let graph3 = Graph<Any, Any>()
```

A node's value may be supplied when the node is created and can be changed anytime. Edge values work the same way.

```
var graph = Graph<String, Int>()

var node1 = graph.addNode(value: "my first node")

var node2 = graph.addNode()
node2.value = "another node"

var edge1 = graph.addEdge(node1, node2, value: 1)

var edge2 = graph.addEdge(node2, node1)
edge2.value = 2
```

Nodes keep track of both inbound and outbound edges, allowing graphs to be treated as undirected.

```
for edge in node.inEdges {
    // do something using edge's data and origin
}

for edge in node.outEdges {
    // do the same thing using edge's data and destination
}
```
