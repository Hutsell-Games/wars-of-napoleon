# QB64 Parsing-Based Testing Framework Design

## Overview

This document describes a testing framework that **parses QB64 source files** and **generates temporary test files** rather than using QB64's `$INCLUDE` system. This approach completely bypasses QB64's code organization limitations by handling all the complexity in the framework itself.

## Core Concept

Instead of:
```qb64
'$INCLUDE: 'declarations.bas'  ' Has executable code
'$INCLUDE: 'test_framework.bas'  ' Has SUB definitions
'$INCLUDE: 'test_combat.bas'  ' Has SUB definitions
```

The framework:
1. **Parses** all source files
2. **Resolves** all `$INCLUDE` directives (flattens includes)
3. **Reorganizes** code into QB64's required three-phase structure
4. **Generates** a temporary, properly-organized test file
5. **Compiles** and **runs** the test file
6. **Reports** results

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Test Framework (Python)                   │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  1. File Discovery                                            │
│     └─> Scans src/test/ for test_*.bas files                  │
│                                                               │
│  2. Source Parsing                                           │
│     ├─> Parse QB64 syntax (SUB, FUNCTION, CONST, DIM, etc.) │
│     ├─> Resolve $INCLUDE directives (recursive)             │
│     └─> Build dependency graph                                │
│                                                               │
│  3. Code Reorganization                                       │
│     ├─> Phase 1: All CONST, TYPE, DIM declarations          │
│     ├─> Phase 2: All SUB/FUNCTION definitions               │
│     └─> Phase 3: All executable statements                   │
│                                                               │
│  4. Test Discovery                                            │
│     ├─> Find SUB Test* patterns                              │
│     ├─> Find SUB Run*Tests patterns                          │
│     └─> Extract test metadata                                │
│                                                               │
│  5. Test File Generation                                      │
│     ├─> Generate properly-organized temp file               │
│     ├─> Add test runner                                      │
│     └─> Add initialization code                              │
│                                                               │
│  6. Compilation & Execution                                   │
│     ├─> Call qb64pe to compile temp file                     │
│     ├─> Execute compiled test                                │
│     └─> Capture output                                        │
│                                                               │
│  7. Result Reporting                                          │
│     ├─> Parse test output                                    │
│     ├─> Generate report (console, JSON, HTML)                │
│     └─> Return exit code                                      │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## Detailed Design

### Phase 1: File Discovery

**Input**: Project root directory, test directory pattern

**Process**:
```python
def discover_test_files(root_dir, pattern="test_*.bas"):
    """
    Discover all test files in the project.
    
    Returns:
        List of test file paths
    """
    test_files = []
    for root, dirs, files in os.walk(root_dir):
        for file in files:
            if fnmatch.fnmatch(file, pattern):
                test_files.append(os.path.join(root, file))
    return test_files
```

**Output**: List of test file paths

### Phase 2: Source Parsing

**Components**:

#### A. QB64 Syntax Parser

Parse QB64 source into structured representation:

```python
class QB64Parser:
    def parse_file(self, filepath):
        """
        Parse a QB64 source file.
        
        Returns:
            FileAST containing:
            - constants: List of CONST declarations
            - types: List of TYPE definitions
            - dims: List of DIM declarations
            - declares: List of DECLARE statements
            - subs: List of SUB definitions
            - functions: List of FUNCTION definitions
            - executable: List of executable statements
            - includes: List of $INCLUDE directives
        """
```

**Parse Patterns**:
- `CONST name = value` → Constant declaration
- `TYPE TypeName ... END TYPE` → Type definition
- `DIM [SHARED] name [AS type]` → Variable declaration
- `DECLARE SUB/FUNCTION ...` → Forward declaration
- `SUB name ... END SUB` → Subroutine definition
- `FUNCTION name ... END FUNCTION` → Function definition
- `'$INCLUDE: 'path'` → Include directive
- Everything else → Executable statement

#### B. Include Resolver

Resolve all `$INCLUDE` directives recursively:

```python
class IncludeResolver:
    def resolve_includes(self, filepath, visited=None):
        """
        Recursively resolve all $INCLUDE directives.
        
        Returns:
            ResolvedFile containing all code from includes
        """
        if visited is None:
            visited = set()
        
        if filepath in visited:
            return None  # Circular dependency detected
        
        visited.add(filepath)
        
        # Parse file
        ast = parser.parse_file(filepath)
        
        # Resolve each include
        resolved = ResolvedFile()
        for include_path in ast.includes:
            resolved_path = self.resolve_path(filepath, include_path)
            included = self.resolve_includes(resolved_path, visited.copy())
            if included:
                resolved.merge(included)
        
        # Add this file's content
        resolved.merge(ast)
        
        return resolved
```

**Path Resolution**:
- Relative paths resolved relative to including file
- Absolute paths used as-is
- Track circular dependencies

#### C. Dependency Graph Builder

Build dependency graph for proper ordering:

```python
class DependencyGraph:
    def build_graph(self, files):
        """
        Build dependency graph from file includes.
        
        Returns:
            Ordered list of files in dependency order
        """
        # Build graph
        graph = {}
        for file in files:
            graph[file] = self.get_dependencies(file)
        
        # Topological sort
        return self.topological_sort(graph)
```

### Phase 3: Code Reorganization

**The Critical Step**: Reorganize all code into QB64's three-phase structure.

```python
class CodeReorganizer:
    def reorganize(self, resolved_files):
        """
        Reorganize code into QB64's required structure:
        
        Phase 1: All CONST, TYPE, DIM declarations
        Phase 2: All SUB/FUNCTION definitions
        Phase 3: All executable statements
        """
        phase1 = []  # Declarations
        phase2 = []  # SUB/FUNCTION definitions
        phase3 = []  # Executable statements
        
        for file in resolved_files:
            # Phase 1: Declarations
            phase1.extend(file.constants)
            phase1.extend(file.types)
            phase1.extend(file.dims)
            phase1.extend(file.declares)
            
            # Phase 2: Definitions
            phase2.extend(file.subs)
            phase2.extend(file.functions)
            
            # Phase 3: Executable
            phase3.extend(file.executable)
        
        # Generate initialization SUB for Phase 3 code
        init_sub = self.generate_init_sub(phase3)
        phase2.append(init_sub)
        
        return ReorganizedCode(phase1, phase2, phase3)
    
    def generate_init_sub(self, executable_statements):
        """
        Generate initialization SUB from executable statements.
        """
        code = "SUB __AutoInitialize\n"
        code += "    ' Auto-generated initialization code\n"
        for stmt in executable_statements:
            code += f"    {stmt}\n"
        code += "END SUB\n"
        return code
```

**Key Features**:
- Collects all declarations first
- Collects all SUB/FUNCTION definitions second
- Moves all executable statements to initialization SUB
- Preserves original code structure in comments

### Phase 4: Test Discovery

**Pattern Matching**:

```python
class TestDiscovery:
    def discover_tests(self, reorganized_code):
        """
        Discover all test SUBs and test suite SUBs.
        
        Patterns:
        - SUB Test* → Individual test
        - SUB Run*Tests → Test suite runner
        """
        tests = []
        suites = []
        
        for sub in reorganized_code.subs:
            if sub.name.startswith('Test'):
                tests.append({
                    'name': sub.name,
                    'suite': self.extract_suite_name(sub),
                    'file': sub.source_file
                })
            elif sub.name.startswith('Run') and 'Test' in sub.name:
                suites.append({
                    'name': sub.name,
                    'file': sub.source_file
                })
        
        return {'tests': tests, 'suites': suites}
    
    def extract_suite_name(self, test_sub):
        """
        Extract suite name from test SUB.
        
        Example: TestCalculateCombatStrengthBaseSize
        -> Looks for StartTest "SuiteName", "test_name"
        """
        # Parse StartTest call in SUB body
        match = re.search(r'StartTest\s+"([^"]+)"', test_sub.body)
        if match:
            return match.group(1)
        return 'DefaultSuite'
```

### Phase 5: Test File Generation

**Generate Temporary Test File**:

```python
class TestFileGenerator:
    def generate(self, reorganized_code, tests, config):
        """
        Generate temporary test file with proper structure.
        """
        output = []
        
        # Header
        output.append("'============================================================================")
        output.append("' AUTO-GENERATED TEST FILE")
        output.append("'============================================================================")
        output.append("' Generated by QB64 Test Framework")
        output.append("' DO NOT EDIT - This file is auto-generated")
        output.append("")
        
        # Phase 1: All declarations
        output.append("'============================================================================")
        output.append("' PHASE 1: DECLARATIONS")
        output.append("'============================================================================")
        for decl in reorganized_code.phase1:
            output.append(self.format_declaration(decl))
        
        # Phase 2: All SUB/FUNCTION definitions
        output.append("")
        output.append("'============================================================================")
        output.append("' PHASE 2: SUB/FUNCTION DEFINITIONS")
        output.append("'============================================================================")
        for defn in reorganized_code.phase2:
            output.append(self.format_definition(defn))
        
        # Phase 3: Test runner
        output.append("")
        output.append("'============================================================================")
        output.append("' PHASE 3: TEST EXECUTION")
        output.append("'============================================================================")
        output.append(self.generate_test_runner(tests))
        
        # Entry point
        output.append("")
        output.append("'============================================================================")
        output.append("' ENTRY POINT")
        output.append("'============================================================================")
        output.append("DECLARE SUB RunAllTests ()")
        output.append("CALL __AutoInitialize")
        output.append("CALL RunAllTests")
        output.append("END")
        
        return '\n'.join(output)
    
    def generate_test_runner(self, tests):
        """
        Generate test runner SUB.
        """
        code = []
        code.append("SUB RunAllTests")
        code.append("    CALL InitializeTestFramework")
        code.append("    CALL __AutoInitialize")
        code.append("")
        code.append("    PRINT STRING$(80, \"=\")")
        code.append("    PRINT \"AUTO-GENERATED TEST RUNNER\"")
        code.append("    PRINT STRING$(80, \"=\")")
        code.append("    PRINT")
        code.append("")
        
        # Group tests by suite
        suites = {}
        for test in tests:
            suite = test['suite']
            if suite not in suites:
                suites[suite] = []
            suites[suite].append(test)
        
        # Generate suite runners
        for suite_name, suite_tests in suites.items():
            code.append(f"    ' Suite: {suite_name}")
            for test in suite_tests:
                code.append(f"    CALL {test['name']}")
            code.append("")
        
        code.append("    CALL PrintTestResults")
        code.append("END SUB")
        
        return '\n'.join(code)
```

### Phase 6: Compilation & Execution

**Compile and Run**:

```python
class TestExecutor:
    def compile_and_run(self, temp_file, config):
        """
        Compile temporary test file and execute it.
        """
        # Compile
        compile_cmd = [
            config['qb64_path'],
            '-x',  # Console output
            temp_file,
            '-o', config['temp_exe']
        ]
        
        result = subprocess.run(
            compile_cmd,
            capture_output=True,
            text=True,
            cwd=config['temp_dir']
        )
        
        if result.returncode != 0:
            return {
                'success': False,
                'error': 'compilation',
                'output': result.stderr
            }
        
        # Execute
        exec_result = subprocess.run(
            [config['temp_exe']],
            capture_output=True,
            text=True,
            timeout=config.get('timeout', 30)
        )
        
        return {
            'success': exec_result.returncode == 0,
            'output': exec_result.stdout,
            'error': exec_result.stderr
        }
```

### Phase 7: Result Reporting

**Parse and Report**:

```python
class ResultReporter:
    def parse_output(self, output):
        """
        Parse test framework output.
        
        Looks for patterns like:
        - [PASS] test_name
        - [FAIL] test_name
        - Assertion failures
        """
        results = {
            'passed': [],
            'failed': [],
            'errors': []
        }
        
        lines = output.split('\n')
        for line in lines:
            if '[PASS]' in line:
                test_name = self.extract_test_name(line)
                results['passed'].append(test_name)
            elif '[FAIL]' in line:
                test_name = self.extract_test_name(line)
                results['failed'].append(test_name)
            elif 'ERROR' in line or 'Error' in line:
                results['errors'].append(line)
        
        return results
    
    def generate_report(self, results, format='console'):
        """
        Generate test report in specified format.
        """
        if format == 'console':
            return self.console_report(results)
        elif format == 'json':
            return self.json_report(results)
        elif format == 'html':
            return self.html_report(results)
    
    def console_report(self, results):
        """
        Generate console-friendly report.
        """
        report = []
        report.append("=" * 80)
        report.append("TEST RESULTS")
        report.append("=" * 80)
        report.append("")
        report.append(f"Passed: {len(results['passed'])}")
        report.append(f"Failed: {len(results['failed'])}")
        report.append("")
        
        if results['failed']:
            report.append("FAILED TESTS:")
            for test in results['failed']:
                report.append(f"  - {test}")
        
        return '\n'.join(report)
```

## Implementation Details

### File Structure

```
qb64-test-framework/
├── framework/
│   ├── __init__.py
│   ├── parser.py          # QB64 syntax parser
│   ├── resolver.py        # Include resolver
│   ├── reorganizer.py     # Code reorganization
│   ├── discovery.py       # Test discovery
│   ├── generator.py       # Test file generation
│   ├── executor.py        # Compilation & execution
│   └── reporter.py        # Result reporting
├── cli/
│   └── main.py            # Command-line interface
├── config/
│   └── default.yaml       # Default configuration
├── tests/
│   └── test_framework.py  # Framework tests
└── README.md
```

### Configuration

```yaml
# config.yaml
qb64:
  path: "C:/code/hutsell/qb64pe/qb64pe.exe"
  flags: ["-x", "-w"]

project:
  root: "C:/code/hutsell/wars-of-napoleon"
  source_dirs:
    - "src/common"
    - "src/strategic"
    - "src/tactical"
    - "src/ui"
  test_dir: "src/test"
  test_pattern: "test_*.bas"

output:
  temp_dir: ".test_temp"
  reports_dir: "test_reports"
  formats: ["console", "json"]

discovery:
  test_patterns:
    - "^SUB Test"
    - "^SUB Run.*Tests"
  suite_extraction: "StartTest \"([^\"]+)\""
```

### Command-Line Interface

```bash
# Run all tests
python -m qb64_test_framework run

# Run specific test file
python -m qb64_test_framework run test_combat.bas

# Run tests matching pattern
python -m qb64_test_framework run --filter combat

# Generate test file without running
python -m qb64_test_framework generate

# List discovered tests
python -m qb64_test_framework discover

# Clean temp files
python -m qb64_test_framework clean
```

## Advantages

### 1. Solves All QB64 Limitations

- ✅ **Code Organization**: Automatically reorganizes code into correct phases
- ✅ **Include Order**: Resolves and flattens all includes
- ✅ **Test Discovery**: Automatically finds all tests
- ✅ **Test Isolation**: Can generate separate test files per suite
- ✅ **No Manual Registration**: Tests discovered automatically

### 2. Transparent to Developers

Developers write normal QB64 code:
```qb64
SUB TestCombatStrength
    StartTest "CombatTests", "test_combat_strength"
    ' Test code
    ExecuteTest "CombatTests", "test_combat_strength"
END SUB
```

Framework handles everything else automatically.

### 3. Flexible and Extensible

- Can add test filtering
- Can generate separate test executables
- Can add code coverage
- Can integrate with CI/CD
- Can generate multiple report formats

### 4. No Compiler Modifications

- Works with standard QB64-PE
- No fork to maintain
- No risk of breaking compiler
- Can be used by other projects

## Challenges and Solutions

### Challenge 1: QB64 Syntax Parsing

**Problem**: QB64 syntax is complex, with many edge cases.

**Solution**:
- Start with simple regex-based parsing
- Handle common cases first
- Add edge cases incrementally
- Use existing QB64 codebase as test cases

### Challenge 2: Preserving Line Numbers

**Problem**: Reorganizing code changes line numbers, making debugging harder.

**Solution**:
- Add `#line` directives (if QB64 supports) or comments
- Preserve original file/line info in comments
- Generate source maps for debugging

### Challenge 3: Complex Type Handling

**Problem**: Some types may have complex initialization.

**Solution**:
- Detect initialization patterns
- Generate appropriate initialization code
- Allow manual initialization overrides

### Challenge 4: Performance

**Problem**: Parsing and reorganizing large codebases may be slow.

**Solution**:
- Cache parsed results
- Incremental parsing (only changed files)
- Parallel processing where possible

## Implementation Roadmap

### Phase 1: Core Parser (Weeks 1-2)

**Goal**: Parse basic QB64 syntax

**Deliverables**:
- CONST, TYPE, DIM parsing
- SUB/FUNCTION parsing
- Basic include resolution
- Simple code reorganization

### Phase 2: Test Discovery (Week 3)

**Goal**: Automatically discover tests

**Deliverables**:
- Test pattern matching
- Suite extraction
- Test metadata collection

### Phase 3: File Generation (Week 4)

**Goal**: Generate properly-organized test files

**Deliverables**:
- Three-phase code organization
- Test runner generation
- Initialization SUB generation

### Phase 4: Execution (Week 5)

**Goal**: Compile and run generated tests

**Deliverables**:
- QB64 compilation integration
- Test execution
- Output capture

### Phase 5: Reporting (Week 6)

**Goal**: Parse and report test results

**Deliverables**:
- Output parsing
- Console reporting
- JSON reporting
- Basic statistics

### Phase 6: Polish (Weeks 7-8)

**Goal**: Improve usability and robustness

**Deliverables**:
- Error handling
- Better error messages
- Configuration system
- Documentation
- Edge case handling

## Estimated Effort

**Total**: 6-8 weeks for full implementation

**Breakdown**:
- Core parser: 2 weeks
- Test discovery: 1 week
- File generation: 1 week
- Execution: 1 week
- Reporting: 1 week
- Polish: 1-2 weeks

## Comparison with Other Approaches

| Approach | Effort | Risk | Maintainability | Solves Problems |
|----------|--------|------|-----------------|----------------|
| **Parsing Framework** | 6-8 weeks | Low | High | All |
| External Preprocessor | 12-16 weeks | Medium | Medium | Most |
| Compiler Modifications | 20+ weeks | Very High | Low | All |
| Manual (Current) | 0 weeks | None | High | None |

## Conclusion

A parsing-based testing framework provides the best balance of:
- **Effectiveness**: Solves all QB64 limitations
- **Risk**: Low (no compiler changes)
- **Effort**: Reasonable (6-8 weeks)
- **Maintainability**: High (standard Python tooling)
- **Usability**: Excellent (transparent to developers)

This approach is **recommended** as the best solution for modern testing in QB64.

---

## Related Documentation

- [QB64 Unit Testing Limitations](./QB64_UNIT_TESTING_LIMITATIONS.md) - Current limitations
- [QB64 Testing Solutions Analysis](./QB64_TESTING_SOLUTIONS_ANALYSIS.md) - Alternative approaches
- [Testing Framework](../TESTING_FRAMEWORK.md) - Current testing framework

