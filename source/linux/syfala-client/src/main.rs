use clap::Parser;
use std::io::{BufRead, BufReader};
use std::path::PathBuf;
use std::fs;
use std::process::{Command, Stdio};
use std::net::SocketAddr;
use sysinfo::System;

mod ethernet;

#[derive(Debug, Parser)]
#[command(name = "syfala-load")]
struct Cli {
    // ---------------------------------------
    /// Syfala target to be loaded
    #[arg(value_name = "target")]
    target: Option<PathBuf>,
    // ---------------------------------------
    /// List all syfala targets
    #[arg(short, long)]
    list: bool,
    // ---------------------------------------
    /// Run without reinitializing audio codec(s)
    #[arg(short = 'r', long)]
    no_reset: bool,
    // ---------------------------------------
    /// Syfala target directory
    #[arg(short, long)]
    #[arg(default_value = "/root")]
    #[arg(value_name = "dir")]
    directory: PathBuf,
    // ---------------------------------------
    /// Use ethernet for i/o streaming 
    #[arg(short, long)]
    #[arg(value_hint = clap::ValueHint::Hostname)]
    #[arg(value_name = "IPv4 Address")]
    ethernet: Option<SocketAddr>,
    // -----------------------------------------------------------------
    /// Name of the ethernet client displayed on the network 
    #[arg(short, long)]
    #[arg(default_value = "Syfala FPGA")]
    #[arg(value_hint = clap::ValueHint::Other)]
    #[arg(value_name = "string")]
    name: String,
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
    let cli = Cli::parse();
    if cli.list {
        display_target_list(&cli.directory);
        return;
    }
    match cli.target {
        Some(ref t) => {
            let mut path = cli.directory.clone();
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
                if cli.no_reset {
                    exec.arg("--no-reset");
                }
                let mut exec = exec
                    .spawn()
                    .expect("Command failed");
                // ----------------------------------------------
                // Ethernet (optional)
                // ----------------------------------------------
                if cli.ethernet.is_some() {
                    crate::ethernet::run().unwrap();
                }
                exec.wait().unwrap();
            }
        }
        None => {
            display_target_list(&cli.directory);
            return;
        }
    }
    if cli.list {
        display_target_list(&cli.directory);
    }
}
