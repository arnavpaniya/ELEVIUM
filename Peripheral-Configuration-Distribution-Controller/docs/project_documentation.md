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

The project focuses on developing the basic hardware building blocks required for communication between a processor/SoC and peripheral devices.

The planned communication architecture is:

**CPU / SoC → AXI → APB → SPI → Peripheral**

The project is being developed incrementally, with individual RTL blocks being designed and verified before integrating them into the complete SPI-based controller.

---

# 3. Project Scope

The Peripheral Configuration Distribution Controller is being developed as a modular RTL system. The project is divided into multiple hardware blocks that will be implemented, verified, and integrated progressively.

### Planned RTL Building Blocks

- PISO (Parallel-In Serial-Out)
- SIPO (Serial-In Parallel-Out)
- Clock Divider
- Counters
- FIFO
- Clock Domain Crossing (CDC)
- Memory

These blocks will subsequently be integrated to form the SPI Master and the higher-level peripheral configuration controller.

---

# 4. Current Implementation Status

The project is being developed incrementally.

| Block | Status |
|---|---|
| PISO | ✅ Implemented & Verified |
| SIPO | ✅ Implemented & Verified |
| Clock Divider | ✅ Implemented & Verified |
| Counters | 🔄 Planned |
| FIFO | 🔄 Planned |
| CDC | 🔄 Planned |
| Memory | 🔄 Planned |
| SPI Master | 🔄 Planned |
| APB Interface | 🔄 Planned |
| AXI / SoC Integration | 🔄 Planned |

---

# 5. System Architecture

The planned architecture is:

```text
                         CPU / SoC
                             |
                            AXI
                             |
                            APB
                             |
                  Peripheral Configuration
                       Controller
                             |
                         SPI Master
                             |
          +------------------+------------------+
          |                  |                  |
         PISO             SIPO            Clock Divider
          |                  |                  |
          +-------- SPI Full-Duplex Bus -------+
                             |
                         Peripheral