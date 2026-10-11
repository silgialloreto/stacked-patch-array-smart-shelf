# Stacked Patch Array for smart food shelves

Final project for the **Wireless Electromagnetic Technologies (WET)** course, A.Y. 2024/2025  
Prof. Gaetano Marrocco – Reference: Eng. Alessio Mostaccio  
Group 2: Silvia Gialloreto, Valerio Luzi, M. Barracu

Design of a **linear array of 5 stacked patch antennas at 2.45 GHz**, to be mounted on the ceiling of a food warehouse. The antenna receives the signals sent by sensors on "smart" shelves, which detect changes in the dielectric properties of the food as it deteriorates, with the aim of reducing food waste.

As required by the brief (*Combined Human-AI Design of a Patch Antenna Array*), the **manual** design based on the course formulas is compared with a design proposed by **ChatGPT**. Both are simulated in MATLAB with the method of moments (MoM).

---

## Repository structure

```
stacked-patch-array-smart-shelf/
├── matlab/
│   ├── design_manuale/
│   │   ├── antennaPatchFinale.m   # single patch: sizing, mesh convergence, S11(W,L) contour plot, performance
│   │   ├── stacked.m              # stacked patch (Duroid 5880 + foam): S11, impedance, bandwidth, pattern, beamwidth
│   │   └── array.m                # 5-element linear array with Chebyshev tapering
│   └── design_ai_chatgpt/
│       ├── ChatPatch.m            # single patch with the parameters proposed by ChatGPT (FR-4)
│       ├── ChatStacked.m          # stacked patch proposed by ChatGPT
│       └── ChatArray.m            # 5-element array built from the ChatGPT stacked patch
└── docs/
    ├── AI_Driven_Antenna_Project_Instructions.pdf   # project brief
    ├── RelazioneGruppo2.pdf                         # final report (20 pages, in Italian)
    ├── Presentazione WET gruppo 2.pptx              # presentation
    ├── Approfondimento presentazione Gruppo2.pptx   # in-depth slides
    └── Stacked_Parameters_WET.xlsx                  # log of the stacked-patch optimisation attempts
```

---

## Requirements

- MATLAB with the **Antenna Toolbox** (`patchMicrostrip`, `pcbStack`, `conformalArray`, `sparameters`, `pattern`, `beamwidth`)
- **Phased Array System Toolbox** (`phased.ULA`, `phased.CosineAntennaElement`) for the array-factor section of `array.m`
- **Signal Processing Toolbox** (`chebwin`)
- **RF Toolbox** (`rfplot`)

The scripts are independent of each other and are meant to be run **section by section**. The MoM simulations (especially the mesh sweep and the contour plot in `antennaPatchFinale.m`) can take a long time.

---

## Manual design

### 1. Single patch – `antennaPatchFinale.m`
- **Substrate:** Rogers **Duroid 5880** (ε<sub>r</sub> = 2.2, tan δ = 9·10⁻⁴), chosen for its low losses and thermal stability. Copper conductor.
- First sizing with Balanis' formulas (ε<sub>eff</sub>, ΔL, L<sub>eff</sub>, R<sub>r</sub>, feed point L<sub>feed</sub>, beamwidth and directivity), 50 Ω coaxial feed.
- **Mesh convergence:** S11 at 2.45 GHz versus mesh density (λ/n); λ/26 chosen.
- **Contour plot** of |S11| versus W and L to locate the optimum.

| L | W | H | Mesh | S11 | Z<sub>in</sub> |
|---|---|---|---|---|---|
| 38.3 mm | 42.9 mm | 1.3 mm | λ/26 | −16 dB | ≈ 40 + j8 Ω |

| Parameter | Formulas | Simulation |
|---|---|---|
| E-plane beamwidth | 90.7° | 81° |
| H-plane beamwidth | 130.5° | 216° |
| Directivity | 5.1 dB | 7.8 dB |
| Gain | – | 7.7 dB |

### 2. Stacked patch – `stacked.m`
A **parasitic patch** is added above the fed patch, separated by a **foam** layer (ε<sub>r</sub> ≈ 1.03) that widens the bandwidth and makes the beam more directive.

| L2 | W2 | h2 (foam) | L<sub>feed</sub> |
|---|---|---|---|
| 45.1 mm | 42.7 mm | 8.1 mm | 18.3 mm |

Compared with the single patch, the beamwidth shrinks by 17% in the E-plane and by 35% in the H-plane, while directivity and gain rise to about **8.6 dB** (+10%). All intermediate attempts are logged in `docs/Stacked_Parameters_WET.xlsx`.

### 3. Array – `array.m`
Linear array of **5 elements** with **Chebyshev** synthesis and a side-lobe level R = 25 dB.

| x<sub>1</sub> | C<sub>0</sub> | C<sub>1</sub> | C<sub>2</sub> | Shape gain GF | Tapering efficiency η | d<sub>opt</sub> |
|---|---|---|---|---|---|---|
| 3.064 | 5.26 | 4.19 | 2.06 | 2.97 | 60% | 91.7 mm (≈ 3λ/4) |

| Spacing | Chebyshev BW | Uniform BW |
|---|---|---|
| d = λ/2 = 61.2 mm | 66.8° | 45.8° |
| d<sub>opt</sub> = 3λ/4 = 91.7 mm | 42.5° | 30.6° |

The array directivity reaches **about 15 dB**.

---

## AI-driven design (ChatGPT) – `matlab/design_ai_chatgpt/`

ChatGPT proposed a patch on **FR-4** (ε<sub>r</sub> = 4.4, h = 1.6 mm, L = 28.8 mm, W = 37.2 mm, mesh λ/10) and a stacked patch, also on FR-4, with L2 = 27.4 mm, W2 = 35.4 mm and h2 = 3 mm.

- The **single patch does not resonate** at 2.45 GHz: S11 never drops below −10 dB, the resistance is far below 50 Ω and the reactance is high.
- The **stacked patch** shows two peaks (2.45 and ~2.77 GHz), but S11 does not drop below −10 dB between them, so it behaves as a multiband rather than a wideband antenna. Its gain is low, ~3 dBi against 2.47 dBi for the patch.
- As a result, the **array** built from this design also performs poorly.

## Conclusions

The manual design meets the requirements; the AI-generated one does not. AI is useful and fast during preliminary research, but it tends to be superficial and over-accommodating, mixes up formulas and produces incomplete MATLAB code. It should therefore be used critically, with results always checked against reliable sources, and not as a primary source of scientific information.
