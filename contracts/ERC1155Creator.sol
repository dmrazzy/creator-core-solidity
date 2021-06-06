// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @author: manifold.xyz

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

import "manifoldxyz-libraries-solidity/contracts/access/AdminControl.sol";
import "./core/ERC1155CreatorCore.sol";

/**
 * @dev ERC1155Creator implementation
 */
contract ERC1155Creator is AdminControl, ERC1155, ERC1155CreatorCore {

    constructor (string memory uri_) ERC1155(uri_) {
        _setBaseTokenURI(uri_);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, ERC1155CreatorCore, AdminControl) returns (bool) {
        return ERC1155CreatorCore.supportsInterface(interfaceId) || ERC1155.supportsInterface(interfaceId) || AdminControl.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(address, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory) internal virtual override {
        _approveTransfer(from, to, ids, amounts);
    }

    /**
     * @dev See {ICreatorCore-registerExtension}.
     */
    function registerExtension(address extension, string calldata baseURI) external override adminRequired nonBlacklistRequired(extension) {
        _registerExtension(extension, baseURI, false);
    }

    /**
     * @dev See {ICreatorCore-registerExtension}.
     */
    function registerExtension(address extension, string calldata baseURI, bool baseURIIdentical) external override adminRequired nonBlacklistRequired(extension) {
        _registerExtension(extension, baseURI, baseURIIdentical);
    }


    /**
     * @dev See {ICreatorCore-unregisterExtension}.
     */
    function unregisterExtension(address extension) external override adminRequired {
        _unregisterExtension(extension);
    }

    /**
     * @dev See {ICreatorCore-blacklistExtension}.
     */
    function blacklistExtension(address extension) external override adminRequired {
        _blacklistExtension(extension);
    }

    /**
     * @dev See {ICreatorCore-setBaseTokenURIExtension}.
     */
    function setBaseTokenURIExtension(string calldata uri_) external override extensionRequired {
        _setBaseTokenURIExtension(uri_, false);
    }

    /**
     * @dev See {ICreatorCore-setBaseTokenURIExtension}.
     */
    function setBaseTokenURIExtension(string calldata uri_, bool identical) external override extensionRequired {
        _setBaseTokenURIExtension(uri_, identical);
    }

    /**
     * @dev See {ICreatorCore-setTokenURIPrefixExtension}.
     */
    function setTokenURIPrefixExtension(string calldata prefix) external override extensionRequired {
        _setTokenURIPrefixExtension(prefix);
    }

    /**
     * @dev See {ICreatorCore-setTokenURIExtension}.
     */
    function setTokenURIExtension(uint256 tokenId, string calldata uri_) external override extensionRequired {
        _setTokenURIExtension(tokenId, uri_);
    }

    /**
     * @dev See {ICreatorCore-setTokenURIExtension}.
     */
    function setTokenURIExtension(uint256[] memory tokenIds, string[] calldata uris) external override extensionRequired {
        require(tokenIds.length == uris.length, "ERC1155Creator: Invalid input");
        for (uint i = 0; i < tokenIds.length; i++) {
            _setTokenURIExtension(tokenIds[i], uris[i]);            
        }
    }

    /**
     * @dev See {ICreatorCore-setBaseTokenURI}.
     */
    function setBaseTokenURI(string calldata uri_) external override adminRequired {
        _setBaseTokenURI(uri_);
    }

    /**
     * @dev See {ICreatorCore-setTokenURIPrefix}.
     */
    function setTokenURIPrefix(string calldata prefix) external override adminRequired {
        _setTokenURIPrefix(prefix);
    }

    /**
     * @dev See {ICreatorCore-setTokenURI}.
     */
    function setTokenURI(uint256 tokenId, string calldata uri_) external override adminRequired {
        _setTokenURI(tokenId, uri_);
    }

    /**
     * @dev See {ICreatorCore-setTokenURI}.
     */
    function setTokenURI(uint256[] memory tokenIds, string[] calldata uris) external override adminRequired {
        require(tokenIds.length == uris.length, "ERC1155Creator: Invalid input");
        for (uint i = 0; i < tokenIds.length; i++) {
            _setTokenURI(tokenIds[i], uris[i]);            
        }
    }

    /**
     * @dev See {ICreatorCore-setMintPermissions}.
     */
    function setMintPermissions(address extension, address permissions) external override adminRequired {
        _setMintPermissions(extension, permissions);
    }

    /**
     * @dev See {IERC1155CreatorCore-mintBaseNew}.
     */
    function mintBaseNew(address to, uint256 amount, string calldata uri_) public virtual override nonReentrant adminRequired returns(uint256) {
        return _mintNew(address(this), to, _createUint256Array(amount), _createStringArray(uri_))[0];
    }

    /**
     * @dev See {IERC1155CreatorCore-mintBaseBatchNew}.
     */
    function mintBaseBatchNew(address to, uint256[] calldata amounts, string[] calldata uris) public virtual override nonReentrant adminRequired returns(uint256[] memory) {
        require(uris.length == 0 || amounts.length == uris.length, "ERC1155Creator: Invalid input");
        return _mintNew(address(this), to, amounts, uris);
    }

    /**
     * @dev See {IERC1155CreatorCore-mintBaseExisting}.
     */
    function mintBaseExisting(address to, uint256 tokenId, uint256 amount) public virtual override nonReentrant adminRequired {
        require(_tokensExtension[tokenId] == address(this), "ERC1155Creator: Specified token was created by an extension");
        _mintExisting(address(this), to, _createUint256Array(tokenId), _createUint256Array(amount));
    }

    /**
     * @dev See {IERC1155CreatorCore-mintBaseBatchExisting}.
     */
    function mintBaseBatchExisting(address to, uint256[] calldata tokenIds, uint256[] calldata amounts) public virtual override nonReentrant adminRequired {
        require(tokenIds.length == amounts.length, "ERC1155Creator: Invalid input");
        for (uint i = 0; i < tokenIds.length; i++) {
            require(_tokensExtension[tokenIds[i]] == address(this), "ERC1155Creator: A specified token was created by an extension");
        }
        _mintExisting(address(this), to, tokenIds, amounts);
    }

    /**
     * @dev See {IERC1155CreatorCore-mintExtensionNew}.
     */
    function mintExtensionNew(address to, uint256 amount, string calldata uri_) public virtual override nonReentrant extensionRequired returns(uint256) {
        return _mintNew(msg.sender, to, _createUint256Array(amount), _createStringArray(uri_))[0];
    }

    /**
    /**
     * @dev See {IERC1155CreatorCore-mintExtensionBatchNew}.
     */
    function mintExtensionBatchNew(address to, uint256[] calldata amounts, string[] calldata uris) public virtual override nonReentrant extensionRequired returns(uint256[] memory tokenIds) {
        require(uris.length == 0 || amounts.length == uris.length, "ERC1155Creator: Invalid input");
        return _mintNew(msg.sender, to, amounts, uris);
    }

    /**
     * @dev See {IERC1155CreatorCore-mintExtensionExisting}.
     */
    function mintExtensionExisting(address to, uint256 tokenId, uint256 amount) public virtual override nonReentrant extensionRequired {
        require(_tokensExtension[tokenId] == address(msg.sender), "ERC1155Creator: Specified token was not created by this extension");
        _mintExisting(msg.sender, to, _createUint256Array(tokenId), _createUint256Array(amount));
    }

    /**
     * @dev See {IERC1155CreatorCore-mintExtensionBatchExisting}.
     */
    function mintExtensionBatchExisting(address to, uint256[] calldata tokenIds, uint256[] calldata amounts) public virtual override nonReentrant extensionRequired {
        require(tokenIds.length == amounts.length, "ERC1155Creator: Invalid input");
        for (uint i = 0; i < tokenIds.length; i++) {
            require(_tokensExtension[tokenIds[i]] == address(msg.sender), "ERC1155Creator: A specified token was not created by this extension");
        }
        _mintExisting(msg.sender, to, tokenIds, amounts);
    }

    /**
     * @dev Mint new tokens
     */
    function _mintNew(address extension, address to, uint256[] memory amounts, string[] memory uris) internal returns(uint256[] memory tokenIds) {
        tokenIds = new uint256[](amounts.length);
        for (uint i = 0; i < amounts.length; i++) {
            _tokenCount++;
            tokenIds[i] = _tokenCount;
            // Track the extension that minted the token
            _tokensExtension[_tokenCount] = extension;
        }

        if (extension != address(this)) {
            _checkMintPermissions(to, tokenIds, amounts);
        }

        if (tokenIds.length == 1) {
            _mint(to, tokenIds[0], amounts[0], new bytes(0));        
        } else {
            _mintBatch(to, tokenIds, amounts, new bytes(0));
        }

        for (uint i = 0; i < amounts.length; i++) {
            if (bytes(uris[i]).length > 0) {
                _tokenURIs[tokenIds[i]] = uris[i];
            }
        }
        _postMint(tokenIds, amounts);
        return tokenIds;
    }

    /**
     * @dev Mint existing tokens
     */
    function _mintExisting(address extension, address to, uint256[] memory tokenIds, uint256[] memory amounts) internal {
        if (extension != address(this)) {
            _checkMintPermissions(to, tokenIds, amounts);
        }

        if (tokenIds.length == 1) {
            _mint(to, tokenIds[0], amounts[0], new bytes(0));        
        } else {
            _mintBatch(to, tokenIds, amounts, new bytes(0));
        }
        _postMint(tokenIds, amounts);
    }

    /**
     * @dev See {IERC1155CreatorCore-tokenExtension}.
     */
    function tokenExtension(uint256 tokenId) public view virtual override returns (address) {
        return _tokenExtension(tokenId);
    }

    /**
     * @dev See {IERC1155CreatorCore-burn}.
     */
    function burn(address account, uint256 tokenId, uint256 amount) public virtual override nonReentrant {
        require(account == msg.sender || isApprovedForAll(account, msg.sender), "ERC1155Creator: caller is not owner nor approved");
        _burn(account, tokenId, amount);
        _postBurn(account, _createUint256Array(tokenId), _createUint256Array(amount));
    }

    /**
     * @dev See {IERC1155CreatorCore-burnBatch}.
     */
    function burnBatch(address account, uint256[] memory tokenIds, uint256[] memory amounts) public virtual override nonReentrant {
        require(account == msg.sender || isApprovedForAll(account, msg.sender), "ERC1155Creator: caller is not owner nor approved");
        require(tokenIds.length == amounts.length, "ERC1155Creator: Invalid input");
        _burnBatch(account, tokenIds, amounts);
        _postBurn(account, tokenIds, amounts);
    }

    /**
     * @dev See {ICreatorCore-setRoyalties}.
     */
    function setRoyalties(address payable[] calldata receivers, uint256[] calldata basisPoints) external override adminRequired {
        _setRoyaltiesExtension(address(this), receivers, basisPoints);
    }

    /**
     * @dev See {ICreatorCore-setRoyalties}.
     */
    function setRoyalties(uint256 tokenId, address payable[] calldata receivers, uint256[] calldata basisPoints) external override adminRequired {
        _setRoyalties(tokenId, receivers, basisPoints);
    }

    /**
     * @dev See {ICreatorCore-setRoyaltiesExtension}.
     */
    function setRoyaltiesExtension(address extension, address payable[] calldata receivers, uint256[] calldata basisPoints) external override adminRequired {
        _setRoyaltiesExtension(extension, receivers, basisPoints);
    }

    /**
     * @dev {See ICreatorCore-getRoyalties}.
     */
    function getRoyalties(uint256 tokenId) external view virtual override returns (address payable[] memory, uint256[] memory) {
        return _getRoyalties(tokenId);
    }

    /**
     * @dev {See ICreatorCore-getFees}.
     */
    function getFees(uint256 tokenId) external view virtual override returns (address payable[] memory, uint256[] memory) {
        return _getRoyalties(tokenId);
    }

    /**
     * @dev {See ICreatorCore-getFeeRecipients}.
     */
    function getFeeRecipients(uint256 tokenId) external view virtual override returns (address payable[] memory) {
        return _getRoyaltyReceivers(tokenId);
    }

    /**
     * @dev {See ICreatorCore-getFeeBps}.
     */
    function getFeeBps(uint256 tokenId) external view virtual override returns (uint[] memory) {
        return _getRoyaltyBPS(tokenId);
    }
    
    /**
     * @dev {See ICreatorCore-royaltyInfo}.
     */
    function royaltyInfo(uint256 tokenId, uint256 value, bytes calldata) external view virtual override returns (address, uint256, bytes memory) {
        return _getRoyaltyInfo(tokenId, value);
    } 

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function uri(uint256 tokenId) public view virtual override returns (string memory) {
        return _tokenURI(tokenId);
    }
    
}