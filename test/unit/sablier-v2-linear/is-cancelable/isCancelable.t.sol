// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.13;

import { SablierV2LinearUnitTest } from "../SablierV2LinearUnitTest.t.sol";

contract SablierV2Linear__UnitTest__IsCancelable is SablierV2LinearUnitTest {
    /// @dev When the stream does not exist, it should return zero.
    function testIsCancelable__StreamNonExistent() external {
        uint256 nonStreamId = 1729;
        bool actualCancelable = sablierV2Linear.isCancelable(nonStreamId);
        bool expectedCancelable = false;
        assertEq(actualCancelable, expectedCancelable);
    }

    /// @dev When the stream is cancelable, it should return false.
    function testIsCancelable__CancelableStream() external {
        uint256 streamId = createDefaultDaiStream();
        bool actualCancelable = sablierV2Linear.isCancelable(streamId);
        bool expectedCancelable = true;
        assertEq(actualCancelable, expectedCancelable);
    }

    /// @dev When the stream is not cancelable, it should return true.
    function testIsCancelable__NonCancelableStream() external {
        uint256 nonCancelableDaiStreamId = createNonCancelableDaiStream();
        bool actualCancelable = sablierV2Linear.isCancelable(nonCancelableDaiStreamId);
        bool expectedCancelable = false;
        assertEq(actualCancelable, expectedCancelable);
    }
}