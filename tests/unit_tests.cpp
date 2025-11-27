#include "math_operations.h"

#if defined(USE_GTEST)
#include <gtest/gtest.h>

TEST(AddTest, PositiveNumbers) {
    EXPECT_EQ(add(2, 3), 5);
}

TEST(AddTest, NegativeNumbers) {
    EXPECT_EQ(add(-4, -6), -10);
}

TEST(AddTest, MixedSign) {
    EXPECT_EQ(add(-2, 2), 0);
}

TEST(AddTest, LargeNumbers) {
    EXPECT_EQ(add(1000000, 2000000), 3000000);
}

int main(int argc, char** argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}

#else

#include <iostream>

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

#endif
