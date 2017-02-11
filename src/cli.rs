use clap::{Arg, App};

pub fn build_cli() -> App<'static, 'static> {
    return app_from_crate!()
        .arg(Arg::with_name("cfg")
            .short("c")
            .long("cfg")
            .aliases(&["config", "configuration"])
            .takes_value(true)
            .value_name("CONFIGURATION_FILE")
            .help("Sets a custom configuration file"))
        .arg(Arg::with_name("simulate")
            .short("s")
            .long("simulate")
            .alias("dry-run")
            .help("Dry run in simulation mode, system will be untouched"))
        .arg(Arg::with_name("verbose")
            .short("v")
            .long("verbose")
            .alias("verbosity")
            .multiple(true)
            .help("Sets the level of verbosity"));
}