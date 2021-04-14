// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @author: manifold.xyz

import "openzeppelin-solidity/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "./access/IAdminControl.sol";

interface IERC721Creator is IAdminControl, IERC721Enumerable {

    event ExtensionRegistered(address indexed extension, address indexed sender);
    event ExtensionUnregistered(address indexed extension, address indexed sender);

    /**
     * @dev gets address of all extensions
     */
    function getExtensions() external view returns (address[] memory);

    /*
     * @dev get balance of owner for an extension
     */
   function extensionBalanceOf(address extension, address owner) external view returns (uint256 balance);

   /*
    * @dev Returns a token ID owned by `owner` at a given `index` of its token list for a given extension
    */
   function extensionTokenOfOwnerByIndex(address extension, address owner, uint256 index) external view returns (uint256 tokenId);

    /*
     * @dev gets the total number of tokens created by the extension (unburned)
     */
    function totalSupplyOfExtension(address extension) external view returns (uint256);

    /*
     * @dev gets tokenId of an extension by index. 
     * Iterate over this to get the full list of tokens of a given extension
     */
    function tokenByIndexOfExtension(address extension, uint256 index) external view returns (uint256);

    /**
     * @dev add an extension.  Can only be called by contract owner or admin.
     * extension address must point to a contract implementing IERC721CreatorExtension.
     * Returns True if newly added, False if already added.
     */
    function registerExtension(address extension, string calldata baseURI) external returns (bool);

    /**
     * @dev add an extension.  Can only be called by contract owner or admin.
     * Returns True if removed, False if already removed.
     */
    function unregisterExtension(address extension) external returns (bool);

    /**
     * @dev set the baseTokenURI of an extension.  Can only be called by extension.
     */
    function setBaseTokenURI(string calldata uri) external;

    /**
     * @dev set the tokenURI of a token extension.  Can only be called by extension that minted token.
     */
    function setTokenURI(uint256 tokenId, string calldata uri) external;

    /**
     * @dev mint a token. Can only be called by a registered extension.
     * Returns tokenId minted
     */
    function mint(address to) external returns (uint256);

    /**
     * @dev burn a token. Can only be called by token owner or approved address.
     * On burn, calls back to the registered extension's onBurn method
     */
    function burn(uint256 tokenId) external;

}