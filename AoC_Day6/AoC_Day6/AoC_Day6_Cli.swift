//
//  AoC_Day6_Cli.swift
//  AoC_Day6_Cli
//
//  Created by Pieter Nijs on 05/12/2024.
//

import Foundation
import ArgumentParser
import RegexBuilder

//@main
struct AoC_Day6_Cli: AsyncParsableCommand {
    @Option(help: "Specify the path to the file containing the data")
    public var path: String
    
    public func run() async throws {
        //Load the data
        let data = try loadData()
        
        
        
        var _guard = getGuard(map: data)!
        var _loopGuard = getGuard(map: data)!
        
        while _guard.move(map: data) {
        }

        print("locations: \(_guard.locationsVisited.count)")
        
        
        var updatedMap = data
        updatedMap[_loopGuard.posRow][_loopGuard.posCol] = "."
        let task = Task {
            await _loopGuard.findLoopingTask(map: updatedMap, path: _guard.locationsVisited)
        }
        
        let result = await task.result
        print("Loop: \(result.get() ?? -1)")
        
        print(_guard.locationsVisited.count)
    }
    

    
    private func getGuard(map: [[Character]]) -> Guard?{
        for (rowIndex, row) in map.enumerated() {
            for (colIndex, _) in row.enumerated() {
                let char = map[rowIndex][colIndex]
                if(char == "^" || char == ">" || char == "v" || char == "<"){
                    return Guard(posRow: rowIndex, posCol: colIndex, direction: Direction(character: char)!)
                }
            }
        }
        return nil
    }
    
    private func getObstructions(map: [[Character]]) -> [(Int, Int)] {
        var result = [(Int, Int)]()
        for (rowIndex, row) in map.enumerated() {
            for (colIndex, _) in row.enumerated() {
                let char = map[rowIndex][colIndex]
                if(char == "#"){
                    result.append((rowIndex, colIndex))
                }
            }
        }
        return result
    }

    private func loadData() throws -> [[Character]] {
        let fileContents = try String(contentsOfFile: path, encoding: .utf8);
        
        let splitData = fileContents.split(separator: "\n")
        
        return splitData.map{ Array($0) }
    }
}

struct Guard {

    var posRow = 0
    var posCol = 0
    var direction = Direction.north
    var locationsVisited = [(Int, Int)]()
    
    init(posRow: Int, posCol: Int, direction: Direction){
        self.posRow = posRow
        self.posCol = posCol
        self.direction = direction
        
        addLocationVisited(location: (posRow, posCol))
    }
    
    private mutating func addLocationVisited(location: (Int, Int)) {
        if(!locationsVisited.contains(where: {$0 == location})) {
            locationsVisited.append(location)
        }
    }
    
    public mutating func move(map: [[Character]]) -> Bool {
        var nextPosition = (posRow, posCol)
        
        switch direction {
        case .north:
            nextPosition = (nextPosition.0 - 1, nextPosition.1)
        case .south:
            nextPosition = (nextPosition.0 + 1, nextPosition.1)
        case .east:
            nextPosition = (nextPosition.0, nextPosition.1 + 1)
        case .west:
            nextPosition = (nextPosition.0, nextPosition.1 - 1)
        }
        
        if(isWithinBounds(map: map, nextPosition: nextPosition)) {
            if(isObstructed(map: map, nextPosition: nextPosition)) {
                rotate()
                return move(map: map)
            }
            else
            {
                posRow = nextPosition.0
                posCol = nextPosition.1
                addLocationVisited(location: (posRow, posCol))
            }
            return true
        }
        //Guard exited
        return false
    }
    
    func getRotatedDirection(direction: Direction) -> Direction {
        switch direction {
        case .north:
            return .east
        case .east:
            return .south
        case .south:
            return .west
        case .west:
            return .north
        }
    }
        
    private mutating func rotate() {
        switch direction {
        case .north:
            self.direction = .east
        case .south:
            self.direction = .west
        case .east:
            self.direction = .south
        case .west:
            self.direction = .north
        }
    }
    
    private func isWithinBounds(map: [[Character]], nextPosition: (Int, Int)) -> Bool{
        if(nextPosition.0 < 0 || nextPosition.0 >= map.first!.count) {
            return false
        }
        if(nextPosition.1 < 0 || nextPosition.1 >= map.count) {
            return false
        }
        
        return true
    }
    
    private func isObstructed(map: [[Character]], nextPosition: (Int, Int)) -> Bool{
        return map[nextPosition.0][nextPosition.1] == "#"
    }
    
    func findLoopingTask(map: [[Character]], path: [(Int, Int)]) async -> Int? {
        try? await withThrowingTaskGroup(of: Bool.self) { group in
            var looping = 0
            for block in path {
                group.addTask {
                    await tryMoveInLoop(
                        map: map,
                        start: (posRow, posCol),
                        theDirection: direction,
                        block: block
                    )
                }
            }
            
            for try await loop in group {
                if loop {
                    looping += 1
                    print("looping = \(looping)")
                } else {
                    print("exit")
                }
            }
            
            return looping
        }
    }
    
    func tryMoveInLoop(map: [[Character]], start: (Int, Int), theDirection: Direction, block: (Int, Int)) async -> Bool {
        var visited = [(Int, Int, Direction)]()
        var currentPos = start
        var currentDir = theDirection
        var nextPosition: (Int, Int)
        
        let rows = map.endIndex
        let cols = map[0].endIndex
        
        while 0..<rows ~= currentPos.0 && 0..<cols ~= currentPos.1 {
            let point =  (currentPos.0, currentPos.1, currentDir)
            
            if visited.contains(where: { $0 == point }) {
                // Looping
                return true
            }
            visited.append(point)
            
            
            switch currentDir {
            case .north:
                nextPosition = (currentPos.0 - 1, currentPos.1)
            case .south:
                nextPosition = (currentPos.0 + 1, currentPos.1)
            case .east:
                nextPosition = (currentPos.0, currentPos.1 + 1)
            case .west:
                nextPosition = (currentPos.0, currentPos.1 - 1)
            }
            guard 0..<rows ~= nextPosition.0 && 0..<cols ~= nextPosition.1 else { return false } // Went over the edge
            
            if map[nextPosition.0][nextPosition.1] != "#" && nextPosition != block {
                // Move forward
                currentPos = nextPosition
            } else {
                currentDir = currentDir.turnRight()
            }
        }
        
        return false
    }
}



enum Direction : Character {
    case north = "^"
    case south = "v"
    case east = ">"
    case west = "<"
    
    init?(character: Character) {
            switch character {
            case "^":
                self = .north
            case "v":
                self = .south
            case ">":
                self = .east
            case "<":
                self = .west
            default:
                return nil
            }
        }
    
    func turnRight() -> Direction {
        switch self {
        case .north: .east
        case .east: .south
        case .south: .west
        case .west: .north
        }
    }
}
