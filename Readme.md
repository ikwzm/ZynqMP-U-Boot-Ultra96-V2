Build Boot Loader for Ultra96-V2
====================================================================================

## Files that you can to build

  + boot.bin
  + boot_outer_shareable.bin
  + zynqmp_fsbl.elf           (FSBL)
  + zynqmp_pmufw.elf          (PMU Firmware)
  + bl31.elf                  (ARM Trusted Firmware Boot Loader state 3-1)
  + u-boot.elf                (U-Boot)
  + design_1_wrapper.bit      (FPGA Bitstream File)
  + boot.bif                  (BIF for boot.bin)
  + boot_outer_shareable.bif  (BIF for boot_outer_shareable.bin)
  + regs.init                 (for boot_outer_shareable.bin)


Build Ultra96-V2 Sample FPGA
------------------------------------------------------------------------------------

### Requirement

* Vivado 2019.2

### File Description

  - fpga/
    + create_project.tcl
    + design_1_bd.tcl
    + implementation.tcl
    + export_hardware.tcl
    + design_1_pin.xdc

### Create Project

```console
vivado% cd fpga
vivado% vivado -mode batch -source create_project.tcl
```

### Implementation

```console
vivado% cd fpga
vivado% vivado -mode batch -source implementation.tcl
```

### Export Hadware to project.sdk

```console
vivado% cd fpga
vivado% vivado -mode batch -source export_hardware.tcl
```

### Copy design_1_wrapper.bit

```console
shell$ cd fpga
shell$ cp project.runs/impl_1/design_1_wrapper.bit ../design_1_wrapper.bit
```

Build FSBL
------------------------------------------------------------------------------------

### Requirement

* Vivado SDK 2019.2

### File Description

  - fpga/
    + build_zynqmp_fsbl.tcl
    + project.sdk/design_1_wrapper.hwdef
  - zynqmp_fsbl.elf

### Build zynqmp_fsbl.elf

```console
vivado% cd fpga/
vivado% xsct build_zynqmp_fsbl.tcl
```

Build PMU Firmware
------------------------------------------------------------------------------------

### Requirement

* Vivado SDK 2019.2

### File Description

  - fpga/
    + build_zynqmp_pmufw.tcl
    + project.sdk/design_1_wrapper.hwdef
  - zynqmp_pmufw.elf

### Build zynqmp_pmufw.elf

```console
vivado% cd fpga/
vivado% xsct build_zynqmp_pmufw.tcl
```

Build ARM Trusted Firmware
------------------------------------------------------------------------------------

### Requirement

* Vivado SDK 2019.1 or gcc-aarch64-linux-gnu

### Fetch Sources

```console
vivado% git clone https://github.com/Xilinx/arm-trusted-firmware.git
```

### Checkout xilinx-v2019.2

```console
vivado% cd arm-trusted-firmware
vivado% git checkout -b xilinx-v2019.2-ultra96 refs/tags/xilinx-v2019.2
```


### Build

```console
vivado% cd arm-trusted-firmware
vivado% make ERROR_DEPRECATED=1 RESET_TO_BL31=1 CROSS_COMPILE=aarch64-linux-gnu- PLAT=zynqmp ZYNQMP_CONSOLE=cadence1 bl31
```

If you get the following error and you can not compile

```console
vivado% make ERROR_DEPRECATED=1 RESET_TO_BL31=1 CROSS_COMPILE=aarch64-linux-gnu- PLAT=zynqmp ZYNQMP_CONSOLE=cadence1 bl31
   :
   :
   :
In file included from drivers/console/aarch64/console.S:10:0:
drivers/console/aarch64/deprecated_console.S:12:2: error: #warning "Using deprecated console implementation. Please migrate to MULTI_CONSOLE_API" [-Werror=cpp]
 #warning "Using deprecated console implementation. Please migrate to MULTI_CONSOLE_API"
  ^
cc1: all warnings being treated as errors
```
Please comment out the following line in drivers/console/aarch64/deprecated_console.S

```diff
--- a/drivers/console/aarch64/deprecated_console.S
+++ b/drivers/console/aarch64/deprecated_console.S
@@ -9,7 +9,7 @@
  * This is the common console core code for the deprecated single-console API.
  * New platforms should set MULTI_CONSOLE_API=1 and not use this file.
  */
-#warning "Using deprecated console implementation. Please migrate to MULTI_CONSOLE_API"
+/* #warning "Using deprecated console implementation. Please migrate to MULTI_CONSOLE_API" */
 
        .globl  console_init
        .globl  console_uninit
```

```console
vivado% git add --update
vivado% git commit -m "[remove] warning in drivers/console/aarch64/deprecated_console.S"
vivado% git tag -a xilinx-v2019.2-ultra96-1 -m "release xilinx-v2019.2-ultra96-1"
```
If you get the following error and you can not compile

```console
Building zynqmp
  AS      bl31/aarch64/runtime_exceptions.S
bl31/aarch64/runtime_exceptions.S: Assembler messages:
bl31/aarch64/runtime_exceptions.S:157: Error: non-constant expression in ".if" statement
bl31/aarch64/runtime_exceptions.S:165: Error: non-constant expression in ".if" statement
bl31/aarch64/runtime_exceptions.S:170: Error: non-constant expression in ".if" statement
bl31/aarch64/runtime_exceptions.S:175: Error: non-constant expression in ".if" statement
bl31/aarch64/runtime_exceptions.S:189: Error: non-constant expression in ".if" statement
bl31/aarch64/runtime_exceptions.S:193: Error: non-constant expression in ".if" statement
bl31/aarch64/runtime_exceptions.S:197: Error: non-constant expression in ".if" statement
bl31/aarch64/runtime_exceptions.S:201: Error: non-constant expression in ".if" statement
bl31/aarch64/runtime_exceptions.S:215: Error: non-constant expression in ".if" statement
bl31/aarch64/runtime_exceptions.S:219: Error: non-constant expression in ".if" statement
bl31/aarch64/runtime_exceptions.S:223: Error: non-constant expression in ".if" statement
bl31/aarch64/runtime_exceptions.S:231: Error: non-constant expression in ".if" statement
bl31/aarch64/runtime_exceptions.S:245: Error: non-constant expression in ".if" statement
bl31/aarch64/runtime_exceptions.S:249: Error: non-constant expression in ".if" statement
bl31/aarch64/runtime_exceptions.S:253: Error: non-constant expression in ".if" statement
bl31/aarch64/runtime_exceptions.S:261: Error: non-constant expression in ".if" statement
Makefile:597: recipe for target 'build/zynqmp/release/bl31/runtime_exceptions.o' failed
make: *** [build/zynqmp/release/bl31/runtime_exceptions.o] Error 1
```

please build using tool chain of Vivado SDK.

```console
vivado% cd arm-trusted-firmware
vivado% make ERROR_DEPRECATED=1 RESET_TO_BL31=1 CROSS_COMPILE="<SDK PATH>/gnu/aarch64/<lin or nt>/aarch64-linux/bin/aarch64-linux-gnu-" PLAT=zynqmp bl31
```

```<SDK PATH>``` is Vivado SDK Installed PATH.
```<lin or nt>``` is platform. lin=linux, nt=windows

### Copy bl31.elf

```console
vivado% cp build/zynqmp/release/bl31/bl31.elf ../bl31.elf
```

Build U-Boot
------------------------------------------------------------------------------------

### Requirement

* gcc-aarch64-linux-gnu (v6.0 later)

### Download U-Boot Source

#### Clone from u-boot-xlnx.git and Checkout xilinx-v2019.2

```console
shell$ git clone --depth=1 -b xilinx-v2019.2 https://github.com/Xilinx/u-boot-xlnx.git u-boot-xlnx-v2019.2
shell$ cd u-boot-xlnx-v2019.2
shell$ git checkout -b xilinx-v2019.2-ultra96
```

### Patch for Ultra96-V2

```console
shell$ patch -p1 < ../files/u-boot-xlnx-v2019.2-ultra96-of_embed.diff
shell$ git add --update
shell$ git commit -m "patch for embeded device tree"
shell$ git tag -a xilinx-v2019.2-ultra96-0 -m "release xilinx-v2019.2-ultra96 release 0"
```

### Patch for bootmenu

```console
shell$ patch -p1 < ../files/u-boot-xlnx-v2019.2-ultra96-bootmenu.diff
shell$ git add --update
shell$ git commit -m "[update] for boot menu command"
shell$ git tag -a xilinx-v2019.2-ultra96-1 -m "release xilinx-v2019.2-ultra96 release 1"
```


### Setup for Build 

```console
shell$ cd u-boot-xlnx-v2019.2
shell$ export ARCH=arm
shell$ export CROSS_COMPILE=aarch64-linux-gnu-
shell$ make avnet_ultra96_rev1_defconfig
```

### Build u-boot.elf

```console
shell$ make
```

### Copy u-boot.elf

```console
shell$ cp u-boot.elf ../u-boot.elf
```

Build boot.bin
------------------------------------------------------------------------------------

## Requirement

* bootgen

### File Description

 + zynqmp_fsbl.elf      (Built by "Build FSBL")
 + zynqmp_pmufw.elf     (Built by "Build PMU Firmware")
 + bl31.elf             (Built by "Build ARM Trusted Firmware")  
 + u-boot.elf           (Built by "Build U-Boot")
 + design_1_wrapper.bit (Build by "Build Ultra96-V2 Sample FPGA")
 + boot.bif

### Build boot.bin

```console
vivado% bootgen -arch zynqmp -image boot.bif -w -o boot.bin
```

### Build boot_outer_sharable.bin

```console
vivado% bootgen -arch zynqmp -image boot_outer_shareable.bif -w -o boot_outer_shareable.bin
```

