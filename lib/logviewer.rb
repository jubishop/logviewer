 require 'json'
require 'optparse'
require 'fileutils'
require 'time'
require 'set'
require_relative 'logviewer/version'

module LogViewer
  class CLI
    LOG_LEVELS = {
      'trace' => 0,
      'debug' => 1,
      'info' => 2,
      'notice' => 3,
      'warning' => 4,
      'error' => 5,
      'critical' => 6
    }

    def initialize(args = ARGV)
      @args = args
      @min_level = 'trace'
      @input_file = nil
    end

    def parse_options
      OptionParser.new do |opts|
        opts.banner = "Usage: logviewer [options] [ndjson_file]"

        opts.on('-l', '--level LEVEL', 'Minimum log level (trace, debug, info, notice, warning, error, critical)') do |level|
          level = level.downcase
          if LOG_LEVELS.key?(level)
            @min_level = level
          else
            puts "Invalid log level: #{level}"
            puts "Valid levels: #{LOG_LEVELS.keys.join(', ')}"
            exit 1
          end
        end

        opts.on('-v', '--version', 'Show version') do
          puts "logviewer #{LogViewer::VERSION}"
          exit
        end

        opts.on('-h', '--help', 'Show this help message') do
          puts opts
          exit
        end
      end.parse!(@args)

      if @args.empty?
        @input_file = find_most_recent_ndjson_file
        if @input_file.nil?
          puts "Error: No .ndjson files found in current directory"
          puts "Usage: logviewer [options] [ndjson_file]"
          exit 1
        end
        puts "No file specified, using most recent .ndjson file: #{@input_file}"
      else
        @input_file = @args[0]
      end

      unless File.exist?(@input_file)
        puts "Error: File not found: #{@input_file}"
        exit 1
      end
    end

    def find_most_recent_ndjson_file
      ndjson_files = Dir.glob('*.ndjson')
      return nil if ndjson_files.empty?

      # Sort by modification time (most recent first) and return the first one
      ndjson_files.max_by { |file| File.mtime(file) }
    end

    def should_include_log?(level)
      return true unless level
      LOG_LEVELS[level.downcase] >= LOG_LEVELS[@min_level]
    end

    def parse_logs
      logs = []
      @all_tags = Set.new

      File.foreach(@input_file) do |line|
        begin
          log_entry = JSON.parse(line.strip)

          if should_include_log?(log_entry['levelName'])
            # Build tag from subsystem/category
            tag = []
            tag << log_entry['subsystem'] if log_entry['subsystem']
            tag << log_entry['category'] if log_entry['category']
            tag_string = tag.join('/')
            @all_tags.add(tag_string) unless tag_string.empty?

            logs << {
              timestamp: log_entry['timestamp'] || '',
              level: log_entry['levelName'] || 'unknown',
              tag: tag_string,
              text: log_entry['message'] || '',
              file: log_entry['file'] || '',
              method: log_entry['function'] || ''
            }
          end
        rescue JSON::ParserError => e
          puts "Warning: Skipping invalid JSON line: #{e.message}"
        end
      end

      logs
    end

    def level_color(level)
      case level.downcase
      when 'trace'
        '#adb5bd'
      when 'debug'
        '#adb5bd'
      when 'info'
        '#6ea8fe'
      when 'notice'
        '#ffc107'
      when 'warning'
        '#fd9843'
      when 'error'
        '#ea868f'
      when 'critical'
        '#c29ffa'
      else
        '#e0e0e0'
      end
    end

    def format_timestamp(timestamp)
      return '' if timestamp.nil? || timestamp == ''

      begin
        # Convert milliseconds to seconds for Time.at
        time = Time.at(timestamp / 1000.0)
        time.strftime('%m/%d %H:%M:%S')
      rescue => e
        timestamp.to_s # fallback to original if parsing fails
      end
    end

    def extract_filename(file_path)
      return '' if file_path.nil? || file_path.empty?
      File.basename(file_path)
    end

    def generate_html(logs)
      html = <<~HTML
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Log Viewer - #{File.basename(@input_file)}</title>
            <style>
                body {
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                    margin: 0;
                    padding: 20px;
                    background-color: #1a1a1a;
                    color: #e0e0e0;
                }
                .container {
                    max-width: 1800px;
                    margin: 0 auto;
                    background: #2d2d2d;
                    border-radius: 8px;
                    box-shadow: 0 2px 10px rgba(0,0,0,0.3);
                    overflow: hidden;
                }
                .header {
                    background: #1e1e1e;
                    color: #f0f0f0;
                    padding: 20px;
                    text-align: center;
                }
                .header h1 {
                    margin: 0;
                    font-size: 24px;
                }
                .header p {
                    margin: 5px 0 0 0;
                    opacity: 0.8;
                }
                .table-container {
                    overflow-x: auto;
                }
                table {
                    width: 100%;
                    border-collapse: collapse;
                    font-size: 18px;
                    table-layout: fixed;
                }
                th {
                    background: #3a3a3a;
                    color: #f0f0f0;
                    padding: 18px;
                    text-align: left;
                    font-weight: 600;
                    border-bottom: 2px solid #555555;
                    position: sticky;
                    top: 0;
                }
                td {
                    padding: 15px 18px;
                    border-bottom: 1px solid #404040;
                    vertical-align: top;
                    color: #e0e0e0;
                }
                tr:hover {
                    background-color: #3a3a3a;
                }
                .level {
                    font-weight: bold;
                    text-transform: uppercase;
                    font-size: 16px;
                    white-space: nowrap;
                }
                .text {
                    word-wrap: break-word;
                    white-space: pre-wrap;
                    width: auto;
                }
                .file {
                    font-family: 'Monaco', 'Menlo', monospace;
                    font-size: 16px;
                    color: #b0b0b0;
                    max-width: 200px;
                    word-wrap: break-word;
                }
                .method {
                    font-family: 'Monaco', 'Menlo', monospace;
                    font-size: 16px;
                    color: #d0d0d0;
                    font-weight: 500;
                    max-width: 300px;
                    word-wrap: break-word;
                    overflow-wrap: break-word;
                }
                .timestamp {
                    font-family: 'Monaco', 'Menlo', monospace;
                    font-size: 15px;
                    color: #b0b0b0;
                    white-space: nowrap;
                }
                .tag {
                    font-family: 'Monaco', 'Menlo', monospace;
                    font-size: 16px;
                    color: #5dade2;
                    font-weight: 500;
                    word-wrap: break-word;
                    overflow-wrap: break-word;
                }

                .empty {
                    color: #777;
                    font-style: italic;
                }
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h1>Log Viewer</h1>
                    <p>#{File.basename(@input_file)} • #{logs.length} entries • Level: #{@min_level.upcase}+</p>
                    <div style="margin-top: 15px;">
                        <label for="levelFilter" style="color: white; margin-right: 10px;">Filter by level:</label>
                        <select id="levelFilter" style="padding: 5px; font-size: 14px; border-radius: 4px; border: none; background-color: #3a3a3a; color: #f0f0f0;">
      HTML

    # Generate dropdown options only for levels >= command line minimum
    min_level_num = LOG_LEVELS[@min_level]
    LOG_LEVELS.each do |level, level_num|
      if level_num >= min_level_num
        html += <<~HTML
                            <option value="#{level}">#{level.upcase}+</option>
        HTML
      end
    end

    html += <<~HTML
                        </select>

                        <div style="margin-top: 10px;">
                            <label for="tagFilter" style="color: white; margin-right: 10px;">Filter by tags:</label>
                            <select id="tagFilter" multiple style="padding: 5px; font-size: 14px; border-radius: 4px; border: none; background-color: #3a3a3a; color: #f0f0f0; min-height: 100px; width: 300px;">
#{@all_tags.sort.map { |tag| "                                <option value=\"#{tag}\" selected>#{tag}</option>" }.join("\n")}
                            </select>
                            <div style="margin-top: 5px; font-size: 12px; color: #ccc;">
                                <button id="selectAllTags" style="padding: 3px 8px; margin-right: 5px; background: #5a5a5a; color: white; border: none; border-radius: 3px; cursor: pointer;">Select All</button>
                                <button id="clearAllTags" style="padding: 3px 8px; background: #5a5a5a; color: white; border: none; border-radius: 3px; cursor: pointer;">Clear All</button>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="table-container">
                    <table>
                        <thead>
                            <tr>
                                <th style="width: 120px;">Date</th>
                                <th style="width: 80px;">Level</th>
                                <th style="width: 120px;">Tag</th>
                                <th style="width: 180px;">File</th>
                                <th style="width: 300px;">Function</th>
                                <th style="width: auto;">Text</th>
                            </tr>
                        </thead>
                        <tbody>
      HTML

      logs.each do |log|
        level_style = "color: #{level_color(log[:level])}"
        formatted_timestamp = format_timestamp(log[:timestamp])
        timestamp_content = formatted_timestamp.empty? ? '<span class="empty">-</span>' : formatted_timestamp
        tag_content = log[:tag].empty? ? '<span class="empty">-</span>' : log[:tag]
        text_content = log[:text].empty? ? '<span class="empty">-</span>' : log[:text]
        filename = extract_filename(log[:file])
        file_content = filename.empty? ? '<span class="empty">-</span>' : filename
        method_content = log[:method].empty? ? '<span class="empty">-</span>' : log[:method]

        html += <<~HTML
                                <tr data-level="#{log[:level].downcase}" data-level-num="#{LOG_LEVELS[log[:level].downcase] || 0}" data-tag="#{log[:tag]}">
                                    <td class="timestamp">#{timestamp_content}</td>
                                    <td class="level" style="#{level_style}">#{log[:level]}</td>
                                    <td class="tag">#{tag_content}</td>
                                    <td class="file">#{file_content}</td>
                                    <td class="method">#{method_content}</td>
                                    <td class="text">#{text_content}</td>
                                </tr>
        HTML
      end

      html += <<~HTML
                        </tbody>
                    </table>
                </div>
            </div>

            <script>
                const LOG_LEVELS = {
                    'trace': 0,
                    'debug': 1,
                    'info': 2,
                    'notice': 3,
                    'warning': 4,
                    'error': 5,
                    'critical': 6
                };

                const levelFilter = document.getElementById('levelFilter');
                const tagFilter = document.getElementById('tagFilter');
                const selectAllTagsBtn = document.getElementById('selectAllTags');
                const clearAllTagsBtn = document.getElementById('clearAllTags');
                const tableRows = document.querySelectorAll('tbody tr');

                // Set initial filter to debug (default UI filter)
                levelFilter.value = 'debug';

                function getSelectedTags() {
                    const selected = [];
                    for (let option of tagFilter.selectedOptions) {
                        selected.push(option.value);
                    }
                    return selected;
                }

                function applyFilters() {
                    const selectedLevel = levelFilter.value;
                    const selectedLevelNum = LOG_LEVELS[selectedLevel];
                    const selectedTags = getSelectedTags();
                    let visibleCount = 0;

                    tableRows.forEach(row => {
                        const rowLevelNum = parseInt(row.dataset.levelNum);
                        const rowTag = row.dataset.tag;

                        const levelMatch = rowLevelNum >= selectedLevelNum;
                        const tagMatch = selectedTags.length === 0 || selectedTags.includes(rowTag) || rowTag === '';

                        if (levelMatch && tagMatch) {
                            row.style.display = '';
                            visibleCount++;
                        } else {
                            row.style.display = 'none';
                        }
                    });

                    // Update the header count
                    const header = document.querySelector('.header p');
                    const originalText = header.textContent.split(' • ');
                    const headerParts = [
                        originalText[0], // filename
                        visibleCount + ' entries',
                        'Level: ' + selectedLevel.toUpperCase() + '+'
                    ];

                    if (selectedTags.length > 0 && selectedTags.length < tagFilter.options.length) {
                        headerParts.push('Tags: ' + selectedTags.length + ' selected');
                    }

                    header.textContent = headerParts.join(' • ');
                }

                selectAllTagsBtn.addEventListener('click', function() {
                    for (let option of tagFilter.options) {
                        option.selected = true;
                    }
                    applyFilters();
                });

                clearAllTagsBtn.addEventListener('click', function() {
                    for (let option of tagFilter.options) {
                        option.selected = false;
                    }
                    applyFilters();
                });

                levelFilter.addEventListener('change', applyFilters);
                tagFilter.addEventListener('change', applyFilters);

                // Apply initial filter
                applyFilters();
            </script>
        </body>
        </html>
      HTML

      html
    end

    def run
      parse_options

      puts "Parsing log file: #{@input_file}"
      puts "Minimum log level: #{@min_level}"

      logs = parse_logs
      puts "Found #{logs.length} log entries matching criteria"

      if logs.empty?
        puts "No log entries found matching the specified criteria."
        exit 0
      end

      html_content = generate_html(logs)

      # Use /tmp directory for HTML files
      tmp_dir = '/tmp'

      # Generate output filename
      base_name = File.basename(@input_file, '.*')
      timestamp = Time.now.strftime('%Y%m%d_%H%M%S')
      output_file = File.join(tmp_dir, "#{base_name}_#{timestamp}.html")

      # Write HTML file
      File.write(output_file, html_content)
      puts "HTML file created: #{output_file}"

      # Open in browser
      system('open', output_file)
      puts "Opening in browser..."
    end
  end
end
