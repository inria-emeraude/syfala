
function give_grid_width(num_windows, window_width, border_width) 
    return window_width + (num_windows - 1)*(window_width - 2 * border_width)
end 

function write_grid_indices(window_width :: Integer, 
                            num_windows_hor :: Integer, 
                            num_windows_vert :: Integer) :: Nothing

    border_width = 2

    grid_width = give_grid_width(num_windows_hor, window_width, border_width)
    grid_height = give_grid_width(num_windows_vert, window_width, border_width)

    index_X = 0
    index_Y = 0

    window_indexes = []
    num_windows = 0

    while (index_X <= (grid_width - window_width) && index_Y <= (grid_height - window_width))

        lin_index = index_X + index_Y * grid_width
        push!(window_indexes, lin_index)
        num_windows += 1

        index_X += window_width - 2 * border_width

        if index_X > grid_width - window_width
            index_X = 0
            index_Y += window_width - 2 * border_width
        end
    end
    
    open("examples/cpp/phys-model/static-plate-fdtd/grid_config.h", "w") do file 
        write(file, "#ifndef GRID_CONFIG_H\n");
        write(file, "#define GRID_CONFIG_H\n\n");
        write(file, "constexpr u16 num_windows = $(num_windows);\n")
        write(file, "constexpr u32 window_indexes[num_windows] = {\n    ")
        for elem in window_indexes
            write(file, "$(elem), ")
        end 
        write(file, "\n};\n")
        
        write(file, "constexpr u16 grid_height = $(grid_height);\n")
        write(file, "constexpr u16 grid_width = $(grid_width);\n")
        write(file, "constexpr u32 grid_length = $(grid_height * grid_width);\n")
        write(file, "constexpr u32 num_max_samples = $(grid_width * grid_height);\n")
        write(file, "constexpr u16 window_width = $(window_width);\n")
        write(file, "constexpr u16 window_height = $(window_width);\n")
        write(file, "constexpr u32 window_length = $(window_width * window_width);\n")
        write(file, "constexpr u8 border_size = $(border_width);\n")
        write(file, "\n#endif // GRID_CONFIG_H\n");
    end 

    println("constexpr u16 num_windows = $(num_windows);")
    print("constexpr u32 window_indexes[num_windows] = {\n    ")
    for elem in window_indexes
        print("$(elem), ")
    end 
    print("\n};\n")

    println("constexpr u16 grid_height = $(grid_height);")
    println("constexpr u16 grid_width = $(grid_width);")
    println("constexpr u32 num_max_samples = grid_width * grid_height;")
    println("constexpr u16 window_width = $(window_width);")
    println("constexpr u16 window_height = $(window_width);")
    println("constexpr u32 window_length = window_height * window_width;")
    println("constexpr u8 border_size = $(border_width);")

    return nothing
end 

run(`clear`)

write_grid_indices(20, 5, 6)
# write_grid_indices(20, 10, 12)
# write_grid_indices(10, 5, 6)
# write_grid_indices(8, 2, 2)
# write_grid_indices(15, 2, 3)
# write_grid_indices(20, 1, 1)
