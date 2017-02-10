extern crate skeptic;

extern crate clog;


use clog::Clog;


fn main() {
    run_skeptic();
    run_clog();
}

fn run_skeptic() {
    skeptic::generate_doc_tests(&["README.md"]);
}

fn run_clog() {
    // Create the struct
    let mut clog = Clog::with_dir("~/clog").unwrap_or_else(|e| {
        // Prints the error message and exits
        e.exit();
    });

    // TODO
    clog.repository("https://github.com/alem0lars/fizzy")
        .subtitle("fizzy changelog")
        .from("374c7f4")
        .changelog("CHANGELOG.md")
        .version("0.1.0");

    // Write the changelog to the current working directory.
    clog.write_changelog().unwrap_or_else(|e| { e.exit(); });
}