# ELEVIUM

This repository contains the projects, RTL designs, simulations, verification work, and related development completed as part of the **Elevium MNC Training Program**.

## Training Work

The repository includes work related to:

- Digital Design
- Verilog / RTL Design
- Simulation and Verification
- Peripheral Interfaces
- SoC Architecture
- Communication Protocols

## Project

### Peripheral Configuration Distribution Controller

The main project focuses on developing a modular RTL-based peripheral configuration controller.

The current implementation includes:

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

## Architecture

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
 +--+---------+---------+
 |            |         |
PISO         SIPO   Clock Divider
 |            |         |
 +-------- SPI Bus ----+
            |
        Peripheral
```

## Verification Status

All currently implemented RTL modules and integration testbenches have been simulated successfully.

### Standalone

- Counter — ✅ PASSED
- FIFO — ✅ PASSED
- CDC — ✅ PASSED
- Memory — ✅ PASSED
- Clock Divider — ✅ PASSED
- PISO — ✅ PASSED
- SIPO — ✅ PASSED
- SPI Master — ✅ PASSED
- APB Interface — ✅ PASSED
- AXI Interface — ✅ PASSED
- Peripheral Controller — ✅ PASSED

### Integration

- SPI Master Top — ✅ PASSED
- APB Peripheral Controller — ✅ PASSED
- AXI-APB Peripheral Controller — ✅ PASSED

## Upcoming Project

### Step Counter

The next project in the Elevium training work is a **Step Counter** project.

**Status:** 🔄 Upcoming

Implementation details and verification status will be added as development progresses.

## Tools

- Verilog
- Icarus Verilog
- VS Code
- Git
- GitHub

## Repository Structure

```text
ELEVIUM/
├── README.md
└── Peripheral-Configuration-Distribution-Controller/
    ├── rtl/
    ├── tb/
    ├── sim/
    │   └── waves/
    └── docs/
        └── project_documentation.md
```

## Documentation

Detailed project documentation is available in:

`Peripheral-Configuration-Distribution-Controller/docs/project_documentation.md`

## Current Status

**RTL implementation and verification milestone completed.**

The next planned project is the **Step Counter**. Further development will follow the project roadmap and the requirements provided during the Elevium training program.
