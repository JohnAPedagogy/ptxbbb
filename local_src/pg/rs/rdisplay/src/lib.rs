use std::io::{self, Write};

fn flush_stdout() {
    io::stdout().flush().unwrap();
}

fn read_json_file(path: &str) -> Result<serde_json::Value, std::io::Error> {
    println!("Reading JSON file: {}", path);
    flush_stdout();
    
    let file = std::fs::File::open(path).map_err(|e| {
        eprintln!("Failed to open file '{}': {}", path, e);
        e
    })?;
    
    println!("File opened successfully, creating buffer reader...");
    flush_stdout();
    let reader = std::io::BufReader::new(file);
    
    println!("Parsing JSON content...");
    flush_stdout();
    let json: serde_json::Value = serde_json::from_reader(reader).map_err(|e| {
        eprintln!("Failed to parse JSON from file '{}': {}", path, e);
        std::io::Error::new(std::io::ErrorKind::InvalidData, format!("JSON parse error: {}", e))
    })?;
    
    println!("JSON file parsed successfully");
    flush_stdout();
    Ok(json)
}

fn write_json_file(path: &str, json: &serde_json::Value) -> Result<(), std::io::Error> {
    println!("Writing JSON to file: {}", path);
    flush_stdout();
    
    let file = std::fs::File::create(path).map_err(|e| {
        eprintln!("Failed to create file '{}': {}", path, e);
        io::stderr().flush().unwrap();
        e
    })?;
    
    println!("File created successfully, writing JSON content...");
    flush_stdout();
    serde_json::to_writer_pretty(file, json).map_err(|e| {
        eprintln!("Failed to write JSON to file '{}': {}", path, e);
        io::stderr().flush().unwrap();
        std::io::Error::new(std::io::ErrorKind::WriteZero, format!("JSON write error: {}", e))
    })?;
    
    println!("JSON file written successfully (formatted with indentation)");
    flush_stdout();
    Ok(())
}

pub fn reset_gui_tile_state(path: &str) -> Result<(), Box<dyn std::error::Error>> {
    println!("Starting reset_gui_tile_state operation for file: {}", path);
    flush_stdout();
    
    println!("Step 1: Reading JSON file...");
    flush_stdout();
    let mut json = read_json_file(path)?;
    
    println!("Step 2: Looking for 'das' object in JSON...");
    flush_stdout();
    if let Some(das_obj) = json.get_mut("das") {
        println!("Found 'das' object, now looking for 'gui_tile_state' field...");
        flush_stdout();
        
        if let Some(gui_tile_state) = das_obj.get_mut("gui_tile_state") {
            println!("Found 'gui_tile_state' field with current value: {}", gui_tile_state);
            flush_stdout();
            *gui_tile_state = serde_json::Value::String("".to_string());
            println!("Successfully reset 'gui_tile_state' to empty string");
            flush_stdout();
        } else {
            println!("Warning: 'gui_tile_state' field not found in 'das' object");
            flush_stdout();
            return Err("gui_tile_state field not found in das object".into());
        }
    } else {
        println!("Warning: 'das' object not found in JSON root");
        flush_stdout();
        return Err("das object not found in JSON root".into());
    }
    
    println!("Step 3: Writing modified JSON back to file...");
    flush_stdout();
    write_json_file(path, &json)?;
    
    println!("Operation completed successfully: gui_tile_state has been reset");
    flush_stdout();
    Ok(())
}