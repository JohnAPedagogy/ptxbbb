fn read_json_file(path: &str) -> Result<serde_json::Value, std::io::Error> {
    let file = std::fs::File::open(path)?;
    let reader = std::io::BufReader::new(file);
    let json: serde_json::Value = serde_json::from_reader(reader)?;
    Ok(json)
}

fn write_json_file(path: &str, json: &serde_json::Value) -> Result<(), std::io::Error> {
    let file = std::fs::File::create(path)?;
    serde_json::to_writer(file, json)?;
    Ok(())
}

pub fn reset_gui_tile_state(path: &str) -> Result<(), Box<dyn std::error::Error>> {
    let mut json = read_json_file(path)?;
    
    if let Some(gui_tile_state) = json.get_mut("gui_tile_state") {
        *gui_tile_state = serde_json::Value::String("".to_string());
    }
    
    write_json_file(path, &json)?;
    Ok(())
}