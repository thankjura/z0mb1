#ifndef UTILS_H
#define UTILS_H
#include <iostream>

namespace utils {
    int sign(const double value);
    
    double clamp(const double n, const double lower, const double upper);
    
    double lerp(const double a, const double b, const double f);
    
    double db2linear(double p_db);
    double linear2db(double p_linear);
    
    double rad2deg(const double p_y);
    double deg2rad(const double p_y);
}

#endif