# _plugins/rouge/hdl.rb
require 'rouge'

module Rouge
  module Lexers
    class HDL < RegexLexer
      tag 'hdl'
      filenames '*.hdl'
      mimetypes 'text/x-hdl'

      # Keywords
      keywords = %w(
        CHIP IN OUT BUILTIN PARTS
      )

      # Built-in gates
      builtins = %w(
        Nand And Or Not Xor Mux DMux
        Add16 Inc16 ALU Register RAM8 RAM64
      )

      # Pin directions and types
      pins = %w(in out)

      state :root do
        rule %r(//.*), Comment::Single
        rule %r(/\*), Comment::Multiline, :comment
        rule %r/\b(#{keywords.join('|')})\b/, Keyword
        rule %r/\b(#{builtins.join('|')})\b/, Name::Builtin
        rule %r/\b(#{pins.join('|')})\b/, Keyword::Pseudo
        rule %r/[a-zA-Z_]\w*/, Name::Variable
        rule %r/\d+/, Num
        rule %r/[\[\]\(\)\{\},;=]/, Punctuation
        rule %r/[\.:&|<>]/, Operator  # Treat these as operators
        rule %r/\s+/, Text::Whitespace
      end

      state :comment do
        rule %r/\*\//, Comment::Multiline, :pop!  # Highlight '*/' as part of the comment
        rule %r/[^\*]+/, Comment::Multiline
        rule %r/\*/, Comment::Multiline  # Highlight '*' as part of the comment
      end
    end
  end
end
