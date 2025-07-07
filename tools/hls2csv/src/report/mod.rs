mod latency;
mod resources;

use crate::report::resources::Resources;
use crate::report::latency::Latency;
use crate::parser;
use chrono::prelude::*;
use std::path::{Path, PathBuf};
use serde::{Serialize, Deserialize};

const RPT_ESTIM:
&str = "build/syfala_ip/syfala/syn/report/syfala_csynth.rpt";

const RPT_IMPL:
&str = "build/syfala_ip/syfala/impl/report/vhdl/export_impl.rpt";

#[allow(dead_code)]
const RPT_SYN:
&str = "build/syfala_ip/syfala/impl/report/vhdl/syfala_export.rpt";

#[derive(Default, Clone, Debug)]
#[derive(Serialize, Deserialize)]
pub enum Source {
    #[default]
    Undefined,
    Estimate(
        #[serde(skip)]
        PathBuf
    ),
    Synthesis(
        #[serde(skip)]
        PathBuf
    ),
    Implementation(
        #[serde(skip)]
        PathBuf
    ),
}

#[derive(Debug, Default)]
pub struct Value {
    pub number: i32,
    pub percentage: f32,
    pub guideline: f32,
}

impl Value {
    pub fn new(n: i32, p: f32) -> Value {
        Value {
            number: n,
            percentage: p,
            guideline: 0.0
        }
    }
    pub fn new_with_guideline(n: i32, p: f32, g: f32)
        -> Value {
        Value {
            number: n,
            percentage: p,
            guideline: g,
        }
    }
}

fn get_author() -> String {
    String::from(hostname::get()
        .unwrap()
        .to_str()
        .unwrap()
    )
}

fn get_date(path: &PathBuf) -> String {
    let metadata = std::fs::metadata(path).unwrap();
    if let Ok(t) = metadata.created() {
        let dt: chrono::DateTime<Local> = t.into();
        return dt.format("%d/%m/%Y/%T").to_string();
    } else {
        return String::from("undefined");
    }
}

fn get_xversion(rpt: &String, src: &Source) -> String {
    match src {
        Source::Implementation(..) => {
            // TODO! this is really ugly.
            parser::values::<f32>(&rpt, "    * Version:")
                .unwrap()
                .first().unwrap()
                .to_string()
        }
        Source::Estimate(..) => {
            parser::values::<f32>(&rpt, "* Version:")
                .unwrap()
                .first().unwrap()
                .to_string()
        }
        Source::Synthesis(..) => {
            unimplemented!()
        }
        Source::Undefined => unreachable!()
    }
}

fn get_board(rpt: &String, src: &Source) -> String {
    match src {
        Source::Implementation(..) => {
            parser::values::<String>(&rpt, "    * Target device:")
                .unwrap()[3].to_string()
        }
        Source::Estimate(..) => {
            parser::values::<String>(&rpt, "* Target device:")
                .unwrap()[3].to_string()
        }
        Source::Synthesis(..) => {
            unimplemented!()
        }
        Source::Undefined => unreachable!()
    }
}


#[derive(Debug, Default)]
pub struct Report {
    pub author: String,
    pub date: String,
    pub label: String,
    pub xversion: String,
    pub source: Source,
    pub board: String,
    pub resources: Resources,
    pub latency: Latency
}

impl Report {
    fn copy_report<T: AsRef<Path>>(&self, rpt: T, path: &PathBuf, output: &PathBuf) {
        let mut src = path.clone();
        src.push(rpt);

        let mut dst = output.clone();
        let dst_name = String::from(output.file_stem().unwrap().to_str().unwrap());
        let suffix = match &self.source {
            Source::Implementation(..) => "impl",
            Source::Synthesis(..) => "synth",
            Source::Estimate(..) => "estim",
            Source::Undefined => unreachable!()
        };
        let dst_name = format!("{}_{}",
            dst_name, suffix
        );
        dst.set_file_name(&dst_name);
        dst.set_extension("rpt");
        println!("Copying report file {:?} to {:?}",
            src.display(), dst.display()
        );
        std::fs::copy(&src, &dst).expect("Report copy failed!");
    }
    pub fn copy_files(&self, path: &PathBuf, output: &PathBuf) {
        match &self.source {
            Source::Implementation(src) |
            Source::Synthesis(src) => {
                self.copy_report(&src, path, output);
                self.copy_report(RPT_ESTIM, path, output);
            }
            Source::Estimate(src) => {
                self.copy_report(&src, path, output);
            }
            Source::Undefined => unreachable!()
        }
    }
}

impl Report {
    pub fn new(path: &PathBuf, label: &String) -> Report {
        let mut p = PathBuf::from(&path);
        p.push(RPT_IMPL);
        let mut src = Source::Implementation(p.clone());
        let rpt = std::fs::read_to_string(&p).unwrap_or_else(|_| {
            println!("Couldn't find HLS implementation report in '{}'",
                p.display()
            );
            println!("Trying synthesis report...");
            p.pop();
            p.push("syfala_export.rpt");
            src = Source::Synthesis(p.clone());
            std::fs::read_to_string(&p).unwrap_or_else(|_| {
                println!("Couldn't find HLS synthesis report in '{}'",
                    p.display()
                );
                println!("Trying estimate report...");
                p.clear();
                p.push(path);
                p.push(&RPT_ESTIM);
                src = Source::Estimate(p.clone());
                std::fs::read_to_string(&p).expect(
                    format!("Couldn't find estimate report in '{}', aborting...\
                        \nPlease run the syfala HLS step before calling 'hls2csv'",
                        p.display()
                    ).as_str()
                )
            })
        });
        let latency = match src {
            Source::Estimate(..) => {
                Latency::from(&rpt)
            } _ => {
                let mut p = PathBuf::from(&path);
                p.push(RPT_ESTIM);
                let f = std::fs::read_to_string(p).unwrap();
                Latency::from(&f)
            }
        };
        return Report {
             author: get_author(),
               date: get_date(&p),
              label: label.clone(),
           xversion: get_xversion(&rpt, &src),
             source: src.clone(),
              board: get_board(&rpt, &src),
          resources: Resources::new(&rpt, &src),
            latency: latency
        };
    }
}
