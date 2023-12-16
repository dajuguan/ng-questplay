mod tests; // Do not modify this first line!

fn main(key: u32, lock_1: pub u32, lock_2: pub u32) {
    assert(key != 1);
    assert(lock_1 % key == 0);
    assert(lock_2 % key == 0);
}
