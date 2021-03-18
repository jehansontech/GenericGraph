# GenericGraph

Latest Version: 0.2.0

GenericGraph is a Swift package for labeled multigraphs.
It uses terminology "nodes" and "edges" for graph elements, and "values" for labels.
The node and edge values are generic types.

----

The fundamental type of graph is BaseGraph

```
/// create a graph with Strings for node values and Ints for edge values
let graph1 = BaseGraph<String, Int>()

let graph2 = BaseGraph<MyNodeValueType, MyEdgeValueType>()

let graph3 = BaseGraph<Any, Any>()
```

Nodes are created by the BaseGraph that contains them.
You can set a node's value when it is created and change it anytime thereafter.

```
var node1 = graph1.addNode("my first node")

var node2 = graph1.addNode() // node2's value is nil
node2.value = "another node"
```

Edges work the same way.

```
var edge1 = graph1.addEdge(node1.id, node2.id, 101)

var edge2 = graph1.addEdge(node2.id, node1.id) 
edge2.value = 102
```

Edges are directed.

```
var source1 = edge1.source // same as node1
var target1 = edge1.target // same as node2
```

Nodes keep track of both inbound and outbound edges.
This permits to be treated as undirected.

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
let nodeIDs = Set<NodeID>()
nodeIDs.insert(node1.id)
nodeIDs.insert(node2.id)
let subgraph1 = graph1.subgraph(nodeIDs)

let subgraph2 = subgraph1.subgraph()
subgraph2.addNode(node1.id)
```

