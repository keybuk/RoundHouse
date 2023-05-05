//
//  TrainMembersTests.swift
//  RoundHouse
//
//  Created by Scott James Remnant on 2/2/20.
//

import XCTest
import CoreData

@testable import RoundHouse

class TrainMembersTests: XCTestCase {
    var persistenceController: PersistenceController!

    override func setUpWithError() throws {
        persistenceController = PersistenceController(inMemory: true)
    }

    override func tearDownWithError() throws {
        persistenceController = nil
    }

    // MARK: addMember

    /// Check that we can add a member to an empty train.
    func testAddFirstTrainMember() throws {
        let train = Train(context: persistenceController.container.viewContext)
        let member = train.addMember()

        XCTAssertEqual(member.train, train)
        XCTAssertNotNil(train.members)
        XCTAssertTrue(train.members?.contains(member) ?? false)

        XCTAssertEqual(member.index, 0)
    }

    /// Check that we can add a second member to a train.
    func testAddSecondTrainMember() throws {
        let train = Train(context: persistenceController.container.viewContext)

        var members: [TrainMember] = []
        for index in 0...0 {
            let member = TrainMember(context: persistenceController.container.viewContext)
            member.index = Int16(clamping: index)
            train.addToMembers(member)
            members.append(member)
            train.maxMemberIndex = member.index
        }

        let member = train.addMember()

        XCTAssertEqual(member.train, train)
        XCTAssertNotNil(train.members)
        XCTAssertTrue(train.members?.contains(member) ?? false)

        XCTAssertEqual(member.index, 1)

        XCTAssertEqual(members[0].index, 0)
    }

    // MARK: removeMember

    /// Check that we can remove the only member from a train.
    func testRemoveMember() throws {
        let train = Train(context: persistenceController.container.viewContext)

        var members: [TrainMember] = []
        for index in 0...0 {
            let member = TrainMember(context: persistenceController.container.viewContext)
            member.index = Int16(clamping: index)
            train.addToMembers(member)
            members.append(member)
            train.maxMemberIndex = member.index
        }

        train.removeMember(members[0])

        XCTAssertTrue(members[0].isDeleted)
        XCTAssertNil(members[0].train)
        XCTAssertFalse(train.members?.contains(members[0]) ?? false)
    }

    /// Check that we can remove a second member from a train.
    func testRemoveSecondTrainMember() throws {
        let train = Train(context: persistenceController.container.viewContext)

        var members: [TrainMember] = []
        for index in 0...1 {
            let member = TrainMember(context: persistenceController.container.viewContext)
            member.index = Int16(clamping: index)
            train.addToMembers(member)
            members.append(member)
            train.maxMemberIndex = member.index
        }

        train.removeMember(members[1])

        XCTAssertTrue(members[1].isDeleted)
        XCTAssertNil(members[1].train)
        XCTAssertFalse(train.members?.contains(members[1]) ?? false)
        XCTAssertTrue(train.members?.contains(members[0]) ?? false)

        XCTAssertEqual(members[0].index, 0)
    }

    /// Check that we can remove the first of two members from a train, and the second is reindexed.
    func testRemoveFirstTrainMemberOfTwo() throws {
        let train = Train(context: persistenceController.container.viewContext)

        var members: [TrainMember] = []
        for index in 0...1 {
            let member = TrainMember(context: persistenceController.container.viewContext)
            member.index = Int16(clamping: index)
            train.addToMembers(member)
            members.append(member)
            train.maxMemberIndex = member.index
        }

        train.removeMember(members[0])

        XCTAssertTrue(members[0].isDeleted)
        XCTAssertNil(members[0].train)
        XCTAssertFalse(train.members?.contains(members[0]) ?? false)
        XCTAssertTrue(train.members?.contains(members[1]) ?? false)

        XCTAssertEqual(members[1].index, 0)
    }

    /// Check that we can remove the first of three members from a train, and the second and third are reindexed.
    func testRemoveFirstTrainMemberOfThree() throws {
        let train = Train(context: persistenceController.container.viewContext)

        var members: [TrainMember] = []
        for index in 0...2 {
            let member = TrainMember(context: persistenceController.container.viewContext)
            member.index = Int16(clamping: index)
            train.addToMembers(member)
            members.append(member)
            train.maxMemberIndex = member.index
        }

        train.removeMember(members[0])

        XCTAssertTrue(members[0].isDeleted)
        XCTAssertNil(members[0].train)
        XCTAssertFalse(train.members?.contains(members[0]) ?? false)
        XCTAssertTrue(train.members?.contains(members[1]) ?? false)
        XCTAssertTrue(train.members?.contains(members[2]) ?? false)

        XCTAssertEqual(members[1].index, 0)
        XCTAssertEqual(members[2].index, 1)
    }

    /// Check that removing a member makes minimal changes to indexes.
    func testRemoveMinimizesChanges() throws {
        let train = Train(context: persistenceController.container.viewContext)

        var members: [TrainMember] = []
        for index in 0...1 {
            let member = TrainMember(context: persistenceController.container.viewContext)
            member.index = Int16(clamping: index)
            train.addToMembers(member)
            members.append(member)
            train.maxMemberIndex = member.index
        }

        try persistenceController.container.viewContext.save()

        train.removeMember(members[1])

        XCTAssertFalse(members[0].hasChanges)
    }

    // MARK: moveMember

    /// Check that moving a member forwards works.
    func testMoveTrainMemberForwards() throws {
        let train = Train(context: persistenceController.container.viewContext)

        var members: [TrainMember] = []
        for index in 0...5 {
            let member = TrainMember(context: persistenceController.container.viewContext)
            member.index = Int16(clamping: index)
            train.addToMembers(member)
            members.append(member)
            train.maxMemberIndex = member.index
        }

        train.moveMemberAt(4, to: 2)

        XCTAssertEqual(members[0].index, 0)
        XCTAssertEqual(members[1].index, 1)
        XCTAssertEqual(members[2].index, 3)
        XCTAssertEqual(members[3].index, 4)
        XCTAssertEqual(members[4].index, 2)
        XCTAssertEqual(members[5].index, 5)
    }

    /// Check that moving a member backwards works.
    func testMoveTrainMemberBackwards() throws {
        let train = Train(context: persistenceController.container.viewContext)

        var members: [TrainMember] = []
        for index in 0...5 {
            let member = TrainMember(context: persistenceController.container.viewContext)
            member.index = Int16(clamping: index)
            train.addToMembers(member)
            members.append(member)
            train.maxMemberIndex = member.index
        }

        train.moveMemberAt(1, to: 3)

        XCTAssertEqual(members[0].index, 0)
        XCTAssertEqual(members[1].index, 3)
        XCTAssertEqual(members[2].index, 1)
        XCTAssertEqual(members[3].index, 2)
        XCTAssertEqual(members[4].index, 4)
        XCTAssertEqual(members[5].index, 5)
    }

    /// Check that moving a member to its existing location does nothing.
    func testMoveTrainMemberToSameTrainMember() throws {
        let train = Train(context: persistenceController.container.viewContext)

        var members: [TrainMember] = []
        for index in 0...5 {
            let member = TrainMember(context: persistenceController.container.viewContext)
            member.index = Int16(clamping: index)
            train.addToMembers(member)
            members.append(member)
            train.maxMemberIndex = member.index
        }

        train.moveMemberAt(4, to: 4)

        for (index, member) in members.enumerated() {
            XCTAssertEqual(member.index, Int16(clamping: index))
        }
    }

    /// Check that swapping two members forward in the middle of the set works.
    func testMoveTrainMemberSwapForwards() throws {
        let train = Train(context: persistenceController.container.viewContext)

        var members: [TrainMember] = []
        for index in 0...5 {
            let member = TrainMember(context: persistenceController.container.viewContext)
            member.index = Int16(clamping: index)
            train.addToMembers(member)
            members.append(member)
            train.maxMemberIndex = member.index
        }

        train.moveMemberAt(2, to: 3)

        XCTAssertEqual(members[0].index, 0)
        XCTAssertEqual(members[1].index, 1)
        XCTAssertEqual(members[2].index, 3)
        XCTAssertEqual(members[3].index, 2)
        XCTAssertEqual(members[4].index, 4)
        XCTAssertEqual(members[5].index, 5)
    }

    /// Check that swapping two members backward in the middle of the set works.
    func testMoveTrainMemberSwapBackwards() throws {
        let train = Train(context: persistenceController.container.viewContext)

        var members: [TrainMember] = []
        for index in 0...5 {
            let member = TrainMember(context: persistenceController.container.viewContext)
            member.index = Int16(clamping: index)
            train.addToMembers(member)
            members.append(member)
            train.maxMemberIndex = member.index
        }

        train.moveMemberAt(3, to: 2)

        XCTAssertEqual(members[0].index, 0)
        XCTAssertEqual(members[1].index, 1)
        XCTAssertEqual(members[2].index, 3)
        XCTAssertEqual(members[3].index, 2)
        XCTAssertEqual(members[4].index, 4)
        XCTAssertEqual(members[5].index, 5)
    }

    /// Check that we can swap two members forwards.
    func testMoveTrainMemberSwapTwoForwards() throws {
        let train = Train(context: persistenceController.container.viewContext)

        var members: [TrainMember] = []
        for index in 0...1 {
            let member = TrainMember(context: persistenceController.container.viewContext)
            member.index = Int16(clamping: index)
            train.addToMembers(member)
            members.append(member)
            train.maxMemberIndex = member.index
        }

        train.moveMemberAt(1, to: 0)

        XCTAssertEqual(members[0].index, 1)
        XCTAssertEqual(members[1].index, 0)
    }

    /// Check that we can swap two members backwards.
    func testMoveTrainMemberSwapTwoBackwards() throws {
        let train = Train(context: persistenceController.container.viewContext)

        var members: [TrainMember] = []
        for index in 0...1 {
            let member = TrainMember(context: persistenceController.container.viewContext)
            member.index = Int16(clamping: index)
            train.addToMembers(member)
            members.append(member)
            train.maxMemberIndex = member.index
        }

        train.moveMemberAt(0, to: 1)

        XCTAssertEqual(members[0].index, 1)
        XCTAssertEqual(members[1].index, 0)
    }

    /// Check that moving a member makes minimal changes to indexes.
    func testMoveMinimizesChanges() throws {
        let train = Train(context: persistenceController.container.viewContext)

        var members: [TrainMember] = []
        for index in 0...5 {
            let member = TrainMember(context: persistenceController.container.viewContext)
            member.index = Int16(clamping: index)
            train.addToMembers(member)
            members.append(member)
            train.maxMemberIndex = member.index
        }

        try persistenceController.container.viewContext.save()

        train.moveMemberAt(1, to: 3)

        XCTAssertFalse(members[0].hasChanges)
        XCTAssertFalse(members[4].hasChanges)
    }
}
