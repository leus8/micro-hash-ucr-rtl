# Micro UCR Hash RTL

## Overview
This project consists of the RTL design of micro-hash-ucr, a nonce calculator that iterates over nonces to check if a hash output complies with a given target.

## Requirements
* Icarus Verilog, for simulation outputting
```
sudo apt install iverilog
```
* GTKWave Analyzer, to view simulation waves
```
sudo apt install gtkwave
```
* Qflow, for synthesis
```
sudo apt install qflow
```

## Installation
Clone repository with:
```
git clone github.com/leus8/micro-ucr-hash-rtl.git
```
## Usage
### Simulate design testbench and show wave output
Area oriented system:
```
make waves-area
```
Speed oriented system:
```
make waves-speed
```
Both systems
```
make waves
```
### Synthesize with Qflow (Yosys)
Area oriented system:
```
make synth-area
```
Speed oriented system:
```
make synth-speed
```
### Clean workspace
```
make clean
```