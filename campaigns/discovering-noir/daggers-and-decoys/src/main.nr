mod tests; // Do not modify this first line!
use dep::std::hash::{keccak256, sha256};
// use dep::std::hash::poseidon;
use dep::std;
use dep::std::hash::poseidon::bn254;
use dep::std::collections::vec::Vec;

fn convert_slice2_arr(slice: [u8]) -> [u8; 32] {
    let mut res: [u8;32] = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
    for i in 0..32 {
        res[i] = slice[i];
    }
    res
}

fn convert_slice2_arr64(slice: [u8]) -> [u8; 64] {
    let mut res: [u8;64] = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
    for i in 0..64 {
        res[i] = slice[i];
    }
    res
}
fn main(
    secret: Field,
    index: Field,
    merkle_proof: [[u8; 32]; 3],
    merkle_root: pub [u8; 32],
    nullifier: pub Field,
) {
    // Implement this
    let mut merkle_hash = bn254::hash_1([secret]).to_be_bytes(32);
    let mut merkle_hash = convert_slice2_arr(merkle_hash);
    let mut layer = index as u8;
    let mut input = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
    let mut lhs = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
    let mut rhs = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
    for i in 0..3 {
        if layer % 2 == 0 {
            lhs = merkle_hash;
            rhs = merkle_proof[i];
        } else {
            lhs = merkle_proof[i];
            rhs = merkle_hash;
        }
        for j in 0..32 {
            input[j] = lhs[j];
        }
        for j in 32..64 {
            input[j] = rhs[j-32];
        }
        merkle_hash = keccak256(input, 64);
        layer /= 2;
    }
    assert(merkle_hash == merkle_root);
    // std::println(f"merkle_hash------------------>: {merkle_hash}");
    let nullifier_hash = bn254::hash_1([secret + 1]);
    assert( nullifier_hash == nullifier);
}
