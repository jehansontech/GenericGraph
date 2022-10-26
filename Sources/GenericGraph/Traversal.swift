//
//  Traversal.swift
//  GenericGraph

import Foundation


// ====================================================
// MARK:- Step
// ====================================================

///
///
///
public enum Direction: String, CaseIterable, Codable, Sendable {
    case forward
    case backward

    public static func reverse(_ dir: Direction) -> Direction {
        switch dir {
        case .forward:
            return .backward
        case .backward:
            return .forward
        }
    }
}


///
///
///
public class Step<EdgeType: Edge>: Hashable, Equatable {
    
    public var edgeID: EdgeID {
        return _edge.id
    }
    
    public var edgeValue: EdgeType.ValueType? {
        get {
            return _edge.value
        }
        set(newValue) {
            _edge.value = newValue
        }
    }
    
    public let direction: Direction
    
    public var origin: EdgeType.NodeType {
        switch direction {
        case .forward:
            return _edge.source
        case .backward:
            return _edge.target
        }
    }
    
    public var destination: EdgeType.NodeType {
        switch direction {
        case .forward:
            return _edge.target
        case .backward:
            return _edge.source
        }
    }
    
    internal let _edge: EdgeType
    
    public init(_ edge: EdgeType, _ direction: Direction) {
        self._edge = edge
        self.direction = direction
    }

    public func reverse() -> Step<EdgeType> {
        return Step(self._edge, Direction.reverse(self.direction))
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(edgeID)
        hasher.combine(direction)
    }

    public static func ==<EdgeType: Edge>(lhs: Step<EdgeType>, rhs: Step<EdgeType>) -> Bool {
        return lhs.edgeID == rhs.edgeID && lhs.direction == rhs.direction
    }
}


///
///
///
public struct StepCollection<EdgeType: Edge>: Sequence {
    public typealias Element = Step<EdgeType>
    public typealias Iterator = StepIterator<EdgeType>
    
    public var count: Int {
        return _node.outEdges.count + _node.inEdges.count
    }
    
    public let direction: Direction?
    
    internal weak var _node: EdgeType.NodeType!
    
    public init(_ node: EdgeType.NodeType, _ direction: Direction?) {
        self._node = node
        self.direction = direction
    }
    
    public func contains(_ id: EdgeID) -> Bool {
        if let direction = direction {
            switch direction {
            case .forward:
                return _node.outEdges.contains(id)
            case .backward:
                return _node.inEdges.contains(id)
            }
        }
        else {
            return _node.outEdges.contains(id) || _node.inEdges.contains(id)
        }
    }
    
    public func randomElement() -> Step<EdgeType>? {
        if let direction = direction {
            switch direction {
            case .forward:
                return randomForwardStep()
            case .backward:
                return randomBackwardStep()
            }
        }
        else {
            return randomAnyDirection()
        }
    }
        
    private func randomForwardStep() -> Step<EdgeType>? {
        if let edge = _node.outEdges.randomElement() as? EdgeType {
            return Step(edge, .forward)
        }
        else {
            return nil
        }
    }
    
    private func randomBackwardStep() -> Step<EdgeType>? {
        if let edge = _node.inEdges.randomElement() as? EdgeType {
            return Step(edge, .backward)
        }
        else {
            return nil
        }
    }

    private func randomAnyDirection() -> Step<EdgeType>? {
        let inDegree = _node.inEdges.count
        let outDegree = _node.outEdges.count
        if inDegree + outDegree == 0 {
            return nil
        }
        else {
            let forwardBias = Float(outDegree)/Float(outDegree + inDegree)
            if (Float.random(in: 0..<1) < forwardBias) {
                return randomForwardStep()
            }
            else {
                return randomBackwardStep()
            }
        }
    }

    public subscript(_ id: EdgeID) -> Step<EdgeType>? {
        if let direction = direction {
            switch direction {
            case .forward:
                return forwardStep(withID: id)
            case .backward:
                return backwardStep(withID: id)
            }
        }
        else {
            return anyStep(withID: id)
        }
    }

    private func forwardStep(withID id: EdgeID) -> Step<EdgeType>? {
        if let edge = _node.outEdges[id] as? EdgeType {
            return Step<EdgeType>(edge, .forward)
        }
        else {
            return nil
        }
    }

    private func backwardStep(withID id: EdgeID) -> Step<EdgeType>? {
        if let edge = _node.inEdges[id] as? EdgeType {
            return Step<EdgeType>(edge, .backward)
        }
        else {
            return nil
        }
    }

    private func anyStep(withID id: EdgeID) -> Step<EdgeType>? {
        if let edge = _node.outEdges[id] as? EdgeType {
            return Step<EdgeType>(edge, .forward)
        }
        else if let edge = _node.inEdges[id] as? EdgeType {
            return Step<EdgeType>(edge, .backward)
        }
        else {
            return nil
        }
    }

    public func makeIterator() -> StepIterator<EdgeType> {
        return StepIterator<EdgeType>(_node, direction)
    }
}


///
///
///
public struct StepIterator<EdgeType: Edge>: IteratorProtocol {
    public typealias Element = Step<EdgeType>

    internal var _outEdgeIterator: EdgeType.NodeType.OutEdgeCollectionType.Iterator? = nil
    
    internal var _inEdgeIterator: EdgeType.NodeType.InEdgeCollectionType.Iterator? = nil

    public init(_ node: EdgeType.NodeType, _ direction: Direction?) {
        if (direction == nil || direction! == .forward) {
            self._outEdgeIterator = node.outEdges.makeIterator()
        }
        if (direction == nil || direction! == .backward) {
            self._inEdgeIterator = node.inEdges.makeIterator()
        }
    }
    
    public mutating func next() -> Step<EdgeType>? {

        if let nextOutEdge = _outEdgeIterator?.next() as? EdgeType {
            return Step<EdgeType>(nextOutEdge, .forward)
        }
        else if let nextInEdge = _inEdgeIterator?.next() as? EdgeType {
            return Step<EdgeType>(nextInEdge, .backward)
        }
        else {
            return nil
        }
    }
}


// ====================================================
// MARK:- Path
// ====================================================


public enum PathError: Error {
    case disconnectedPath(destination1: NodeID, origin2: NodeID)
}


///
///
///
public struct Path<EdgeType: Edge> {
    
    public var length: Int {
        return _steps.count
    }
    
    public var origin: EdgeType.NodeType {
        return _origin
    }
    
    public var destination: EdgeType.NodeType {
        if let lastStep = _steps.last {
            return lastStep.destination
        }
        else {
            return _origin
        }
    }

    public var steps: [Step<EdgeType>] {
        return _steps
    }
    
    internal weak var _origin: EdgeType.NodeType!
    
    internal var _steps: [Step<EdgeType>]
    
    public init(_ origin: EdgeType.NodeType) {
        self._origin = origin
        self._steps = [Step<EdgeType>]()
    }
    
    internal init(_ origin: EdgeType.NodeType, _ steps: [Step<EdgeType>]) {
        self._origin = origin
        self._steps = steps
    }

    public func append(_ step: Step<EdgeType>) throws -> Path<EdgeType> {
        if self.destination.id != step.origin.id {
            throw PathError.disconnectedPath(destination1: self.destination.id, origin2: step.origin.id)
        }
        var newPath = Path<EdgeType>(_origin, _steps)
        newPath._steps.append(step)
        return newPath
    }
    
    public func append(_ path: Path<EdgeType>) throws -> Path<EdgeType> {
        if self.destination.id != path.origin.id {
            throw PathError.disconnectedPath(destination1: self.destination.id, origin2: path.origin.id)
        }
        var newPath = Path<EdgeType>(_origin, _steps)
        for step in path.steps {
            newPath._steps.append(step)
        }
        return newPath
    }
}


// ====================================================
// MARK:- Neighborhood
// ====================================================


///
///
///
public struct Neighborhood<NodeType: Node>: Sequence {
    public typealias Iterator = NeighborhoodTraverser<NodeType>
    
    public let origin: NodeType
    
    public let radius: Int

    public let direction: Direction?
    
    public init(_ origin: NodeType, _ radius: Int, _ direction: Direction?) {
        self.origin = origin
        self.radius = radius
        self.direction = direction
    }

    public func makeIterator() -> NeighborhoodTraverser<NodeType> {
        return NeighborhoodTraverser<NodeType>(origin, radius, direction)
    }
}


///
/// Performs depth-limited breadth-first traversal starting at a given node
///
public struct NeighborhoodTraverser<NodeType: Node>: IteratorProtocol {
    public typealias Element = Path<NodeType.EdgeType>
    
    class FrontierElement {
        
        let path: Path<NodeType.EdgeType>
        
        var next: FrontierElement? = nil
        
        public init(_ path: Path<NodeType.EdgeType>) {
            self.path = path
        }
    }
    
    struct Frontier {
        
        var first: FrontierElement? = nil
        
        var last: FrontierElement? = nil
        
        mutating func addLast(_ path: Path<NodeType.EdgeType>) {
            if let oldLast = last {
                self.last = FrontierElement(path)
                oldLast.next = self.last
            }
            else {
                self.first = FrontierElement(path)
                self.last = self.first
            }
        }
        
        mutating func removeFirst() -> Path<NodeType.EdgeType>? {
            if let oldFirst = first {
                self.first = oldFirst.next
                if self.first == nil {
                    self.last = nil
                }
                return oldFirst.path
            }
            else {
                return nil
            }
        }
    }
        
    public let radius: Int
    
    public let direction: Direction?
    
    private var _frontier = Frontier()
    
    private var _visited = Set<NodeID>()
    
    public init(_ origin: NodeType, _ radius: Int, _ direction: Direction?) {
        self.radius = radius
        self.direction = direction
        push(Path<NodeType.EdgeType>(origin as! NodeType.EdgeType.NodeType))
    }
    
    public mutating func next() -> Path<NodeType.EdgeType>? {
        if let path = pop() {
            if path.length < radius {
                let steps = StepCollection<NodeType.EdgeType>(path.destination, direction)
                for step in steps {
                    if !_visited.contains(step.destination.id) {
                        try! push(path.append(step))
                    }
                }
            }
            return path
        }
        else {
            return nil
        }
    }
    
    private mutating func push(_ path: Path<NodeType.EdgeType>) {
        _frontier.addLast(path)
        _visited.insert(path.destination.id)
    }
    
    private mutating func pop() -> Path<NodeType.EdgeType>? {
        return _frontier.removeFirst()
    }
}

// ========================================
// MARK:- Node extensions
// ========================================

///
///
///
extension Node {
    
    public func steps(_ direction: Direction? = nil) -> StepCollection<EdgeType> {
        return StepCollection<EdgeType>(self as! EdgeType.NodeType, direction)
    }
    
    public func neighborhood(_ radius: Int, _ direction: Direction? = nil) -> Neighborhood<Self> {
        return Neighborhood<Self>(self, radius, direction)
    }
}


// ========================================
// MARK:- Graph extensions
// ========================================

///
///
///
extension Graph {
        
    /// returns IDs of nodes with inDegree 0
    public func sourceNodes() -> Set<NodeID> {
        var sources = Set<NodeID>()
        for node in nodes {
            if node.inDegree == 0 {
                sources.insert(node.id)
            }
        }
        return sources
    }

    /// returns IDs of nodes with outDegree 0
    public func sinkNodes() -> Set<NodeID> {
        var sinks = Set<NodeID>()
        for node in nodes {
            if node.outDegree == 0 {
                sinks.insert(node.id)
            }
        }
        return sinks
    }

    public func components(_ direction: Direction? = nil) -> [SubGraphType] {
        var subgraphs = [SubGraphType]()

        var visited = Set<NodeID>()
        for node in self.nodes {
            if visited.contains(node.id) {
                continue
            }
            
            let reachable: Set<NodeID> = reachableFrom(nodeID: node.id, direction)
            visited.formUnion(reachable)
            subgraphs.append(subgraph(reachable))
        }

        return subgraphs
    }

    public func reachableFrom(nodeID: NodeID, _ direction: Direction? = nil) -> Set<NodeID> {
        var reached = Set<NodeID>()
        var frontier = Set<NodeID>()
        frontier.insert(nodeID)
        while (!frontier.isEmpty) {
            let nodeID = frontier.removeFirst()
            if !reached.contains(nodeID), let node = self.nodes[nodeID]  {
                reached.insert(nodeID)
                if (direction == nil || direction! == .forward) {
                    for edge in node.inEdges {
                        frontier.insert(edge.source.id)
                    }
                }
                if (direction == nil || direction! == .backward) {
                    for edge in node.outEdges {
                        frontier.insert(edge.target.id)
                    }
                }
            }
        }
        return reached
    }
}
