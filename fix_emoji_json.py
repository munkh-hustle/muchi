import json
import re
import sys

def fix_mojibake_emoji(text):
    """Fix UTF-8 emojis that are displayed as Latin-1 mojibake."""
    if not isinstance(text, str):
        return text
    
    # Try to fix mojibake by encoding as latin-1 then decoding as utf-8
    try:
        # This handles cases like "ð¦­" -> "🦭"
        return text.encode('latin-1', errors='ignore').decode('utf-8', errors='ignore')
    except:
        return text

def decode_unicode_escape(text):
    """Decode \\uXXXX sequences directly."""
    if not isinstance(text, str) or '\\u' not in text:
        return text
    
    try:
        # Handle standard JSON unicode escape sequences like \u00e2
        return text.encode('utf-8').decode('unicode-escape')
    except:
        return text

def decode_double_encoded_string(text):
    """Handle various types of encoded emojis."""
    if not isinstance(text, str):
        return text
    
    original_text = text
    
    # Handle case 1: Already double-decoded mojibake like "ð¦­"
    if any(c in text for c in ['ð', '', '', '©', '·', 'â', '', '¤', 'ï', '¸', '']):
        result = fix_mojibake_emoji(text)
        if result != original_text:
            return result
    
    # Handle case 2: Standard JSON unicode escapes like \u00e2\u009d\u00a4
    if '\\u' in text:
        result = decode_unicode_escape(text)
        if result != original_text:
            # The result might still have mojibake, so fix that too
            return fix_mojibake_emoji(result)
    
    return text

def fix_json_data(data):
    """Recursively fix all strings in the JSON data."""
    if isinstance(data, dict):
        return {key: fix_json_data(value) for key, value in data.items()}
    elif isinstance(data, list):
        return [fix_json_data(item) for item in data]
    elif isinstance(data, str):
        return decode_double_encoded_string(data)
    else:
        return data

def main():
    if len(sys.argv) < 2:
        print("Usage: python fix_emoji_json.py <input_json_file> [output_json_file]")
        print("Example: python fix_emoji_json.py message_1.json message_1_fixed.json")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else "message_1_fixed.json"
    
    try:
        # Read the JSON file with explicit encoding handling
        with open(input_file, 'r', encoding='utf-8') as f:
            raw_content = f.read()
        
        # Try to parse the JSON
        try:
            data = json.loads(raw_content)
        except json.JSONDecodeError:
            # If UTF-8 fails, try latin-1
            with open(input_file, 'r', encoding='latin-1') as f:
                raw_content = f.read()
            data = json.loads(raw_content)
        
        print(f"Loaded JSON from {input_file}")
        
        # Count problematic strings before fixing
        problem_count = count_problem_strings(data)
        print(f"Found {problem_count} strings with potential emoji encoding issues")
        
        # Fix the data
        fixed_data = fix_json_data(data)
        
        # Write the fixed JSON
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(fixed_data, f, ensure_ascii=False, indent=2)
        
        print(f"Fixed JSON written to {output_file}")
        
        # Show some examples of fixes
        print("\nExample fixes:")
        find_and_print_examples(data, fixed_data)
        
    except FileNotFoundError:
        print(f"Error: File '{input_file}' not found.")
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON in '{input_file}': {e}")
        sys.exit(1)
    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

def count_problem_strings(data):
    """Count how many strings contain problematic patterns."""
    count = 0
    
    def count_recursive(item):
        nonlocal count
        if isinstance(item, dict):
            for value in item.values():
                count_recursive(value)
        elif isinstance(item, list):
            for subitem in item:
                count_recursive(subitem)
        elif isinstance(item, str):
            # Check for problematic patterns
            if ('\\u' in item or 
                any(c in item for c in ['ð', '', '', '©', '·', 'â', '', '¤', 'ï', '¸', ''])):
                count += 1
    
    count_recursive(data)
    return count

def find_and_print_examples(original, fixed, max_examples=10):
    """Find and print examples of fixed emojis."""
    examples = []
    
    def find_examples(orig, fix, path=""):
        if isinstance(orig, dict) and isinstance(fix, dict):
            for key in orig:
                if key in fix:  # Only compare if key exists in both
                    new_path = f"{path}.{key}" if path else key
                    find_examples(orig[key], fix[key], new_path)
        elif isinstance(orig, list) and isinstance(fix, list):
            # Only compare up to the minimum length
            min_len = min(len(orig), len(fix))
            for i in range(min_len):
                new_path = f"{path}[{i}]"
                find_examples(orig[i], fix[i], new_path)
        elif isinstance(orig, str) and isinstance(fix, str):
            if orig != fix:
                examples.append((path, orig, fix))
    
    try:
        find_examples(original, fixed)
    except Exception as e:
        print(f"  Note: Could not compare all examples: {e}")
    
    if examples:
        print(f"Found {len(examples)} strings that were fixed")
        for i, (path, orig, fix) in enumerate(examples[:max_examples]):
            print(f"\n  Example {i+1} ({path}):")
            print(f"    Original: {repr(orig[:100])}{'...' if len(orig) > 100 else ''}")
            print(f"    Fixed:    {repr(fix[:100])}{'...' if len(fix) > 100 else ''}")
        
        if len(examples) > max_examples:
            print(f"\n  ... and {len(examples) - max_examples} more fixes")
    else:
        print("  No encoding issues found to fix.")

def test_decoding():
    """Test the decoding function with known examples."""
    test_cases = [
        # Your specific example
        (r"\u00e2\u009d\u00a4\u00ef\u00b8\u008f\u00e2\u009d\u00a4\u00ef\u00b8\u008f\u00e2\u009d\u00a4\u00ef\u00b8\u008f", "❤️❤️❤️"),
        
        # Other common cases
        (r"\u00f0\u009f\u00a6\u00ad", "🦭"),
        (r"\u00f0\u009f\u0098\u0082", "😂"),
        
        # Mojibake patterns
        ("ð\x9f¦\xad", "🦭"),
        ("ð\x9f\x98\x82", "😂"),
        
        # Mixed text
        ("Hello \u00e2\u009d\u00a4\u00ef\u00b8\u008f World", "Hello ❤️ World"),
        ("Babeð\x9f©· heleldee?", "Babe🧛 heleldee?"),
        
        # No changes
        ("Hello World", "Hello World"),
    ]
    
    print("Test cases:")
    passed = 0
    for input_str, expected in test_cases:
        result = decode_double_encoded_string(input_str)
        status = "✓" if result == expected else "✗"
        if status == "✓":
            passed += 1
        print(f"  {status} Input: {repr(input_str)}")
        print(f"      -> {repr(result)} (expected: {repr(expected)})")
    
    print(f"\n  Passed: {passed}/{len(test_cases)}")

if __name__ == "__main__":
    # Run a test first
    print("Testing emoji decoding...")
    test_decoding()
    print("\n" + "="*50 + "\n")
    
    # Run the main conversion
    main()