mod csv;
mod parser;
mod report;
mod syfala;
mod markdown;

use crate::csv as rpt2csv;
use crate::report::Report;
use std::path::PathBuf;
use clap::{Parser, Subcommand};

#[derive(Parser, Debug, PartialEq)]
#[command(author = "Inria Emeraude")]
#[command(version = "0.1.0")]
#[command(about = "Simple utility to generate a .csv file from HLS report data.")]

struct Cli {
// ------------------------------------------------------------------
    #[arg(help = "Sets input syfala directory")]
    #[arg(short, long)]
    #[arg(value_name = "path/to/syfala/repository")]
    path: Option<PathBuf>,
// ------------------------------------------------------------------
    #[arg(help = "Sets .csv file output path")]
    #[arg(short, long)]
    #[arg(value_name = "path")]
    output: Option<PathBuf>,
// ------------------------------------------------------------------
    #[arg(help = "Sets a custom label for the report")]
    #[arg(short, long)]
    #[arg(value_name = "string")]
    label: Option<String>,
// ------------------------------------------------------------------
    #[arg(help = "Adds .md table generation with mdtable-cli")]
    #[arg(short, long)]
    markdown: bool,
// ------------------------------------------------------------------
    #[command(subcommand)]
    command: Option<Commands>,
}

#[derive(Debug, Subcommand, PartialEq)]
pub enum Commands {
// ----------------------------------------------------------------------------
    #[command(about = "Concatenate one or several .csv files into a single one")]
    Concat {
    // --------------------------------------------
        #[arg(help = "Source .csv files to be concatenated")]
        #[arg(required = true)]
        #[arg(value_name = "List of .csv file paths")]
        targets: Vec<PathBuf>,
    // --------------------------------------------
        #[arg(help = "Sets .csv file output path")]
        #[arg(short, long)]
        #[arg(value_name = "path")]
        output: Option<PathBuf>,
    }
// ----------------------------------------------------------------------------
}

fn main() {
    let cli = Cli::parse();
    // If the 'concat' command is called:
    if cli.command.is_some() {
        match cli.command.unwrap() {
            Commands::Concat {targets, output} => {
                let mut o = match output {
                    Some(ref f) => PathBuf::from(f),
                           None => PathBuf::from(""),
                };
                // If no specific output name has been specified,
                // set it to 'concat.csv'
                if o.is_dir() || o.as_os_str().is_empty() {
                    o.push("concat.csv");
                }
                rpt2csv::concatenate_reports(&targets, &o);
                return;
            }
        }
    }
    // Otherwise, generate the .csv file.
    // If no arguments have been explicitly provided by the user,
    // such as the '-o' and '-p' arguments, set them to current directory
    let mut output = match cli.output {
        Some(ref f) => PathBuf::from(f),
               None => PathBuf::from("."),
    };
    let path = match cli.path {
        Some(ref f) => PathBuf::from(f),
               None => PathBuf::from(".")
    };
    // Parse syfala parameters for the current build
    // TODO: check if a build is actually been made
    let params = syfala::Parameters::from(&path);
    // Parse the HLS report for the current build.
    let rpt = Report::new(
        &path, &cli.label.unwrap_or("None".to_string())
    );
    // If the output argument is a directory, or has not
    // been explicitly provided by the user, give it the name
    // of the current build target (for example 'bypass.csv')
    if output.is_dir() {
        let mut p = PathBuf::from(&params.file);
        p.set_extension("csv");
        output.push(p.file_name().unwrap());
    }
    // Write the CSV report
    let csv = rpt2csv::write_report(&output, &rpt, &params);
    // Generate the markdown equivalent if option has been set
    if cli.markdown {
        markdown::generate_mdtable(&csv);
    }
    // Copy report files in the same directory as the .csv file
    rpt.copy_files(&path, &csv);
}
