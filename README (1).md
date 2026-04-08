# 🎮 VGA Grid Game — Basys3 FPGA

A hardware-implemented interactive grid game built in Verilog and deployed on the **Digilent Basys3 FPGA**. A cursor moves across a grid displayed over VGA, controlled entirely through the board's push-buttons, with the current position reflected on the onboard LEDs in real time.

---

## 📸 Demo

> *Connect the Basys3 to a VGA monitor and power on — the grid appears immediately.*

---

## ✨ Features

- 🖥️ **VGA output** at 640×480 @ 60Hz via an on-chip 25 MHz pixel clock
- 🕹️ **5-button cursor control** — Up, Down, Left, Right, and Toggle (btnC)
- 💡 **LED feedback** — current grid position mirrored on `led[5:0]`
- ♻️ **Clean reset** — hardware-debounced system reset via switches + button
- 🔒 **Fully synchronous design** — all logic clocked from PLL-generated clocks

---

## 🗂️ Project Structure

```
vga_driver_basys/
├── vga_driver_basys.v      # Top-level module
├── clk_wiz_1/              # Xilinx Clocking Wizard IP (25 MHz + system clock)
├── fsm_game.v              # Game FSM — handles button inputs & state transitions
├── Grid_counter.v          # Cursor position counter (Position[5:0])
├── vga_driver.v            # VGA sync signal generator + colour output
└── constraints/
    └── basys3.xdc          # Pin mapping for Basys3 board
```

---

## 🔌 Hardware

| Component | Details |
|---|---|
| FPGA Board | Digilent Basys3 (Artix-7) |
| Display | Any VGA monitor (640×480 @ 60Hz) |
| Interface | Standard 15-pin VGA connector |

---

## 🧩 Architecture

```
Inputs                Clock & Reset         Game Logic            Display
──────                ─────────────         ──────────            ───────
clk   ──►  clk_wiz_1 ──► 25 MHz ──────────────────────► vga_driver ──► Hsync
reset ──►  (PLL)      ──► sys_clk           fsm_game               ──► Vsync
sw[5:0] ──► Reset      ──► sys_reset ──►  ──► Grid_counter          ──► vgaRed[3:0]
btnD/U/L/R ──────────────────────────────►                           ──► vgaGreen[3:0]
btnC ────────────────────────────────────►                           ──► vgaBlue[3:0]
                                            Position[5:0] ──────────► led[5:0]
```

The **clk_wiz_1** Xilinx IP core generates two clocks from the 100 MHz board oscillator: a 25 MHz pixel clock for VGA timing, and a system clock for game logic. A small reset network (inverter + OR gate) combines the board reset button with `sw[5:0]` to produce a clean synchronous system reset.

The **fsm_game** module decodes directional button presses into move commands (DOWN / UP / LEFT / RIGHT / TOGGLE) and drives the **Grid_counter**, which maintains the current cursor position as a 6-bit value. This position is fed simultaneously to the **vga_driver** for on-screen rendering and to the `led[5:0]` output for physical feedback.

---

## 🚀 Getting Started

### Prerequisites

- [Vivado Design Suite](https://www.xilinx.com/products/design-tools/vivado.html) (2020.x or later recommended)
- Digilent Basys3 board + USB cable + VGA cable

### Build & Flash

1. **Clone the repo**
   ```bash
   git clone https://github.com/your-username/vga-grid-game-basys3.git
   cd vga-grid-game-basys3
   ```

2. **Open in Vivado**
   - Create a new project targeting `xc7a35tcpg236-1` (Basys3)
   - Add all `.v` source files and the `.xdc` constraints file
   - Re-generate the `clk_wiz_1` IP if prompted

3. **Run Synthesis & Implementation**
   - Click *Generate Bitstream*

4. **Program the board**
   - Open *Hardware Manager* → *Open Target* → *Program Device*
   - Select the generated `.bit` file

### Controls

| Button | Action |
|---|---|
| `btnU` | Move cursor up |
| `btnD` | Move cursor down |
| `btnL` | Move cursor left |
| `btnR` | Move cursor right |
| `btnC` | Toggle selection |
| `sw[5:0]` + reset | System reset |

---

## 📐 VGA Timing (640×480 @ 60Hz)

| Parameter | Value |
|---|---|
| Pixel clock | 25.175 MHz |
| Horizontal total | 800 pixels |
| Vertical total | 525 lines |
| Active area | 640 × 480 |
| Hsync polarity | Negative |
| Vsync polarity | Negative |

---

## 🛠️ Module Overview

### `fsm_game`
Finite state machine that listens for button edges and outputs one-hot direction signals. Includes debounce logic and handles the TOGGLE state for cursor selection.

### `Grid_counter`
Wrapping 6-bit counter that tracks the cursor's grid position. Accepts direction inputs from `fsm_game` and exposes `Position[5:0]` to both the VGA driver and LED output.

### `vga_driver`
Generates standard 640×480 VGA sync signals from the 25 MHz pixel clock. Accepts `cursor_pos[5:0]` to determine which grid cell to highlight and drives 4-bit RGB colour channels.

---

## 📋 Resource Utilisation (post-implementation)

| Resource | Used |
|---|---|
| LUTs | ~6 cells |
| I/O Ports | 32 |
| Nets | 37 |

---

## 📄 License

This project is released under the [MIT License](LICENSE).

---

## 🙏 Acknowledgements

- Digilent for the Basys3 board and reference designs
- Xilinx Vivado for synthesis and IP generation tools
