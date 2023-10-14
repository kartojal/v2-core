// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.20 <0.9.0;

import { Errors } from "src/libraries/Errors.sol";

import { ERC721Mock } from "../../../../mocks/erc721/ERC721Mock.sol";
import { NFTDescriptor_Integration_Concrete_Test } from "../NFTDescriptor.t.sol";

contract MapSymbol_Integration_Concrete_Test is NFTDescriptor_Integration_Concrete_Test {
    function test_RevertGiven_UnknownNFT() external {
        ERC721Mock nft = new ERC721Mock("Foo NFT", "FOO");
        vm.expectRevert(abi.encodeWithSelector(Errors.SablierV2NFTDescriptor_UnknownNFT.selector, nft, "FOO"));
        nftDescriptorMock.mapSymbol_(nft);
    }

    modifier givenKnownNFT() {
        _;
    }

    function test_MapSymbol_LockupDynamic() external givenKnownNFT {
        string memory actualStreamingModel = nftDescriptorMock.mapSymbol_(lockupDynamic);
        string memory expectedStreamingModel = "Lockup Dynamic";
        assertEq(actualStreamingModel, expectedStreamingModel, "streamingModel");
    }

    function test_MapSymbol_LockupLinear() external givenKnownNFT {
        string memory actualStreamingModel = nftDescriptorMock.mapSymbol_(lockupLinear);
        string memory expectedStreamingModel = "Lockup Linear";
        assertEq(actualStreamingModel, expectedStreamingModel, "streamingModel");
    }
}
