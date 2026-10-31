# Service catalog verification

The request method, path, and bearer authentication come from the Service
section of `kanoct15.postman_collection.json`. The library record uses the
user-supplied response fields. Both a bare array and a `data` envelope are
covered because the example supplied a record rather than a complete response.
This is a local fixture, not live-server validation. No shared workspace mock
was searched; the supplied local collection is the contract for this task.

Start the mock:

```sh
postman simulation run postman/simulations/services.sim.yaml --port 4909 --output ndjson
```

Run the client and UI tests:

```sh
/home/kirancchand/Desktop/install/flutter/flutter_linux_3.29/flutter/bin/flutter test test/service_api_simulation_test.dart test/service_catalog_test.dart --dart-define=service_simulation_url=http://127.0.0.1:4909/kan
```

The HTTP test checks GET routing through the configured base URL, bearer-token
refresh after 401, response envelopes, empty results, and a 503 response.
The widget test checks retry and API-driven metadata, with no enum catalog
fallback. `ServiceType` remains an internal identifier for existing modules
and local marketplace/cart data; `ServiceDefinition` drives the visible catalog.
Unknown shortforms display an availability message instead of opening the wrong
screen. Icon strings are matched against known AppIcons constants, never executed.
