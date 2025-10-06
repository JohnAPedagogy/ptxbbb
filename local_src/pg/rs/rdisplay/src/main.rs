use std::env;
use std::io::{self, Write};

// Import the library functions directly
use rdisplay::reset_gui_tile_state;

fn flush_stdout() {
    io::stdout().flush().unwrap();
}

fn main() {
    println!("rdisplay v0.1.0 - GUI Tile State Reset Tool");
    flush_stdout();
    println!("========================================");
    flush_stdout();
    
    let default_path = "/var/lib/ipt4-daemon/settings.das";
    let args: Vec<String> = env::args().collect();
    
    println!("Command line arguments received: {:?}", args);
    flush_stdout();
    
    let json_path = if args.len() > 1 {
        println!("Using provided file path: {}", &args[1]);
        flush_stdout();
        &args[1]
    } else {
        println!("No file path provided, using default: {}", default_path);
        flush_stdout();
        default_path
    };

    println!("Target file: {}", json_path);
    flush_stdout();
    println!("Starting GUI tile state reset process...");
    flush_stdout();
    
    match reset_gui_tile_state(json_path) {
        Ok(()) => {
            println!("✓ Success: GUI tile state has been reset successfully!");
            flush_stdout();
            println!("Program completed without errors.");
            flush_stdout();
        }
        Err(e) => {
            eprintln!("✗ Error occurred during operation: {}", e);
            io::stderr().flush().unwrap();
            eprintln!("Program failed to complete the reset operation.");
            io::stderr().flush().unwrap();
            std::process::exit(1);
        }
    }
}