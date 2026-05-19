#!/usr/bin/env python3
"""
Generate a typed Dart API for the Sage Flutter binding from Sage's OpenAPI spec.

Input : an OpenAPI 3.1 JSON spec (produced by `sage rpc generate_openapi`).
Output:
  - lib/src/sage_api.g.dart  : Dart models (one class/enum per schema) + a
                               typed `SageApi` facade (one method per endpoint).
  - doc/API.md               : human docs, endpoints grouped by tag.

The Dart side mirrors the Rust side (which auto-tracks Sage via the
`impl_endpoints!` macro): regenerating keeps Dart in sync with vendored Sage.

Usage: python3 tool/gen_sage_api.py <openapi.json> <repo_root>
"""
import json
import re
import sys
from pathlib import Path

DART_KEYWORDS = {
    "abstract", "else", "import", "show", "as", "enum", "in", "static", "assert",
    "export", "interface", "super", "async", "extends", "is", "switch", "await",
    "extension", "late", "sync", "break", "external", "library", "this", "case",
    "factory", "mixin", "throw", "catch", "false", "new", "true", "class",
    "final", "null", "try", "const", "finally", "on", "typedef", "continue",
    "for", "operator", "var", "covariant", "Function", "part", "void", "default",
    "get", "part", "while", "deferred", "hide", "required", "with", "do", "if",
    "return", "yield", "dynamic", "implements", "set",
}

# Schemas modelled as a raw JSON map instead of a generated class.
# `Id`/`Action` are tagged unions used only by the advanced action-system /
# offer endpoints; raw maps keep scope sane while staying fully usable.
RAW_MAP_SCHEMAS = {"Id", "Action"}


def camel(s: str) -> str:
    parts = re.split(r"[_\-]", s)
    return parts[0] + "".join(p[:1].upper() + p[1:] for p in parts[1:])


def safe_ident(s: str) -> str:
    c = camel(s)
    if c in DART_KEYWORDS or not c or c[0].isdigit():
        c += "_"
    return c


def doc_comment(text, indent=""):
    if not text:
        return ""
    out = []
    for line in str(text).strip().splitlines():
        out.append(f"{indent}/// {line.rstrip()}")
    return "\n".join(out) + "\n"


class Gen:
    def __init__(self, spec):
        self.spec = spec
        self.schemas = spec["components"]["schemas"]
        self.enums = {}        # name -> [values]
        self.classes = {}      # name -> schema
        self.raw = set(RAW_MAP_SCHEMAS)
        self._classify()

    def _classify(self):
        for name, s in self.schemas.items():
            if name == "Amount":
                continue  # handled inline as BigInt
            if name in self.raw:
                continue
            if s.get("type") == "string" and "enum" in s:
                self.enums[name] = s["enum"]
            elif "oneOf" in s and not self._nullable_ref(s):
                self.raw.add(name)  # tagged union -> raw map
            else:
                self.classes[name] = s

    @staticmethod
    def _ref_name(node):
        r = node.get("$ref")
        return r.split("/")[-1] if r else None

    def _nullable_ref(self, node):
        """oneOf:[{type:null}, X] (any order) -> returns the X node, else None."""
        if "oneOf" not in node:
            return None
        variants = node["oneOf"]
        non_null = [v for v in variants if v.get("type") != "null"]
        has_null = any(v.get("type") == "null" for v in variants)
        if has_null and len(non_null) == 1:
            return non_null[0]
        return None

    def dart_type(self, node):
        """(dartType, isNullable, kind) for a schema node.

        kind in: prim | bigint | enum | class | list | raw
        """
        # $ref (possibly with sibling annotations)
        ref = self._ref_name(node)
        if ref:
            if ref == "Amount":
                return "BigInt", False, "bigint"
            if ref in self.enums:
                return ref, False, "enum"
            if ref in self.raw:
                return "Map<String, dynamic>", False, "raw"
            return ref, False, "class"

        if "oneOf" in node:
            inner = self._nullable_ref(node)
            if inner is not None:
                t, _, k = self.dart_type(inner)
                return t, True, k
            return "Map<String, dynamic>", False, "raw"

        t = node.get("type")
        if isinstance(t, list):  # e.g. ["string","null"]
            base = [x for x in t if x != "null"][0]
            nullable = "null" in t
            dt, _, k = self.dart_type({**node, "type": base})
            return dt, nullable, k
        if t == "array":
            it, inull, ik = self.dart_type(node.get("items", {}))
            cell = f"{it}?" if inull else it
            return f"List<{cell}>", False, "list"
        if t == "string":
            return "String", False, "prim"
        if t == "boolean":
            return "bool", False, "prim"
        if t == "integer":
            return "int", False, "prim"
        if t == "number":
            return "double", False, "prim"
        if t == "object" or t is None:
            return "Map<String, dynamic>", False, "raw"
        return "dynamic", False, "raw"

    def _unwrap(self, node):
        """Resolve nullable-oneOf wrappers to the inner node; return (node,kind,ref)."""
        if "oneOf" in node and self._nullable_ref(node) is not None:
            node = self._nullable_ref(node)
        _, _, kind = self.dart_type(node)
        return node, kind, self._ref_name(node)

    # ---- (de)serialization expression helpers -------------------------------
    # `nullable` is the *effective* nullability: schema-nullable OR an optional
    # (not-required) field. Both must be null-safe in (de)serialization.
    def from_json_expr(self, node, src, nullable):
        node, kind, ref = self._unwrap(node)

        if kind == "bigint":
            core = (
                f"(({src}) is String ? BigInt.parse({src} as String) "
                f": BigInt.from(({src} as num).toInt()))"
            )
        elif kind == "enum":
            core = f"{ref}.fromJson({src} as String)"
        elif kind == "class":
            core = f"{ref}.fromJson(({src} as Map).cast<String, dynamic>())"
        elif kind == "list":
            it = node.get("items", {})
            it2, ik, iref = self._unwrap(it)
            _, inull, _ = self.dart_type(it)
            if ik == "prim":
                dt, _, _ = self.dart_type(it2)
                core = f"(({src}) as List).cast<{dt}>()"
            else:
                elem = self.from_json_expr(it, "e", inull)
                core = f"(({src}) as List).map((e) => {elem}).toList()"
        elif kind == "raw":
            core = (
                f"({src} as Map).cast<String, dynamic>()"
                if (node.get("type") == "object" or ref in self.raw)
                else src
            )
        else:  # prim
            dt, _, _ = self.dart_type(node)
            if dt == "double":
                core = f"({src} as num).toDouble()"
            else:
                core = f"{src} as {dt}"

        if nullable:
            return f"{src} == null ? null : ({core})"
        return core

    def to_json_expr(self, node, src, nullable):
        node, kind, ref = self._unwrap(node)
        b = "!" if nullable else ""

        if kind == "bigint":
            expr = f"{src}{b}.toString()"
        elif kind == "enum":
            expr = f"{src}{b}.toJson()"
        elif kind == "class":
            expr = f"{src}{b}.toJson()"
        elif kind == "list":
            it = node.get("items", {})
            it2, ik, _ = self._unwrap(it)
            _, inull, _ = self.dart_type(it)
            if ik in ("prim", "raw"):
                return src if not nullable else src  # primitives are JSON-safe
            inner = self.to_json_expr(it, "e", inull)
            expr = f"{src}{b}.map((e) => {inner}).toList()"
        else:  # prim / raw
            return src

        # Optional fields are emitted inside `if (field != null)` by the
        # caller, so `!` is safe and no ternary is needed here.
        return expr

    # ---- code emit ----------------------------------------------------------
    def emit_enum(self, name):
        vals = self.enums[name]
        lines = [f"enum {name} {{"]
        for v in vals:
            lines.append(f"  {safe_ident(v)}('{v}'),")
        lines[-1] = lines[-1][:-1] + ";"
        lines += [
            "",
            "  const " + name + "(this.value);",
            "  final String value;",
            "",
            f"  factory {name}.fromJson(String v) =>",
            f"      {name}.values.firstWhere((e) => e.value == v);",
            "  String toJson() => value;",
            "}",
            "",
        ]
        return "\n".join(lines)

    def emit_class(self, name):
        s = self.classes[name]
        props = s.get("properties") or {}
        required = set(s.get("required") or [])
        fields = []
        for jkey, pnode in props.items():
            dt, nullable, kind = self.dart_type(pnode)
            opt = (jkey not in required) or nullable
            fields.append((jkey, safe_ident(jkey), dt, opt, kind, pnode))

        out = [doc_comment(s.get("description")) + f"class {name} {{"]
        # constructor
        if fields:
            out.append(f"  {name}({{")
            for jkey, ident, dt, opt, kind, pn in fields:
                out.append(
                    f"    {'this.' + ident if opt else 'required this.' + ident},"
                )
            out.append("  });")
        else:
            out.append(f"  const {name}();")
        out.append("")
        # fields
        for jkey, ident, dt, opt, kind, pn in fields:
            out.append(doc_comment(pn.get("description"), "  ").rstrip("\n"))
            out.append(f"  final {dt}{'?' if opt else ''} {ident};")
        out.append("")
        # fromJson
        out.append(
            f"  factory {name}.fromJson(Map<String, dynamic> json) => {name}("
        )
        for jkey, ident, dt, opt, kind, pn in fields:
            expr = self.from_json_expr(pn, f"json['{jkey}']", opt)
            out.append(f"        {ident}: {expr},")
        out.append("      );")
        out.append("")
        # toJson
        out.append("  Map<String, dynamic> toJson() => {")
        for jkey, ident, dt, opt, kind, pn in fields:
            val = self.to_json_expr(pn, ident, opt)
            if opt:
                out.append(f"        if ({ident} != null) '{jkey}': {val},")
            else:
                out.append(f"        '{jkey}': {val},")
        out.append("      };")
        out.append("}")
        out.append("")
        return "\n".join(out)

    def endpoints(self):
        eps = []
        for path, ops in self.spec["paths"].items():
            op = ops["post"]
            name = path.strip("/")
            req = self._ref_name(
                op["requestBody"]["content"]["application/json"]["schema"]
            )
            resp = self._ref_name(
                op["responses"]["200"]["content"]["application/json"]["schema"]
            )
            tag = (op.get("tags") or ["Other"])[0]
            desc = self.schemas.get(req, {}).get("description") or name
            eps.append((name, req, resp, tag, desc))
        return eps

    def emit_api(self):
        out = [
            "/// Typed facade over [SageClient]. One method per Sage endpoint,",
            "/// auto-generated from Sage's OpenAPI spec — see tool/gen_sage_api.py.",
            "class SageApi {",
            "  SageApi(this._client);",
            "  final SageClient _client;",
            "",
        ]
        for name, req, resp, tag, desc in self.endpoints():
            method = safe_ident(name)
            req_empty = not (self.schemas.get(req, {}).get("properties"))
            req_is_raw = req in self.raw
            # response decode
            if resp in self.classes:
                rtype = resp
                decode = f"{resp}.fromJson(json)"
            elif resp in self.enums:
                rtype = resp
                decode = f"{resp}.fromJson(json['result'] as String)"
            else:
                rtype = "Map<String, dynamic>"
                decode = "json"
            # request param
            if req_is_raw:
                param = "Map<String, dynamic> request"
                body = "request"
            elif req_empty:
                param = f"[{req} request = const {req}()]"
                body = "request.toJson()"
            else:
                param = f"{req} request"
                body = "request.toJson()"
            out.append(doc_comment(desc, "  ").rstrip("\n"))
            out.append(f"  Future<{rtype}> {method}({param}) async {{")
            out.append(
                f"    final json = await _client.callJson('{name}', {body});"
            )
            out.append(f"    return {decode};")
            out.append("  }")
            out.append("")
        out.append("}")
        out.append("")
        return "\n".join(out)

    def emit_dart(self):
        header = (
            "// GENERATED CODE - DO NOT MODIFY BY HAND.\n"
            "// Regenerate with: tool/generate_api.sh\n"
            "// Source: Sage OpenAPI spec (vendored Sage @ "
            f"{self.spec.get('info', {}).get('version', '?')}).\n"
            "// ignore_for_file: type=lint, unused_element, prefer_const_constructors\n\n"
            "import 'rust/api/sage_client.dart';\n"
            "import 'sage_client_ext.dart';\n\n"
        )
        body = []
        for n in sorted(self.enums):
            body.append(self.emit_enum(n))
        for n in sorted(self.classes):
            body.append(self.emit_class(n))
        body.append(self.emit_api())
        return header + "\n".join(body)

    def emit_docs(self):
        from collections import defaultdict
        by_tag = defaultdict(list)
        for name, req, resp, tag, desc in self.endpoints():
            by_tag[tag].append((name, req, resp, desc))
        out = [
            "# Sage Flutter API",
            "",
            "Typed Dart API generated from Sage's OpenAPI spec. Every method is",
            "available on `SageClient.api` (see `lib/src/sage_api.g.dart`).",
            "",
            "```dart",
            "await SageBinding.init();",
            "final sage = await SageClient.newInstance(dataDir: dir);",
            "final res = await sage.api.generateMnemonic("
            "GenerateMnemonic(use24Words: true));",
            "print(res.mnemonic);",
            "```",
            "",
            f"**{len(self.endpoints())} endpoints**, "
            f"{len(self.classes)} models, {len(self.enums)} enums.",
            "",
            "## Endpoints",
            "",
        ]
        for tag in sorted(by_tag):
            out.append(f"### {tag}\n")
            for name, req, resp, desc in sorted(by_tag[tag]):
                out.append(f"#### `{safe_ident(name)}`")
                out.append("")
                if desc:
                    out.append(desc)
                    out.append("")
                rs = self.schemas.get(req, {})
                props = rs.get("properties") or {}
                if props:
                    reqset = set(rs.get("required") or [])
                    out.append("| Field | Type | Required | Description |")
                    out.append("|---|---|---|---|")
                    for k, pn in props.items():
                        dt, nl, _ = self.dart_type(pn)
                        req_f = "yes" if (k in reqset and not nl) else "no"
                        d = (pn.get("description") or "").replace("\n", " ")
                        out.append(
                            f"| `{safe_ident(k)}` | `{dt}` | {req_f} | {d} |"
                        )
                else:
                    out.append("_No request fields._")
                out.append("")
                out.append(f"Returns `{resp}`.")
                out.append("")
        return "\n".join(out) + "\n"


def main():
    spec_path, root = sys.argv[1], Path(sys.argv[2])
    spec = json.load(open(spec_path))
    g = Gen(spec)
    (root / "lib" / "src" / "sage_api.g.dart").write_text(g.emit_dart())
    (root / "doc").mkdir(exist_ok=True)
    (root / "doc" / "API.md").write_text(g.emit_docs())
    print(
        f"generated: {len(g.classes)} classes, {len(g.enums)} enums, "
        f"{len(g.endpoints())} endpoints"
    )


if __name__ == "__main__":
    main()
