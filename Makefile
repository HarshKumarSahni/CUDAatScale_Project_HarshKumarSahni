# Windows-friendly Makefile for NVCC + CUDA

NVCC = nvcc.exe
CXXFLAGS = -O3 -std=c++17 --expt-relaxed-constexpr -Xcompiler="/std:c++17"
SRCDIR = src
BINDIR = bin
TARGET = $(BINDIR)/process_images.exe
SRC = $(SRCDIR)/main.cu
INCLUDES = -I$(SRCDIR)

all: $(TARGET)

$(TARGET): $(SRC)
	$(NVCC) $(CXXFLAGS) $(INCLUDES) -o $(TARGET) $(SRC)

clean:
	del /Q $(BINDIR)\*.exe
