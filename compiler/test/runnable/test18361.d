module runnable.test18361;

/++
 * Test conservative range-checking for array lengths (issue #18361).
 * When a dynamic array is initialized from a known-length source and never
 * reassigned, bounds checks should be eliminated for provably-safe indices.
 +/

int main()
{
    // Case (c): array initialized from array literal, never reassigned
    {
        int[] arr = [1, 2, 3, 4, 5];
        // Index 0-4 should be provably in bounds (length 5)
        assert(arr[0] == 1);
        assert(arr[4] == 5);
    }

    // Case (c): string initialized from literal, never reassigned
    {
        string s = "hello";
        assert(s[0] == 'h');
        assert(s[4] == 'o');
    }

    // Case (b): array reassigned from unknown source
    {
        int[] arr = [1, 2, 3];
        int[] other = getArray();
        arr = other; // reassignment from unknown source
        // Bounds check should NOT be eliminated (conservative)
        if (arr.length > 0)
            assert(arr[0] >= 0);
    }

    // Case (a): array reassigned from known-length source
    // (conservative: still treats as unknown since we only track initializers)
    {
        int[] arr = [1, 2, 3];
        arr = [4, 5, 6]; // reassignment from known-length source
        if (arr.length > 0)
            assert(arr[0] == 4);
    }

    // Array with foreach (index should be in bounds from foreach)
    {
        int[] arr = [10, 20, 30];
        int sum = 0;
        foreach (v; arr)
            sum += v;
        assert(sum == 60);
    }

    return 0;
}

int[] getArray()
{
    return [7, 8, 9];
}
