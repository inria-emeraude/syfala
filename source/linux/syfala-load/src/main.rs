use clap::{Args, Parser, Subcommand, ValueEnum};
use std::path::{Path, PathBuf};
use std::fs::File;
use std::fs;
use std::io::BufReader;
use std::process::Command;
use sysinfo::{Pid, Signal, System};

#[derive(Debug, Parser)]
#[command(name = "syfala-load")]
struct Cli {
// ---------------------------------------
    #[arg(help = "Syfala target to be loaded")]
    #[arg(value_name = "target")]
    target: Option<PathBuf>,
// ---------------------------------------
    #[arg(short, long)]
    #[arg(help = "List all syfala targets")]
    list: bool,
// ---------------------------------------
    #[arg(short, long)]
    #[arg(help = "Do not reinitialize audio codec(s)")]
    no_reset: bool,
// ---------------------------------------
    #[arg(short, long)]
    #[arg(default_value = "/root")]
    #[arg(value_name = "dir")]
    #[arg(help = "Syfala target directory")]
    directory: PathBuf,
// ---------------------------------------
    #[arg(short, long)]
    #[arg(help = "Run the syfala-ethernet client")]
    #[arg(value_name = "IPv6 address")]
    ethernet: Option<String>,
}

fn is_syfala_target(target: &PathBuf) -> bool {
    let mut app = false;
    let mut bin = false;
    let entries = fs::read_dir(target).unwrap();
    for entry in entries {
        let d = entry.as_ref().unwrap();
        if d.file_type().unwrap().is_file() {
            if d.file_name() == "application.elf" {
                app = true;
            } else if d.file_name() == "bitstream.bin" {
                bin = true;
            }
        }
        if app && bin {
            return true;
        }
    }
    return false;
}

fn display_target_list(dir: &PathBuf) {
    println!("Checking directory: {:?}", dir);
    let paths = fs::read_dir(dir).unwrap();
    for p in paths {
        let path = p.as_ref().unwrap().path();
        if path.is_dir() && is_syfala_target(&path) {
            println!("syfala target: {:?}", path.file_name().unwrap());
        }
    }
}

fn terminate_child_process(id: String) {
    Command::new("kill")
        .arg(id)
        .output()
        .expect("Couldn't kill process");
}

fn check_terminate_running_processes() {
    let s = System::new_all();
    println!("Checking for already-running syfala processes");
    for p in s.processes_by_name("application.elf") {
        println!("Termating process: {}:{}", p.pid(), p.name());
        terminate_child_process(p.pid().to_string());
    }
}

fn main() {
    let arguments = Cli::parse();
    if arguments.list {
        display_target_list(&arguments.directory);
        return;
    }
    match arguments.target {
        Some(t) => {
            let mut path = arguments.directory.clone();
            println!("Attempting to load target: {:?}", &t);
            path.push(t);
            if is_syfala_target(&path) {
                check_terminate_running_processes();
                // ----------------------------------------------
                println!("Loading bitstream: {:?}", path);
                // ----------------------------------------------
                path.push("bitstream.bin");
                Command::new("fpgautil")
                    .arg("-b")
                    .arg(path.to_str().unwrap())
                    .status()
                    .expect("Command failed");
                // ----------------------------------------------
                println!("Running ARM executable...");
                // ----------------------------------------------
                path.pop();
                path.push("application.elf");
                let mut exec = Command::new(path.to_str().unwrap());
                if arguments.no_reset {
                    exec.arg("--no-reset");
                }
                let mut exec = exec.spawn().expect("Command failed");
                // ----------------------------------------------
                // Ethernet (optional)
                // ----------------------------------------------
                if arguments.ethernet.is_some() {
                    println!("Starting syfala-ethernet...");
                    std::thread::sleep(std::time::Duration::from_secs(5));
                    let mut eth = Command::new("syfala-ethernet")
                        .arg("--server")
                        .arg(arguments.ethernet.unwrap())
                        .spawn()
                        .expect("Command failed");
                    ctrlc::set_handler(move || {
                        println!("Received SIGINT, terminating subprograms");
                        terminate_child_process(eth.id().to_string());
                        terminate_child_process(exec.id().to_string());
                    });
                } else {
                    ctrlc::set_handler(move || {
                        println!("Received SIGINT, terminating subprograms");
                        terminate_child_process(exec.id().to_string());
                    });
                }
            }
        }
        None => {
            println!("No target was provided, exiting.");
            display_target_list(&arguments.directory);
            return;
        }
    }
    if arguments.list {
        display_target_list(&arguments.directory);
    }
}
