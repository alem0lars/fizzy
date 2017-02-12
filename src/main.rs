#[macro_use]
extern crate log;

extern crate fizzy;

fn main() {
    let matches = fizzy::cli::build_cli().get_matches();
    let cli_args = fizzy::cli::parse_arguments(&matches);

    fizzy::misc::log::init(cli_args.verbosity_level);
    debug!("Logger initialized");

    debug!("Successfully parsed commandline arguments:");
    // TODO    debug!("Configuration file: {}", cli_args.cfg_file_path);
    debug!("Verbosity level: {}", cli_args.verbosity_level);
    debug!("Simulate: {}", cli_args.simulate);
}
