#!/usr/bin/tclsh

set app_name          "fsbl"
set app_type          "zynqmp_fsbl"
set hwspec_file       "design_1_wrapper.hwdef"
set proc_name         "psu_cortexa53_0"
set project_name      "project"
set project_dir       [pwd]
set sdk_workspace     [file join $project_dir $project_name.sdk]
set app_dir           [file join $sdk_workspace $app_name]
set app_release_dir   [file join [pwd] ".." ]
set app_release_elf   "zynqmp_fsbl.elf"

set hw_design         [hsi::open_hw_design [file join $sdk_workspace $hwspec_file]]

hsi::generate_app -hw $hw_design -os standalone -proc $proc_name -app $app_type -compile -dir $app_dir
file copy -force [file join $app_dir "executable.elf"] [file join $app_release_dir $app_release_elf]
