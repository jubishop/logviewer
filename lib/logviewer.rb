require 'json'
require 'optparse'
require 'fileutils'
require 'time'
require_relative 'logviewer/version'

module LogViewer
  class CLI
    LOG_LEVELS = {
      'trace' => 0,
      'debug' => 1,
      'info' => 2,
      'warning' => 3,
      'error' => 4,
      'fatal' => 5
    }

    def initialize(args = ARGV)
      @args = args
      @min_level = 'debug'
      @input_file = nil
    end

    def parse_options
      OptionParser.new do |opts|
        opts.banner = "Usage: logviewer [options] [ndjson_file]"
        
        opts.on('-l', '--level LEVEL', 'Minimum log level (trace, debug, info, warning, error, fatal)') do |level|
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
      
      File.foreach(@input_file) do |line|
        begin
          log_entry = JSON.parse(line.strip)
          
          if should_include_log?(log_entry['level'])
            logs << {
              timestamp: log_entry['timestamp'] || '',
              level: log_entry['level'] || 'unknown',
              tag: log_entry['tag'] || '',
              text: log_entry['text'] || '',
              file: log_entry['file'] || '',
              line: log_entry['line'],
              method: log_entry['method'] || ''
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
        '#6c757d'
      when 'debug'
        '#6c757d'
      when 'info'
        '#0d6efd'
      when 'warning'
        '#fd7e14'
      when 'error'
        '#dc3545'
      when 'fatal'
        '#6f42c1'
      else
        '#000000'
      end
    end

    def format_timestamp(timestamp_str)
      return '' if timestamp_str.nil? || timestamp_str.empty?
      
      begin
        time = Time.parse(timestamp_str)
        time.strftime('%m/%d %H:%M:%S')
      rescue => e
        timestamp_str # fallback to original if parsing fails
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
                    background-color: #f8f9fa;
                }
                .container {
                    max-width: 1800px;
                    margin: 0 auto;
                    background: white;
                    border-radius: 8px;
                    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
                    overflow: hidden;
                }
                .header {
                    background: #343a40;
                    color: white;
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
                }
                th {
                    background: #e9ecef;
                    padding: 18px;
                    text-align: left;
                    font-weight: 600;
                    border-bottom: 2px solid #dee2e6;
                    position: sticky;
                    top: 0;
                }
                td {
                    padding: 15px 18px;
                    border-bottom: 1px solid #dee2e6;
                    vertical-align: top;
                }
                tr:hover {
                    background-color: #f8f9fa;
                }
                .level {
                    font-weight: bold;
                    text-transform: uppercase;
                    font-size: 16px;
                    white-space: nowrap;
                }
                .text {
                    min-width: 600px;
                    word-wrap: break-word;
                    white-space: pre-wrap;
                }
                .file {
                    font-family: 'Monaco', 'Menlo', monospace;
                    font-size: 16px;
                    color: #666;
                    max-width: 200px;
                    word-wrap: break-word;
                }
                .method {
                    font-family: 'Monaco', 'Menlo', monospace;
                    font-size: 16px;
                    color: #333;
                    font-weight: 500;
                }
                .timestamp {
                    font-family: 'Monaco', 'Menlo', monospace;
                    font-size: 15px;
                    color: #666;
                    white-space: nowrap;
                }
                .tag {
                    font-family: 'Monaco', 'Menlo', monospace;
                    font-size: 16px;
                    color: #007acc;
                    font-weight: 500;
                }
                .line {
                    font-family: 'Monaco', 'Menlo', monospace;
                    font-size: 16px;
                    color: #999;
                    text-align: right;
                }
                .empty {
                    color: #999;
                    font-style: italic;
                }
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h1>Log Viewer</h1>
                    <p>#{File.basename(@input_file)} • #{logs.length} entries • Level: #{@min_level.upcase}+</p>
                </div>
                <div class="table-container">
                    <table>
                        <thead>
                            <tr>
                                <th style="width: 120px;">Timestamp</th>
                                <th style="width: 80px;">Level</th>
                                <th style="width: 120px;">Tag</th>
                                <th>Text</th>
                                <th style="width: 180px;">File</th>
                                <th style="width: 50px;">Line</th>
                                <th style="width: 100px;">Method</th>
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
        line_content = log[:line].nil? ? '<span class="empty">-</span>' : log[:line]
        method_content = log[:method].empty? ? '<span class="empty">-</span>' : log[:method]
        
        html += <<~HTML
                                <tr>
                                    <td class="timestamp">#{timestamp_content}</td>
                                    <td class="level" style="#{level_style}">#{log[:level]}</td>
                                    <td class="tag">#{tag_content}</td>
                                    <td class="text">#{text_content}</td>
                                    <td class="file">#{file_content}</td>
                                    <td class="line">#{line_content}</td>
                                    <td class="method">#{method_content}</td>
                                </tr>
        HTML
      end

      html += <<~HTML
                        </tbody>
                    </table>
                </div>
            </div>
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