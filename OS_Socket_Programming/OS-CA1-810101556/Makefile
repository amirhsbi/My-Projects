CXX := g++
CXXFLAGS := -std=gnu++17 -Wall -Wextra -Werror -O2 -pipe -Isrc
LDFLAGS :=

BIN_DIR := bin
TARGET_SERVER := $(BIN_DIR)/server
TARGET_CLIENT := $(BIN_DIR)/client

SRCS_SERVER := os/server.cpp os/common.cpp
SRCS_CLIENT := os/client.cpp os/common.cpp

all: $(TARGET_SERVER) $(TARGET_CLIENT)

$(TARGET_SERVER): $(SRCS_SERVER)
	@mkdir -p $(BIN_DIR)
	$(CXX) $(CXXFLAGS) $(SRCS_SERVER) -o $@ $(LDFLAGS)

$(TARGET_CLIENT): $(SRCS_CLIENT)
	@mkdir -p $(BIN_DIR)
	$(CXX) $(CXXFLAGS) $(SRCS_CLIENT) -o $@ $(LDFLAGS)

run-server: $(TARGET_SERVER)
	$(TARGET_SERVER)

run-client: $(TARGET_CLIENT)
	$(TARGET_CLIENT) 127.0.0.1 5050

clean:
	rm -rf $(BIN_DIR)