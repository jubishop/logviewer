# LogViewer

A Ruby gem that converts NDJSON log files into a readable HTML format for easy viewing in your browser.

## Features

- Converts NDJSON log files to HTML tables
- Filters logs by minimum level (trace, debug, info, warning, error, fatal)
- Displays key fields: date, level, tag, file, function, and text
- Human-readable timestamp formatting (MM/DD HH:MM:SS)
- Simplified file paths (shows only filename, not full path)
- Color-coded log levels for easy identification
- Large, readable fonts throughout the interface (18px base size)
- Responsive design that works well in any browser
- Automatically opens the generated HTML file in your default browser

## Installation

Install the gem from RubyGems:

```bash
gem install logviewer
```

## Usage

### Basic Usage

```bash
# With a specific file
logviewer example.ndjson

# Without specifying a file (auto-detects most recent .ndjson file)
logviewer
```

This will:
1. Parse the NDJSON file (or auto-detect the most recent .ndjson file in current directory)
2. Include all log levels (debug and above)
3. Generate an HTML file in `/tmp/`
4. Open the HTML file in your default browser

### Filter by Log Level

```bash
logviewer --level info example.ndjson
```

Only shows log entries with level "info" and above (info, warning, error, fatal).

### Auto-Detection of Log Files

When no file is specified, LogViewer automatically searches the current directory for `.ndjson` files and uses the one with the most recent modification date:

```bash
logviewer --level info
```

This will find the most recent `.ndjson` file in the current directory and apply the specified log level filter.

### Command Line Options

- `-l, --level LEVEL`: Set minimum log level (trace, debug, info, warning, error, fatal)
- `-v, --version`: Show version
- `-h, --help`: Show help message

### Examples

```bash
# Show all logs from a specific file
logviewer app.ndjson

# Auto-detect most recent .ndjson file and show all logs
logviewer

# Auto-detect most recent .ndjson file and show only warnings and above
logviewer --level warning

# Show only errors and fatal logs from specific file
logviewer -l error system.ndjson

# Show version
logviewer --version
```

## Expected Log Format

The tool expects NDJSON (newline-delimited JSON) files where each line contains a JSON object with these fields:

- `timestamp`: ISO 8601 timestamp (e.g., "2025-06-02T18:22:48.855-07:00") (displayed as MM/DD HH:MM:SS)
- `level`: Log level (trace, debug, info, warning, error, fatal)
- `tag`: Category or module tag (e.g., "Play/manager")
- `text`: The log message
- `file`: Source file path (displayed as filename only)
- `method`: Function/method name

Example log entry:
```json
{"timestamp":"2025-06-02T18:22:48.855-07:00","level":"info","tag":"Auth/manager","text":"User logged in successfully","file":"auth.rb","method":"login"}
```

## Output

The generated HTML file will be saved in `/tmp/` with a timestamp and automatically opened in your browser. The HTML includes:

- A wide, responsive table layout (1800px max width) with columns in order: date, level, tag, file, function, text
- Human-readable timestamps (MM/DD HH:MM:SS format)
- Color-coded log levels
- Sticky header for easy navigation
- Hover effects for better readability
- Large fonts (18px base size) for excellent readability
- Simplified file display (filename only, not full paths)
- Optimized column widths with expanded text area for log messages
- Date, file, and function names in monospace font
- Color-coded tags for easy categorization

## Development

After checking out the repo, run the following commands to set up development:

```bash
# Install dependencies
bundle install

# Build the gem
rake build

# Install locally for testing
rake install

# Clean build artifacts
rake clean
```

### Building and Publishing

```bash
# Build the gem
rake build

# Install locally
rake install

# Push to RubyGems (requires authentication)
rake push
```

## Requirements

- Ruby 2.5.0 or higher
- macOS (uses `open` command to launch browser)

## License

MIT