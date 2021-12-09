//
//  LabeledGraph.swift
//  GenericGraph
//
//  Created by Jim Hanson on 12/6/21.
//

import Foundation

public protocol LabeledValue {

    var label: String { get set }
}

extension Graph where EdgeType.ValueType: LabeledValue {

    public func makeEdgeLabels() -> Set<String> {
        var labels = Set<String>()
        for edge in self.edges {
            if let value = edge.value {
                labels.insert(value.label)
            }
        }
        return labels
    }
}
