# rdisplay

rdisplay is a Rust application that modifies a specified JSON configuration file by resetting the "gui_tile_state" property to an empty string. 

## Features

- Command-line argument support for specifying the path to the JSON file.
- Default path is set to `/var/lib/ipt4-daemon/settings.das`.
- Parses JSON files and updates the specified property.

## Installation

To build and run the application, ensure you have Rust and Cargo installed. You can download them from [rust-lang.org](https://www.rust-lang.org/).

Clone the repository and navigate to the project directory:

```
git clone <repository-url>
cd rdisplay
```

## Building the Project

Run the following command to build the project:

```
cargo build
```

## Running the Application

You can run the application with the following command:

```
cargo run -- <path-to-json-file>
```

If no path is provided, it will default to `/var/lib/ipt4-daemon/settings.das`.

## Usage Example

To reset the "gui_tile_state" property in the default settings file:

```
cargo run
```

To specify a different JSON file:

```
cargo run -- /path/to/your/file.json
```
building for linux target
```
cargo build --target armv7-unknown-linux-gnueabihf
rustup target add armv7-unknown-linux-gnueabihf
```

## License

This project is licensed under the MIT License. See the LICENSE file for more details.