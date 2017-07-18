$cfg = {}

$cfg[:paths] = {}
$cfg[:paths][:root]     = Pathname.new(__FILE__).expand_path.dirname.dirname.dirname
$cfg[:paths][:metadata] = $cfg[:paths][:root].join("metadata.yaml")
$cfg[:paths][:build]    = $cfg[:paths][:root].join("build")
$cfg[:paths][:pkg]      = $cfg[:paths][:build].join("package")
$cfg[:paths][:tmp]      = $cfg[:paths][:root].join("tmp")
$cfg[:paths][:docker]   = $cfg[:paths][:root].join("docker")
$cfg[:paths][:test]     = $cfg[:paths][:root].join("test")
$cfg[:paths][:website]  = $cfg[:paths][:root].join("website")
$cfg[:paths][:src]      = $cfg[:paths][:root].join("src")
$cfg[:paths][:grammars] = $cfg[:paths][:src].join("grammars")
$cfg[:paths][:bin]      = $cfg[:paths][:build].join("fizzy")
$cfg[:paths][:old_bin]  = $cfg[:paths][:build].join("fizzy_old")
$cfg[:paths][:bin_rb]   = Pathname.new("#{$cfg[:paths][:bin]}.rb")

$cfg[:api_doc] = { markup: {} }
$cfg[:api_doc][:markup][:provider] = "kramdown"
$cfg[:api_doc][:markup][:name] = "markdown"
$cfg[:api_doc][:main] = "README.md"

$cfg[:grammars_source_name] = "<grammars>"

$cfg[:paths][:build].mkpath unless $cfg[:paths][:build].directory?
$cfg[:paths][:pkg].mkpath   unless $cfg[:paths][:pkg].directory?
$cfg[:paths][:tmp].mkpath   unless $cfg[:paths][:tmp].directory?

# ☞ Read build configuration.
$cfg = deep_merge($cfg, symbolize(YAML.load_file($cfg[:paths][:metadata].to_s)))

def $cfg.debug?
  ENV["FIZZY_DEBUG"] == "true"
end
