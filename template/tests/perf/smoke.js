// k6 tripwire against a booted app.
//   k6 run -e BASE_URL=http://127.0.0.1:8080 tests/perf/smoke.js            # smoke (default, about 70s)
//   k6 run -e BASE_URL=... -e PROFILE=stress tests/perf/smoke.js            # ramp to find the limit
// Read paths only. Point it only at an instance you own.
import http from 'k6/http';
import { check, group, sleep } from 'k6';

const BASE = __ENV.BASE_URL || 'http://127.0.0.1:8080';
const STRESS = __ENV.PROFILE === 'stress';

const ramp = (peak) => [
  { duration: '20s', target: peak }, { duration: '40s', target: peak }, { duration: '10s', target: 0 },
];

export const options = {
  scenarios: {
    visitors: { executor: 'ramping-vus', exec: 'visitor', startVUs: 0, stages: ramp(STRESS ? 100 : 20) },
  },
  thresholds: {
    http_req_failed: ['rate<0.01'],
    'http_req_duration{scenario:visitors}': ['p(95)<800'],
    checks: ['rate>0.99'],
  },
};

const ok = (res, name) => check(res, { [`${name} is 200`]: (r) => r.status === 200 });

export function visitor() {
  group('visitor browse', () => {
    for (const path of ['/']) {
      ok(http.get(`${BASE}${path}`, { tags: { name: path } }), path);
      sleep(1);
    }
  });
}
