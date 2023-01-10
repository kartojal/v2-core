// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.13 <0.9.0;

import { ISablierV2Recipient } from "src/interfaces/hooks/ISablierV2Recipient.sol";

contract GoodRecipient is ISablierV2Recipient {
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
    }

    function onStreamWithdrawn(uint256 streamId, address caller, uint128 amount) external pure {
        streamId;
        caller;
        amount;
    }
}