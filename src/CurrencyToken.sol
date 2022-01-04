// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

import "solmate/tokens/ERC20.sol";
import "solmate/tokens/ERC721.sol";

contract CurrencyToken is ERC20 {
    ERC721 internal nft;
    uint256 public tokensPerClaim;

    event Claimed(uint256 indexed tokenId, address indexed claimer);

    error NotOwner();
    error AlreadyRedeemed();

    mapping(uint256 => bool) public hasClaimed;

    constructor(
        ERC721 _nft,
        uint256 _tokensPerClaim,
        string memory name,
        string memory symbol
    ) ERC20(name, symbol, 18) {
        nft = _nft;
        tokensPerClaim = _tokensPerClaim;
    }

    function claim(uint256 tokenId) external payable {
        if (hasClaimed[tokenId]) revert AlreadyRedeemed();
        if (nft.ownerOf(tokenId) != msg.sender) revert NotOwner();

        hasClaimed[tokenId] = true;
        emit Claimed(tokenId, msg.sender);

        _mint(msg.sender, tokensPerClaim);
    }

    function batchClaim(uint256[] memory tokenIds) external payable {
        for (uint256 index = 0; index < tokenIds.length; index++) {
            uint256 tokenId = tokenIds[index];

            if (hasClaimed[tokenId]) revert AlreadyRedeemed();
            if (nft.ownerOf(tokenId) != msg.sender) revert NotOwner();

            hasClaimed[tokenId] = true;
            emit Claimed(tokenId, msg.sender);
        }

        _mint(msg.sender, tokensPerClaim * tokenIds.length);
    }
}
