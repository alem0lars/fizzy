extern crate skeptic;
extern crate clog;
#[macro_use]
extern crate clap;

use clap::Shell;
use clog::Clog;
use std::env;
use std::fs;
use std::io;
use std::path::{Path, PathBuf};

include!("src/cli.rs");

fn main() {
    generate_doc_tests();
    generate_changelog();
    match generate_cli_completion() {
        Ok(val) => val,
        Err(e) => panic!("Failed to generate CLI completion: {}", e),
    };
}

fn generate_doc_tests() {
    skeptic::generate_doc_tests(&["README.md"]);
}

fn generate_changelog() {
    // Create the struct
    // TODO is it ok to use ~/clog ??
    let mut clog = Clog::with_dir("~/clog").unwrap_or_else(|e| { e.exit(); });

    clog.repository(env!("CARGO_PKG_HOMEPAGE"))
        .subtitle("fizzy changelog")
        .from("374c7f4") // TODO
        .changelog("CHANGELOG.md")
        .version(env!("CARGO_PKG_VERSION"));

    // Write the changelog to the current working directory
    clog.write_changelog().unwrap_or_else(|e| { e.exit(); });
}

fn generate_cli_completion() -> Result<(), io::Error> {
    let out_dir_path: PathBuf = Path::new(&env::var("CARGO_MANIFEST_DIR")
            .unwrap())
        .join("target")
        .join(&env::var("PROFILE").unwrap())
        .join("shell_completion");

    let mut app = build_cli();

    if !out_dir_path.is_dir() {
        try!(fs::create_dir(&out_dir_path));
    }

    app.gen_completions(env!("CARGO_PKG_NAME"),
                        Shell::PowerShell,
                        &out_dir_path);
    app.gen_completions(env!("CARGO_PKG_NAME"), Shell::Bash, &out_dir_path);
    app.gen_completions(env!("CARGO_PKG_NAME"), Shell::Zsh, &out_dir_path);
    app.gen_completions(env!("CARGO_PKG_NAME"), Shell::Fish, &out_dir_path);

    Ok(())
}