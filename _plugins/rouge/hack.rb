# _plugins/rouge/hack.rb
require 'rouge'

module Rouge
  module Lexers
    class HackAssembly < RegexLexer
      tag 'hackassembly'
      filenames '*.hack', '*.asm'
      mimetypes 'text/x-hackassembly'

      # Registers and predefined symbols
      registers = %w(A D M AM AD AMD)
      symbols = %w(SP LCL ARG THIS THAT SCREEN KBD R0 R1 R2 R3 R4 R5 R6 R7 R8 R9 R10 R11 R12 R13 R14 R15)

      # C-instruction components
      dest = %w(A D M AM AD AMD)
      comp = %w(0 1 -1 D A !D !A -D -A D+1 A+1 D-1 A-1 D+A D-A A-D D&A D\|A)
      jump = %w(JGT JEQ JGE JLT JNE JLE JMP)

      state :root do
        rule %r(//.*), Comment::Single
        rule %r/@([a-zA-Z_\.\$:][\w\.\$:]*)/, Name::Label  # Labels like @LOOP
        rule %r/@(\d+)/, Num                              # Numeric addresses like @42
        rule %r/\(([a-zA-Z_\.\$:][\w\.\$:]*)\)/, Name::Function  # Labels like (LOOP)
        rule %r/\b(#{dest.join('|')})\b(?=\s*=)/, Keyword::Declaration  # Destinations (e.g., D=)
        rule %r/\b(#{comp.join('|')})\b/, Keyword::Reserved             # Computations (e.g., D+A)
        rule %r/\b(#{jump.join('|')})\b/, Keyword::Type                 # Jumps (e.g., JGT)
        rule %r/\b(#{registers.join('|')})\b/, Name::Builtin            # Registers (A, D, M)
        rule %r/\b(#{symbols.join('|')})\b/, Name::Constant             # Predefined symbols (SP, R0)
        rule %r/[=;]/, Operator
        rule %r/\d+/, Num
        rule %r/\s+/, Text::Whitespace
      end
    end
  end
end
