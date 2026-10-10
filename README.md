# Hardware-Efficient FPGA Perceptron Accelerator 🧠⚡

## Overview
This repository presents a hardware-efficient, multiplier-free **Single Layer Perceptron (SLP)** accelerator implemented on Field-Programmable Gate Array (FPGA) platforms using a **Software/Hardware Co-Design** methodology.

The architecture is specifically engineered to learn and model linearly separable binary logic functions (AND, OR, NAND, NOR) across dynamic input dimensions ($n = 2, 4, 6, 8$). The design completely eliminates resource-heavy hardware multipliers by leveraging **Q6.26 fixed-point representation** and a power-of-two learning rate ($\eta = 0.125 = 2^{-3}$), allowing weight and bias updates to be executed purely via bit-wise arithmetic right-shifts.

---

## Academic Metadata
* **Institution:** Omar Al-Mukhtar University — Faculty of Engineering
* **Department:** Computer Engineering Department
* **Project Title:** Implementation of Perceptron on FPGAs
* **Research Paper:** *Implementation of a Hardware-Efficient Perceptron on FPGA for Logic Gate Learning*
* **Project Team:** Amira Jomaa, Amna Alhassan Hamad, Azizah Ebrahim, Monya Ashraf, Noor Al-huda Miloud, Rbah Masoud, Souad Abdulatif
* **Academic Supervisor:** M.Eng. Salem Ali Al-Akaer

---

## Key Technical Highlights
* **Software/Hardware Co-Design:** Offline parameter optimization using Python (NumPy) combined with real-time hardware execution in Verilog HDL.
* **Multiplier-Free Architecture:** Selecting $\eta = 0.125$ transforms $e \times \eta$ operations into a 3-bit arithmetic right-shift (`>>> 3`), resulting in **0% DSP Slice Utilization**.
* **Fixed-Point Quantization (Q6.26):** 32-bit word format (1 sign bit, 5 integer bits, 26 fractional bits) ensuring high numerical precision and zero classification loss without floating-point overhead.
* **Structural CU/DU Decoupling:** Decouples the Control Unit (CU) Finite State Machine from the Datapath Unit (DU) for cycle-accurate control.
* **Timing Closure & `WAIT_SUM` State:** Integrates a dedicated synchronization state (`WAIT_SUM`) in the FSM to resolve FPGA routing propagation delays, ensuring setup-and-hold stability during post-implementation timing simulations.

---

## Hardware Architecture

The system is partitioned into two main decoupled modules synchronized via an 8-bit Control Vector (`CV`):

```text
       +-------------------------------------------------------+
       |                  Control Unit (CU)                    |
       |     10-State FSM (IDLE -> FETCH -> ... -> DONE)       |
       +-------------------------------------------------------+
                                  | Control Vector (CV[7:0])
                                  v
+---------------------------------------------------------------------+
|                         Datapath Unit (DU)                          |
|  +------------------+   +-------------------+   +----------------+  |
|  |  LUT Data Store  |   | Weight/Bias Regs  |   | Accumulator    |  |
|  |   (Generic_LUT)  |   | (Q6.26 Format)    |   | & Shift Logic  |  |
|  +------------------+   +-------------------+   +----------------+  |
+---------------------------------------------------------------------+
```

### 1. Control Unit (CU) FSM States
* **`S0: IDLE`**: Standby state awaiting execution signal.
* **`S1: FETCH`**: Retrieves input vector $X$ and target $T$ from LUT memory.
* **`S2: LOAD`**: Registers sample features and resets the accumulator.
* **`S3: SETUP`**: Loads the initial bias term into the accumulator.
* **`S4: SUM`**: Iteratively accumulates weighted inputs ($x_i \cdot w_i$).
* **`S5: SHIFT`**: Shifts input bits and increments feature counters.
* **`S6: WAIT_SUM`**: Synchronization wait state ensuring multi-bit adder stability.
* **`S7: CHECK`**: Evaluates prediction sign against target $T$.
* **`S8: UPDATE`**: Applies shift-based weight and bias updates upon error detection.
* **`S9: NEXT`**: Manages sample traversal and epoch completion checks.

---

## Performance & Experimental Results

### 1. Resource Optimization (Structural vs. Behavioral at $n=6$)
Transitioning from a high-level behavioral model to a decoupled structural architecture yielded significant logic area savings on the target FPGA:

| Resource Element | Behavioral Model | Proposed Structural Model | Improvement / Area Reduction |
| :--- | :---: | :---: | :---: |
| **LUTs (Look-Up Tables)** | 236 | **141** | **40.2% Reduction** |
| **Flip-Flops (FFs)** | 263 | **135** | **48.6% Reduction** |
| **DSP Blocks** | 0 | **0** | **100% Multiplier-Free** |
| **Classification Accuracy** | 100% | **100%** | **Optimal Convergence** |

### 2. Execution Time: CPU vs. FPGA Hardware ($n=6$)
Post-implementation timing simulations (at 100 MHz clock) demonstrate massive computational speedups compared to software execution:

| Logic Gate Function | Software Execution (Python / CPU) | FPGA Hardware Execution (Structural) | Hardware Speedup |
| :--- | :---: | :---: | :---: |
| **AND Gate** | 87.00 ms | **0.646 ms** | **~134x Faster** |
| **OR Gate** | 10.00 ms | **0.092 ms** | **~108x Faster** |
| **NAND Gate** | 71.00 ms | **0.646 ms** | **~109x Faster** |
| **NOR Gate** | 8.00 ms | **0.092 ms** | **~86x Faster** |

---

## Project Structure
```text
FPGA-Perceptron-Hardware-Accelerator/
│
├── rtl/                        # Synthesizable Verilog HDL Design Sources
│   ├── Perceptron_Top.v        # Top-level structural module
│   ├── Generic_CU.v            # Finite State Machine Control Unit
│   ├── Generic_DU.v            # Datapath Unit & Q6.26 Accumulator
│   ├── Generic_LUT.v           # ROM/RAM Dataset storage module
│   └── perceptron_dataset.v    # Behavioral reference model
│
├── testbench/                  # Testbench Verification Files
│   ├── Perceptron_Top_tb.v     # Structural top-level simulation testbench
│   └── tb_perceptron_dataset.v # Behavioral testbench
│
├── python/                     # Software Training & Parameter Extraction
│   └── perceptron_trainer.ipynb
│
├── docs/                       # Architectural Diagrams & Waveforms
│   ├── asm_fsm_chart.png
│   ├── datapath_architecture.png
│   └── timing_simulation_6in.png
│
├── publication/                # Graduation Documentation
│   ├── Graduation_Project_Report.pdf
│   └── Scientific_Paper_Perceptron.pdf
│
└── README.md                   # Complete Repository Documentation
```

## How to Run & Simulate (Xilinx Vivado)

1. **Clone the repository:**
   ```bash
   git clone [https://github.com/YourUsername/FPGA-Perceptron-Hardware-Accelerator.git](https://github.com/YourUsername/FPGA-Perceptron-Hardware-Accelerator.git)
   ```

2. **Setup Vivado Project:**
   * Open Xilinx Vivado (2020.2 or newer).
   * Create a new RTL Project and select your target FPGA device (e.g., Artix-7 / Zynq-7000).
   * Add all `.v` files from `/rtl` as **Design Sources**.
   * Add `Perceptron_Top_tb.v` from `/testbench` as **Simulation Sources**.

3. **Run Behavioral & Post-Implementation Timing Simulation:**
   * Run Behavioral Simulation to verify logic convergence.
   * Run Synthesis and Implementation.
   * Execute **Post-Implementation Timing Simulation** to evaluate `WAIT_SUM` state clock stabilization.

---

## Individual Contributions (Amna Al-Hassan)
* **Software Modeling & Training Pipeline (Python):** Developed the object-oriented Python architecture for automated dataset generation, Perceptron learning, learning rate sensitivity analysis, and Q6.26 fixed-point parameter extraction (`python/perceptron_trainer.ipynb`).
* **Hardware Control Unit Design (Verilog HDL):** Engineered the 10-state Finite State Machine (FSM) Control Unit (`rtl/Generic_CU.v`), orchestrating cycle-accurate Control Vector (`CV`) generation, state transitions, and the `WAIT_SUM` timing synchronization mechanism.

---

## License
Distributed under the [MIT License](LICENSE).