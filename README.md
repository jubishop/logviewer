# LogViewer

A Ruby gem that converts NDJSON log files into a readable HTML format for easy viewing in your browser.

## Features

- Converts NDJSON log files to HTML tables
- Filters logs by minimum level (trace, debug, info, warning, error, fatal)
- Displays key fields: timestamp, level, tag, text, file, line, and method
- Color-coded log levels for easy identification
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
logviewer example.ndjson
```

This will:
1. Parse the NDJSON file
2. Include all log levels (debug and above)
3. Generate an HTML file in `/tmp/`
4. Open the HTML file in your default browser

### Filter by Log Level

```bash
logviewer --level info example.ndjson
```

Only shows log entries with level "info" and above (info, warning, error, fatal).

### Command Line Options

- `-l, --level LEVEL`: Set minimum log level (trace, debug, info, warning, error, fatal)
- `-v, --version`: Show version
- `-h, --help`: Show help message

### Examples

```bash
# Show all logs
logviewer app.ndjson

# Show only warnings and above
logviewer --level warning app.ndjson

# Show only errors and fatal logs
logviewer -l error system.ndjson

# Show version
logviewer --version
```

## Expected Log Format

The tool expects NDJSON (newline-delimited JSON) files where each line contains a JSON object with these fields:

- `timestamp`: ISO 8601 timestamp (e.g., "2025-06-02T18:22:48.855-07:00")
- `level`: Log level (trace, debug, info, warning, error, fatal)
- `tag`: Category or module tag (e.g., "Play/manager")
- `text`: The log message
- `file`: Source file name
- `line`: Line number in the source file
- `method`: Function/method name

Example log entry:
```json
{"timestamp":"2025-06-02T18:22:48.855-07:00","level":"info","tag":"Auth/manager","text":"User logged in successfully","file":"auth.rb","line":42,"method":"login"}
```

## Output

The generated HTML file will be saved in `/tmp/` with a timestamp and automatically opened in your browser. The HTML includes:

- A responsive table layout with timestamp, level, tag, text, file, line, and method columns
- Color-coded log levels
- Sticky header for easy navigation
- Hover effects for better readability
- Timestamp, file, line, and method names in monospace font
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