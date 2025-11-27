#include <iostream>
#include "math_operations.h"

int main() {
    int failures = 0;

    auto check = [&](const char* name, int got, int expect) {
        if (got != expect) {
            std::cout << "[FAILED] " << name << ": got " << got << ", expected " << expect << "\n";
            ++failures;
        } else {
            std::cout << "[ OK ] " << name << "\n";
        }
    };

    check("PositiveNumbers", add(2,3), 5);
    check("NegativeNumbers", add(-4,-6), -10);
    check("MixedSign", add(-2,2), 0);
    check("LargeNumbers", add(1000000,2000000), 3000000);

    if (failures == 0) {
        std::cout << "All tests passed\n";
    } else {
        std::cout << failures << " test(s) failed\n";
    }

    return failures == 0 ? 0 : 1;
}
