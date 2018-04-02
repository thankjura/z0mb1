#include "utils.hpp"
#include <math.h> 

int utils::sign(const double value) {
    if (value > 0) {
        return 1;    
    }
    
    if (value < 0) {
        return -1;
    }
    
    return 0;
}

double utils::clamp(const double n, const double lower, const double upper) {
    return std::max(lower, std::min(n, upper));
}

double utils::lerp(const double a, const double b, const double f) {
    if (a != b) {
        return a + f * (b - a);
    } else {
        return a;
    }
}

double utils::db2linear(double p_db) {
     return exp(p_db * 0.11512925464970228420089957273422);
}

double utils::linear2db(double p_linear) {
     return log(p_linear) * 8.6858896380650365530225783783321;
}

double utils::rad2deg(const double p_y) {
    return p_y * 180.0 / M_PI;
}

double utils::deg2rad(const double p_y) {
    return p_y * M_PI / 180.0;
}
