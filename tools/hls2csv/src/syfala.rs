use crate::parser::{values};
use std::path::PathBuf;
use std::process::Command;
use std::error::Error;
use serde::{Serialize, Deserialize};

pub const FPGA_CLOCK_RATE: f32 = 122_885_835f32;

#[allow(dead_code)]
#[derive(Debug, Default, Copy, Clone)]
#[derive(Serialize, Deserialize)]
pub enum Target {
    #[default] Undefined,
    Faust,
    Cpp
}

#[derive(Debug, Default)]
pub struct Faust {
    pub mcd: usize,
    pub mem: usize, // TODO
}

impl Faust {
    fn new(path: &PathBuf) -> Faust {
        Faust {
            mcd: Self::parse_mcd(path).unwrap_or(0),
            mem: 0
        }
    }
    fn parse_mcd(path: &PathBuf) -> Option<usize> {
        let mut p = PathBuf::from(path);
        p.push("makefile.env");
        let mkenv = std::fs::read_to_string(&p).unwrap();
        match values::<usize>(&mkenv, "FAUST_MCD") {
            Some(vec) => Some(vec[0]),
                 None => None,
        }
    }
    fn parse_io(path: &PathBuf) -> (usize, usize) {
        let mut p = PathBuf::from(path);
        p.push("build/syfala_ip/syfala_ip.cpp");
        let mkenv = std::fs::read_to_string(&p).unwrap();
        let i = values::<usize>(&mkenv, "\t#define FAUST_INPUTS").expect(
            format!("Couldn't parse 'FAUST_INPUTS' in {:?}", p.display())
            .as_str()
        );
        let o = values::<usize>(&mkenv, "\t#define FAUST_OUTPUTS").expect(
            format!("Couldn't parse 'FAUST_OUTPUTS' in {:?}", p.display())
            .as_str()
        );
        return (i[0], o[0]);
    }
}

#[derive(Debug, Default)]
pub struct Parameters {
       pub version: String,
        pub commit: String,
        pub branch: String,
          pub file: String,
        pub target: Target,
   pub sample_rate: usize,
  pub sample_width: usize,
      pub nsamples: usize,
            pub io: (usize, usize),
           pub umo: Option<()>,
         pub faust: Option<Faust>
}

fn parse_version(path: &PathBuf) -> Result<String, Box<dyn Error>> {
    // TODO: don't read the whole file...
    let mut p = PathBuf::from(path);
    p.push("Makefile");
    let mk = std::fs::read_to_string(&p)?;
    let vmajor = values::<i32>(&mk, "SYFALA_VERSION_MAJOR")
        .ok_or("Error parsing Syfala version")?
    ;
    let vminor = values::<i32>(&mk, "SYFALA_VERSION_MINOR")
        .ok_or("Error parsing Syfala version")?
    ;
    let vpatch = values::<i32>(&mk, "SYFALA_VERSION_PATCH")
        .ok_or("Error parsing Syfala version")?
    ;
    Ok(format!("{:?}.{:?}.{:?}",
            vmajor.first().unwrap(),
            vminor.first().unwrap(),
            vpatch.first().unwrap()
        )
    )
}

fn parse_branch(_path: &PathBuf) -> Result<String, Box<dyn Error>> {
    let cmd = Command::new("git")
        .arg("symbolic-ref")
        .arg("--short").arg("HEAD")
        .output()?;
    let mut s = String::from_utf8(cmd.stdout)?;
    s.pop();
    Ok(s)
}

fn parse_commit(_path: &PathBuf) -> Result<String, Box<dyn Error>> {
    let cmd = Command::new("git")
        .arg("rev-parse").arg("HEAD")
        .output()?;
    let mut s = String::from_utf8(cmd.stdout)?;
    s.pop();
    Ok(s)
}

fn parse_file(path: &PathBuf) -> Result<(String, Target), Box<dyn Error>> {
    let mut p = PathBuf::from(path);
    p.push("makefile.env");
    let mkenv = std::fs::read_to_string(&p)?;
    let (file, target) = match values::<String>(&mkenv, "FAUST_DSP_TARGET") {
        Some(f) => (f, Target::Faust),
        None => {
            let f = values::<String>(&mkenv, "HLS_SOURCE_MAIN").unwrap();
            (f, Target::Cpp)
        }
    };
    let p = PathBuf::from(&file[2]);
    let s = String::from(p.file_name().unwrap().to_str().unwrap());
    Ok((s, target))
}

fn parse_umo(path: &PathBuf) -> Result<Option<()>, Box<dyn Error>> {
    let mut p = PathBuf::from(path);
    p.push("makefile.env");
    let mkenv = std::fs::read_to_string(&p)?;
    let umo = values::<String>(
        &mkenv, "HLS_DIRECTIVES_UNSAFE_MATH_OPTIMIZATIONS"
    );
    return match umo {
         Some(..) => Ok(Some(())),
             None => Ok(None)
    };
}

fn parse_sample_rate(path: &PathBuf) -> Result<usize, Box<dyn Error>> {
    let mut p = PathBuf::from(path);
    p.push("build/include/syfala/config_common.hpp");
    let f = std::fs::read_to_string(&p).unwrap();
    let s = values::<usize>(&f, "#define SYFALA_SAMPLE_RATE")
        .ok_or("Error parsing SYFALA_SAMPLE_RATE")?
    ;
    Ok(s[0])
}

fn parse_sample_width(path: &PathBuf) -> Result<usize, Box<dyn Error>> {
    let mut p = PathBuf::from(path);
    p.push("build/include/syfala/config_common.hpp");
    let f = std::fs::read_to_string(&p).unwrap();
    let s = values::<usize>(&f, "#define SYFALA_SAMPLE_WIDTH")
        .ok_or("Error parsing SYFALA_SAMPLE_WIDTH")?
    ;
    Ok(s[0])
}

fn parse_nsamples(path: &PathBuf) -> Result<usize, Box<dyn Error>> {
    let mut p = PathBuf::from(path);
    p.push("build/include/syfala/config_common.hpp");
    let f = std::fs::read_to_string(&p).unwrap();
    let s = values::<usize>(&f, "#define SYFALA_BLOCK_NSAMPLES")
        .ok_or("Error parsing SYFALA_BLOCK_NSAMPLES")?
    ;
    Ok(s[0])
}

fn parse_io_cpp(path: &PathBuf) -> (usize, usize) {
    let mut p = PathBuf::from(path);
    p.push("build/syfala_ip/syfala_ip.cpp");
    let mkenv = std::fs::read_to_string(&p).unwrap();
    let i = values::<usize>(&mkenv, "#define INPUTS").unwrap();
    let o = values::<usize>(&mkenv, "#define OUTPUTS").unwrap();
    return (i[0], o[0]);
}

impl From<&PathBuf> for Parameters {
    fn from(path: &PathBuf) -> Parameters {
        let (file, target) = parse_file(path).unwrap();
        let faust = match target {
            Target::Faust => Some(Faust::new(path)),
              Target::Cpp => None,
              Target::Undefined => unreachable!()
        };
        let (i, o) = match target {
            Target::Faust => Faust::parse_io(path),
              Target::Cpp => parse_io_cpp(path),
              Target::Undefined => unreachable!()
        };
        Parameters {
              faust: faust,
               file: file,
             target: target,
                 io: (i, o),
            umo: parse_umo(path)
                .unwrap_or(None),
            version: parse_version(path)
                .unwrap_or(String::from("Undefined")),
            commit: parse_commit(path)
                .unwrap_or(String::from("Undefined")),
            branch: parse_branch(path)
                .unwrap_or(String::from("Undefined")),
            sample_rate: parse_sample_rate(path)
                .unwrap_or(0),
            sample_width: parse_sample_width(path)
                .unwrap_or(0),
            nsamples: parse_nsamples(path)
                .unwrap_or(0),
        }
    }
}


