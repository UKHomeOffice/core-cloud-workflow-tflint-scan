#!/bin/bash

# Local TFLint Behaviour Test Suite
#
# This script executes TFLint directly against all test cases under ./tests/
# to ensure:
#   - each test folder's .tflint.hcl works as expected
#   - rules and plugins load correctly
#   - valid configs pass and invalid configs fail
#
# Important: This does NOT test the GitHub Action or reusable workflow.
# Those are validated separately using CI (e.g., a self-test workflow in this repo).

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "=========================================="
echo "   TFLint Local Testing Suite"
echo "=========================================="
echo ""

# Check if TFLint is installed
if ! command -v tflint &> /dev/null; then
    echo -e "${RED}✗ Error: TFLint is not installed${NC}"
    echo ""
    echo "Install it with:"
    echo "  macOS:   brew install tflint"
    echo "  Linux:   curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash"
    echo "  Windows: choco install tflint"
    echo ""
    echo "Or visit: https://github.com/terraform-linters/tflint"
    exit 1
fi

echo -e "${GREEN}✓ TFLint is installed${NC}"
tflint --version
echo ""

# Function to run test
run_test() {
    local test_name=$1
    local test_dir=$2
    local should_pass=$3
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${BLUE}Test: $test_name${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Directory: $test_dir"
    echo ""
    
    if [ ! -d "$test_dir" ]; then
        echo -e "${RED}✗ Test directory not found: $test_dir${NC}"
        return 1
    fi
    
    cd "$test_dir"
    
    # Initialize TFLint
    echo "→ Initializing TFLint..."
    if ! tflint --init > /dev/null 2>&1; then
        echo -e "${RED}✗ Failed to initialize TFLint${NC}"
        cd "$SCRIPT_DIR"
        return 1
    fi
    echo -e "${GREEN}✓ TFLint initialized${NC}"
    echo ""
    
    # Run TFLint
    echo "→ Running TFLint scan..."
    echo ""
    set +e
    tflint --format=compact --recursive
    exit_code=$?
    set -e
    
    echo ""
    
    # Check result
    if [ "$should_pass" = "true" ]; then
        if [ $exit_code -eq 0 ]; then
            echo -e "${GREEN}✓✓✓ TEST PASSED ✓✓✓${NC}"
            echo "Expected: Pass (no issues)"
            echo "Result:   Pass (no issues found)"
            cd "$SCRIPT_DIR"
            return 0
        else
            echo -e "${RED}✗✗✗ TEST FAILED ✗✗✗${NC}"
            echo "Expected: Pass (no issues)"
            echo "Result:   Failed (issues found - exit code: $exit_code)"
            cd "$SCRIPT_DIR"
            return 1
        fi
    else
        if [ $exit_code -ne 0 ]; then
            echo -e "${GREEN}✓✓✓ TEST PASSED ✓✓✓${NC}"
            echo "Expected: Fail (issues detected)"
            echo "Result:   Failed as expected (exit code: $exit_code)"
            cd "$SCRIPT_DIR"
            return 0
        else
            echo -e "${RED}✗✗✗ TEST FAILED ✗✗✗${NC}"
            echo "Expected: Fail (issues detected)"
            echo "Result:   Pass (no issues found - should have found issues!)"
            cd "$SCRIPT_DIR"
            return 1
        fi
    fi
}

# Run all tests
TESTS_PASSED=0
TESTS_FAILED=0
FAILED_TESTS=()

echo "=========================================="
echo "   Running Test Suite"
echo "=========================================="

# Test 1: Valid Terraform (should pass)
if run_test "Valid Terraform Configuration" "$SCRIPT_DIR/test-terraform-valid" "true"; then
    ((TESTS_PASSED++))
else
    ((TESTS_FAILED++))
    FAILED_TESTS+=("Valid Terraform Configuration")
fi

# Test 2: Invalid Terraform (should fail)
if run_test "Invalid Terraform Configuration" "$SCRIPT_DIR/test-terraform-invalid" "false"; then
    ((TESTS_PASSED++))
else
    ((TESTS_FAILED++))
    FAILED_TESTS+=("Invalid Terraform Configuration")
fi

# Test 3: AWS Provider Issues (should fail) - YOUR KEY TEST!
if run_test "AWS Provider-Specific Issues (t1.2xlarge example)" "$SCRIPT_DIR/test-aws-provider-issues" "false"; then
    ((TESTS_PASSED++))
else
    ((TESTS_FAILED++))
    FAILED_TESTS+=("AWS Provider-Specific Issues")
fi

# Test 4: Terragrunt (should pass)
if run_test "Terragrunt Configuration" "$SCRIPT_DIR/test-terragrunt" "true"; then
    ((TESTS_PASSED++))
else
    ((TESTS_FAILED++))
    FAILED_TESTS+=("Terragrunt Configuration")
fi

# Test 5: Custom Config (expected to fail due to strict rules)
if run_test "Custom Strict Configuration" "$SCRIPT_DIR/test-custom-config" "false"; then
    ((TESTS_PASSED++))
else
    ((TESTS_FAILED++))
    FAILED_TESTS+=("Custom Strict Configuration")
fi

# Summary
echo ""
echo ""
echo "=========================================="
echo "   Test Summary"
echo "=========================================="
echo ""
echo -e "Total Tests:  5"
echo -e "${GREEN}Passed:       $TESTS_PASSED${NC}"
echo -e "${RED}Failed:       $TESTS_FAILED${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}   ✓✓✓ ALL TESTS PASSED! ✓✓✓${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "Your TFLint action is working correctly!"
    echo ""
    exit 0
else
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${RED}   ✗✗✗ SOME TESTS FAILED ✗✗✗${NC}"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "Failed tests:"
    for test in "${FAILED_TESTS[@]}"; do
        echo -e "${RED}  ✗ $test${NC}"
    done
    echo ""
    exit 1
fi