// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "../security/HasSecurityContext.sol";

/**
 * @title HamzaNftCollection 
 * 
 * 1155 NFT collection contract, upgradeable.
 * 
 * @author John R. Kosinski
 * Hamza Labs Ltd.
 * All rights reserved. Unauthorized use prohibited.
 */
contract HamzaNftCollection is ERC1155Upgradeable, HasSecurityContext {
    struct NftTypeSpec {
        uint256 id;
        string uri;
    }

    mapping(uint256 => NftTypeSpec) private nftTypes;
    mapping(uint256 => uint256) public tokenSupply;

    function initialize(ISecurityContext securityContext_, string memory uri_) public initializer {
        __ERC1155_init(uri_);

        _setSecurityContext(securityContext_);

        //GOLD 
        nftTypes[1] = NftTypeSpec(1, "");

        //SILVER 
        nftTypes[2] = NftTypeSpec(2, "");

        //BRONZE
        nftTypes[3] = NftTypeSpec(3, "");
    }

    /**
     * @dev Allows authorized accounts to mint new NFTs of an existing type.
     * @param account The address to receive the NFTs.
     * @param id The ID of the NFT type to mint.
     * @param amount The number of NFTs to mint.
     */
    function mint(address account, uint256 id, uint256 amount) external onlyRole(NFT_MINTER_ROLE) {
        require(nftTypes[id].id != 0, "InvalidNftType");
        _mint(account, id, amount, "");
        tokenSupply[id] += amount;
    }

    /**
     * @dev Returns the total supply of a given NFT type.
     * @param id The token ID.
     */
    function totalSupply(uint256 id) external view returns (uint256) {
        return tokenSupply[id];
    }

    /**
     * @dev Adds a new NFT type. Only authorized accounts can call this function.
     * @param id The ID of the new NFT type.
     * @param uri_ The URI for the new NFT type's metadata.
     */
    function addNftType(uint256 id, string memory uri_) public onlyRole(NFT_MINTER_ROLE) {
        require(nftTypes[id].id == 0, "NftTypeAlreadyExists");
        nftTypes[id] = NftTypeSpec({ id: id, uri: uri_ });
    }

    /**
     * @dev Updates the URI for an existing NFT type. Only authorized accounts can call this function.
     * @param id The ID of the NFT type to update.
     * @param uri_ The new URI for the NFT type's metadata.
     */
    function setURI(uint256 id, string memory uri_) external onlyRole(NFT_MINTER_ROLE) {
        require(nftTypes[id].id != 0, "InvalidNftType");
        nftTypes[id].uri = uri_;
    }

    /**
     * @dev Returns the URI for a given NFT type.
     * @param id The token ID.
     */
    function uri(uint256 id) public view override returns (string memory) {
        require(nftTypes[id].id != 0, "InvalidNftType");
        return nftTypes[id].uri;
    }
}
