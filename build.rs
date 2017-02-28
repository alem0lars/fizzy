extern crate skeptic;
extern crate clog;
#[macro_use]
extern crate clap;

include!("src/cli.rs");

/// Build script entry-point.
fn main() {
    let mut cli_app = build_cli();

    build::generate_doc_tests();
    build::generate_changelog();
    match build::generate_cli_completion(&mut cli_app) {
        Ok(val) => val,
        Err(e) => panic!("Failed to generate CLI completion: {}", e),
    };
}

mod build {
    use clap::{App, Shell};
    use clog::Clog;
    use skeptic;
    use std::env;
    use std::fs;
    use std::io;
    use std::path::Path;

    /// Generate tests for code stored in documents.
    pub fn generate_doc_tests() {
        skeptic::generate_doc_tests(&["README.md"]);
    }

    /// Generate the changelog file.
    pub fn generate_changelog() {
        // Create the struct
        // TODO is it ok to use ~/clog ??
        let mut clog = Clog::with_dir("~/clog")
            .unwrap_or_else(|e| { e.exit(); });

        clog.repository(env!("CARGO_PKG_HOMEPAGE"))
            .subtitle("fizzy changelog")
            .from("374c7f4") // TODO
            .changelog("CHANGELOG.md")
            .version(env!("CARGO_PKG_VERSION"));

        // Write the changelog to the current working directory
        clog.write_changelog().unwrap_or_else(|e| { e.exit(); });
    }

    /// Generate commandline completion.
    ///
    /// Don't generate completion when compiling debug code (faster).
    /// Completions are only needed for deployment.
    pub fn generate_cli_completion(cli_app: &mut App) -> Result<(), io::Error> {
        let manifest_dir = env::var("CARGO_MANIFEST_DIR").unwrap();
        let profile_name = env::var("PROFILE").unwrap();
        let pkg_name = env!("CARGO_PKG_NAME");

        if profile_name == "release" {
            let out_dir_path = Path::new(&manifest_dir)
                .join("target")
                .join(&profile_name)
                .join("shell_completion");

            if !out_dir_path.is_dir() {
                try!(fs::create_dir(&out_dir_path));
            }

            cli_app.gen_completions(pkg_name, Shell::PowerShell, &out_dir_path);
            cli_app.gen_completions(pkg_name, Shell::Bash, &out_dir_path);
            cli_app.gen_completions(pkg_name, Shell::Zsh, &out_dir_path);
            cli_app.gen_completions(pkg_name, Shell::Fish, &out_dir_path);
        }

        Ok(())
    }
}
