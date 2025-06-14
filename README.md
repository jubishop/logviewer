# LogViewer

A Ruby gem that converts NDJSON log files into a readable HTML format for easy viewing in your browser.

## Features

- Converts NDJSON log files to HTML tables
- Filters logs by minimum level (trace, debug, info, notice, warning, error, critical)
- Displays key fields: date, level, tag, file, function, and text
- Human-readable timestamp formatting (MM/DD HH:MM:SS)
- Simplified file paths (shows only filename, not full path)
- Color-coded log levels for easy identification
- Large, readable fonts throughout the interface (18px base size)
- Interactive dynamic filtering by log level in the browser
- Dark mode interface with optimized colors for comfortable viewing
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
1. Parse the NDJSON file
2. Include all log levels (trace and above by default)
3. Generate an HTML file in `/tmp/`
4. Open the HTML file in your default browser (initially filtered to debug+)

### Filter by Log Level

```bash
logviewer --level info example.ndjson
```

Only includes log entries with level "info" and above in the HTML file. You can then use the interactive dropdown in the browser to filter within those entries.

### Auto-Detection of Log Files

When no file is specified, LogViewer automatically searches the current directory for `.ndjson` files and uses the one with the most recent modification date:

```bash
logviewer --level info
```

This will find the most recent `.ndjson` file in the current directory and apply the specified log level filter.

### Command Line Options

- `-l, --level LEVEL`: Set minimum log level (trace, debug, info, notice, warning, error, critical)
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

- `timestamp`: Unix timestamp in milliseconds since epoch (displayed as MM/DD HH:MM:SS)
- `levelName`: Log level (trace, debug, info, notice, warning, error, critical)
- `subsystem` and `category`: Combined to create tag display (e.g., "Play/avPlayer")
- `message`: The log message
- `file`: Source file path (displayed as filename only)
- `function`: Function/method name

Example log entry:
```json
{"timestamp":1749926447359,"levelName":"debug","subsystem":"Play","category":"avPlayer","message":"pausing","file":"PodHaven/PodAVPlayer.swift","function":"pause(overwritePreSeekStatus:)","line":136}
```

## Output

The generated HTML file will be saved in `/tmp/` with a timestamp and automatically opened in your browser. The HTML includes:

- A wide, responsive table layout (1800px max width) with columns in order: date, level, tag, file, function, text
- Interactive log level filtering dropdown for dynamic filtering in the browser
- Dark mode theme with comfortable dark backgrounds and light text
- Human-readable timestamps (MM/DD HH:MM:SS format)
- Color-coded log levels optimized for dark backgrounds
- Sticky header for easy navigation
- Hover effects for better readability
- Large fonts (18px base size) for excellent readability
- Simplified file display (filename only, not full paths)
- Optimized column widths with expanded text area for log messages
- Date, file, and function names in monospace font
- Color-coded tags for easy categorization

## Interactive Features

Once the HTML file opens in your browser, you can:
- Use the dropdown in the header to dynamically filter log entries by minimum level
- Filter changes are applied instantly without page reload
- Entry counts update automatically to show how many entries match the current filter
- Command line level controls what entries are included in the HTML file
- Browser initially shows debug+ level by default, regardless of command line level
- Browser filtering works within the entries included from the command line

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