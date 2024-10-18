use std::time::Duration;
use crate::parser;

#[derive(Debug, Default)]
pub struct Latency {
    pub cycles: i32,
       pub dur: Duration,
}

impl From<&String> for Latency {
    fn from(rpt: &String) -> Latency {
        let mut no = parser::index_of(&rpt, "+ Latency").expect(
            "Couldn't parse Latency from report, aborting."
        );
        no += 6;
        let cy = parser::line::<String>(&rpt, no);
        let d = cy[4].parse::<f32>().unwrap();
        let duration = match cy[5].as_str() {
            "ns" => Duration::from_nanos(d as u64),
            "us" => Duration::from_nanos((d*1000.0) as u64),
            "ms" => Duration::from_micros((d*1000.0) as u64),
              &_ => unreachable!()
        };
        Latency {
            cycles: cy[1].parse::<i32>().unwrap(),
               dur: duration
        }
    }
}
