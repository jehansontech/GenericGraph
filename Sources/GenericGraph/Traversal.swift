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
    
    public var edgeNumber: Int {
        return _edge.edgeNumber
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
        hasher.combine(edgeNumber)
        hasher.combine(direction)
    }

    public static func ==<EdgeType: Edge>(lhs: Step<EdgeType>, rhs: Step<EdgeType>) -> Bool {
        return lhs.edgeNumber == rhs.edgeNumber && lhs.direction == rhs.direction
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
    
    public func contains(edgeNumber: Int) -> Bool {
        if let direction = direction {
            switch direction {
            case .forward:
                return _node.outEdges.contains(edgeNumber)
            case .backward:
                return _node.inEdges.contains(edgeNumber)
            }
        }
        else {
            return _node.outEdges.contains(edgeNumber) || _node.inEdges.contains(edgeNumber)
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

    public subscript(_ edgeNumber: Int) -> Step<EdgeType>? {
        if let direction = direction {
            switch direction {
            case .forward:
                return forwardStep(withEdgeNumber: edgeNumber)
            case .backward:
                return backwardStep(withEdgeNumber: edgeNumber)
            }
        }
        else {
            return anyStep(withEdgeNumber: edgeNumber)
        }
    }

    private func forwardStep(withEdgeNumber edgeNumber: Int) -> Step<EdgeType>? {
        if let edge = _node.outEdges[edgeNumber] as? EdgeType {
            return Step<EdgeType>(edge, .forward)
        }
        else {
            return nil
        }
    }

    private func backwardStep(withEdgeNumber edgeNumber: Int) -> Step<EdgeType>? {
        if let edge = _node.inEdges[edgeNumber] as? EdgeType {
            return Step<EdgeType>(edge, .backward)
        }
        else {
            return nil
        }
    }

    private func anyStep(withEdgeNumber edgeNumber: Int) -> Step<EdgeType>? {
        if let edge = _node.outEdges[edgeNumber] as? EdgeType {
            return Step<EdgeType>(edge, .forward)
        }
        else if let edge = _node.inEdges[edgeNumber] as? EdgeType {
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
    case disconnectedPath(destination1: Int, origin2: Int)
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
        if self.destination.nodeNumber != step.origin.nodeNumber {
            throw PathError.disconnectedPath(destination1: self.destination.nodeNumber, origin2: step.origin.nodeNumber)
        }
        var newPath = Path<EdgeType>(_origin, _steps)
        newPath._steps.append(step)
        return newPath
    }
    
    public func append(_ path: Path<EdgeType>) throws -> Path<EdgeType> {
        if self.destination.nodeNumber != path.origin.nodeNumber {
            throw PathError.disconnectedPath(destination1: self.destination.nodeNumber, origin2: path.origin.nodeNumber)
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
    
    private var _visited = Set<Int>()
    
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
                    if !_visited.contains(step.destination.nodeNumber) {
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
        _visited.insert(path.destination.nodeNumber)
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

    public func nearestNeighbors() -> [Int] {
        var nbrs = [Int]()
        self.outEdges.forEach {
            nbrs.append($0.target.nodeNumber)
        }
        self.inEdges.forEach {
            nbrs.append($0.source.nodeNumber)
        }
        return nbrs
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
        
    /// returns nodeNunbers of nodes with inDegree 0
    public func sourceNodes() -> Set<Int> {
        var sources = Set<Int>()
        for node in nodes {
            if node.inDegree == 0 {
                sources.insert(node.nodeNumber)
            }
        }
        return sources
    }

    /// returns nodeNumbers of nodes with outDegree 0
    public func sinkNodes() -> Set<Int> {
        var sinks = Set<Int>()
        for node in nodes {
            if node.outDegree == 0 {
                sinks.insert(node.nodeNumber)
            }
        }
        return sinks
    }

    public func components(_ direction: Direction? = nil) -> [SubGraphType] {
        var subgraphs = [SubGraphType]()

        var visited = Set<Int>()
        for node in self.nodes {
            if visited.contains(node.nodeNumber) {
                continue
            }
            
            let reachable: Set<Int> = reachableFrom(nodeNumber: node.nodeNumber, direction)
            visited.formUnion(reachable)
            subgraphs.append(subgraph(reachable))
        }

        return subgraphs
    }

    public func reachableFrom(nodeNumber: Int, _ direction: Direction? = nil) -> Set<Int> {
        var reached = Set<Int>()
        var frontier = Set<Int>()
        frontier.insert(nodeNumber)
        while (!frontier.isEmpty) {
            let nodeNumber = frontier.removeFirst()
            if !reached.contains(nodeNumber), let node = self.nodes[nodeNumber]  {
                reached.insert(nodeNumber)
                if (direction == nil || direction! == .forward) {
                    for edge in node.inEdges {
                        frontier.insert(edge.source.nodeNumber)
                    }
                }
                if (direction == nil || direction! == .backward) {
                    for edge in node.outEdges {
                        frontier.insert(edge.target.nodeNumber)
                    }
                }
            }
        }
        return reached
    }
}
