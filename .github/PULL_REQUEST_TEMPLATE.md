---
name: Pull Request
about: Submit a pull request
---

## Description

<!-- Briefly describe what this PR does -->

## Type of Change

- [ ] Bug fix (non-breaking change that fixes an issue)
- [ ] New feature (non-breaking change that adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Transpiler fix (changes to venom_generator.py or related transpilation logic)
- [ ] Backend fix (changes to vyper/ fork - requires justification)
- [ ] Documentation update

## Testing

- [ ] Tests pass locally (`cd foundry && forge test`)
- [ ] Transpilation works (`python3.11 testing/test_framework.py --test-all`)
- [ ] New tests added (if applicable)

## Benchmark Impact

<!-- If this PR affects bytecode size or gas usage, describe the impact -->
<!-- The CI will automatically generate benchmark results -->

## Checklist

- [ ] My code follows the project's coding style
- [ ] I have performed a self-review
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] Any dependent changes have been merged and published

## Related Issues

<!-- Link any related issues: Fixes #123, Relates to #456 -->
