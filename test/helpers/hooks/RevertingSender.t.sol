// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.13 <0.9.0;

import { ISablierV2Sender } from "src/interfaces/hooks/ISablierV2Sender.sol";

contract RevertingSender is ISablierV2Sender {
    function onStreamCanceled(
        uint256 streamId,
        address caller,
        uint128 recipientAmount,
        uint128 senderAmount
    ) external pure {
        streamId;
        caller;
        recipientAmount;
        senderAmount;
        revert("You shall not pass");
    }
}