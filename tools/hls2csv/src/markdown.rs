
use std::path::PathBuf;
use std::process::Command;

pub fn generate_mdtable(path: &PathBuf) {
    println!("Generating .md table file");
    let mut mdpath = PathBuf::from(path);
    mdpath.set_extension("md");
    Command::new("mdtable")
        .arg(path)
        .arg("-o").arg(mdpath)
        .output()
        .expect("Markdown generation failed!");
}
