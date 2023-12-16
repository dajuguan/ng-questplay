use dep::std;

struct Square {
    x: Field,
    y: Field
}

pub fn is_valid_path(path: [Square; 8], dagger: Square) {
    // Part 1
    // starts from (0,0), ends at dagger's location
    assert(path[0].x == 0);
    assert(path[0].y == 0);
    assert(path[7].x == dagger.x);
    assert(path[7].y == dagger.y);
    // consists of only L-shape moves
    for i in 0..7 {
        let case_1 = ((path[i + 1].x - path[i].x == 2) & (path[i + 1].y - path[i].y == 1));
        let case_2 = ((path[i + 1].x - path[i].x == 2) & (path[i + 1].y - path[i].y == -1));
        let case_3 = ((path[i + 1].x - path[i].x == -2) & (path[i + 1].y - path[i].y == 1));
        let case_4 = ((path[i + 1].x - path[i].x == -2) & (path[i + 1].y - path[i].y == -1));
        let case_5 = ((path[i + 1].x - path[i].x == 1) & (path[i + 1].y - path[i].y == 2));
        let case_6 = ((path[i + 1].x - path[i].x == 1) & (path[i + 1].y - path[i].y == -2));
        let case_7 = ((path[i + 1].x - path[i].x == -1) & (path[i + 1].y - path[i].y == 2));
        let case_8 = ((path[i + 1].x - path[i].x == -1) & (path[i + 1].y - path[i].y == -2));
        assert(case_1 | case_2 | case_3 | case_4 | case_5 | case_6 | case_7 | case_8);
        let x = path[i].x as u8;
        let y = path[i].y as u8;
        assert((x >= 0) & (x < 8) & (y >= 0) & (y < 8));
    }
    // contains only squares within the 8x8 board.
    let x = path[7].x as u8;
    let y = path[7].y as u8;
    assert((x >= 0) & (x < 8) & (y >= 0) & (y < 8));
}

pub fn is_safe_path(path: [Square; 8], watcher_map: [[bool; 8]; 8]) {
    // Part 2
    for w_x in 0..8 {
        for w_y in 0..8 {
            if watcher_map[w_x][w_y] {
                for p in path {
                    let (x, y) = (p.x, p.y);
                    assert(((x - w_x) != (y - w_y)) & ((x - w_x) != -(y - w_y)));
                }
            }
        }
    }
}
