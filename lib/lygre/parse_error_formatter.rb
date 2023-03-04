class ParseErrorFormatter
  # Extract error information from a Treetop parser as single human-readable
  # and helpful string
  def self.format(parser, input)
    [
      "'#{parser.failure_reason}' on line #{parser.failure_line} column #{parser.failure_column}:",
      input.split("\n")[parser.failure_line - 1],
      (' ' * parser.failure_column) + '^'
    ].join("\n")
  end
end
