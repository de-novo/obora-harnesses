# Obora File Generation Issue - 2026-03-31

## Problem
Models claim to create files but actual files are not generated.

## Evidence

### Workflow 1: todo-cli-minimal
```yaml
name: todo-cli-minimal
sandbox:
  enabled: true
  paths:
    - path: .
      mode: "rw"
```

**Result**:
- ✅ Workflow completed successfully
- ✅ Model claims: "Done. Created `package.json` and `src/index.js`..."
- ❌ No actual files created in target directory
- ✅ Run bundle created with model's claim

### Workflow 2: todo-cli-enhanced (slice-1)
**Result**:
- ❌ SDK_8002 Execution cancelled at evaluate_contract_slice1
- Multiple attempts, all failed at evaluation step

## Root Cause Analysis

### Hypothesis 1: Sandbox Configuration
- **Status**: Disproven
- **Evidence**: Added sandbox config but files still not created

### Hypothesis 2: Output Directory Configuration
- **Status**: Possible
- **Evidence**: Workflow runs but files go nowhere
- **Check**: Need to verify `--output-dir` behavior

### Hypothesis 3: Obora SDK File Writing Mechanism
- **Status**: Likely
- **Evidence**: 
  - Model says files are created
  - Run bundle captures model's claim
  - But actual filesystem unchanged
- **Implication**: Obora might not be passing file write operations through to actual filesystem

## Key Question
**Does Obora actually execute file write operations, or does it only simulate them?**

## Next Debug Steps
1. Check Obora SDK file writing documentation
2. Test with explicit file write commands in workflow
3. Compare with working examples in obora-kit
4. Check if there's a separate "materialize" step needed

## Related Issues
- This might explain why `materialize_todo_cli_artifacts.py` was needed
- Run bundle contains claims but not actual file contents
- Agent execution environment might be isolated from target directory

## Impact on Current Experiment
- **Todo CLI enhanced**: Previously worked because materialization script extracted from run bundle
- **Todo CLI minimal**: Fails because no materialization step exists
- **Conclusion**: Obora needs explicit materialization or different file writing approach

## Temporary Workaround
Current runner scripts use `materialize_todo_cli_artifacts.py` to extract artifacts from run bundle JSON. This suggests:
1. Run bundle contains step outputs (including file creation claims)
2. Materialization script parses these claims and creates actual files
3. This is a post-processing step, not part of core Obora flow

## Recommendation
Either:
1. Document this materialization requirement clearly
2. Or fix Obora to actually write files during workflow execution
3. Or provide built-in materialization command
