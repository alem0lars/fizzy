#[macro_use]
extern crate log;

extern crate fizzy;

fn main() {
    // let default_cfg_file_path: &Path = Path::new("foo"); // TODO xdg

    let matches = fizzy::cli::build_cli().get_matches();

    //let cfg_file_path: Path = value_t!(matches, "cfg", Path)
    //    .unwrap_or(default_cfg_file_path);
    let verbosity_level: u64 = matches.occurrences_of("verbose");
    let simulate = matches.is_present("simulate");

    fizzy::misc::log::init(verbosity_level);
    debug!("Logger initialized");

    debug!("Successfully parsed commandline arguments:");
    //debug!("Configuration file: {}", cfg_file_path.to_str());
    debug!("Verbosity level: {}", verbosity_level);
    debug!("Simulate: {}", simulate);
}
