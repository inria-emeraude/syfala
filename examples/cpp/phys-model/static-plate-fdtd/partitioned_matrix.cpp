#include <iostream>
#include <cstdint>


void display_formated(int value) {
    if (value < 10) { printf("%d ", value); }
    else            { printf("%d", value); }
}

int main() {
    
    constexpr size_t matrix_width = 100;
    constexpr size_t matrix_height = 84;
    constexpr size_t matrix_size = matrix_height * matrix_width;

    constexpr size_t window_width = 20;
    constexpr size_t window_height = 20;
    constexpr size_t window_length = window_width * window_width;

    constexpr int border_size = 2;


    int matrix[matrix_size] = {0};
    int output_matrix[matrix_size] = {0};

    for (size_t i = 0; i < matrix_size; i++) {
        matrix[i] = 1;
    }
    
    for (size_t j = 0; j < matrix_height; j++) {
        for (size_t i = 0; i < matrix_width; i++) {
            
            int value = matrix[j*matrix_width + i];        
            // display_formated(value);
        }
        // printf("\n");
    }
    
    // printf("\n\n\n");
    
    int window_index_X = 0;
    int window_index_Y = 0;
    int window_index = window_index_X * window_width + window_index_Y * window_height;

    int num_windows = 0;

    while (window_index_X <= matrix_width - window_width && window_index_Y <= matrix_height - window_height) {
    
        for (size_t row_index = border_size; row_index < window_width - border_size; row_index++) {
            for (size_t col_index = border_size; col_index < window_width - border_size; col_index++) {

                int mask_center_index = (window_index_Y + row_index)*matrix_width + window_index_X + col_index;

                int result = matrix[mask_center_index]
                           + matrix[mask_center_index + 1]
                           + matrix[mask_center_index - 1]
                           + matrix[mask_center_index + matrix_width]
                           + matrix[mask_center_index - matrix_width]
                           + matrix[mask_center_index + matrix_width + 1]
                           + matrix[mask_center_index - matrix_width - 1]
                           + matrix[mask_center_index + matrix_width - 1]
                           + matrix[mask_center_index - matrix_width + 1]
                           
                           + matrix[mask_center_index + 2]
                           + matrix[mask_center_index - 2]
                           + matrix[mask_center_index + 2*matrix_width]
                           + matrix[mask_center_index - 2*matrix_width];

                if (result == 13) { output_matrix[mask_center_index] = 1; }
                else              { output_matrix[mask_center_index] = result; }

                // display_formated(output_matrix[mask_center_index]);

            }
            // printf("\n");
        }
        // printf("\n\n");

        window_index_X += window_width - 2*border_size;

        if (window_index_X > matrix_width - window_width) {
            window_index_X = 0;
            window_index_Y += window_height - 2*border_size;
        }
        num_windows++;
    }
    
    printf("\n\n\n");

    for (size_t j = 0; j < matrix_height; j++) {
        for (size_t i = 0; i < matrix_width; i++) {
            
            int value = output_matrix[j*matrix_width + i];
            
            display_formated(value);
        }     
        printf("\n");
    }
 
    printf("\n\nnumber of windows : %d\n\n", num_windows);

    return 0;
}
