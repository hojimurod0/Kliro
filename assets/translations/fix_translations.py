import json
import os
import re

files = ["en.json", "ru.json", "uz.json", "uz-CYR.json"] # uz-CYR.json might have the same issue
# But checking regex "hotel" might trigger on descriptions?
# Keys are usually quoted: "hotel":

typo_fix_key = "coomon"
typo_fix_content = {
    "data": {
        "not": {
            "found": "Ma'lumot topilmadi" 
        }
    }
}
# Translations for typo fix
typo_fixes = {
    "uz.json": "Ma'lumot topilmadi",
    "uz-CYR.json": "Маълумот топилмади",
    "ru.json": "Данные не найдены",
    "en.json": "Data not found"
}

def deep_merge(dict1, dict2):
    """
    Merge dict2 into dict1.
    """
    for key, val in dict2.items():
        if key in dict1:
            if isinstance(dict1[key], dict) and isinstance(val, dict):
                deep_merge(dict1[key], val)
            else:
                dict1[key] = val
        else:
            dict1[key] = val
    return dict1

def fix_file(filename):
    print(f"Processing {filename}...")
    try:
        with open(filename, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        print(f"Error reading {filename}: {e}")
        return

    # Find all occurrences of "hotel": {
    # We use regex to be robust against whitespace
    # But we need to be careful not to match inside strings.
    # Assuming standard formatting where keys are at the start of lines or after commas.
    
    matches = list(re.finditer(r'"hotel"\s*:\s*{', content))
    
    if len(matches) < 2:
        print(f"  No duplicate 'hotel' keys found in {filename} (found {len(matches)}). Checking for missing typo key...")
        # Even if no duplicate, we might want to add the typo key.
        # But if valid json, we can just load and edit.
        pass
    
    if len(matches) >= 2:
        print(f"  Found {len(matches)} 'hotel' blocks. Merging...")
        
        # We need to extract the JSON objects. This is hard with regex because of nested braces.
        # Strategy: 
        # 1. Split the file string into parts.
        # 2. Extract valid JSON object starting at match index.
        # To extract valid JSON, we can count braces.
        
        blocks = []
        indices = [] # (start, end)
        
        for match in matches:
            start_idx = match.start()
            # Find matching closing brace
            brace_count = 0
            in_string = False
            escape = False
            end_idx = -1
            
            # Start scanning from the opening brace
            scan_start = content.find('{', start_idx)
            
            for i in range(scan_start, len(content)):
                char = content[i]
                if escape:
                    escape = False
                    continue
                if char == '\\':
                    escape = True
                    continue
                if char == '"':
                    in_string = not in_string
                    continue
                if not in_string:
                    if char == '{':
                        brace_count += 1
                    elif char == '}':
                        brace_count -= 1
                        if brace_count == 0:
                            end_idx = i + 1
                            break
            
            if end_idx != -1:
                block_str = content[start_idx:end_idx]
                # The block string needs to be valid JSON to parse, but it starts with "hotel": {.
                # We need to wrap it in {} to parse it as a dict {"hotel": ...}
                try:
                    # We only care about the value, but let's parse keys too.
                    # Actually, raw string is "hotel": {...}.
                    # Valid JSON requires { "hotel": ... }.
                    wrapped = "{" + block_str + "}"
                    data = json.loads(wrapped)
                    blocks.append(data['hotel'])
                    indices.append((start_idx, end_idx))
                except json.JSONDecodeError as e:
                    print(f"  Failed to parse block starting at {start_idx}: {e}")
            else:
                print(f"  Could not find closing brace for block at {start_idx}")

        if len(blocks) < 2:
            print("  Could not parse enough blocks to merge.")
            return

        # Merge blocks. content of blocks[1] into blocks[0]
        # We assume blocks are in order of appearance.
        # The file structure is likely:
        # { ... "hotel": { ... }, ... "hotel": { ... } ... }
        # We want to keep the FIRST "hotel": { ... } location, but update its content.
        # And REMOVE subsequent "hotel": { ... } blocks AND the preceding comma if present.
        
        merged_hotel = blocks[0]
        for i in range(1, len(blocks)):
            merged_hotel = deep_merge(merged_hotel, blocks[i])
            
        # Add the typo fix
        typo_translation = typo_fixes.get(filename, "Ma'lumot topilmadi")
        
        # Ensure regex structure for typo key
        # We add "coomon": ...
        # Also ensure "common": { "data_not_found": ... }
        
        if "common" not in merged_hotel:
            merged_hotel["common"] = {}
        if "data_not_found" not in merged_hotel["common"]:
             merged_hotel["common"]["data_not_found"] = typo_translation
             
        # Add coomon/typo key
        if typo_fix_key not in merged_hotel:
             merged_hotel[typo_fix_key] = {
                 "data": {
                     "not": {
                         "found": typo_translation
                     }
                 }
             }

        # Reconstruct file
        # We keep everything BEFORE the first hotel block.
        # We keep everything AFTER the last hotel block? No.
        # The first hotel block is at indices[0].
        # We replace it with new merged JSON.
        # We remove other blocks.
        
        # Careful with commas.
        # If we replace the first block, does it need a trailing comma?
        # Check original context.
        
        # Read char after first block
        first_end = indices[0][1]
        # Check if there was a comma after it originally
        # But wait, we are removing SUBSEQUENT blocks.
        # The subsequent blocks might have commas around them.
        
        # Safe strategy:
        # Load the FULL file as one JSON object allowing duplicates (custom loader).
        # Actually python `json.load` with `object_pairs_hook` allows handling duplicates.
        
        print("  Using json.load with object_pairs_hook strategy...")
        
        def merge_duplicates(ordered_pairs):
            d = {}
            for k, v in ordered_pairs:
                if k in d:
                    if isinstance(d[k], dict) and isinstance(v, dict):
                        deep_merge(d[k], v)
                    else:
                        d[k] = v # Overwrite non-dict values
                else:
                    d[k] = v
            return d
            
        try:
            with open(filename, 'r', encoding='utf-8') as f:
                full_json = json.load(f, object_pairs_hook=merge_duplicates)
                
            # Now we have a clean dict with merged content (because our hook merged them).
            # We just need to add the typo fix to 'hotel'.
            
            if 'hotel' in full_json:
                hotel = full_json['hotel']
                if "common" not in hotel:
                    hotel["common"] = {}
                if "data_not_found" not in hotel["common"]:
                     hotel["common"]["data_not_found"] = typo_translation
                     
                if typo_fix_key not in hotel:
                     hotel[typo_fix_key] = {
                         "data": {
                             "not": {
                                 "found": typo_translation
                             }
                         }
                     }
            
            # Write back
            with open(filename, 'w', encoding='utf-8') as f:
                json.dump(full_json, f, indent=2, ensure_ascii=False)
                
            print(f"  Successfully merged and saved {filename}")
                
        except Exception as e:
            print(f"  JSON strategy failed: {e}")
            
    else:
        # No duplicates, just load and check for typo key
        try:
            with open(filename, 'r', encoding='utf-8') as f:
                full_json = json.load(f)
            
            changed = False
            if 'hotel' in full_json:
                hotel = full_json['hotel']
                typo_translation = typo_fixes.get(filename, "Ma'lumot topilmadi")

                if "common" not in hotel:
                    hotel["common"] = {}
                    changed = True
                if "data_not_found" not in hotel["common"]:
                     hotel["common"]["data_not_found"] = typo_translation
                     changed = True
                     
                if typo_fix_key not in hotel:
                     hotel[typo_fix_key] = {
                         "data": {
                             "not": {
                                 "found": typo_translation
                             }
                         }
                     }
                     changed = True
            
            if changed:
                with open(filename, 'w', encoding='utf-8') as f:
                    json.dump(full_json, f, indent=2, ensure_ascii=False)
                print(f"  Added missing keys to {filename}")
            else:
                print(f"  No changes needed for {filename}")

        except Exception as e:
            print(f"  Processing failed: {e}")

if __name__ == "__main__":
    for f in files:
        if os.path.exists(f):
            fix_file(f)
        else:
            print(f"File not found: {f}")
