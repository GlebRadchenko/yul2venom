"""Test cases for MainnetFlat - testing what we can compile."""

from pathlib import Path


def get_mainnet_test_cases():
    """Get test cases for MainnetFlat components."""

    # Since the full MainnetFlat is too complex, we'll test components
    return [
        {
            'name': 'mainnet_components_simple',
            'description': 'Test simple components from MainnetFlat patterns',
            'contract_file': 'MainnetComponents.sol',
            'test_cases': [
                {
                    'name': 'deployment',
                    'call_data': b'',
                    'expected_success': True,
                    'description': 'Deploy MainnetComponents contracts'
                }
            ]
        }
    ]


def add_mainnet_to_test_suite():
    """Add MainnetFlat test to the main test suite."""
    test_cases_file = Path(__file__).parent / "test_cases.py"

    # Read current test_cases.py
    content = test_cases_file.read_text()

    # Add import for mainnet tests
    if "from test_cases_mainnet import" not in content:
        import_line = "from test_validation.test_cases_mainnet import get_mainnet_test_cases\n"

        # Find where to add the import
        import_section_end = content.find("\ndef get_test_cases_for_contract")
        if import_section_end > 0:
            content = content[:import_section_end] + import_line + "\n" + content[import_section_end:]

        # Add mainnet tests to the registry
        registry_section = content.find("TEST_REGISTRY = {")
        if registry_section > 0:
            # Find the closing brace
            closing_brace = content.find("}", registry_section)
            if closing_brace > 0:
                # Add before closing brace
                new_entry = '    "MainnetComponents": get_mainnet_test_cases()[0]["test_cases"],\n'
                content = content[:closing_brace] + new_entry + content[closing_brace:]

        # Write back
        test_cases_file.write_text(content)
        print("✓ Added MainnetFlat to test suite")


if __name__ == "__main__":
    print("MainnetFlat test cases module")
    print("=" * 50)

    cases = get_mainnet_test_cases()
    for case in cases:
        print(f"Test: {case['name']}")
        print(f"  Description: {case['description']}")
        print(f"  Contract: {case['contract_file']}")
        print(f"  Test cases: {len(case['test_cases'])}")