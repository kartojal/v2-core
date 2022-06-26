// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.13;

import { ISablierV2 } from "@sablier/v2-core/interfaces/ISablierV2.sol";
import { ISablierV2Linear } from "@sablier/v2-core/interfaces/ISablierV2Linear.sol";

import { SablierV2LinearUnitTest } from "../SablierV2LinearUnitTest.t.sol";

contract SablierV2Linear__UnitTest__WithdrawAll is SablierV2LinearUnitTest {
    uint256[] internal defaultAmounts;
    uint256[] internal defaultStreamIds;

    /// @dev A setup function invoked before each test case.
    function setUp() public override {
        super.setUp();

        // Define the default amounts, since most tests need them.
        defaultAmounts.push(WITHDRAW_AMOUNT_DAI);
        defaultAmounts.push(WITHDRAW_AMOUNT_DAI);

        // Create the default streams, since most tests need them.
        defaultStreamIds.push(createDefaultDaiStream());
        defaultStreamIds.push(createDefaultDaiStream());

        // Make the recipient the `msg.sender` in this test suite.
        changePrank(users.recipient);
    }

    /// @dev When the array counts are not equal, it should revert.
    function testCannotWithdrawAll__WithdrawAllArraysNotEqual() external {
        uint256[] memory streamIds = new uint256[](2);
        uint256[] memory amounts = new uint256[](1);
        vm.expectRevert(
            abi.encodeWithSelector(
                ISablierV2.SablierV2__WithdrawAllArraysNotEqual.selector,
                streamIds.length,
                amounts.length
            )
        );
        sablierV2Linear.withdrawAll(streamIds, amounts);
    }

    /// @dev When the stream ids array points only to non existent streams, it should do nothing.
    function testCannotWithdrawAll__OnlyNonExistentStreams() external {
        uint256 nonStreamId = 1729;
        uint256[] memory nonStreamIds = createDynamicArray(nonStreamId);
        uint256[] memory amounts = createDynamicArray(WITHDRAW_AMOUNT_DAI);
        sablierV2Linear.withdrawAll(nonStreamIds, amounts);
    }

    /// @dev When the stream ids array points to some non existent streams, it should make the withdrawals for
    /// the existing streams.
    function testCannotWithdrawAll__SomeNonExistentStreams() external {
        uint256 nonStreamId = 1729;
        uint256[] memory streamIds = createDynamicArray(nonStreamId, defaultStreamIds[0]);

        // Warp to 2,600 seconds after the start time (26% of the default stream duration).
        vm.warp(daiStream.startTime + TIME_OFFSET);

        // Run the test.
        sablierV2Linear.withdrawAll(streamIds, defaultAmounts);
        ISablierV2Linear.Stream memory queriedStream = sablierV2Linear.getStream(defaultStreamIds[0]);
        uint256 actualWithdrawnAmount = queriedStream.withdrawnAmount;
        uint256 expectedWithdrawnAmount = WITHDRAW_AMOUNT_DAI;
        assertEq(actualWithdrawnAmount, expectedWithdrawnAmount);
    }

    /// @dev When the caller is neither the sender nor the recipient of any stream, it should revert.
    function testCannotWithdrawAll__CallerUnauthorized__AllStreams() external {
        // Make Eve the `msg.sender` in this test case.
        changePrank(users.eve);

        // Run the test.
        vm.expectRevert(
            abi.encodeWithSelector(ISablierV2.SablierV2__Unauthorized.selector, defaultStreamIds[0], users.eve)
        );
        sablierV2Linear.withdrawAll(defaultStreamIds, defaultAmounts);
    }

    /// @dev When the caller is neither the sender nor the recipient of some of the streams, it should revert.
    function testCannotWithdrawAll__CallerUnauthorized__SomeStreams() external {
        // Make Eve the `msg.sender` in this test case.
        changePrank(users.eve);

        // Create a stream with Eve as the sender.
        uint256 eveStreamId = sablierV2Linear.create(
            users.eve,
            daiStream.recipient,
            daiStream.depositAmount,
            daiStream.token,
            daiStream.startTime,
            daiStream.cliffTime,
            daiStream.stopTime,
            daiStream.cancelable
        );

        // Warp to 2,600 seconds after the start time (26% of the default stream duration).
        vm.warp(daiStream.startTime + TIME_OFFSET);

        // Run the test.
        uint256[] memory streamIds = createDynamicArray(eveStreamId, defaultStreamIds[0]);
        vm.expectRevert(
            abi.encodeWithSelector(ISablierV2.SablierV2__Unauthorized.selector, defaultStreamIds[0], users.eve)
        );
        sablierV2Linear.withdrawAll(streamIds, defaultAmounts);
    }

    /// @dev When the caller is the sender of all streams, it should make the withdrawals and update the withdrawn
    /// amounts.
    function testWithdrawAll__CallerSender() external {
        // Make the sender the `msg.sender` in this test case.
        changePrank(users.sender);

        // Warp to 2,600 seconds after the start time (26% of the default stream duration).
        vm.warp(daiStream.startTime + TIME_OFFSET);

        // Run the test.
        sablierV2Linear.withdrawAll(defaultStreamIds, defaultAmounts);
        ISablierV2Linear.Stream memory queriedStream0 = sablierV2Linear.getStream(defaultStreamIds[0]);
        ISablierV2Linear.Stream memory queriedStream1 = sablierV2Linear.getStream(defaultStreamIds[1]);

        uint256 actualWithdrawnAmount0 = queriedStream0.withdrawnAmount;
        uint256 actualWithdrawnAmount1 = queriedStream1.withdrawnAmount;
        uint256 expectedWithdrawnAmount0 = WITHDRAW_AMOUNT_DAI;
        uint256 expectedWithdrawnAmount1 = WITHDRAW_AMOUNT_DAI;

        assertEq(actualWithdrawnAmount0, expectedWithdrawnAmount0);
        assertEq(actualWithdrawnAmount1, expectedWithdrawnAmount1);
    }

    /// @dev When some amounts are zero, it should revert.
    function testCannotWithdrawAll__SomeAmountsZero() external {
        // Warp to 2,600 seconds after the start time (26% of the default stream duration).
        vm.warp(daiStream.startTime + TIME_OFFSET);

        // Run the test.
        uint256[] memory amounts = createDynamicArray(WITHDRAW_AMOUNT_DAI, 0);
        vm.expectRevert(abi.encodeWithSelector(ISablierV2.SablierV2__WithdrawAmountZero.selector, defaultStreamIds[1]));
        sablierV2Linear.withdrawAll(defaultStreamIds, amounts);
    }

    /// @dev When some amounts are greater than the withrawable amounts, it should revert.
    function testCannotWithdrawAll__SomeAmountsGreaterThanWithdrawableAmount() external {
        // Warp to 2,600 seconds after the start time (26% of the default stream duration).
        vm.warp(daiStream.startTime + TIME_OFFSET);

        // Run the test.
        uint256 withdrawableAmount = WITHDRAW_AMOUNT_DAI;
        uint256 withdrawAmountMaxUint256 = MAX_UINT_256;
        uint256[] memory amounts = createDynamicArray(withdrawableAmount, withdrawAmountMaxUint256);
        vm.expectRevert(
            abi.encodeWithSelector(
                ISablierV2.SablierV2__WithdrawAmountGreaterThanWithdrawableAmount.selector,
                defaultStreamIds[1],
                withdrawAmountMaxUint256,
                withdrawableAmount
            )
        );
        sablierV2Linear.withdrawAll(defaultStreamIds, amounts);
    }

    /// @dev When all streams are ended, it should make the withdrawals and delete the streams.
    function testWithdrawAll__AllStreamsEnded() external {
        // Warp to the end of the stream.
        vm.warp(daiStream.stopTime);

        // Run the test.
        uint256[] memory amounts = createDynamicArray(daiStream.depositAmount, daiStream.depositAmount);
        sablierV2Linear.withdrawAll(defaultStreamIds, amounts);

        ISablierV2Linear.Stream memory actualStream0 = sablierV2Linear.getStream(defaultStreamIds[0]);
        ISablierV2Linear.Stream memory actualStream1 = sablierV2Linear.getStream(defaultStreamIds[1]);
        ISablierV2Linear.Stream memory expectedStream;

        assertEq(actualStream0, expectedStream);
        assertEq(actualStream1, expectedStream);
    }

    /// @dev When all streams are ended, it should emit multiple Withdraw events.
    function testWithdrawAll__AllStreamsEnded__Events() external {
        // Warp to the end of the stream.
        vm.warp(daiStream.stopTime);

        // Run the test.
        uint256 withdrawAmount = daiStream.depositAmount;
        vm.expectEmit(true, true, false, true);
        emit Withdraw(defaultStreamIds[0], daiStream.recipient, withdrawAmount);
        vm.expectEmit(true, true, false, true);
        emit Withdraw(defaultStreamIds[1], daiStream.recipient, withdrawAmount);
        uint256[] memory amounts = createDynamicArray(withdrawAmount, withdrawAmount);
        sablierV2Linear.withdrawAll(defaultStreamIds, amounts);
    }

    /// @dev When all streams are ongoing, it should make the withdrawals and update the withdrawn amounts.
    function testWithdrawAll__AllStreamsOngoing() external {
        // Warp to 2,600 seconds after the start time (26% of the default stream duration).
        vm.warp(daiStream.startTime + TIME_OFFSET);

        // Run the test.
        sablierV2Linear.withdrawAll(defaultStreamIds, defaultAmounts);
        ISablierV2Linear.Stream memory queriedStream0 = sablierV2Linear.getStream(defaultStreamIds[0]);
        ISablierV2Linear.Stream memory queriedStream1 = sablierV2Linear.getStream(defaultStreamIds[1]);

        uint256 actualWithdrawnAmount0 = queriedStream0.withdrawnAmount;
        uint256 actualWithdrawnAmount1 = queriedStream1.withdrawnAmount;
        uint256 expectedWithdrawnAmount0 = WITHDRAW_AMOUNT_DAI;
        uint256 expectedWithdrawnAmount1 = WITHDRAW_AMOUNT_DAI;

        assertEq(actualWithdrawnAmount0, expectedWithdrawnAmount0);
        assertEq(actualWithdrawnAmount1, expectedWithdrawnAmount1);
    }

    /// @dev When all streams are ongoing, it should emit multiple Withdraw events.
    function testWithdrawAll__AllStreamsOngoing__Events() external {
        // Warp to 2,600 seconds after the start time (26% of the default stream duration).
        vm.warp(daiStream.startTime + TIME_OFFSET);

        // Run the test.
        uint256 withdrawAmount = WITHDRAW_AMOUNT_DAI;
        vm.expectEmit(true, true, false, true);
        emit Withdraw(defaultStreamIds[0], daiStream.recipient, withdrawAmount);
        vm.expectEmit(true, true, false, true);
        emit Withdraw(defaultStreamIds[1], daiStream.recipient, withdrawAmount);
        sablierV2Linear.withdrawAll(defaultStreamIds, defaultAmounts);
    }

    /// @dev When some streams are ended and some streams are ongoing, it should make the withdrawals, delete the
    /// ended streams and update the withdrawn amounts.
    function testWithdrawAll__SomeStreamsEndedSomeStreamsOngoing() external {
        // Create the ended daiStream.
        changePrank(daiStream.sender);
        uint256 earlyStopTime = daiStream.startTime + TIME_OFFSET;
        uint256 endedStreamId = sablierV2Linear.create(
            daiStream.sender,
            daiStream.recipient,
            daiStream.depositAmount,
            daiStream.token,
            daiStream.startTime,
            daiStream.cliffTime,
            earlyStopTime,
            daiStream.cancelable
        );
        changePrank(daiStream.recipient);

        // Use the first default stream as the ongoing daiStream.
        uint256 ongoingStreamId = defaultStreamIds[0];

        // Warp to the end of the early daiStream.
        vm.warp(earlyStopTime);

        // Run the test.
        uint256 endedWithdrawAmount = daiStream.depositAmount;
        uint256 ongoingWithdrawAmount = WITHDRAW_AMOUNT_DAI;
        uint256[] memory streamIds = createDynamicArray(endedStreamId, ongoingStreamId);
        uint256[] memory amounts = createDynamicArray(endedWithdrawAmount, ongoingWithdrawAmount);
        sablierV2Linear.withdrawAll(streamIds, amounts);

        ISablierV2Linear.Stream memory createdStream0 = sablierV2Linear.getStream(endedStreamId);
        ISablierV2Linear.Stream memory expectedStream0;
        assertEq(createdStream0, expectedStream0);

        ISablierV2Linear.Stream memory queriedStream1 = sablierV2Linear.getStream(ongoingStreamId);
        uint256 actualWithdrawnAmount1 = queriedStream1.withdrawnAmount;
        uint256 expectedWithdrawnAmount1 = WITHDRAW_AMOUNT_DAI;
        assertEq(actualWithdrawnAmount1, expectedWithdrawnAmount1);
    }

    /// @dev When some streams are ended and some streams are ongoing, it should emit Withdraw events.
    function testWithdrawAll__SomeStreamsEndedSomeStreamsOngoing__Events() external {
        // Create the ended daiStream.
        changePrank(daiStream.sender);
        uint256 earlyStopTime = daiStream.startTime + TIME_OFFSET;
        uint256 endedStreamId = sablierV2Linear.create(
            daiStream.sender,
            daiStream.recipient,
            daiStream.depositAmount,
            daiStream.token,
            daiStream.startTime,
            daiStream.cliffTime,
            earlyStopTime,
            daiStream.cancelable
        );
        changePrank(daiStream.recipient);

        // Use the first default stream as the ongoing daiStream.
        uint256 ongoingStreamId = defaultStreamIds[0];

        // Warp to the end of the early daiStream.
        vm.warp(earlyStopTime);

        // Run the test.
        uint256 endedWithdrawAmount = daiStream.depositAmount;
        uint256 ongoingWithdrawAmount = WITHDRAW_AMOUNT_DAI;

        vm.expectEmit(true, true, false, true);
        emit Withdraw(endedStreamId, daiStream.recipient, endedWithdrawAmount);
        vm.expectEmit(true, true, false, true);
        emit Withdraw(ongoingStreamId, daiStream.recipient, ongoingWithdrawAmount);

        uint256[] memory streamIds = createDynamicArray(endedStreamId, ongoingStreamId);
        uint256[] memory amounts = createDynamicArray(endedWithdrawAmount, ongoingWithdrawAmount);
        sablierV2Linear.withdrawAll(streamIds, amounts);
    }
}