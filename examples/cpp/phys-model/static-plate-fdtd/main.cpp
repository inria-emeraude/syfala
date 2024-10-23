

void update_loop(float *out, size_t nFrames) {
    
    for (size_t n = 0; n < nFrames; n++) {
        for (size_t Y = 2; Y < (Ny - 1); Y++) {
            for (size_t X = 2; X < (Nx - 1); X++) {
                
                cp = Y*width + X;
                
                u[cp] = B1 * (u1[cp - 1] + u1[cp + 1] + u1[cp - width] + u1[cp + width])
                      + B2 * (u1[cp - 2] + u1[cp + 2] + u1[cp - 2*width] + u1[cp + 2*width])
                      + B3 * (u1[cp + width - 1] + u1[cp + width + 1] + u1[cp - width - 1] + u1[cp - width + 1])
                      + B4 * u1[cp]
                      + C1 * (u2[cp - 1] + u2[cp + 1] + u2[cp - width] + u2[cp + width]) 
                      + C2 * u2[cp];    
            }
        }
        
        out[n] = u[out_location];
        
        dummy_pty = u2;
        u2  u1; 
        u1 = u;
        u = dummy_ptr;
    }
}
