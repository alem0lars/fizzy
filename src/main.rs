extern crate fizzy;
extern crate clap;

use clap::{Arg, App, SubCommand};

pub fn main() {
    let matches = App::new("fizzy")
        .version(env!("CARGO_PKG_VERSION"))
        .about("The hassle-free configuration manager")
        .author("Alessandro Molari <molari.alessandro@gmail.com>")
        .get_matches();
}
