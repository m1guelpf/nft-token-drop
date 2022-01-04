// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.10;

import "./Hevm.sol";
import "ds-test/test.sol";
import "../CurrencyToken.sol";

contract User {}

contract TestNFT is ERC721("Test NFT", "TEST") {
    uint256 public tokenId = 1;

    function tokenURI(uint256) public pure override returns (string memory) {
        return "test";
    }

    function mint() public returns (uint256) {
        _mint(msg.sender, tokenId);

        return tokenId++;
    }
}

contract ZurrencyTest is DSTest {
    Hevm internal hevm;
    User internal user;
    TestNFT internal nft;
    uint256 internal nftId;
    uint256 internal nftId2;
    CurrencyToken internal token;

    event Claimed(uint256 indexed tokenId, address indexed claimer);

    function setUp() public {
        user = new User();
        nft = new TestNFT();
        nftId = nft.mint();
        nftId2 = nft.mint();
        token = new CurrencyToken(nft, 1, "Test Currency", "TEST");
        hevm = Hevm(HEVM_ADDRESS);
    }

    function testOwnerCanClaim() public {
        assertTrue(!token.hasClaimed(nftId));
        assertEq(token.balanceOf(address(this)), 0);

        hevm.expectEmit(true, true, false, false);
        emit Claimed(nftId, address(this));

        token.claim(nftId);

        assertTrue(token.hasClaimed(nftId));
        assertEq(token.balanceOf(address(this)), 1);
    }

    function testNonOwnerCannotClaim() public {
        assertTrue(!token.hasClaimed(nftId));
        assertEq(token.balanceOf(address(user)), 0);

        hevm.prank(address(user));
        hevm.expectRevert(abi.encodeWithSignature("NotOwner()"));
        emit Claimed(nftId, address(this));

        token.claim(nftId);

        assertTrue(!token.hasClaimed(nftId));
        assertEq(token.balanceOf(address(user)), 0);
    }

    function testOwnerCannotClaimTwice() public {
        token.claim(nftId);
        assertEq(token.balanceOf(address(this)), 1);

        hevm.expectRevert(abi.encodeWithSignature("AlreadyRedeemed()"));
        token.claim(nftId);

        assertEq(token.balanceOf(address(this)), 1);
    }

    function testOwnerCanMultiClaim() public {
        assertTrue(!token.hasClaimed(nftId));
        assertTrue(!token.hasClaimed(nftId2));
        assertEq(token.balanceOf(address(this)), 0);

        hevm.expectEmit(true, true, false, false);
        emit Claimed(nftId, address(this));
        hevm.expectEmit(true, true, false, false);
        emit Claimed(nftId2, address(this));

        uint256[] memory nftIds = new uint256[](2);
        nftIds[0] = nftId;
        nftIds[1] = nftId2;

        token.batchClaim(nftIds);

        assertTrue(token.hasClaimed(nftId));
        assertTrue(token.hasClaimed(nftId2));
        assertEq(token.balanceOf(address(this)), 2);
    }

    function testNonOwnerCannotMultiClaim() public {
        assertTrue(!token.hasClaimed(nftId));
        assertTrue(!token.hasClaimed(nftId2));
        assertEq(token.balanceOf(address(user)), 0);

        uint256[] memory nftIds = new uint256[](2);
        nftIds[0] = nftId;
        nftIds[1] = nftId2;

        hevm.prank(address(user));
        hevm.expectRevert(abi.encodeWithSignature("NotOwner()"));
        token.batchClaim(nftIds);

        assertTrue(!token.hasClaimed(nftId));
        assertTrue(!token.hasClaimed(nftId2));
        assertEq(token.balanceOf(address(user)), 0);
    }

    function testOwnerCannotMultiClaimTwice() public {
        uint256[] memory nftIds = new uint256[](2);
        nftIds[0] = nftId;
        nftIds[1] = nftId2;

        token.batchClaim(nftIds);

        assertEq(token.balanceOf(address(this)), 2);

        hevm.expectRevert(abi.encodeWithSignature("AlreadyRedeemed()"));
        token.batchClaim(nftIds);

        assertEq(token.balanceOf(address(this)), 2);
    }

    function testOwnerCannotDoubleMultiClaim() public {
        uint256[] memory nftIds = new uint256[](2);
        nftIds[0] = nftId;
        nftIds[1] = nftId;

        hevm.expectRevert(abi.encodeWithSignature("AlreadyRedeemed()"));
        token.batchClaim(nftIds);

        assertEq(token.balanceOf(address(this)), 0);
    }
}
