// src/main.cu
#include <iostream>
#include <vector>
#include <string>
#include <filesystem>
#include <chrono>
#include <fstream>
#include "ppm_io.h"

namespace fs = std::filesystem;

// GPU kernel: converts RGB to grayscale (and optional blur pass)
__global__ void rgb_to_gray_kernel(const unsigned char* in, unsigned char* out, int w, int h) {
  int x = blockIdx.x * blockDim.x + threadIdx.x;
  int y = blockIdx.y * blockDim.y + threadIdx.y;
  if (x >= w || y >= h) return;
  int idx = (y * w + x);
  int in_idx = idx * 3;
  unsigned char r = in[in_idx + 0];
  unsigned char g = in[in_idx + 1];
  unsigned char b = in[in_idx + 2];
  unsigned char gray = static_cast<unsigned char>((0.299f*r + 0.587f*g + 0.114f*b));
  out[idx] = gray;
}

// CPU fallback for single-file debug
void rgb_to_gray_cpu(const Image &in, Image &out) {
  out.width = in.width;
  out.height = in.height;
  out.channels = 1;
  out.data.resize(out.width * out.height);
  for (int y = 0; y < in.height; ++y) {
    for (int x = 0; x < in.width; ++x) {
      int i = (y * in.width + x) * 3;
      unsigned char r = in.data[i+0];
      unsigned char g = in.data[i+1];
      unsigned char b = in.data[i+2];
      out.data[y * out.width + x] = static_cast<unsigned char>((0.299f*r + 0.587f*g + 0.114f*b));
    }
  }
}

void usage(const char* prog) {
  std::cout << "Usage: " << prog << " --in_dir INPUT_DIR --out_dir OUTPUT_DIR [--device GPU_ID] [--cpu]\n";
}

int main(int argc, char** argv) {
  std::string in_dir = "data_in";
  std::string out_dir = "outputs/processed";
  int device = 0;
  bool force_cpu = false;

  // simple CLI parse
  for (int i = 1; i < argc; ++i) {
    std::string a = argv[i];
    if (a == "--in_dir" && i+1 < argc) in_dir = argv[++i];
    else if (a == "--out_dir" && i+1 < argc) out_dir = argv[++i];
    else if (a == "--device" && i+1 < argc) device = std::stoi(argv[++i]);
    else if (a == "--cpu") force_cpu = true;
    else if (a == "--help") { usage(argv[0]); return 0; }
  }

  fs::create_directories(out_dir);
  std::ofstream logf(out_dir + "/../logs/run_log.txt", std::ios::app);
  auto t0 = std::chrono::high_resolution_clock::now();

  if (!force_cpu) {
    int deviceCount = 0;
    cudaError_t cerr = cudaGetDeviceCount(&deviceCount);
    if (cerr != cudaSuccess || deviceCount == 0) {
      std::cerr << "No CUDA device found or cudaGetDeviceCount failed: " << cudaGetErrorString(cerr) << "\n";
      force_cpu = true;
    } else {
      if (device < 0 || device >= deviceCount) device = 0;
      cudaSetDevice(device);
    }
  }

  int processed = 0;
  for (auto &p : fs::directory_iterator(in_dir)) {
    if (!p.is_regular_file()) continue;
    std::string path = p.path().string();
    if (p.path().extension() != ".ppm") continue;

    try {
      Image in = read_ppm(path);
      Image out;
      if (force_cpu) {
        rgb_to_gray_cpu(in, out);
      } else {
        // allocate device
        unsigned char *d_in=nullptr, *d_out=nullptr;
        size_t in_bytes = in.data.size() * sizeof(unsigned char);
        size_t out_bytes = in.width * in.height * sizeof(unsigned char);
        cudaMalloc(&d_in, in_bytes);
        cudaMalloc(&d_out, out_bytes);
        cudaMemcpy(d_in, in.data.data(), in_bytes, cudaMemcpyHostToDevice);

        dim3 block(16, 16);
        dim3 grid((in.width + block.x - 1)/block.x, (in.height + block.y - 1)/block.y);
        rgb_to_gray_kernel<<<grid, block>>>(d_in, d_out, in.width, in.height);
        cudaDeviceSynchronize();

        out.width = in.width; out.height = in.height; out.channels = 1;
        out.data.resize(out.width * out.height);
        cudaMemcpy(out.data.data(), d_out, out_bytes, cudaMemcpyDeviceToHost);

        cudaFree(d_in); cudaFree(d_out);
      }

      std::string outname = out_dir + "/" + p.path().stem().string() + "_gray.pgm";
      write_pgm(outname, out);
      ++processed;
      std::cout << "Processed " << path << " -> " << outname << "\n";
      logf << "Processed " << path << " -> " << outname << " [time_ms placeholder]\n";
    } catch (const std::exception &e) {
      std::cerr << "Failed processing " << path << ": " << e.what() << "\n";
      logf << "Failed " << path << " : " << e.what() << "\n";
    }
  }

  auto t1 = std::chrono::high_resolution_clock::now();
  double secs = std::chrono::duration<double>(t1 - t0).count();
  logf << "Total files processed: " << processed << " Time(s): " << secs << "\n";
  std::cout << "Total processed: " << processed << " in " << secs << " s\n";
  return 0;
}
