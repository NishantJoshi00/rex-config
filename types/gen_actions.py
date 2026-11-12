"""Render LuaLS annotations for Rex's built-in actions.

Usage: gen_actions.py CLIENT_INSPECT_JSON ACTIONS_JSON
  CLIENT_INSPECT_JSON  `rex api call client.inspect '{"client_id": "..."}'` (the app's actions)
  ACTIONS_JSON         `rex actions --json` (block actions; Lua actions are skipped)
"""
import json
import sys

LUA_TYPES = {"string": "string", "integer": "integer", "number": "number", "boolean": "boolean", "object": "table"}


def class_name(action: str) -> str:
    return "rex.args." + action.replace(".", "_")


def field_type(schema: dict) -> str:
    if "enum" in schema:
        return "|".join(json.dumps(v) for v in schema["enum"])
    kinds = schema.get("type", "any")
    kinds = [k for k in (kinds if isinstance(kinds, list) else [kinds]) if k != "null"]
    return "|".join(one_type(k, schema) for k in kinds) or "any"


def one_type(kind: str, schema: dict) -> str:
    if kind == "array":
        return field_type(schema.get("items", {})) + "[]"
    return LUA_TYPES.get(kind, "any")


def render_class(action: dict) -> list[str]:
    schema = action["args"]
    required = set(schema.get("required", []))
    lines = [f"---@class {class_name(action['name'])}"]
    for name, prop in schema.get("properties", {}).items():
        opt = "" if name in required else "?"
        desc = prop.get("description", "").replace("\n", " ")
        lines.append(f"---@field {name}{opt} {field_type(prop)} {desc}".rstrip())
    return lines + [""]


def args_param(action: dict) -> str:
    opt = "" if action["args"].get("required") else "?"
    return f"args{opt}: {class_name(action['name'])}"


def overloads(first: str, with_args: list[dict]) -> list[str]:
    return [f'---@overload fun({first}, action: "{a["name"]}", {args_param(a)})' for a in with_args]


def render_bind(with_args: list[dict]) -> list[str]:
    head = [
        "--- Binds a key to an action. Each built-in action is checked against its own arguments.",
        "---@param key rex.Key",
        "---@param action rex.ClientNoArgAction|rex.BlockNoArgAction|rex.LocalAction",
        "---@param args? table",
        "---@overload fun(key: rex.Key, fn: rex.KeyFn)",
    ]
    return head + overloads("key: rex.Key", with_args) + ["function rex.bind(key, action, args) end", ""]


def render_queue(with_args: list[dict]) -> list[str]:
    head = [
        "--- Asks the client that ran the current action to perform one of its own actions.",
        "---@param action rex.ClientNoArgAction",
    ]
    tail = ["function rex.client.queue(action) end"]
    return head + [o.replace("fun(, ", "fun(") for o in overloads("", with_args)] + tail


def render_alias(name: str, actions: list[dict]) -> list[str]:
    return [f"---@alias {name}"] + [f'---| "{a["name"]}" # {a["title"]}' for a in actions] + [""]


def render(client: list[dict], blocks: list[dict], version: str) -> str:
    def split(xs: list[dict]) -> tuple[list[dict], list[dict]]:
        return [a for a in xs if not a.get("args")], [a for a in xs if a.get("args")]

    client_plain, client_args = split(client)
    block_plain, block_args = split(blocks)
    out = [
        "---@meta rex.builtin_actions",
        f"-- Generated from the actions Rex {version} offers (`rex api call client.inspect`, `rex actions --json`).",
        "-- Regenerate with types/gen_actions.py after a Rex update adds or changes actions.",
        "",
    ]
    out += render_alias("rex.ClientNoArgAction", client_plain) + render_alias("rex.BlockNoArgAction", block_plain)
    for a in client_args + block_args:
        out += render_class(a)
    out += render_bind(client_args + block_args) + render_queue(client_args)
    return "\n".join(out) + "\n"


def main() -> None:
    client = json.load(open(sys.argv[1]))
    blocks = [a for a in json.load(open(sys.argv[2]))["actions"] if a.get("kind") == "block"]
    blocks = [{"title": a.get("description", ""), **a} for a in blocks]
    sys.stdout.write(render(client["actions"], blocks, client["client"]["info"]["version"]))


main()
