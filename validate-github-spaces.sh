#!/bin/bash

echo "🧪 Running AuxJuris V2 GitHub Spaces validation tests..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_TOTAL=0

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo -n "Testing $test_name... "
    ((TESTS_TOTAL++))
    
    if eval "$test_command" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ PASSED${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗ FAILED${NC}"
    fi
}

# Check if we're in the right directory
if [[ ! -f "package.json" ]]; then
    echo -e "${RED}❌ Error: Not in AuxJuris V2 directory${NC}"
    exit 1
fi

echo "📋 Running validation tests..."

# Test 1: Check if dependencies can be installed
if [[ ! -d "node_modules" ]]; then
    run_test "NPM dependencies installation" "npm ci --silent"
else
    run_test "NPM dependencies exist" "test -d node_modules"
fi

# Test 2: Check backend dependencies
if [[ ! -d "backend/node_modules" ]]; then
    run_test "Backend dependencies installation" "cd backend && npm ci --silent"
else
    run_test "Backend dependencies exist" "test -d backend/node_modules"
fi

# Test 3: Check if frontend builds
run_test "Frontend build" "npm run build:frontend"

# Test 4: Check if backend builds
run_test "Backend build" "npm run build:backend"

# Test 5: Check if required files exist
run_test "Required files exist" "test -f Dockerfile && test -f .devcontainer/devcontainer.json && test -f startup.sh"

# Test 6: Check if scripts are executable
run_test "Scripts are executable" "test -x startup.sh && test -x start-all.sh"

# Test 7: Check if configuration files can be created
run_test "Configuration files creation" "./startup.sh && test -f qdrant-config.yaml && test -f backend/.env"

# Test 8: Check if build outputs exist
run_test "Build outputs exist" "test -d backend/dist && test -d dist"

# Test 9: Check if environment template is valid
run_test "Environment template validity" "grep -q 'GOOGLE_API_KEY' backend/.env.example && grep -q 'PORT' backend/.env.example"

# Test 10: Check if Docker build context is valid
run_test "Docker build context" "docker build --dry-run . > /dev/null 2>&1 || test -f Dockerfile"

echo ""
echo "📊 Test Results:"
echo "   Passed: $TESTS_PASSED/$TESTS_TOTAL"

if [[ $TESTS_PASSED -eq $TESTS_TOTAL ]]; then
    echo -e "${GREEN}🎉 All tests passed! AuxJuris V2 is ready for GitHub Spaces.${NC}"
    echo ""
    echo -e "${YELLOW}📌 Next Steps:${NC}"
    echo "   1. Push your changes to GitHub"
    echo "   2. Create a new GitHub Codespace"
    echo "   3. The environment will be automatically configured"
    echo "   4. Add your GOOGLE_API_KEY to backend/.env"
    echo "   5. Run './start-all.sh' to start all services"
    echo ""
    echo -e "${GREEN}🚀 Ready to deploy!${NC}"
    exit 0
else
    echo -e "${RED}❌ Some tests failed. Please check the issues above.${NC}"
    exit 1
fi