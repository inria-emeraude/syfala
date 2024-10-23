
use crate::report;
use crate::parser::{values};

#[derive(Debug, Default)]
pub struct Resources {
     pub dsp: report::Value,
      pub ff: report::Value,
     pub lut: report::Value,
    pub bram: report::Value,
}

impl Resources {
    pub fn new(rpt: &String, src: &report::Source) -> Resources {
        match src {
            report::Source::Estimate(..) => {
                let total = values::<i32>(&rpt, "|Total").unwrap();
                let util  = values::<f32>(&rpt, "|Utilization").unwrap();
                Resources {
                    dsp: report::Value::new(total[1], util[1]),
                     ff: report::Value::new(total[2], util[2]),
                    lut: report::Value::new(total[3], util[3]),
                   bram: report::Value::new(total[0], util[0])
                }
            }
            report::Source::Synthesis(..) => {
                unimplemented!()
            }
            report::Source::Implementation(..) => {
                let lut_n = values::<i32>(&rpt, "LUT:").unwrap();
                let lut_p = values::<f32>(&rpt, "| LUT").unwrap();
                let dsp_n = values::<i32>(&rpt, "DSP:").unwrap();
                let dsp_p = values::<f32>(&rpt, "| DSP").unwrap();
                let ff_n = values::<i32>(&rpt, "FF:").unwrap();
                let ff_p = values::<f32>(&rpt, "| FD").unwrap();
                let bram_n = values::<i32>(&rpt, "BRAM:").unwrap();
                let bram_p = values::<f32>(&rpt, "| RAMB").unwrap();
                return Resources {
                    dsp: report::Value::new_with_guideline(
                        dsp_n[0], dsp_p[1], dsp_p[0]
                    ),
                    ff: report::Value::new_with_guideline(
                        ff_n[0], ff_p[1], ff_p[0]
                    ),
                    lut: report::Value::new_with_guideline(
                        lut_n[0], lut_p[1], lut_p[0]
                    ),
                    bram: report::Value::new_with_guideline(
                        bram_n[0], bram_p[1], bram_p[0]
                    )
                };
            }
            report::Source::Undefined => unreachable!()
        }
    }
}
