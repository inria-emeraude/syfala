
use rand::Rng;
use std::path::PathBuf;
use clap::{Parser, ValueEnum};

#[derive(ValueEnum, Clone, Debug, PartialEq)]
enum Target {Faust, Cpp}

#[derive(Parser, Debug, PartialEq)]
#[command(author = "Inria Emeraude")]
#[command(version = "0.1.0")]
#[command(about = "Simple utility to generate a 'fake' FIR filter with random coefficients")]

struct Cli {
// ------------------------------------------------------------------
    #[arg(help = "Sets the number of coefficients")]
    #[arg(short, long)]
    #[arg(value_name = "integer")]
    ncoeffs: usize,
// ------------------------------------------------------------------
    #[arg(help = "Sets .dsp or .cpp file output path")]
    #[arg(short, long)]
    #[arg(value_name = "path")]
    output: Option<PathBuf>,
// ------------------------------------------------------------------
    #[arg(help = "Choose between Faust .dsp file export or C++ header")]
    #[arg(short, long)]
    #[clap(value_enum)]
    #[clap(default_value_t = Target::Faust)]
    #[arg(value_name = "path")]
    target: Target,
}

fn generate_coeffs(ncoeffs: usize) -> String {
    let mut rdm = rand::thread_rng();
    let mut s = String::new();
    for n in 0..ncoeffs {
        // Generate random number
        let coeff: f64 = rdm.gen_range(0.0..1.0);
        s.push_str(format!("\t{coeff}").as_str());
        if n < ncoeffs-1 {
            s.push_str(",\n");
        }
    }
    return s;
}

fn generate_faust(ncoeffs: usize) -> String {
    let coeffs = generate_coeffs(ncoeffs);
    let s = format!(
        "import(\"stdfaust.lib\");\n\
        coeffs = (\n{coeffs}\n);\n\
        process = fi.fir(coeffs);"
    );
    println!("{s}");
    return s;
}

fn generate_cpp(ncoeffs: usize) -> String {
    let coeffs = generate_coeffs(ncoeffs);
    let s = format!(
        "#pragma once\n\
        #define NCOEFFS {ncoeffs}\n\
        static double coeffs[{ncoeffs}] = {{\n\
        {coeffs}\n\
        }};"
    );
    println!("{s}");
    return s;
}

use std::io::Write;

fn main() -> std::io::Result<()> {
    let cli = Cli::parse();
    let mut p: PathBuf = if cli.output.is_some() {
        cli.output.unwrap()
    } else {
        match cli.target {
            Target::Faust => PathBuf::from(
                format!("fir{}.dsp", cli.ncoeffs)
            ),
            Target::Cpp => PathBuf::from(
                format!("fir{}/fir{}.hpp", cli.ncoeffs, cli.ncoeffs)
            )
        }

    };
    let fir = match cli.target {
        Target::Faust => generate_faust(cli.ncoeffs),
        Target::Cpp => generate_cpp(cli.ncoeffs)
    };
    if cli.target == Target::Cpp {
        std::fs::create_dir_all(format!("fir{}", cli.ncoeffs))?;
    }
    let mut file = std::fs::File::create(p)?;
    file.write_all(fir.as_bytes())?;
    Ok(())
}
