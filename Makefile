BUILD = build
PROGRAM = example-hpvm-sum
LIB = lib$(PROGRAM).so

#
#
# Tools
#
OPT = $(HPVM_BUILD)/bin/opt
LLVM_LINK = $(HPVM_BUILD)/bin/llvm-link

CXX = $(ANDROID_NDK)/toolchains/llvm/prebuilt/linux-x86_64/bin/clang++
CC  = $(ANDROID_NDK)/toolchains/llvm/prebuilt/linux-x86_64/bin/clang

# 
# 
# Flags
# 
INCLUDES = -I./include -I$(HPVM_ROOT)/hpvm/include
DEFINES  = -DNUM_CORES=$(NUM_CORES)

# O1 is required, otherwise GenHPVM fails (invalid arguments to __hpvm__attributes)
ANDROID_CFLAGS = \
	-target $(TARGET) \
	-fexceptions -fPIC \
	-ffast-math -O1 \
	-fno-lax-vector-conversions -fno-vectorize -fno-slp-vectorize


#
#
# Rules
#

default: check-env build-dir $(BUILD)/$(LIB)

$(BUILD)/hpvm-rt.bc: src/hpvm-rt.cpp
	$(CXX) $(ANDROID_CFLAGS) $^ -c -emit-llvm -o $@ $(INCLUDES) $(DEFINES)

# Generate LLVM IR
$(BUILD)/$(PROGRAM).ll: src/$(PROGRAM).cpp
	$(CC) $(ANDROID_CFLAGS) -S -emit-llvm $^ -o $@ $(INCLUDES)

# Generate HPVM IR
$(BUILD)/$(PROGRAM).hpvm.ll: $(BUILD)/$(PROGRAM).ll
	$(OPT) -debug $^ -S -o $@ -load LLVMGenHPVM.so -genhpvm -hpvm-timers-gen

# Passes
$(BUILD)/$(PROGRAM).host.ll: $(BUILD)/$(PROGRAM).hpvm.ll
	$(OPT) -debug $^ -S -o $@ -load LLVMBuildDFG.so -load LLVMDFG2LLVM_CPU.so -load LLVMClearDFG.so -dfg2llvm-cpu -clearDFG -hpvm-timers-cpu
	sed -i 's/ in,\| out,\| in out,/,/g' $@

# Link with HPVM RT
$(BUILD)/$(PROGRAM).linked.ll: $(BUILD)/$(PROGRAM).host.ll $(BUILD)/hpvm-rt.bc
	$(LLVM_LINK) $^ -S -o $@

# Create obj
$(BUILD)/$(LIB): $(BUILD)/$(PROGRAM).linked.ll
	$(CXX) $(ANDROID_CFLAGS) -Wl,-soname,$(LIB) -static-libstdc++ -shared -L./lib -lOpenCL $^ -o $@ 



# 
# 
# Install
# 
install: check-env
	cp $(BUILD)/$(LIB) $(LIB_INSTALL_PATH)/
	cp ./include/$(PROGRAM).h $(INCLUDE_INSTALL_PATH)/

# 
# 
# Utility
# 
.PHONY: check-env
check-env:
	./check-env.sh

.PHONY: build-dir
build-dir:
	mkdir -p $(BUILD)

.PHONY: clean
clean:
	rm -drf ./build
