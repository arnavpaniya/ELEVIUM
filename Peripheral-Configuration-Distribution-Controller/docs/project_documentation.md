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

## 3. Current Objective

The initial objective is to implement and verify the basic building blocks required for an SPI Master.

The current implementation consists of:

- Parallel-In Serial-Out (PISO)
- Serial-In Parallel-Out (SIPO)
- Clock Divider

These blocks form the fundamental data transmission, data reception, and clock-generation sections of the SPI interface.

---

## 4. System Architecture

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