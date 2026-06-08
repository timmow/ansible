import sys, json, re, shlex

data = json.load(sys.stdin)
tool_input = data.get("tool_input", {})
command = tool_input.get("command", "")

if "\\ " not in command:
    sys.exit(0)

def fix_backslash_spaces(cmd):
    # Tokenize the command character-by-character to identify path segments
    # that use backslash-escaped spaces, and replace them with quoted paths.
    result = []
    i = 0
    while i < len(cmd):
        # If we're inside quotes, pass through unchanged
        if cmd[i] in ('"', "'"):
            quote = cmd[i]
            j = i + 1
            while j < len(cmd) and cmd[j] != quote:
                if cmd[j] == '\\' and j + 1 < len(cmd):
                    j += 1
                j += 1
            result.append(cmd[i:j + 1])
            i = j + 1
        # Check if we're at the start of a token that contains backslash-space
        elif cmd[i] not in (' ', '\t', '\n'):
            # Consume a full shell "word" (non-whitespace, treating \<space> as part of the word)
            j = i
            has_backslash_space = False
            while j < len(cmd):
                if cmd[j] == '\\' and j + 1 < len(cmd) and cmd[j + 1] == ' ':
                    has_backslash_space = True
                    j += 2  # skip backslash and space (they're part of this token)
                elif cmd[j] in (' ', '\t', '\n'):
                    break  # unescaped whitespace ends the token
                elif cmd[j] in ('"', "'"):
                    # Quoted segment within the token — skip it
                    quote = cmd[j]
                    j += 1
                    while j < len(cmd) and cmd[j] != quote:
                        if cmd[j] == '\\':
                            j += 1
                        j += 1
                    j += 1  # skip closing quote
                else:
                    j += 1

            token = cmd[i:j]
            if has_backslash_space:
                # Unescape and wrap in double quotes
                unescaped = token.replace("\\ ", " ")
                result.append(f'"{unescaped}"')
            else:
                result.append(token)
            i = j
        else:
            # Whitespace between tokens — pass through
            result.append(cmd[i])
            i += 1

    return ''.join(result)


fixed_command = fix_backslash_spaces(command)

output = {
    "hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "allow",
        "updatedInput": {
            "command": fixed_command
        },
        "additionalContext": "Auto-fixed backslash-escaped spaces to quoted paths."
    }
}

json.dump(output, sys.stdout)
sys.exit(0)
