# GenericGraph

Latest Version: 0.2.0

GenericGraph is a Swift package for labeled multigraphs.
It uses terminology "nodes" and "edges" for graph elements, and "values" for labels.
The node and edge values are generic types.

----

The fundamental type of graph is BaseGraph

```
let graph1 = BaseGraph<String, Int>()
let graph2 = BaseGraph<MyNodeValueType, MyEdgeValueType>()
let graph3 = BaseGraph<Any, Any>()
```

Nodes are created by the BaseGraph that contains them.
You can set a node's value when it is created and change it anytime thereafter.

```
/// create a new node in graph1
var node1 = graph1.addNode("my first node")

/// node2's value is initially nil
var node2 = graph1.addNode()
node2.value = "another node"
```

Edges work the same way.
Note that edges are directed.

```
/// create a new edge from node1 to node2
var edge1 = graph1.addEdge(node1.id, node2.id, 101)

/// edge2's value is initially nil
var edge2 = graph1.addEdge(node2.id, node1.id)
edge2.value = 102
```

Nodes keep track of both inbound and outbound edges, allowing graphs to be treated as undirected.

```
for edge in node1.inEdges {
    // do something 
}

for edge in node1.outEdges {
    // do something 
}
```

Graphs are serialized and deserialized using delegates.
Node and edge values are encoded/decoded if and only if they are Encodable/Decodable.

```
let encoder = JSONEncoder()
let data = encoder.encode(graph1.makeEncodingDelegate())

let decoder = JSONDecoder()
let decodedGraph = try decoder.decode(BaseGraph<String, Int>.decodingDelegateType(), from: data).graph
```

You can create a subgraph of any graph.
The subgraph's nodes may be provided at creation time, or may be added later.

```
/// create a subgraph of graph1 containing both its nodes
let subgraph1Nodes = Set<NodeID>()
subgraph1Nodes.insert(node1.id)
subgraph1Nodes.insert(node2.id)
let subgraph1 = graph1.subgraph(subgraph1Nodes)

/// create an empty subgraph of subgraph1, then add a node to it
let subgraph2 = subgraph1.subgraph()
subgraph2.addNode(node1.id)
```

