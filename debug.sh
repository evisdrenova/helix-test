#!/bin/bash

# Debug script to find where bad blob is referenced

BAD_BLOB="43acb5091b10484bd291c3da24ab1294e3145387aa9da5312dbc6f3d848742c1"

echo "=== HELIX DEBUG SCRIPT ==="
echo ""
echo "Looking for blob: ${BAD_BLOB:0:16}..."
echo ""

# 1. Check if blob file exists
echo "=== 1. CHECKING BLOB FILE ==="
if [ -f ".helix/objects/blobs/$BAD_BLOB" ]; then
    echo "✓ Blob file EXISTS"
    ls -lh ".helix/objects/blobs/$BAD_BLOB"
else
    echo "❌ Blob file MISSING"
fi
echo ""

# 2. List all blobs
echo "=== 2. ALL BLOBS IN STORAGE ==="
BLOB_COUNT=$(ls .helix/objects/blobs/ 2>/dev/null | wc -l)
echo "Total blobs: $BLOB_COUNT"
echo ""
echo "First 10 blobs:"
ls .helix/objects/blobs/ | head -10 | while read blob; do
    echo "  ${blob:0:16}..."
done
echo ""

# 3. Check if it matches any partial hash
echo "=== 3. CHECKING FOR SIMILAR HASHES ==="
echo "Looking for blobs starting with '43acb509'..."
ls .helix/objects/blobs/ | grep "^43acb509" || echo "  No matches found"
echo ""

# 4. Check commits
echo "=== 4. COMMIT INFO ==="
if [ -f ".helix/HEAD" ]; then
    echo "HEAD contents:"
    cat .helix/HEAD
    echo ""
fi

if [ -f ".helix/refs/heads/main" ]; then
    echo "main branch:"
    cat .helix/refs/heads/main
    echo ""
fi

echo "All commits:"
ls -1 .helix/objects/commits/ 2>/dev/null | head -5 | while read commit; do
    echo "  ${commit:0:16}..."
done
echo ""

# 5. Check trees
echo "=== 5. TREES ==="
TREE_COUNT=$(ls .helix/objects/trees/ 2>/dev/null | wc -l)
echo "Total trees: $TREE_COUNT"
echo ""

# 6. Dump a tree to see what it references
echo "=== 6. SAMPLE TREE CONTENTS ==="
FIRST_TREE=$(ls .helix/objects/trees/ 2>/dev/null | head -1)
if [ ! -z "$FIRST_TREE" ]; then
    echo "Tree: ${FIRST_TREE:0:16}..."
    echo "(Binary data - cannot display directly)"
    echo ""
fi

# 7. Check index
echo "=== 7. INDEX FILE ==="
if [ -f ".helix/helix.idx" ]; then
    echo "Index exists"
    ls -lh .helix/helix.idx
    echo ""
    echo "Index entries (binary, showing hex dump):"
    xxd .helix/helix.idx | head -20
else
    echo "No index file"
fi
echo ""

echo "=== RECOMMENDATIONS ==="
echo ""
echo "The blob $BAD_BLOB is being referenced somewhere but doesn't exist."
echo ""
echo "Try these steps:"
echo ""
echo "1. Check what files are in your index:"
echo "   helix status"
echo ""
echo "2. Force re-add all files to recreate blobs:"
echo "   helix add . --force --verbose"
echo ""
echo "3. Check if the issue persists:"
echo "   helix push origin main --dry-run"
echo ""
echo "4. If still failing, inspect the tree manually:"
echo "   # We can add a tree inspection tool"