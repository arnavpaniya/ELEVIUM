# Peripheral Configuration Distribution Controller
## Project Documentation

### 1. Introduction

The Peripheral Configuration Distribution Controller is an RTL-based digital design project developed as part of the Elevium MNC Training Program.

The project focuses on developing the basic hardware building blocks required for communication between a processor/SoC and peripheral devices.

The planned communication architecture is:

CPU / SoC → AXI → APB → SPI → Peripheral

The project is being developed incrementally, with individual RTL blocks being designed and verified before integrating them into the complete SPI-based controller.

---

## 2. Current Objective

The initial objective is to implement and verify the basic building blocks required for an SPI Master.

The current implementation consists of:

- Parallel-In Serial-Out (PISO)
- Serial-In Parallel-Out (SIPO)
- Clock Divider

These blocks form the fundamental data transmission, data reception, and clock-generation sections of the SPI interface.

---

## 3. System Architecture

The planned high-level architecture is:

```text
             CPU / SoC
                 |
                AXI
                 |
                APB
                 |
            SPI Master
          /      |      \
       PISO    Clock    SIPO
                Divider
                 |
              SPI Bus
                 |
             Peripheral