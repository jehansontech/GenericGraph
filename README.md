# GenericGraph

Latest Version: 0.2.0

GenericGraph is a Swift package for labeled directed multigraphs. It uses terminology "nodes" and "edges" for graph elements, and "values" for labels.


The fundamental object is BaseGraph. You specify the types of node and edge values using generics:

```
let graph1 = BaseGraph<String, Int>()
let graph2 = BaseGraph<MyNodeValueType, MyEdgeValueType>()
let graph3 = BaseGraph<Any, Any>()
```

Subgraphs are supported:
```
let subgraph1 = graph1.subgraph()
let subgraph2 = subgraph1.subgrah()
```

A node's value may be supplied when the node is created and can be changed anytime thereafter:

```
var node1 = graph1.addNode("my first node")

var node2 = graph1.addNode()
node2.value = "another node"
```

Edge values work the same way.

```
var edge1 = graph1.addEdge(node1.id, node2.id, 101)

var edge2 = graph1.addEdge(node2.id, node1.id)
edge2.value = 102
```

Nodes keep track of both inbound and outbound edges, allowing graphs to be treated as undirected:

```
for edge in node1.inEdges {
    // do something 
}

for edge in node1.outEdges {
    // do something 
}
```

Graphs are serialized and deserialized using delegates. Node and edge values are encoded/decoded if and only if they are Encodable/Decodable:

```
let encoder = JSONEncoder()
let data = encoder.encode(graph1.makeEncodingDelegate())

let decoder = JSONDecoder()
let graph1_copy = try decoder.decode(BaseGraph<String, Int>.decodingDelegateType(), from: data).graph
```

