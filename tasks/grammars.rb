def build_grammars
  additional_sources = []

  $cfg[:grammars].each do |grammar_name|
    info("Building grammar `#{grammar_name}`.", indent: 1)
    parser_src_path = $cfg[:paths][:grammars].join(grammar_name, "parser.y")
    lexer_path  = $cfg[:paths][:grammars].join(grammar_name, "lexer.rb")
    evaluator_path  = $cfg[:paths][:grammars].join(grammar_name, "evaluator.rb")
    parser_out_path = $cfg[:paths][:tmp].join("#{grammar_name}_parser.rb")

    status = system("racc " + ($cfg.debug? ? "-g " : "") +
                    "   #{Shellwords.escape(parser_src_path)} " +
                    "-o #{Shellwords.escape(parser_out_path)}")

    error("Failed to run `racc` for `#{parser_src_path}`.") unless status
    additional_sources << lexer_path     if lexer_path.file?
    additional_sources << evaluator_path if evaluator_path.file?
    additional_sources << parser_out_path
  end

  unless additional_sources.empty?
    start_index = $cfg[:sources].find_index($cfg[:grammars_source_name])
    unless start_index
      error("Cannot find `grammar` in `sources` element in `build-cfg.yaml`.")
    end
    $cfg[:sources].insert(start_index, *additional_sources)
    $cfg[:sources].delete($cfg[:grammars_source_name])
  end
end
