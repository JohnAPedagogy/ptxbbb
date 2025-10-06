use std::env;

// Import the library functions directly
use rdisplay::reset_gui_tile_state;

fn main() {
    let default_path = "/var/lib/ipt4-daemon/settings.das";
    let args: Vec<String> = env::args().collect();
    let json_path = if args.len() > 1 {
        &args[1]
    } else {
        default_path
    };

    if let Err(e) = reset_gui_tile_state(json_path) {
        eprintln!("Error: {}", e);
    }
}