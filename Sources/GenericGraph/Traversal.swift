
//
//  Traversal.swift
//
//
//  Created by Jim Hanson on 3/8/21.
//

import Foundation


// ====================================================
// MARK:- Step
// ====================================================

///
///
///
public enum Heading: CaseIterable {
    case downstream
    case upstream

    public static func reverse(_ dir: Heading) -> Heading {
        switch dir {
        case .upstream:
            return .downstream
        case .downstream:
            return .upstream
        }
    }
}


///
///
///
public class Step<EdgeType: Edge> {
    
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
    
    public let heading: Heading
    
    public var origin: EdgeType.NodeType {
        switch heading {
        case .upstream:
            return _edge.target
        case .downstream:
            return _edge.source
        }
    }
    
    public var destination: EdgeType.NodeType {
        switch heading {
        case .upstream:
            return _edge.source
        case .downstream:
            return _edge.target
        }
    }
    
    internal let _edge: EdgeType
    
    public init(_ edge: EdgeType, _ heading: Heading) {
        self._edge = edge
        self.heading = heading
    }
}


///
///
///
public struct StepCollection<EdgeType: Edge>: Sequence {
    public typealias Element = Step<EdgeType>
    public typealias Iterator = StepIterator<EdgeType>
    
    public var count: Int {
        return _node.inEdges.count + _node.outEdges.count
    }
    
    public let heading: Heading?
    
    internal weak var _node: EdgeType.NodeType!
    
    public init(_ node: EdgeType.NodeType, _ heading: Heading?) {
        self._node = node
        self.heading = heading
    }
    
    public func contains(_ id: EdgeID) -> Bool {
        if let heading = heading {
            switch heading {
            case .upstream:
                return _node.inEdges.contains(id)
            case .downstream:
                return _node.outEdges.contains(id)
            }
        }
        else {
            return _node.outEdges.contains(id) || _node.inEdges.contains(id)
        }
    }
    
    public func randomElement() -> Step<EdgeType>? {
        if let heading = heading {
            switch heading {
            case .upstream:
                return randomUpstream()
            case .downstream:
                return randomDownstream()
            }
        }
        else {
            return randomAnyHeading()
        }
    }
        
    private func randomAnyHeading() -> Step<EdgeType>? {
        let inDegree = _node.inEdges.count
        let outDegree = _node.outEdges.count
        if inDegree + outDegree == 0 {
            return nil
        }
        else {
            let downstreamBias = Float(outDegree)/Float(outDegree + inDegree)
            if (Float.random(in: 0..<1) < downstreamBias) {
                return randomDownstream()
            }
            else {
                return randomUpstream()
            }
        }
    }

    private func randomUpstream() -> Step<EdgeType>? {
        if let randomInEdge = _node.inEdges.randomElement() as? EdgeType {
            return Step(randomInEdge, .upstream)
        }
        else {
            return nil
        }
    }

    private func randomDownstream() -> Step<EdgeType>? {
        if let randomOutEdge = _node.outEdges.randomElement() as? EdgeType {
            return Step(randomOutEdge, .downstream)
        }
        else {
            return nil
        }
    }
    
    public subscript(_ id: EdgeID) -> Step<EdgeType>? {
        if let heading = heading {
            switch heading {
            case .upstream:
                return getUpstream(id)
            case .downstream:
                return getDownstream(id)
            }
        }
        else {
            return getAnyHeading(id)
        }
    }

    private func getUpstream(_ id: EdgeID) -> Step<EdgeType>? {
        if let edge = _node.inEdges[id] as? EdgeType {
            return Step<EdgeType>(edge, .upstream)
        }
        else {
            return nil
        }
    }

    private func getDownstream(_ id: EdgeID) -> Step<EdgeType>? {
        if let edge = _node.outEdges[id] as? EdgeType {
            return Step<EdgeType>(edge, .downstream)
        }
        else {
            return nil
        }
    }

    private func getAnyHeading(_ id: EdgeID) -> Step<EdgeType>? {
        if let edge = _node.outEdges[id] as? EdgeType {
            return Step<EdgeType>(edge, .downstream)
        }
        else if let edge = _node.inEdges[id] as? EdgeType {
            return Step<EdgeType>(edge, .upstream)
        }
        else {
            return nil
        }
    }

    public func makeIterator() -> StepIterator<EdgeType> {
        return StepIterator<EdgeType>(_node, heading)
    }
}


///
///
///
public struct StepIterator<EdgeType: Edge>: IteratorProtocol {
    public typealias Element = Step<EdgeType>

    internal var _inEdgeIterator: EdgeType.NodeType.InEdgeCollectionType.Iterator? = nil
    
    internal var _outEdgeIterator: EdgeType.NodeType.OutEdgeCollectionType.Iterator? = nil
    
    public init(_ node: EdgeType.NodeType, _ heading: Heading?) {
        if (heading == nil || heading! == .upstream) {
            self._inEdgeIterator = node.inEdges.makeIterator()
        }
        if (heading == nil || heading! == .downstream) {
            self._outEdgeIterator = node.outEdges.makeIterator()
        }
    }
    
    public mutating func next() -> Step<EdgeType>? {
        if let nextInEdge = _inEdgeIterator?.next() as? EdgeType {
            return Step<EdgeType>(nextInEdge, .upstream)
        }
        else if let nextOutEdge = _outEdgeIterator?.next() as? EdgeType {
            return Step<EdgeType>(nextOutEdge, .downstream)
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

    public func extend(_ step: Step<EdgeType>) throws -> Path<EdgeType> {
        if self.destination.id != step.origin.id {
            throw PathError.disconnectedPath(destination1: self.destination.id, origin2: step.origin.id)
        }
        var newPath = Path<EdgeType>(_origin, _steps)
        newPath._steps.append(step)
        return newPath
    }
    
    public func extend(_ path: Path<EdgeType>) throws -> Path<EdgeType> {
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

    public let heading: Heading?
    
    public init(_ origin: NodeType, _ radius: Int, _ heading: Heading?) {
        self.origin = origin
        self.radius = radius
        self.heading = heading
    }

    public func makeIterator() -> NeighborhoodTraverser<NodeType> {
        return NeighborhoodTraverser<NodeType>(origin, radius, heading)
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
        
    private let _radius: Int
    
    private let _heading: Heading?
    
    private var _frontier = Frontier()
    
    private var _visited = Set<NodeID>()
    
    public init(_ origin: NodeType, _ radius: Int, _ heading: Heading?) {
        self._radius = radius
        self._heading = heading
        push(Path<NodeType.EdgeType>(origin as! NodeType.EdgeType.NodeType))
    }
    
    public mutating func next() -> Path<NodeType.EdgeType>? {
        if let path = pop() {
            if path.length < _radius {
                let steps = StepCollection<NodeType.EdgeType>(path.origin, _heading)
                for step in steps {
                    if !_visited.contains(step.destination.id) {
                        try! push(path.extend(step))
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
    
    public func steps(_ heading: Heading? = nil) -> StepCollection<EdgeType> {
        return StepCollection<EdgeType>(self as! EdgeType.NodeType, heading)
    }
    
    public func neighborhood(_ radius: Int, _ heading: Heading? = nil) -> Neighborhood<Self> {
        return Neighborhood<Self>(self, radius, heading)
    }
}


// ========================================
// MARK:- Graph extensions
// ========================================

///
///
///
extension Graph {
        
    public func reachableFrom(nodeID: NodeID, _ heading: Heading? = nil) -> Set<NodeID> {
        var reached = Set<NodeID>()
        var frontier = Set<NodeID>()
        frontier.insert(nodeID)
        while (!frontier.isEmpty) {
            let nodeID = frontier.removeFirst()
            if !reached.contains(nodeID), let node = self.nodes[nodeID]  {
                reached.insert(nodeID)
                if (heading == nil || heading! == .upstream) {
                    for edge in node.inEdges {
                        frontier.insert(edge.source.id)
                    }
                }
                if (heading == nil || heading! == .downstream) {
                    for edge in node.outEdges {
                        frontier.insert(edge.target.id)
                    }
                }
            }
        }
        return reached
    }
    
    public func components(_ heading: Heading? = nil) -> [SubGraphType] {
        var subgraphs = [SubGraphType]()

        var visited = Set<NodeID>()
        for node in self.nodes {
            if visited.contains(node.id) {
                continue
            }
            
            let reachable: Set<NodeID> = reachableFrom(nodeID: node.id, heading)
            visited.formUnion(reachable)
            subgraphs.append(subgraph(reachable))
        }

        return subgraphs
    }
}
