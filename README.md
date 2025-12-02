# CUDA Image Processing at Scale — Final Project

## Overview

This project implements a CUDA-accelerated image-processing pipeline capable of processing **hundreds of images at scale**.  
The program converts RGB `.ppm` images to grayscale `.pgm` using a CUDA kernel that runs in parallel across pixels.  
A synthetic dataset of **300 input images** is generated automatically using Python, ensuring scalability testing without external downloads.

The goal is to demonstrate:

- GPU parallelization using CUDA  
- Handling many input files (batch processing)  
- Generating output artifacts and logs for evaluation  
- A complete, end-to-end CUDA project  

---

## Algorithms & Kernels

### 🔹 1. `rgb_to_gray_kernel` (CUDA)

This CUDA kernel converts each pixel from RGB → Grayscale using the ITU-R BT.601 formula:

```
gray = 0.299 * R + 0.587 * G + 0.114 * B
```

Each pixel is processed in parallel:

- each thread computes one pixel  
- blocks = 16×16 threads  
- grid sized to cover the image  
- memory accesses are coalesced since RGB is stored sequentially  

### 🔹 2. CPU Fallback

If CUDA is not available (or `--cpu` is passed), the CPU grayscale implementation is used.

Benefits:

- cross-platform compatibility  
- allows comparing GPU vs CPU execution speed  

---

## Project Structure

```
CUDAatScale_Project/
│
├─ src/
│   ├─ main.cu             # CUDA main program + kernel
│   └─ ppm_io.h            # Tiny PPM/PGM image I/O utilities
│
├─ scripts/
│   ├─ generate_data.py    # Generates 300 synthetic PPM images
│   └─ run.sh              # Optional helper script
│
├─ data_in/                # Generated input images
│
├─ outputs/
│   ├─ processed/          # GPU-generated grayscale images
│   └─ logs/
│       └─ run_log.txt     # Execution log (proof of processing)
│
├─ bin/
│   └─ process_images.exe  # Compiled CUDA executable (Windows)
│
├─ Makefile                # Build configuration for NVCC
└─ README.md               # Project documentation
```

---

## How to Build (Windows with NVCC + MSVC)

### ✔ Requirements

- CUDA Toolkit (with `nvcc` in PATH)  
- Visual Studio Build Tools 2019/2022 (provides `cl.exe`)  
- `make` (Chocolatey or MSYS2)  
- Python 3 + Pillow (`pip install pillow`)  

### ✔ Build command  
Run inside **Developer Command Prompt for VS**:

```bash
make
```

This generates:

```
bin/process_images.exe
```

---

## How to Run

### 1. Generate the dataset (300 images)

```bash
python scripts/generate_data.py
```

### 2. Run CUDA processing

```bash
bin\process_images.exe --in_dir data_in --out_dir outputs\processed
```

### 3. (Optional) Force CPU mode

```bash
bin\process_images.exe --in_dir data_in --out_dir outputs\processed --cpu
```

### Output:

- grayscale `.pgm` files generated in:  
  `outputs/processed/`
- execution log created at:  
  `outputs/logs/run_log.txt`

---

## Proof of Execution

To demonstrate scalability and correctness, the repository includes:

### ✔ `outputs/processed/`
Contains **300 grayscale images**, for example:

```
img_0000_gray.pgm
img_0001_gray.pgm
...
img_0299_gray.pgm
```

### ✔ `outputs/logs/run_log.txt`
Example contents:

```
Processed data_in/img_0001.ppm -> outputs/processed/img_0001_gray.pgm
Processed 300 images in 2.13 seconds
```

This satisfies the assignment requirement of:

- multiple data inputs  
- clear evidence of program execution  
- large-scale batch processing  

---

## Lessons Learned

- File I/O becomes a bottleneck when processing many small images; the GPU finishes far faster than disk operations.  
- CUDA kernel configuration (block/grid size) is essential for maximizing throughput.  
- Windows CUDA builds require correct MSVC installation and C++17 flags (`-std=c++17`, `-Xcompiler="/std:c++17"`).  
- Debugging NVCC on Windows is more complex than on Linux; using the Developer Command Prompt is essential.  
- Avoiding external libraries (e.g., OpenCV) keeps the project portable and self-contained.  

---

## Summary

This project demonstrates:

- a scalable, parallel GPU processing pipeline  
- a working CUDA kernel  
- reproducible outputs  
- correct repository structure  
- complete build + run instructions  
- proof artifacts included for peer review  

The repository is fully self-contained and ready for evaluation.