# NFT Currency Airdrop Template

> A drop-in contract to airdrop all current holders of an NFT with an ERC20 token.

A common airdrop style (pioneered by Loot derivatives as far as I know) is to allow current holders of an NFT to claim a certain amount of an ERC20. This repository extends [Rari Capital's Solmate](https://github.com/Rari-Capital/solmate)'s ERC20 implementation with a `claim(uint256 tokenId)` and `batchClaim(uint256[] tokenIds)` functions, allowing holders to claim their tokens. Potential buyers can also call `hasClaimed(uint256 tokenId)` to figure out if the tokens for the NFTs they are about to buy have already been claimed.

You can configure the address of the NFT to use for the lookup, name and symbol of the ERC20, and how many tokens to issue per NFT via the constructor when deploying the contract.

## License

This project is open-sourced software licensed under the GNU Affero GPL v3.0 license. See the [License file](LICENSE) for more information.
