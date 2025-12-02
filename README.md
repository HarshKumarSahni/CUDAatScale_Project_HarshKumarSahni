# CUDA Image Processing at Scale — Project

## Project description (what & why)
This project demonstrates a small CUDA-based image-processing pipeline that can run on **hundreds** of images. The program converts color PPM images to grayscale using a CUDA kernel, showing parallel execution over pixels. The project is self-contained (no OpenCV dependency): it reads/writes PPM/PGM files and includes a Python script to generate 300 synthetic images for testing.

### Algorithms / Kernels
- **rgb_to_gray_kernel**: a simple GPU kernel to convert RGB → grayscale per-pixel using ITU formula (0.299 R + 0.587 G + 0.114 B).
- CPU fallback implemented to allow running in environments without CUDA.

### Lessons learned / notes
- File I/O can dominate time for many small images; batching and larger I/O buffers are useful optimizations.
- Measuring performance: use `cudaEvent_t` or host timers around kernel launches for accurate GPU timing (extension idea).
- This template is intentionally dependency-free to make it portable on lab machines.

## How to build
Requirements:
- CUDA toolkit with `nvcc`
- Python3 and Pillow for data generation (for proof artifacts)

Build:
```bash
make

