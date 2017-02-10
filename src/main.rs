extern crate fizzy;

#[macro_use]
extern crate clap;


use clap::{Arg, App, SubCommand};


pub fn main() {
    let matches = App::new("fizzy")
        .version(crate_version!())
        .about("The hassle-free configuration manager")
        .author(crate_authors!())
        .get_matches();
}
