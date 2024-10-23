  proc build_dts {xsa dtx output} {
      hsi::open_hw_design $xsa
      hsi::set_repo_path $dtx
      set proc 0
      foreach procs [hsi::get_cells -filter {IP_TYPE==PROCESSOR}] {
          if {[regexp {cortex} $procs]} {
              set proc $procs
              break
          }
      }
      if {$proc != 0} {
          puts "Targeting $proc"
          hsi::create_sw_design device-tree -os device_tree -proc $proc
          hsi::generate_target -dir $output
      } else {
          puts "Error: No processor found in XSA file"
      }
      hsi::close_hw_design [hsi::current_hw_design]
  }

  proc include_dtsi {dtsi_file} {
      if {[file exists $dtsi_file]} {
          file copy -force $dtsi_file my_dts
          set fp [open my_dts/system-top.dts r]
          set file_data [read $fp]
          close $fp
          set fileId [open my_dts/system-top.dts "w"]
          set data [split $file_data "\n"]
          foreach line $data {
              puts $fileId $line
          }
          puts $fileId "#include \"$dtsi_file\""
          close $fileId
      }
  }
