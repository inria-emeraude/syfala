#ifndef GRID_CONFIG_H
#define GRID_CONFIG_H

constexpr u16 num_windows = 30;
constexpr u32 window_indexes[num_windows] = {
    0, 16, 32, 48, 64, 1344, 1360, 1376, 1392, 1408, 2688, 2704, 2720, 2736, 2752, 4032, 4048, 4064, 4080, 4096, 5376, 5392, 5408, 5424, 5440, 6720, 6736, 6752, 6768, 6784, 
};
constexpr u16 grid_height = 100;
constexpr u16 grid_width = 84;
constexpr u32 grid_length = 8400;
constexpr u32 num_max_samples = 8400;
constexpr u16 window_width = 20;
constexpr u16 window_height = 20;
constexpr u32 window_length = 400;
constexpr u8 border_size = 2;

#endif // GRID_CONFIG_H
