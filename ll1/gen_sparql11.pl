
top_symbol(sparql11).
output_file('sparql11_table.js').

js_vars([
  defaultQueryType=null,
  lexVersion='"sparql11"',
  startSymbol='"sparql11"',
  acceptEmpty=true
]).

:-reconsult(gen_ll1).
:-reconsult('sparql11grammar.pl').
