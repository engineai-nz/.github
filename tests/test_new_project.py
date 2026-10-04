import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


SCRIPT = Path(__file__).resolve().parents[1] / 'scripts/new-project.sh'
SHA = 'a' * 40
CONTEXTS = ['Project package exists', 'ci / Install, lint, test, typecheck']
MOCK = r'''#!/usr/bin/env python3
import json, os, sys
from pathlib import Path
args = sys.argv[1:]
state_path = Path(os.environ['MOCK_STATE'])
state = json.loads(state_path.read_text())
state['calls'].append(args)
scenario = os.environ['MOCK_SCENARIO']
rc = 0
output = ''
if args[0] == 'api':
    route = next(a for a in args[1:] if a.startswith('repos/'))
    method = args[args.index('-X') + 1] if '-X' in args else 'GET'
    query = args[args.index('-q') + 1] if '-q' in args else None
    if method != 'GET':
        if scenario == 'write-error' and route.endswith('/rulesets') or scenario == 'property-error' and route.endswith('/properties/values'):
            rc = 1
        elif 'allow_auto_merge=true' in args:
            state['auto'] = True
            state['enabled'] = True
            if scenario == 'enable-error': rc = 1
        elif 'allow_auto_merge=false' in args:
            state['auto'] = False
        output = 'updated'
    elif route.endswith('/rulesets'):
        output = '' if query else '[]'
    elif '/rules/branches/' in route:
        rules = [{'type': 'pull_request'}, {'type': 'required_status_checks', 'ruleset_source_type': 'Organization', 'parameters': {'strict_required_status_checks_policy': True, 'required_status_checks': [{'context': c} for c in state['contexts']]}}]
        if scenario == 'no-pr': rules = rules[1:]
        if scenario == 'not-strict': rules[-1]['parameters']['strict_required_status_checks_policy'] = False
        if scenario == 'missing-required': rules[-1]['parameters']['required_status_checks'].pop()
        if scenario == 'protection-error': rc = 1
        output = '1' if query else json.dumps(rules)
    elif '/check-runs' in route:
        runs = [{'name': c, 'head_sha': state['sha'], 'status': 'completed', 'conclusion': 'success'} for c in state['contexts']]
        if scenario == 'empty': runs = []
        if scenario == 'missing-check': runs.pop()
        if scenario == 'failed': runs[-1]['conclusion'] = 'failure'
        if scenario == 'pending': runs[-1]['status'] = 'in_progress'
        if scenario == 'stale': runs[-1]['head_sha'] = 'b' * 40
        if scenario == 'ambiguous': runs.append(runs[-1].copy())
        total = len(runs) + (1 if scenario == 'partial' else 0)
        if scenario == 'invalid-count': total = str(total)
        if scenario == 'checks-error': rc = 1
        output = '\n'.join(r['name'] for r in runs) if query else json.dumps({'total_count': total, 'check_runs': runs})
        state['checked'] = True
    elif '/commits/' in route:
        sha = 'b' * 40 if scenario == 'head-race' and state.get('checked') or scenario == 'post-head-race' and state.get('enabled') else state['sha']
        output = json.dumps({'sha': sha})
    else:
        default = 'other' if scenario == 'branch-race' and state.get('checked') or scenario == 'post-branch-race' and state.get('enabled') else 'main'
        if query == '.default_branch': output = default
        elif query: output = f"auto_merge={state['auto']}"
        else: output = json.dumps({'default_branch': default, 'allow_auto_merge': state['auto']})
if scenario == 'label-error' and args[:2] == ['label', 'create']: rc = 1
state_path.write_text(json.dumps(state))
print(output)
sys.exit(rc)
'''


class BootstrapTest(unittest.TestCase):
    def run_script(self, scenario='healthy', flags=()):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            gh = root / 'gh'
            gh.write_text(MOCK)
            gh.chmod(0o755)
            state_path = root / 'state.json'
            state_path.write_text(json.dumps({'calls': [], 'auto': True, 'sha': SHA, 'contexts': CONTEXTS}))
            env = {**os.environ, 'PATH': f"{root}:{os.environ['PATH']}", 'MOCK_STATE': str(state_path), 'MOCK_SCENARIO': scenario}
            result = subprocess.run(['bash', str(SCRIPT), 'fixture', *flags], env=env, capture_output=True, text=True, timeout=15)
            return result, json.loads(state_path.read_text())

    def test_success_keeps_auto_merge_off_until_complete_proof(self):
        result, state = self.run_script()
        self.assertEqual(result.returncode, 0, result.stderr)
        calls = state['calls']
        enables = [i for i, call in enumerate(calls) if 'allow_auto_merge=true' in call]
        self.assertEqual(len(enables), 1)
        self.assertIn('allow_auto_merge=false', calls[next(i for i, call in enumerate(calls) if '-X' in call)])
        proof = [i for i, call in enumerate(calls) if any('/check-runs' in arg for arg in call)]
        self.assertTrue(proof and enables[0] > max(proof))
        self.assertTrue(state['auto'])

    def test_unverified_prerequisites_fail_closed(self):
        for scenario in ('empty', 'missing-check', 'failed', 'pending', 'stale', 'ambiguous', 'partial', 'no-pr', 'not-strict', 'missing-required', 'protection-error', 'checks-error', 'write-error', 'property-error', 'label-error', 'invalid-count', 'head-race', 'branch-race'):
            with self.subTest(scenario=scenario):
                result, state = self.run_script(scenario)
                self.assertNotEqual(result.returncode, 0)
                self.assertFalse(state['auto'])
                self.assertFalse(any('allow_auto_merge=true' in call for call in state['calls']))

    def test_uncertain_enable_and_post_enable_races_are_rolled_back(self):
        for scenario in ('enable-error', 'post-head-race', 'post-branch-race'):
            with self.subTest(scenario=scenario):
                result, state = self.run_script(scenario)
                self.assertNotEqual(result.returncode, 0)
                self.assertFalse(state['auto'])
                self.assertIn('allow_auto_merge=false', next(call for call in reversed(state['calls']) if '-X' in call))
                self.assertNotIn('done —', result.stdout)

    def test_no_ci_finishes_with_auto_merge_off(self):
        result, state = self.run_script(flags=('--no-ci',))
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(state['auto'])
        self.assertFalse(any('allow_auto_merge=true' in call for call in state['calls']))

    def test_dry_run_has_no_provider_mutations(self):
        result, state = self.run_script(flags=('--dry-run',))
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(any('-X' in call or call[:2] == ['label', 'create'] for call in state['calls']))


if __name__ == '__main__':
    unittest.main()
