// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import {Test} from "forge-std/Test.sol";
import {MaxMintable} from "../../src/lib/MaxMintable.sol";
import {ERC721A} from "ERC721A/ERC721A.sol";

contract MaxMintableImpl is MaxMintable {
    constructor(uint256 _maxMintable) MaxMintable("test", "test", _maxMintable) {}

    function checkAndIncrement(uint256 quantity) public checkMaxMintedForWallet(quantity) {
        _mint(msg.sender, quantity);
    }
}

contract MaxMintableTest is Test {
    MaxMintableImpl list;
    bytes32[] proof;
    bytes32 root;

    function setUp() public {
        list = new MaxMintableImpl(2);
    }

    function testConstructorInitializesPropertiesBatchMint() public {
        list = new MaxMintableImpl(2);
        assertEq(2, list.maxMintsPerWallet());
    }

    function testUpdateMaxMints() public {
        list.setMaxMintsPerWallet(5);
        assertEq(5, list.maxMintsPerWallet());
    }

    function testOnlyOwnerCanSetMaxMints() public {
        list.transferOwnership(address(1));
        vm.expectRevert("Ownable: caller is not the owner");
        list.setMaxMintsPerWallet(5);
    }

    function testCanRedeemUpToMax() public {
        list.checkAndIncrement(1);
        list.checkAndIncrement(1);
        // works with batch too
        vm.prank(address(1));
        list.checkAndIncrement(2);
    }

    function testRedeemingMoreThanMaxReverts() public {
        list.checkAndIncrement(1);
        list.checkAndIncrement(1);
        vm.expectRevert(abi.encodeWithSignature("MaxMintedForWallet()"));
        list.checkAndIncrement(1);
        vm.startPrank(address(1));
        vm.expectRevert(abi.encodeWithSignature("MaxMintedForWallet()"));
        list.checkAndIncrement(3);
        vm.stopPrank();
    }
}
