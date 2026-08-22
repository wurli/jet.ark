"""Generate Lua bindings for the Positron comm JSON-RPC specs.

For each `<comm>-backend-openrpc.json` and `<comm>-frontend-openrpc.json` in
`resources/positron-comms/`, writes a corresponding Lua file at
`lua/jet/ark/comm/<comm>-backend.lua` / `<comm>-frontend.lua`. Each generated
file exports one function per RPC method that wraps the params in the standard
JSON-RPC envelope via `jet.ark.comm.util.rpc_message`.

EmmyLua classes are emitted for any named object schema (either at the method
level as `<method>.Params` / `<method>.Reply` or as a shared class pulled from
`components.schemas`). Cross-file `$ref`s (e.g. `plot-backend-openrpc.json#/...`)
resolve to the class name in the referenced file.
"""

from __future__ import annotations

import json
import os
import re
from typing import Any

SPECS_DIR = "resources/positron-comms"
OUT_DIR = "lua/jet/ark/comm"

# Filename patterns we handle
OPENRPC_SUFFIX = "-openrpc.json"


def comm_and_side(filename: str) -> tuple[str, str] | None:
    """('ui-backend-openrpc.json',) -> ('ui', 'backend')."""
    if not filename.endswith(OPENRPC_SUFFIX):
        return None
    base = filename[: -len(OPENRPC_SUFFIX)]
    for side in ("backend", "frontend"):
        suffix = f"-{side}"
        if base.endswith(suffix):
            return base[: -len(suffix)], side
    return None


def lua_class_prefix(comm: str, side: str) -> str:
    """Prefix used for EmmyLua class names in a given spec file."""
    return f"jet.ark.comm.{comm}_{side}"


# --- schema -> emmylua type ------------------------------------------------


def snake(name: str) -> str:
    # Convert e.g. 'someName' or 'Some-Name' to 'some_name'. Specs already use
    # snake_case for the most part but we normalize just in case.
    s = re.sub(r"[-\s]+", "_", name)
    s = re.sub(r"(?<!^)(?=[A-Z])", "_", s).lower()
    return s


class Emitter:
    """Collects EmmyLua classes and method definitions for one spec file."""

    def __init__(self, comm: str, side: str, spec: dict[str, Any]):
        self.comm = comm
        self.side = side
        self.spec = spec
        self.prefix = lua_class_prefix(comm, side)
        # Classes to emit at file top: list of (name, lines-including-blank-line)
        self.classes: list[str] = []
        self.emitted_class_names: set[str] = set()

    # -- $ref resolution --

    def resolve_ref(self, ref: str) -> str:
        """Turn a JSON `$ref` into an EmmyLua class name."""
        # Two shapes:
        #   "#/components/schemas/plot_size"
        #   "plot-backend-openrpc.json#/components/schemas/plot_size"
        if "#" not in ref:
            raise ValueError(f"unexpected $ref shape: {ref}")
        file_part, frag = ref.split("#", 1)
        parts = frag.strip("/").split("/")
        # ['components', 'schemas', '<name>']
        schema_name = parts[-1]
        if file_part == "":
            # Same-file ref. Some frontend specs reference schemas actually
            # declared in the sibling backend spec; fall back to it when the
            # schema isn't present here.
            schemas = (self.spec.get("components") or {}).get("schemas") or {}
            if schema_name in schemas:
                return f"{self.prefix}.{schema_name}"
            sibling_side = "backend" if self.side == "frontend" else "frontend"
            return f"{lua_class_prefix(self.comm, sibling_side)}.{schema_name}"
        # Cross-file reference
        parsed = comm_and_side(file_part)
        if parsed is None:
            raise ValueError(f"can't parse cross-file $ref: {ref}")
        other_comm, other_side = parsed
        return f"{lua_class_prefix(other_comm, other_side)}.{schema_name}"

    # -- type mapping --

    def type_of(self, schema: dict[str, Any], class_hint: str | None = None) -> str:
        """Return an EmmyLua type string for a JSON schema.

        `class_hint` names an anonymous inline object if we need to synthesise a
        class for it.
        """
        if schema is None:
            return "any"
        if "$ref" in schema:
            return self.resolve_ref(schema["$ref"])

        t = schema.get("type")
        name = schema.get("name")

        # Union: emit as `A|B|C`. If members are named objects with $refs use
        # those class names; inline members get synthesised classes. A named
        # union is registered as a `@alias`.
        if "oneOf" in schema:
            parts: list[str] = []
            for i, member in enumerate(schema["oneOf"]):
                member_name = member.get("name") or f"variant_{i}"
                hint = f"{class_hint}.{member_name}" if class_hint else member_name
                parts.append(self.type_of(member, hint))
            union = "|".join(parts)
            if name:
                class_name = f"{self.prefix}.{name}"
                self.ensure_alias(class_name, union, schema.get("description"))
                return class_name
            return union

        # Named schema: register as a class alias. Any named object anywhere in
        # the tree gets pulled up as its own class — unless it has no
        # properties, in which case we inline it as `{}` (or `table` if it's
        # explicitly open-ended).
        if name and t == "object":
            if not (schema.get("properties") or {}):
                # `additionalProperties: true` with no declared fields is the
                # OpenAPI idiom for "arbitrary JSON value" (used e.g. for
                # positional RPC args), not "table with extra fields". Mapping
                # it to `any` lets callers pass primitives too.
                return "any" if schema.get("additionalProperties") else "{}"
            class_name = f"{self.prefix}.{name}"
            self.ensure_object_class(class_name, schema)
            return class_name
        if name and "enum" in schema:
            class_name = f"{self.prefix}.{name}"
            self.ensure_enum_class(class_name, schema)
            return class_name

        if t == "string":
            if "enum" in schema:
                # Inline enum -> literal union
                return "|".join(f'"{v}"' for v in schema["enum"])
            return "string"
        if t == "integer":
            return "integer"
        if t == "number":
            return "number"
        if t == "boolean":
            return "boolean"
        if t == "null":
            return "nil"
        if t == "array":
            items = schema.get("items", {})
            item_type = self.type_of(items, class_hint)
            # Wrap unions so `A|B[]` parses as `(A|B)[]`
            if "|" in item_type:
                item_type = f"({item_type})"
            return f"{item_type}[]"
        if t == "object":
            if not (schema.get("properties") or {}):
                # `additionalProperties: true` with no declared fields is the
                # OpenAPI idiom for "arbitrary JSON value" (used e.g. for
                # positional RPC args), not "table with extra fields". Mapping
                # it to `any` lets callers pass primitives too.
                return "any" if schema.get("additionalProperties") else "{}"
            if class_hint:
                class_name = f"{self.prefix}.{class_hint}"
                self.ensure_object_class(class_name, schema)
                return class_name
            return "table"

        return "any"

    # -- class emission --

    def ensure_object_class(self, class_name: str, schema: dict[str, Any]) -> None:
        if class_name in self.emitted_class_names:
            return
        self.emitted_class_names.add(class_name)

        lines: list[str] = []
        description = schema.get("description")
        if description:
            for dl in description.strip().splitlines():
                lines.append(f"---{dl}")
        lines.append(f"---@class {class_name}")

        properties = schema.get("properties") or {}
        required = set(schema.get("required") or [])
        for pname, pschema in properties.items():
            # Anonymous nested objects get a synthesised class:
            # `<parent>.<field>`
            hint = (
                f"{class_name.split('.', 3)[-1]}.{pname}"
                if class_name.startswith(self.prefix + ".")
                else pname
            )
            ptype = self.type_of(pschema, hint)
            opt = "" if pname in required else "?"
            pdesc = pschema.get("description", "")
            pdesc_line = f" {pdesc}" if pdesc else ""
            lines.append(f"---@field {pname}{opt} {ptype}{pdesc_line}")

        self.classes.append("\n".join(lines))

    def ensure_enum_class(self, class_name: str, schema: dict[str, Any]) -> None:
        values = schema.get("enum", [])
        union = "|".join(f'"{v}"' for v in values)
        self.ensure_alias(class_name, union, schema.get("description"))

    def ensure_alias(
        self, class_name: str, target: str, description: str | None
    ) -> None:
        if class_name in self.emitted_class_names:
            return
        self.emitted_class_names.add(class_name)
        lines: list[str] = []
        if description:
            for dl in description.strip().splitlines():
                lines.append(f"---{dl}")
        lines.append(f"---@alias {class_name} {target}")
        self.classes.append("\n".join(lines))

    # -- method emission --

    def emit_method(self, method: dict[str, Any]) -> str:
        name = method["name"]
        params = method.get("params") or []
        summary = method.get("summary")
        description = method.get("description")

        lines: list[str] = []

        # Synthesise a Params class from the (positional-in-schema) param list.
        # If there are no params, skip the class and annotate the function with
        # `@param params {}` inline.
        params_class: str | None
        params_block: str
        if params:
            params_class = f"{self.prefix}.{name}.Params"
            params_lines = [f"---@class {params_class}"]
            for p in params:
                pname = p["name"]
                pschema = p.get("schema") or {}
                hint = f"{name}.Params.{pname}"
                ptype = self.type_of(pschema, hint)
                # OpenRPC spec: `required` defaults to false when omitted, but
                # every Positron param without an explicit `required: false` is
                # treated as required in practice. Follow that convention.
                required = p.get("required", True)
                opt = "" if required else "?"
                pdesc = p.get("description", "")
                pdesc_line = f" {pdesc}" if pdesc else ""
                params_lines.append(f"---@field {pname}{opt} {ptype}{pdesc_line}")
            params_block = "\n".join(params_lines)
        else:
            params_class = None
            params_block = ""

        # Doc comment block above the function
        if summary:
            for dl in summary.strip().splitlines():
                lines.append(f"---{dl}")
        if description and description.strip() != (summary or "").strip():
            if summary:
                lines.append("---")
            for dl in description.strip().splitlines():
                lines.append(f"---{dl}")

        # Reply type (registered so callers can annotate their handlers).
        # We always want the callback param typed as `<method>.Reply` for
        # consistency; if the underlying schema is a named object or a `$ref`
        # we emit `<method>.Reply` as an alias to that type so both names
        # resolve.
        result = method.get("result")
        result_type: str | None = None
        if result is not None:
            rschema = result.get("schema") or {}
            underlying = self.type_of(rschema)
            result_class = f"{self.prefix}.{name}.Reply"
            if underlying != result_class:
                self.ensure_alias(result_class, underlying, None)
            result_type = result_class

        lines.append("---@param kernel jet.Kernel")
        lines.append("---@param comm_id string")
        # When the method takes no params we drop the `params` arg from the
        # wrapper signature and pass `vim.empty_dict()` internally, so the
        # payload is serialised as an empty JSON object rather than an array.
        if params_class:
            lines.append(f"---@param params {params_class}")
            params_arg = "params"
            params_sig = "kernel, comm_id, params"
        else:
            params_arg = "nil"
            params_sig = "kernel, comm_id"

        if result_type is not None:
            reply_method = "".join(w.capitalize() for w in name.split("_")) + "Reply"
            lines.append(f"---@param callback? fun(res: {result_type}): boolean")
            lines.append(f"M.{name} = function({params_sig}, callback)")
            lines.append(
                f'\treturn util.rpc_request(kernel, comm_id, "{name}", {params_arg}, "{reply_method}", callback)'
            )
        else:
            lines.append(f"M.{name} = function({params_sig})")
            lines.append(
                f'\treturn util.rpc_request(kernel, comm_id, "{name}", {params_arg})'
            )
        lines.append("end")

        func_block = "\n".join(lines)
        if params_block:
            return f"{params_block}\n\n{func_block}"
        return func_block

    # -- top-level --

    def emit_file(self) -> str:
        # Pre-register component schemas so any that are only referenced via a
        # cross-file $ref (from *another* spec) still get emitted here.
        schemas = (self.spec.get("components") or {}).get("schemas") or {}
        for sname, sschema in schemas.items():
            # `type_of` will register the class as a side-effect.
            annotated = dict(sschema)
            annotated.setdefault("name", sname)
            self.type_of(annotated)

        methods = self.spec.get("methods") or []
        method_blocks = [self.emit_method(m) for m in methods]

        parts: list[str] = []
        parts.append(
            "-------------------------------------------------------------------------------"
        )
        parts.append("-- This file is auto-generated - do not edit by hand")
        parts.append("--")
        parts.append("--   Generator: scripts/gen_comm_lua.py")
        parts.append(
            f"--   Source:    resources/positron-comms/{self.comm}-{self.side}-openrpc.json"
        )
        parts.append(
            "-------------------------------------------------------------------------------"
        )
        parts.append("")
        parts.append('local util = require("jet.ark.comm.util")')
        parts.append("")
        parts.append("local M = {}")
        if self.classes:
            parts.append("")
            parts.append("\n\n".join(self.classes))
        if method_blocks:
            parts.append("")
            parts.append("\n\n".join(method_blocks))
        parts.append("")
        parts.append("return M")
        parts.append("")
        return "\n".join(parts)


def main() -> None:
    os.makedirs(OUT_DIR, exist_ok=True)
    for filename in sorted(os.listdir(SPECS_DIR)):
        parsed = comm_and_side(filename)
        if parsed is None:
            continue
        comm, side = parsed
        with open(os.path.join(SPECS_DIR, filename)) as f:
            spec = json.load(f)
        emitter = Emitter(comm, side, spec)
        out = emitter.emit_file()
        out_path = os.path.join(OUT_DIR, f"{comm}-{side}.lua")
        with open(out_path, "w") as f:
            f.write(out)
        print(f"Wrote {out_path}")


if __name__ == "__main__":
    main()
