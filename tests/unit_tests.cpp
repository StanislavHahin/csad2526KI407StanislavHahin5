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