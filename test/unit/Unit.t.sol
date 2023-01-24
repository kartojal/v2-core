// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.13 <0.9.0;

import { Base_Test } from "test/Base.t.sol";
import { Empty } from "test/helpers/hooks/Empty.t.sol";
import { GoodRecipient } from "test/helpers/hooks/GoodRecipient.t.sol";
import { GoodSender } from "test/helpers/hooks/GoodSender.t.sol";
import { ReentrantRecipient } from "test/helpers/hooks/ReentrantRecipient.t.sol";
import { ReentrantSender } from "test/helpers/hooks/ReentrantSender.t.sol";
import { RevertingRecipient } from "test/helpers/hooks/RevertingRecipient.t.sol";
import { RevertingSender } from "test/helpers/hooks/RevertingSender.t.sol";

abstract contract Unit_Test is Base_Test {
    /*//////////////////////////////////////////////////////////////////////////
                                   TEST CONTRACTS
    //////////////////////////////////////////////////////////////////////////*/

    Empty internal empty = new Empty();
    GoodRecipient internal goodRecipient = new GoodRecipient();
    GoodSender internal goodSender = new GoodSender();
    ReentrantRecipient internal reentrantRecipient = new ReentrantRecipient();
    ReentrantSender internal reentrantSender = new ReentrantSender();
    RevertingRecipient internal revertingRecipient = new RevertingRecipient();
    RevertingSender internal revertingSender = new RevertingSender();

    /*//////////////////////////////////////////////////////////////////////////
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        Base_Test.setUp();

        // Deploy all Sablier contracts.
        deploySablierContracts();

        // Approve all contracts to spend ERC-20 assets fromm the users.
        approveSablierContracts();

        // Label the test contracts.
        labelTestContracts();

        // Finally, change the active prank back to the admin.
        changePrank(users.admin);
    }

    /*//////////////////////////////////////////////////////////////////////////
                           INTERNAL NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Label the test contracts.
    function labelTestContracts() internal {
        vm.label({ account: address(empty), newLabel: "Empty" });
        vm.label({ account: address(dai), newLabel: "Dai" });
        vm.label({ account: address(goodRecipient), newLabel: "Good Recipient" });
        vm.label({ account: address(goodSender), newLabel: "Good Sender" });
        vm.label({ account: address(nonCompliantAsset), newLabel: "Non-Compliant ERC-20 Asset" });
        vm.label({ account: address(reentrantRecipient), newLabel: "Reentrant Recipient" });
        vm.label({ account: address(reentrantSender), newLabel: "Reentrant Sender" });
        vm.label({ account: address(revertingRecipient), newLabel: "Reverting Recipient" });
        vm.label({ account: address(revertingSender), newLabel: "Reverting Sender" });
    }
}
