"""Conservative reachability of an Internal statement checkpoint.

This graph says nothing about memory preservation or live script contents.
It includes EVERY type-compatible indirect target in the selected linkage.
External Clight calls are atomic and contain no Internal statement events.
"""
from collections import defaultdict, deque
from clight import walk


class CheckpointGraph:
    def __init__(self, engine, checkpoint):
        if engine.image is None:
            raise ValueError('Checkpoint analysis needs the complete selected linkage')
        self.engine, self.checkpoint = engine, checkpoint
        self.edges, self.sources, self.indirect = {}, {}, []
        self.seeds = set()
        self.compatible_cache = {}
        for name, symbol in engine.image.symbols.items():
            edges = set()
            if symbol.internal:
                fn = engine.function(symbol.unit, symbol.body)
                self.sources[name] = fn.digest
                for path, node in walk(fn.body):
                    if node.tag != 'Scall':
                        continue
                    targets = self.targets(node, fn.unit)
                    edges.update(targets)
                    if node.args[1].tag != 'Evar':
                        self.indirect.append(dict(caller=name, path=list(path),
                                                  compatibleTargets=len(targets)))
                    if (name, checkpoint[1]) == checkpoint and checkpoint[1] in targets:
                        self.seeds.add(name)
            self.edges[name] = edges
        reverse = defaultdict(set)
        for caller, targets in self.edges.items():
            for target in targets:
                reverse[target].add(caller)
        self.reaches = set(self.seeds)
        queue = deque(self.seeds)
        while queue:
            for caller in reverse[queue.popleft()]:
                if caller not in self.reaches:
                    self.reaches.add(caller)
                    queue.append(caller)

    def targets(self, statement, unit):
        callee = statement.args[1]
        if callee.tag == 'Evar':
            name = callee.args[0].tag.removeprefix('_')
            if name not in self.engine.image.symbols:
                raise ValueError('Call absent from selected linkage: '+name)
            return (name,)
        ty = self.engine.typeof(callee)
        key = self.engine.image.signature_key(ty, unit)
        if key not in self.compatible_cache:
            self.compatible_cache[key] = tuple(
                s.name for s in self.engine.image.compatible(ty, unit))
        return self.compatible_cache[key]

    def may_cross(self, statement, scope):
        targets = self.targets(statement, scope.function.unit)
        return any(name in self.reaches for name in targets) or (
            scope.function.name == self.checkpoint[0] and self.checkpoint[1] in targets)

    def receipt(self):
        return dict(checkpoint=list(self.checkpoint), functions=len(self.edges),
                    internalBodies=len(self.sources), internalBodyHashes=self.sources,
                    checkpointOwners=sorted(self.seeds), mayReachCheckpoint=sorted(self.reaches),
                    indirectSites=self.indirect,
                    interpretation='Control reachability only; no memory frame or live-pointer invariant.')
