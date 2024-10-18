use std::path::PathBuf;
use serde::{Serialize, Deserialize};
use crate::report;
use crate::report::Report;
use crate::syfala;
use dialoguer::Confirm;
use regex::Regex;

#[derive(Debug, Serialize, Deserialize)]
#[serde(rename_all = "SCREAMING_SNAKE_CASE")]
struct CsvReport {
      experiment: usize,
            date: String,
           label: String,
            file: String,
          target: syfala::Target,
          inputs: usize,
         outputs: usize,
           board: String,
          source: report::Source,
         dsp_pct: f32,
          ff_pct: f32,
         lut_pct: f32,
        bram_pct: f32,
         lat_pct: f32,
           dsp_n: i32,
            ff_n: i32,
           lut_n: i32,
          bram_n: i32,
           lat_n: i32,
             umo: bool,
        nsamples: usize,
     sample_rate: usize,
    sample_width: usize,
       faust_mcd: usize,
        xversion: String,
       syversion: String,
        sybranch: String,
        sycommit: String,
          author: String,
}

fn get_latency_percentage(r: &Report, s: &syfala::Parameters) -> f32 {
    let nsamples = if s.nsamples > 0 {
        s.nsamples as f32
    } else {
        1f32
    };
    let ncycles: f32 = r.latency.cycles as f32 / nsamples;
    let ratio = s.sample_rate as f32 / syfala::FPGA_CLOCK_RATE;
    return ratio * ncycles * 100f32;
}

fn get_latency_n(r: &Report, s: &syfala::Parameters) -> i32 {
    let nsamples = if s.nsamples > 0 {
        s.nsamples as i32
    } else {
        1i32
    };
    let ncycles: i32 = r.latency.cycles / nsamples as i32;
    return ncycles;
}

impl CsvReport {
    fn new(r: &Report, s: &syfala::Parameters, i: usize) -> CsvReport {
        CsvReport {
        experiment: i,
          xversion: String::from(&r.xversion),
         syversion: String::from(&s.version),
          sybranch: String::from(&s.branch),
          sycommit: String::from(&s.commit),
            author: String::from(&r.author),
              date: String::from(&r.date),
             board: String::from(&r.board),
              file: String::from(&s.file),
             label: String::from(&r.label),
            target: s.target,
            source: r.source.clone(),
            inputs: s.io.0,
           outputs: s.io.1,
       sample_rate: s.sample_rate,
      sample_width: s.sample_width,
          nsamples: s.nsamples,
         faust_mcd: match &s.faust {
            Some(f) => f.mcd, None => 0
         },
           dsp_pct: r.resources.dsp.percentage,
            ff_pct: r.resources.ff.percentage,
           lut_pct: r.resources.lut.percentage,
          bram_pct: r.resources.bram.percentage,
           lat_pct: get_latency_percentage(r, s),
             dsp_n: r.resources.dsp.number,
              ff_n: r.resources.ff.number,
             lut_n: r.resources.lut.number,
            bram_n: r.resources.bram.number,
             lat_n: get_latency_n(r, s),
               umo: s.umo.is_some()
        }
    }
}

pub fn concatenate_reports(src: &Vec<PathBuf>, dst: &PathBuf) {
    let exists = dst.exists();
    // Prepare the output file
    let f = std::fs::OpenOptions::new()
        .create(!exists)
        .read(true)
        .write(true)
        .append(true)
        .open(dst)
        .unwrap()
    ;
    let mut index = if !exists {0} else {
        linecount::count_lines(&f).unwrap()-1
    };
    // Parse all files, serialize into new CsvReport structs,
    let mut reports: Vec<CsvReport> = vec!();
    for path in src {
        if path == dst {
            println!("Skipping target {:?}", path.display());
            continue;
        }
        let f = std::fs::File::open(path).unwrap();
        let mut rdr = csv::Reader::from_reader(f);
        for result in rdr.deserialize() {
            let mut rpt: CsvReport = result.unwrap();
            rpt.experiment = index;
            reports.push(rpt);
            index += 1;
        }
    }
    let mut wtr = csv::WriterBuilder::new()
        .has_headers(true)
        .from_writer(f)
    ;
    for rpt in &reports {
        wtr.serialize(rpt).expect(
            "Could not write report entry to file, aborting."
        );
        if wtr.flush().is_ok() {
            println!("Succesfully written CSV data to {:?}",
                dst.display()
            );
        }
    }
}

pub fn write_report(path: &PathBuf, rpt: &Report, s: &syfala::Parameters) -> PathBuf {
    let mut p = path.clone();
    // TODO! clean this ugly code:
    loop {
        if p.exists() {
            // if we have 'bypass.csv', let it be 'bypass_1.csv'
            // So we have to retrieve the file stem,
            // If it has already the name_# format,
            // parse the number and increment it
            // otherwise, add _1 to it.
            let mut stem = String::from(
                p.file_stem().unwrap()
                .to_str().unwrap()
            );
            let rx = Regex::new(r".+_(?<index>[0-9]+)").unwrap();
            match rx.captures(&stem) {
                Some(capture) => {
                    let istr = &capture["index"];
                    let index = istr.parse::<u32>().unwrap() + 1u32;
                    let spl: Vec<&str> = stem.split("_").collect();
                    stem = spl[0].to_string();
                    stem.push_str(format!("_{index}").as_str());
                    p.pop();
                    p.push(stem);
                    p.set_extension("csv");
                }
                None => {
                    stem.push_str("_1");
                    p.pop();
                    p.push(stem);
                    p.set_extension("csv");
                }
            }
        } else {
            break;
        }
    }
    let f = std::fs::OpenOptions::new()
        .create(true)
        .truncate(true)
        .read(true)
        .write(true)
        .open(&p)
        .unwrap()
    ;
    let entry = CsvReport::new(rpt, s, 0);
    // Don't re-append headers if file already exists.
    let mut wtr = csv::WriterBuilder::new()
        .has_headers(true)
        .from_writer(f)
    ;
    wtr.serialize(&entry).expect(
        "Could not write report entry to file, aborting."
    );
    if wtr.flush().is_ok() {
        println!("Succesfully written CSV data to {:?}",
            p.display()
        );
    }
    return p;
}
