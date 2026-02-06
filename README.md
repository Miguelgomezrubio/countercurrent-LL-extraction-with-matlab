# Liquid–Liquid Counter-Current Extraction – Stage Calculator

This repository contains a set of MATLAB functions for computing the number of equilibrium stages in **liquid–liquid counter-current extraction** systems using a **graphical equilibrium approach**. The implementation is based on mass balances, polynomial equilibrium correlations, and iterative stage stepping using the pole method.

---

## Repository Contents

| File | Description |
|------|-------------|
| `counterFlow_function.m` | Core solver for counter-current extraction. Computes equilibrium stages, flow conditions, and pole point. |
| `counterFlow_plot_function.m` | Generates a graphical diagram showing equilibrium curves, pole lines, feed points, and stage stepping. |
| `main.m` | Example script demonstrating how to run the solver, plot results, and perform sensitivity analyses. |
| `README.md` | Documentation for the repository (this file). |

---

## Overview

The model performs:

- Polynomial fitting of equilibrium tie-line data
- Computation of the global mixing point
- Pole point construction
- Iterative stage stepping until the desired raffinate composition is achieved
- Extraction of performance metrics such as:
  - Number of stages
  - Stage compositions (extract & raffinate)
  - Separation achieved

Graphical visualization includes:

- Equilibrium curves
- Stage stepping segments
- Pole lines
- Feed points and mixing point
- Target separation

---

## Requirements

- MATLAB R2020a or newer (other versions may work)
- Optimization Toolbox (for `fminbnd`)
- No external dependencies

---

## Usage

1. Clone the repository:

```bash
git clone https://github.com/Miguelgomezrubio/countercurrent-LL-extraction-with-matlab.git
```

2. The user must specify the LL equilibrium data of the components, and the desired separation, as an example, the user can check:

```matlab
MAIN_countercurrentFlow_usage.m
```

The script will:

- Compute equilibrium stages for a base operating point
- Plot the graphical extraction diagram
- Perform sensitivity analysis with respect to the raffinate feed flow rate

---

## Example Output

The solver returns the following variables:

```matlab
[R, E, n, M, pole, Ro, Eo, P_raffinate, P_extract, desired_separation]
```

Where:

- `R` → Raffinate stage compositions `[xS, xD]`
- `E` → Extract stage compositions `[yS, yD]`
- `n` → Number of equilibrium stages
- `M` → Global mixing point
- `pole` → Pole composition
- `P_raffinate` / `P_extract` → Polynomial equilibrium fits
- `desired_separation` → Target raffinate composition

---

## Counter-current Diagram (PDF)

You can open the process diagram directly from the repository here:

- [`countercurrent_diagram.pdf`](./countercurrent_diagram.pdf)

---

## Input Data Format

Equilibrium data must be provided as **mass fraction arrays**:

```matlab
xS_eq = [...];   % solute in raffinate phase
xD_eq = [...];   % solvent in raffinate phase
yS_eq = [...];   % solute in extract phase
yD_eq = [...];   % solvent in extract phase
```

Feed specifications:

```matlab
Ro, xSo, xDo
Eo, ySo, yDo
```

And the target separation:

```matlab
xSn  % desired solute mass fraction in final raffinate
```

---

## Sensitivity Analysis

The `main.m` script also shows how to analyze:

- Number of stages `n` as a function of `Ro`
- Final raffinate solute fraction as a function of `Ro`
- Extract stage-1 solute fraction as a function of `Ro`

Example snippet:

```matlab
for i = 1:length(Ro_range)
    [~,~,n] = counterFlow_function(Ro_range(i), Eo, ...);
    n_plot(i) = n;
end
```

---

## Modifying the Code

You can customize:

- Polynomial degree (`P_degree`)
- Plot styling
- Axis limits
- Label visibility

These are located in `main.m` and `counterFlow_plot_function.m`.

---

## Theoretical Context

The implementation corresponds to graphical equilibrium stage methods commonly found in:

- Liquid–liquid extraction textbooks
- Mass transfer and separation process design literature
- Chemical engineering equilibrium theory

Key assumptions:

- Steady-state operation
- Ideal mixing at stage boundaries
- Two-component (solute/solvent) mass fractions

---

##  License


```
MIT License
```



## Contact

If you use this code for academic work or research, attribution is appreciated.
