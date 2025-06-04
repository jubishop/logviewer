# Log Viewer

A Ruby command-line tool that converts NDJSON log files into a readable HTML format for easy viewing in your browser.

## Features

- Converts NDJSON log files to HTML tables
- Filters logs by minimum level (trace, debug, info, warning, error, fatal)
- Displays key fields: level, text, file, and method
- Color-coded log levels for easy identification
- Responsive design that works well in any browser
- Automatically opens the generated HTML file in your default browser

## Requirements

- Ruby (any recent version)
- macOS (uses `open` command to launch browser)

## Usage

### Basic Usage

```bash
ruby logviewer.rb example.ndjson
```

This will:
1. Parse the NDJSON file
2. Include all log levels (debug and above)
3. Generate an HTML file in `/tmp/`
4. Open the HTML file in your default browser

### Filter by Log Level

```bash
ruby logviewer.rb --level info example.ndjson
```

Only shows log entries with level "info" and above (info, warning, error, fatal).

### Command Line Options

- `-l, --level LEVEL`: Set minimum log level (trace, debug, info, warning, error, fatal)
- `-h, --help`: Show help message

### Examples

```bash
# Show all logs
ruby logviewer.rb app.ndjson

# Show only warnings and errors
ruby logviewer.rb --level warning app.ndjson

# Show only errors and fatal logs
ruby logviewer.rb -l error system.ndjson
```

## Expected Log Format

The tool expects NDJSON (newline-delimited JSON) files where each line contains a JSON object with these fields:

- `level`: Log level (trace, debug, info, warning, error, fatal)
- `text`: The log message
- `file`: Source file name
- `method`: Function/method name

Example log entry:
```json
{"level":"info","text":"User logged in successfully","file":"auth.rb","method":"login"}
```

## Output

The generated HTML file will be saved in `/tmp/` with a timestamp and automatically opened in your browser. The HTML includes:

- A responsive table layout
- Color-coded log levels
- Sticky header for easy navigation
- Hover effects for better readability
- File and method names in monospace font