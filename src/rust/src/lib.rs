use extendr_api::prelude::*;
use rayon::prelude::*;
use regex::Regex;

/// Return string `"Hello world!"` to R.
/// @export
#[extendr]
fn hello_world() -> &'static str {
    "Hello world!"
}

#[extendr]
fn string_detect(s: Vec<String>, re: String) -> Vec<bool> {
  let re = Regex::new(&re).unwrap();
  s.iter().map(|x| re.is_match(x)).collect()
}

#[extendr]
fn string_detect_par(s: Vec<String>, re: String) -> Vec<bool> {
    let re = Regex::new(&re).unwrap();
    s.par_iter().map(|x| re.is_match(x)).collect()
}

// Macro to generate exports.
// This ensures exported functions are registered with R.
// See corresponding C code in `entrypoint.c`.
extendr_module! {
    mod benchmarkStringDetection;
    fn hello_world;
    fn string_detect;
    fn string_detect_par;
}
