#include <gtest/gtest.h>
#include "../math_operations.h"

TEST(MathTests, SimpleAddition) {
    EXPECT_EQ(add(2, 2), 4);
    EXPECT_EQ(add(-1, 1), 0);
}
