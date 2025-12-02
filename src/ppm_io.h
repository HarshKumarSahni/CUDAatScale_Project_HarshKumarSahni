// src/ppm_io.h
#pragma once
#include <vector>
#include <string>
#include <fstream>
#include <sstream>
#include <stdexcept>
#include <cstdint>

// Simple P6 (binary RGB) PPM loader/writer and P5 (binary grayscale) writer
struct Image {
  int width = 0;
  int height = 0;
  int channels = 3; // 3 for RGB, 1 for gray
  std::vector<unsigned char> data; // row-major, channels per pixel
};

inline static std::string read_token(std::ifstream &ifs) {
  std::string tok;
  while (ifs >> tok) {
    if (tok.size() && tok[0] == '#') { // comment
      std::string rest;
      std::getline(ifs, rest);
      continue;
    }
    return tok;
  }
  return tok;
}

inline Image read_ppm(const std::string &path) {
  std::ifstream ifs(path, std::ios::binary);
  if (!ifs) throw std::runtime_error("Cannot open " + path);
  std::string magic = read_token(ifs);
  if (magic != "P6") throw std::runtime_error("Only binary P6 PPM supported: " + path);
  int w = std::stoi(read_token(ifs));
  int h = std::stoi(read_token(ifs));
  int maxv = std::stoi(read_token(ifs));
  if (maxv != 255) throw std::runtime_error("Only maxval 255 supported");
  ifs.get(); // consume single whitespace
  Image img;
  img.width = w; img.height = h; img.channels = 3;
  img.data.resize(w * h * 3);
  ifs.read(reinterpret_cast<char*>(img.data.data()), img.data.size());
  if (!ifs) throw std::runtime_error("Failed reading image data");
  return img;
}

inline void write_pgm(const std::string &path, const Image &imgGray) {
  std::ofstream ofs(path, std::ios::binary);
  if (!ofs) throw std::runtime_error("Cannot open " + path);
  ofs << "P5\n" << imgGray.width << " " << imgGray.height << "\n255\n";
  ofs.write(reinterpret_cast<const char*>(imgGray.data.data()), imgGray.data.size());
}

inline void write_ppm(const std::string &path, const Image &img) {
  std::ofstream ofs(path, std::ios::binary);
  if (!ofs) throw std::runtime_error("Cannot open " + path);
  ofs << "P6\n" << img.width << " " << img.height << "\n255\n";
  ofs.write(reinterpret_cast<const char*>(img.data.data()), img.data.size());
}
