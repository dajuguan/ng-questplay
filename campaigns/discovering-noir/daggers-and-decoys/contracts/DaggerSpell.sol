// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./interfaces/IDaggerSpell.sol";
import "./plonk_vk.sol";

contract DaggerSpell is IDaggerSpell {
    bytes32 merkle_root;
    mapping(address => uint256) dagger_holders;
    uint256 leaf_index;
    mapping(uint256 => bytes32) merkel_leafs;
    mapping(bytes32 => bool) nullifiers;
    UltraVerifier verifier = new UltraVerifier();
    constructor(address[8] memory _keepers) { 
        for(uint i=0; i < 8; i++) {
            dagger_holders[_keepers[i]] = 1;
        }
        leaf_index = 0;
    }

    /// @inheritdoc IDaggerSpell
    function merkleLeaf(uint256 _index) external view returns (bytes32) {
        return merkel_leafs[_index];
    }

    /// @inheritdoc IDaggerSpell
    function merkleRoot() external view returns (bytes32) {
        return merkle_root;
    }

    /// @inheritdoc IDaggerSpell
    function daggers(address _keeper) external view returns (uint256) {
        return dagger_holders[_keeper];
    }

    /// @inheritdoc IDaggerSpell
    function giveDagger(bytes32 _merkleLeaf) external {
        require(dagger_holders[msg.sender] == 1, "NOT_KEEPER");
        dagger_holders[msg.sender] = 0;
        merkel_leafs[leaf_index] = _merkleLeaf;
        leaf_index += 1;
    }

    /// @inheritdoc IDaggerSpell
    function computeRoot() external {
        require(leaf_index == 8, "NOT_ENOUGH_LEAVES");
        bytes32[4] memory nodes;
        for (uint256 i=0; i< 4; i++) {
            nodes[i] = keccak256(abi.encodePacked(merkel_leafs[2*i], merkel_leafs[2*i+1]));
        }
        for (uint256 i=0; i< 2; i++) {
            nodes[i] = keccak256(abi.encodePacked(nodes[2*i], nodes[2*i+1]));
        }
        merkle_root = keccak256(abi.encodePacked(nodes[0], nodes[1]));
    }

    /// @inheritdoc IDaggerSpell
    function pullDagger(bytes32 _nullifier, bytes calldata _proof) external {
        require(!nullifiers[_nullifier], "REPLAYED_NULLIFIER");
        bytes32[] memory _public_inputs = new bytes32[](33);
        for (uint i = 0; i< 32; i++) {
            _public_inputs[i] = bytes32(merkle_root[i]) >> 31*8;
        }
        _public_inputs[32] = _nullifier;
        try verifier.verify(_proof, _public_inputs) {
            require(verifier.verify(_proof, _public_inputs), "INVALID_PROOF");
        } catch {
            require(false, "INVALID_PROOF");
        }
        nullifiers[_nullifier] = true;
        dagger_holders[msg.sender] = 1;
    }
}
