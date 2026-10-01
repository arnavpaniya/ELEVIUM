# Peripheral Configuration Distribution Controller

## Project Documentation

---

## 1. Team & Mentorship

### Project

**Peripheral Configuration Distribution Controller**

### Mentor

**Mr. Uday Prasad (Uday Sir)**  
**Elevium**  
Mentor / Technical Guide

### Team Members

| Name | USN |
|---|---|
| **Arnav Paniya** | 1BY24EC026 |
| **Ayush Mishra** | 1BY24EC029 |
| **Harshini Shankar** | 1BY24EC056 |
| **Ankitha Saipriya** | 1BY24EC019 |

### Special Mention

We would like to express our sincere gratitude to **Mr. Uday Prasad (Uday Sir), Elevium**, for his mentorship, technical guidance, and continuous support throughout the development of the **Peripheral Configuration Distribution Controller** project.

---

## 2. Introduction

The Peripheral Configuration Distribution Controller is an RTL-based digital design project developed as part of the Elevium MNC Training Program.

The project focuses on developing the hardware building blocks required for communication between a processor/SoC and peripheral devices.

The communication architecture being developed is:

**CPU / SoC → AXI → APB → SPI → Peripheral**

The project is being developed incrementally, with individual RTL blocks being designed and verified before integration.

---

# 3. Project Scope

The Peripheral Configuration Distribution Controller is being developed as a modular RTL system. The project includes individual hardware blocks followed by SPI, APB, and AXI-level integration.

### RTL Building Blocks

- PISO (Parallel-In Serial-Out)
- SIPO (Serial-In Parallel-Out)
- Clock Divider
- Counter
- FIFO
- Clock Domain Crossing (CDC)
- Memory
- SPI Master
- SPI Master Top
- APB Interface
- APB Peripheral Controller
- AXI Interface
- AXI-APB Peripheral Controller

---

# 4. Current Implementation Status

The current RTL implementation and verification status is:

| Block | Status |
|---|---|
| PISO | ✅ Implemented & Verified |
| SIPO | ✅ Implemented & Verified |
| Clock Divider | ✅ Implemented & Verified |
| Counter | ✅ Implemented & Verified |
| FIFO | ✅ Implemented & Verified |
| CDC | ✅ Implemented & Verified |
| Memory | ✅ Implemented & Verified |
| SPI Master | ✅ Implemented & Verified |
| SPI Master Top | ✅ Implemented & Verified |
| APB Interface | ✅ Implemented & Verified |
| APB Peripheral Controller | ✅ Implemented & Verified |
| AXI Interface | ✅ Implemented & Verified |
| AXI-APB Peripheral Controller | ✅ Implemented & Verified |

---

# 5. System Architecture

The current integrated architecture is:

```text
                         CPU / SoC
                             |
                            AXI
                             |
                    AXI-APB Bridge
                             |
                            APB
                             |
              APB Peripheral Controller
                             |
                         SPI Master
                             |
          +------------------+------------------+
          |                  |                  |
         PISO              SIPO          Clock Divider
          |                  |                  |
          +------------- SPI Bus --------------+
                             |
                         Peripheral
```

The SPI Master uses PISO for serial transmission, SIPO for serial reception, and the clock divider for generating the lower-frequency SPI clock.

---

# 6. SPI Master

The SPI Master has been implemented and verified as an independent RTL module.

### Signals

- Clock
- Reset
- Start
- TX data
- MISO
- MOSI
- SCLK
- Chip Select (CS)
- RX data
- Busy
- Done

### Verification

The SPI Master testbench verifies:

- Transaction start
- CS assertion
- SPI clock generation
- Correct TX operation
- Correct RX operation
- Busy status
- CS deassertion
- Done indication

**Result: ✅ SPI MASTER TEST PASSED**

---

# 7. SPI Master Top

The SPI Master Top integrates:

- Clock Divider
- PISO
- SIPO
- SPI control logic

The integrated module was verified using an SPI slave model in the testbench.

### Verification

- SPI transaction started
- CS asserted
- Correct RX data received
- Correct TX data transmitted
- BUSY deasserted
- CS deasserted

**Result: ✅ SPI MASTER TOP TEST PASSED**

---

# 8. APB Integration

The APB Peripheral Controller provides an APB-accessible interface to the SPI Master.

### APB Register Map

| Address | Register | Description |
|---|---|---|
| 0x00 | TX DATA | SPI transmit data |
| 0x04 | CONTROL | Bit 0 starts SPI transaction |
| 0x08 | RX DATA | Received SPI data |
| 0x0C | STATUS | Bit 0 = BUSY, Bit 1 = DONE |

### Verification

The APB testbench verifies:

- PREADY
- PSLVERR
- TX register readback
- SPI transaction started through APB
- SPI TX through APB
- SPI RX through APB

**Result: ✅ APB PERIPHERAL CONTROLLER TEST PASSED**

---

# 9. AXI-APB Integration

The AXI-APB Peripheral Controller provides an AXI-side interface and connects it to the APB Peripheral Controller.

The current implementation supports the required AXI write and read transactions used by the project.

### Verification

The AXI testbench verifies:

- AXI write response
- TX register write through AXI
- AXI read response
- TX register read through AXI
- SPI transaction started through AXI
- SPI TX through AXI → APB
- SPI RX through AXI → APB

**Result: ✅ AXI APB PERIPHERAL CONTROLLER TEST PASSED**

---

# 10. Verification Status

All currently implemented RTL blocks and integration testbenches have been executed successfully.

### Standalone Tests

- Counter — **PASSED**
- FIFO — **PASSED**
- CDC — **PASSED**
- Memory — **PASSED**
- Clock Divider — **PASSED**
- PISO — **PASSED**
- SIPO — **PASSED**
- SPI Master — **PASSED**
- APB Interface — **PASSED**
- AXI Interface — **PASSED**
- Peripheral Controller — **PASSED**

### Integration Tests

- SPI Master Top — **PASSED**
- APB Peripheral Controller — **PASSED**
- AXI-APB Peripheral Controller — **PASSED**

### Overall Status

**✅ Current RTL regression: PASSED**

All implemented modules currently compile and pass their corresponding simulation testbenches when required module dependencies are included during compilation.

---

# 11. Simulation

Icarus Verilog is currently used for RTL simulation.

Simulation waveform files are generated in:

```text
sim/waves/
```

Examples include:

- `piso.vcd`
- `sipo.vcd`
- `clock_divider.vcd`
- `spi_master.vcd`
- `spi_master_top.vcd`
- `apb_peripheral_controller.vcd`
- `axi_apb_peripheral_controller.vcd`

---

# 12. Repository Structure

```text
ELEVIUM/
├── .gitignore
├── README.md
└── Peripheral-Configuration-Distribution-Controller/
    ├── docs/
    │   └── project_documentation.md
    ├── rtl/
    │   ├── counter.v
    │   ├── fifo.v
    │   ├── cdc.v
    │   ├── memory.v
    │   ├── clock_divider.v
    │   ├── piso.v
    │   ├── sipo.v
    │   ├── spi_master.v
    │   ├── spi_master_top.v
    │   ├── apb_interface.v
    │   ├── apb_peripheral_controller.v
    │   ├── axi_interface.v
    │   ├── axi_apb_peripheral_controller.v
    │   └── peripheral_controller.v
    ├── tb/
    │   └── *_tb.v
    └── sim/
        └── waves/
            └── *.vcd
```

---

# 13. Development Status

The current milestone has completed the initial RTL building blocks and their verification, followed by SPI, APB, and AXI-APB integration.

### Completed

- Basic RTL blocks
- PISO/SIPO based SPI data path
- SPI Master
- SPI Master Top
- APB interface
- APB Peripheral Controller
- AXI interface
- AXI-APB Peripheral Controller
- Standalone simulation verification
- Integration simulation verification

### Next Development Stage

Further work will follow the project architecture roadmap and the requirements provided during the Elevium training program.
